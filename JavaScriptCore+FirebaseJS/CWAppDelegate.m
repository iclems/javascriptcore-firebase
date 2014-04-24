//
//  CWAppDelegate.m
//  JavaScriptCore+FirebaseJS
//
//  Created by Clément Wehrung on 24/04/2014.
//  Copyright (c) 2014 Clement Wehrung. All rights reserved.
//

#import "CWAppDelegate.h"
#import "Firebase+JS.h"

@implementation CWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Firebase addJavaScriptBridge];
    return YES;
}

@end
