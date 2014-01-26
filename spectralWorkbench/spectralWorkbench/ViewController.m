//
//  ViewController.m
//  spectralWorkbench
//
//  Created by Diego on 1/14/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@implementation ViewController
@synthesize _webView;
//@synthesize _videoOut;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 100, 320, 480)];
    //_videoOut = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_webView setDelegate:self];
    
    NSString *urlAddress = @"http://spectralworkbench.org/capture/beta";

    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //[_webView loadRequest:requestObj];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"html"]isDirectory:NO]]];
    [self.view addSubview:_webView];
    // [self.view addSubview:_videoOut];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.vcPtr = self;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    WebViewJavascriptBridge* bridge = [WebViewJavascriptBridge bridgeForWebView:_webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"Received message from javascript: %@", data);
        responseCallback(@"Right back atcha");
    }];
    /*[self._webView stringByEvaluatingJavaScriptFromString:@"function loadjscssfile(filename, filetype){ if (filetype=='js'){var fileref=document.createElement('script');fileref.setAttribute('type','text/javascript');fileref.setAttribute('src', filename);}else if (filetype=='css'){ var fileref=document.createElement('link');fileref.setAttribute('rel', 'stylesheet');fileref.setAttribute('type', 'text/css');fileref.setAttribute('href', filename);}if (typeof fileref!='undefined') document.getElementsByTagName('head')[0].appendChild(fileref);}loadjscssfile('mods.js', 'js'); "];*/
    
    [self setupCaptureSession];
    NSLog(@"finish");
}

- (void)clearBuffer{
    free(rawData);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error for WEBVIEW: %@", [error description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
- (void)getRGBAsFromImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSString *jsStr;
    // NSMutableArray *result = [NSMutableArray arrayWithCapacity:height*width];
    NSMutableString *img = [NSMutableString string];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    if(_setupDone == false){
        jsStr = [NSString stringWithFormat:@"setup(%lu, %lu);",(unsigned long)height, (unsigned long)width];
        [self._webView stringByEvaluatingJavaScriptFromString:jsStr];
        _setupDone = true;
        NSLog(@"setup Done");
    }
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    //NSLog(@"%lu %lu", (unsigned long)height, (unsigned long)width);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    //int byteIndex = (4 * width * yy) + xx * 4;
    
    NSString *str = [[NSString alloc] initWithBytes:rawData length:height*width*4 encoding:NSASCIIStringEncoding];
    jsStr = [NSString stringWithFormat:@"readImgBuffer('%@', %lu);",str, str.length];
    [self._webView stringByEvaluatingJavaScriptFromString:jsStr];
    free(rawData);
    if(jsStr.length > 0)
        NSLog(@"buffer len: %lu", (unsigned long)jsStr.length);
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetLow;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        NSLog(@"video error");
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    // Configure your output.
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    //output.minFrameDuration = CMTimeMake(1, 15);
    
    // Start the session running to start the flow of data
    [session startRunning];
    
    // Assign session to an ivar.
    _session = session;
    //[self setSession:session];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageWithImage:[self imageFromSampleBuffer:sampleBuffer] convertToSize:CGSizeMake(200, 200)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getRGBAsFromImage:image];
        
        //CGImageRef imageRef = [image CGImage];
        //NSUInteger width = CGImageGetWidth(imageRef);
        //NSUInteger height = CGImageGetHeight(imageRef);
        //NSString *jsStr = [NSString stringWithFormat:@"setup(%lu, %lu);",(unsigned long)height, (unsigned long)width];
        //[self._webView stringByEvaluatingJavaScriptFromString:jsStr];
        //_videoOut.image = image;
    });
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}



@end
