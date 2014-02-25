//
//  DNSInAppPurchaseManager.h
//  FlightTimeConverter2
//
//  Created by Transferred on 6/3/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

//Delegate
@protocol DNSInAppPurchaseManagerDelegate <NSObject>
@required
/**
 * Called when product retrieval has failed. 
 * @param errorMessage - The user-facing error message to display.
 */
-(void)productRetrievalFailed:(NSString *)errorMessage;

/**
 * Called when products have been successfully retrieved. 
 * @param products - The products retrieved in the SKProductsRequest.
 */
-(void)productsRetrieved:(NSArray *)products;

/**
 * Called when a purchase has failed.
 * @param errorMessage - The error message to be displayed to the user.
 */
-(void)purchaseFailed:(NSString *)errorMessage;

/**
 * Called when the user cancels a purchase.
 */
-(void)purchaseCancelled;

/**
 * Called when a purchase has succeeded.
 * @param productIdentifier - The product identifier for the purchase which succeeded. 
 */
-(void)purchaseSucceeded:(NSString *)productIdentifier;

@end

@interface DNSInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

//Note: Any method calling a delegate method should be wrapped in a check to send the command back to the main queue. 
@property (nonatomic, assign) id<DNSInAppPurchaseManagerDelegate> delegate;

/**
 * Whether the user has in-app purchases enabled. 
 * @return YES if the user can make purchases, NO if not.
 */
-(BOOL)canMakePurchases;

/**
 * Convenience alert view to show it the user is unable to make in-app purchases. Should
 * only be shown once, but does not manage this itself.
 */
-(UIAlertView *)cantMakePurchasesAlert;

/**
 * Loads up the store using the given set of product identifiers.
 */
-(void)loadStoreWithIdentifiers:(NSSet *)productIdentifiers;

/**
 * Begins the purchase process for the given product. 
 */
-(void)purchaseProduct:(SKProduct *)product;

@end
