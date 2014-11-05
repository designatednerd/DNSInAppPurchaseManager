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

#pragma mark - Class Convenience.
+(NSString *)localeFormattedPriceForProduct:(SKProduct *)product
{
    static NSNumberFormatter * _formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });

    [_formatter setLocale:product.priceLocale];
    return [_formatter stringFromNumber:product.price];
}

#pragma mark - Lifecycle
- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    self.productsRequest.delegate = nil;
}

#pragma mark - Load 'em up!
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

-(NSString *)noProductsRetrievedString
{
    return NSLocalizedString(@"No products are currently available for purchase. Please try again later.", @"Error for no products.");
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

-(void)restoreExistingPurchases
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate method
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;

    if (response.products.count == 0) {
        NSLog(@"IAP response had no products!");
        //Make sure to call delegate methods on main thread.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakDelegate productRetrievalFailed:[self noProductsRetrievedString]];
        }];
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakDelegate productsRetrieved:response.products];
    }];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error! %@", error);
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;

    //Make sure to call delegate methods on main thread.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakDelegate productRetrievalFailed:error.localizedDescription];
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
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakDelegate purchaseSucceeded:transaction.payment.productIdentifier];
    }];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)transactionFailed:(SKPaymentTransaction *)transaction
{
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSString *message = NSLocalizedString(@"Sorry, your transaction has failed with the following error: ", @"Prepended string for error localized description.");
        NSString *error = [transaction.error localizedDescription];
        message = [message stringByAppendingString:error];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakDelegate purchaseFailed:message];
        }];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakDelegate purchaseCancelled];
        }];
    }
    
    //Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakDelegate restorationSucceeded];
    }];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    __weak id<DNSInAppPurchaseManagerDelegate> weakDelegate = self.delegate;
    NSString *errorMessage = [error localizedDescription];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakDelegate restorationFailedWithError:errorMessage];
    }];
}

@end
