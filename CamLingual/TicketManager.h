//
//  TicketManager.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface TicketManager : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate>

- (void)inAppPurchase:(NSObject*)target action:(SEL)selector;
@property NSInteger availableTickets;
@property NSInteger usedTickets;

@property(retain) NSObject *iap_target;
@property SEL iap_selector;

@end
