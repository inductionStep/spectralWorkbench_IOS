//
//  AppDelegate.h
//  spectralWorkbench
//
//  Created by Diego on 1/14/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
   ViewController *vcPtr;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet ViewController *vcPtr;


@end
