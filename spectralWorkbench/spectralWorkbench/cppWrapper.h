//
//  cppWrapper.h
//  spectralWorkbench
//
//  Created by Diego on 1/23/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#ifndef __spectralWorkbench__cppWrapper__
#define __spectralWorkbench__cppWrapper__



#import <Foundation/Foundation.h>

@interface cppWrapper : NSObject{
    void* imgStr;
}

-(void)setRed:(char)red setGreen:(char)green setBlue:(char)blue;
-(void)reset;
-(NSString*)getStr;

@end

#endif /* defined(__spectralWorkbench__cppWrapper__) */
