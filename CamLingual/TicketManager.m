//
//  TicketManager.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TicketManager.h"

#define AVAILABLE_TICKETS @"available_tickets"
#define USED_TICKETS @"used_tickets"

@implementation TicketManager

@synthesize iap_target = _iap_target;
@synthesize iap_selector = _iap_selector;

- (void)errorAlert:(NSError*)error
{
    NSLog(@"%s: localizedDescription:%@, userInfo:%@", __FUNCTION__, [error localizedDescription], [error userInfo]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (NSInteger)availableTickets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger available_tickets = 3;
    
    NSString * available_tickets_str = [defaults stringForKey:AVAILABLE_TICKETS];
    if(available_tickets_str){
        available_tickets = [available_tickets_str integerValue];
    }
    return available_tickets;
}
- (void)setAvailableTickets:(NSInteger)availableTickets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[[NSNumber numberWithInteger:availableTickets] description] forKey:AVAILABLE_TICKETS];
}
- (NSInteger)usedTickets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger used_tickets = 0;
    
    NSString *used_tickets_str = [defaults stringForKey:USED_TICKETS];
    if(used_tickets_str){
        used_tickets = [used_tickets_str integerValue];
    }
    return used_tickets;
}
- (void)setUsedTickets:(NSInteger)usedTickets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[[NSNumber numberWithInteger:usedTickets] description]  forKey:USED_TICKETS];
}
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if(response == NULL){
        NSLog(@"%s: Response is NULL", __FUNCTION__);
        return;
    }
    for(NSString *identifier in response.invalidProductIdentifiers){
        NSLog(@"Invalid product identifier: %@", identifier);
    }
    for(SKProduct *skProduct in response.products){
        NSLog(@"skProduct: %@", skProduct);
        SKPayment *payment = [SKPayment paymentWithProduct:skProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions){
        NSLog(@"%s: transaction = {.transactionDate = %@, .transactionIdentifier = %@, .transactionState = %d", __FUNCTION__, transaction.transactionDate, transaction.transactionIdentifier, transaction.transactionState);
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                self.availableTickets = self.availableTickets + 200;    
                [queue finishTransaction:transaction];
                [self.iap_target performSelector:self.iap_selector withObject:nil];
                fProcessing = NO;
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed");
                [queue finishTransaction:transaction];
                fProcessing = NO;
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                [queue finishTransaction:transaction];
                fProcessing = NO;
                break;
        }
    }
    
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s, error=%@", __FUNCTION__, error);
    [self errorAlert:error];
    fProcessing = NO;
}
- (void)inAppPurchase:(NSObject*)target action:(SEL)selector
{
    if(fProcessing){
        return;
    }
    fProcessing = YES;
    
    SKPaymentQueue *skPaymentQueue = [SKPaymentQueue defaultQueue];
    [skPaymentQueue addTransactionObserver:self];
    NSSet *productIDs = [NSSet setWithObject:@"Ticket200"];
    SKProductsRequest *skProductsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
    skProductsRequest.delegate = self;
    
    self.iap_target = target;
    self.iap_selector = selector;
    
    [skProductsRequest start];
}
@end

