//
//  CamLingualAppDelegate.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CamLingualViewController;

@interface CamLingualAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate>

- (void)expireCheck;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CamLingualViewController *viewController;

@end
