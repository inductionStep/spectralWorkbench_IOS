//
//  cppWrapper.cpp
//  spectralWorkbench
//
//  Created by Diego on 1/23/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#include "cppWrapper.h"
#include "image.h"
#include <string>
#include <sstream>
using namespace std;

@implementation cppWrapper

-(void)setRed:(char)red setGreen:(char)green setBlue:(char)blue {
    

    /*
    imgStr += to_string(red);
    imgStr += ",";
    imgStr += to_string(green);
    imgStr += ",";
    imgStr += to_string(blue);
    imgStr += ",";
     */
}

-(void)reset {
    myImage::instance()->clear();
    //imgStr.clear();
}

-(NSString*)getStr {
    NSString *result;// = [NSString stringWithCString:imgStr.c_str()
                  //                              encoding:[NSString defaultCStringEncoding]];
    return result;
}

@end