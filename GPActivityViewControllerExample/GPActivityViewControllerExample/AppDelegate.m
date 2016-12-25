//
//  AppDelegate.m
//  GPActivityViewControllerExample
//
//  Created by Gleb on 5/6/13.
//  Copyright (c) 2013 Gleb Pinigin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import <OdnoklassnikiMgr.h>
#import <VkontakteMgr.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - handle url scheme

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    if ([[OdnoklassnikiMgr sharedInstance] handleOpenURL:url]) {
        return YES;
    }

    if ([[VkontakteMgr sharedInstance] handleOpenURL:url]) {
        return YES;
    }


    return NO;
}


@end
