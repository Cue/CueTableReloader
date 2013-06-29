//
//  AppDelegate.m
//  CueTableReloaderDemo
//
//  Created by Aaron Sarazan on 6/29/13.
//  Copyright (c) 2013 Cue. All rights reserved.
//

#import "AppDelegate.h"
#import "TableDemoViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    TableDemoViewController *vc = [[TableDemoViewController alloc] init];
    self.window.rootViewController = vc;
    
    return YES;
}

@end
