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

#define TICKET1000 @"Ticket1000"
#define TICKET200 @"Ticket200"
#define TICKET20 @"Ticket20"

@implementation TicketManager

@synthesize delegate = _delegate;

@synthesize iap_target = _iap_target;
@synthesize iap_selector = _iap_selector;
@synthesize iap_sender = _iap_sender;
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
    NSInteger available_tickets = 0;
    
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
- (void)didFinishInAppPurchase
{
    fProcessing = NO;
    [self.delegate didFinishTicketManagerInAppPurchase:self];
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions){
        NSLog(@"%s: transaction = {.transactionDate = %@, .transactionIdentifier = %@, .transactionState = %d, .payment.productIdentifier=%@}", __FUNCTION__, transaction.transactionDate, transaction.transactionIdentifier, transaction.transactionState, transaction.payment.productIdentifier);
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                {
                    NSString *productIdentifier = transaction.payment.productIdentifier;
                    
                    NSLog(@"SKPaymentTransactionStatePurchased(productIdentifier=%@)", productIdentifier);
                    int bought_tickets = 0;
                    if([productIdentifier isEqual:TICKET1000]){
                        bought_tickets = 1000;
                    }else if([productIdentifier isEqual:TICKET200]){
                        bought_tickets = 200;
                    }else if([productIdentifier isEqual:TICKET20]){
                        bought_tickets = 20;
                    }else{
                        [queue finishTransaction:transaction];
                        [self didFinishInAppPurchase];
                        break;
                    }
                    self.availableTickets = self.availableTickets + bought_tickets;
                    [queue finishTransaction:transaction];
                    [self didFinishInAppPurchase];
                    [self.iap_target performSelector:self.iap_selector withObject:self.iap_sender];
                    break;
                }
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed: %@", transaction.error);
                [queue finishTransaction:transaction];
                [self didFinishInAppPurchase];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                [queue finishTransaction:transaction];
                [self didFinishInAppPurchase];
                break;
        }
    }
    
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s, error=%@", __FUNCTION__, error);
    [self errorAlert:error];
    [self didFinishInAppPurchase];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *ticketstr = nil;
    switch (buttonIndex) {
        case 1:
            ticketstr = TICKET1000;
            break;
        case 2:
            ticketstr = TICKET200;
            break;
        case 3:
            ticketstr = TICKET20;
            break;
        default:
            [self didFinishInAppPurchase];
            return;
            break;
    }

    SKPaymentQueue *skPaymentQueue = [SKPaymentQueue defaultQueue];
    [skPaymentQueue addTransactionObserver:self];
    NSSet *productIDs = [NSSet setWithObject:ticketstr];
    SKProductsRequest *skProductsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
    skProductsRequest.delegate = self;
    
    
    [skProductsRequest start];

}
- (void)inAppPurchase:(NSObject*)target action:(SEL)selector sender:(id)sender
{
    if(fProcessing){
        return;
    }
    fProcessing = YES;
    

    self.iap_target = target;
    self.iap_selector = selector;
    self.iap_sender = sender;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ticket shop" message:@"1 ticket = 1 image translation" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"1,000 tickets($19.99, -60%)",@"  200 tickets($4.99, -50%)", @"20 tickets($0.99)", nil];
    [alertView show];
    [alertView release];
}
@end

