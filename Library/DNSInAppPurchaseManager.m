//
//  DNSInAppPurchaseManager.m
//  FlightTimeConverter2
//
//  Created by Transferred on 6/3/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "DNSInAppPurchaseManager.h"

@interface DNSInAppPurchaseManager() 
@property (nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation DNSInAppPurchaseManager

-(void)loadStoreWithIdentifiers:(NSSet *)productIdentifiers
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description
    [self requestProductData:productIdentifiers];
}

-(void)requestProductData:(NSSet *)productIdentifiers
{
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

-(NSString *)connectionProblemErrorString
{
    return NSLocalizedString(@"There was a problem connecting to the Apple server. Please try your purchase again.", @"Error for failure of in-app purchases");
}

#pragma mark - Public convenience methods
-(BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

-(UIAlertView *)cantMakePurchasesAlert
{
    //Warn the user
    NSString *title = NSLocalizedString(@"In-App Purchases Disabled", @"In-App Purchases Disabled");
    NSString *message = NSLocalizedString(@"Sorry, In-App Purchases are currently disabled on this device. Please enable In-App Purchases if you wish to purchase this item. \n\nThis message will not be repated.", @"Instructions to re-enable In-App Purchases.");
    NSString *ok = NSLocalizedString(@"OK", @"OK");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
    return alert;
}

-(void)purchaseProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate method
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    __block id<DNSInAppPurchaseManagerDelegate> blockDelegate = self.delegate;

    if (response.products.count == 0) {
        NSLog(@"IAP response had no products!");
        //Make sure to call delegate methods on main thread.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [blockDelegate productRetrievalFailed:[self connectionProblemErrorString]];
        }];
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [blockDelegate productsRetrieved:response.products];
    }];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error! %@", error);
    __block id<DNSInAppPurchaseManagerDelegate> blockDelegate = self.delegate;

    //Make sure to call delegate methods on main thread.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [blockDelegate productRetrievalFailed:error.localizedDescription];
    }];
}

#pragma mark - SKPaymentTransactionObserver method
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: //Intentional fall-through
                [self transactionSucceeded:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self transactionFailed:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Transaction handling
-(void)transactionSucceeded:(SKPaymentTransaction *)transaction
{
    //Notify the delegate.
    __block id<DNSInAppPurchaseManagerDelegate> blockDelegate = self.delegate;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [blockDelegate purchaseSucceeded:transaction.payment.productIdentifier];
    }];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)transactionFailed:(SKPaymentTransaction *)transaction
{
    __block id<DNSInAppPurchaseManagerDelegate> blockDelegate = self.delegate;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSString *message = NSLocalizedString(@"Sorry, your transaction has failed with the following error: ", @"Prepended string for error localized description.");
        NSString *error = [transaction.error localizedDescription];
        message = [message stringByAppendingString:error];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [blockDelegate purchaseFailed:message];
        }];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [blockDelegate purchaseCancelled];
        }];
    }
    
    //Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
