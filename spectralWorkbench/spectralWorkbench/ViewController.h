//
//  ViewController.h
//  spectralWorkbench
//
//  Created by Diego on 1/14/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WebViewJavascriptBridge.h"
// #import "cppWrapper.h"

@interface ViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *_webView;
    AVCaptureSession *_session;
    unsigned char *rawData;
    bool _setupDone;
    //UIImageView *_videoOut;
}

@property (nonatomic, retain) UIWebView *_webView;
//@property (nonatomic, retain) UIImageView *_videoOut;

-(void)webViewDidStartLoad:(UIWebView *)webView;
-(void)webViewDidFinishLoad:(UIWebView *)webView;
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)setupCaptureSession;
- (void)getRGBAsFromImage:(UIImage*)image;
- (void)clearBuffer;

@end
