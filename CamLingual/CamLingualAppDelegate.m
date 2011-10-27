//
//  CamLingualAppDelegate.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamLingualAppDelegate.h"

#import "CamLingualViewController.h"

@implementation CamLingualAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *app_url = [NSURL URLWithString:@"itms://itunes.com/apps/camlingual"];
    [[UIApplication sharedApplication] openURL:app_url];        
}
- (void)expireCheck
{
    if(time(NULL) > 1322611200){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update to the latest version" message:@"This version no longer work because of Google Translate API interface changing. Please update to latest version." delegate:self cancelButtonTitle:NSLocalizedString(@"Update", nil) otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s", __FUNCTION__);
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    [self expireCheck];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
