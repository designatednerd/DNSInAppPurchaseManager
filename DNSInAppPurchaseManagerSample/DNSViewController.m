//
//  DNSViewController.m
//  DNSInAppPurchaseManagerSample
//
//  Created by Ellen Shapiro on 1/29/14.
//  Copyright (c) 2014 Ellen Shapiro. All rights reserved.
//

#import "DNSViewController.h"

#import "DNSInAppPurchaseManager.h"

//Replace this with
static NSString * const kReplaceWithYourAdID = @"ReplaceMeIAmOnlyAnExample";

///Used to track whether the in-app purchases failed alert has been shown
static NSString * const kIAPFailAlertShown = @"IAPFailAlertShown";

@interface DNSViewController () <DNSInAppPurchaseManagerDelegate>
@property (nonatomic, strong) DNSInAppPurchaseManager *iapManager;
@property (nonatomic, strong) NSArray *availableProducts;
@property (nonatomic, weak) IBOutlet UIButton *testProductButton;

@end

@implementation DNSViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.iapManager = [[DNSInAppPurchaseManager alloc] init];
    self.iapManager.delegate = self;
    [self setupStore];
    
    self.testProductButton.enabled = NO;
    [self.testProductButton setTitle:NSLocalizedString(@"Loading...", @"Loading...") forState:UIControlStateNormal];
}

#pragma mark - IBActions
-(IBAction)buyTestProuct:(UIButton *)sender
{
    //Disable the button to prevent multiple purchase attempts
    self.testProductButton.enabled = NO;
    [self.testProductButton setTitle:NSLocalizedString(@"Purchasing...", @"Purchasing button title") forState:UIControlStateNormal];
    
    //Use the tag of the button to determine what to purchase.
    [self buyProductAtIndex:sender.tag];
}

#pragma mark - In-App Purchase setup
-(void)setupStore
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self.iapManager canMakePurchases]) {
        //Reset whether the IAP fail alert has been shown
        [defaults setBool:NO forKey:kIAPFailAlertShown];
        [defaults synchronize];
        
        //Run on background thread - delegate forces callbacks on main thread.
        NSOperationQueue *background = [[NSOperationQueue alloc] init];
        __block DNSInAppPurchaseManager *blockManager = self.iapManager;
        [background addOperationWithBlock:^{
            //Gets your store items.
            [blockManager loadStoreWithIdentifiers:[NSSet setWithObject:kReplaceWithYourAdID]];
        }];
    } else {
        if (![defaults boolForKey:kIAPFailAlertShown]) {
            //Warn the user
            UIAlertView *disabled = [self.iapManager cantMakePurchasesAlert];
            [disabled show];
            
            //Note that this alert has been shown.
            [defaults setBool:YES forKey:kIAPFailAlertShown];
            [defaults synchronize];
        }
        
        [self.testProductButton setTitle:NSLocalizedString(@"IAP Disabled On This Device", @"Error button title for IAP disabled") forState:UIControlStateNormal];
    }
}

#pragma mark - Convenience
-(void)showErrorAlertView:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
}

-(void)buyProductAtIndex:(NSInteger)index
{
    if (self.availableProducts) {
        SKProduct *selectedProduct = self.availableProducts[index];
        typeof(self) __weak weakSelf = self;
        
        //Delegate guarantees callback on main thread, fire on BG so as not to block UI.
        NSOperationQueue *background = [[NSOperationQueue alloc] init];
        [background addOperationWithBlock:^{
            [weakSelf.iapManager purchaseProduct:selectedProduct];
        }];
    } else {
        NSAssert(NO, @"This shouldn't be reachable - you should have available products before you enable the purchase button.");
    }
}

-(void)purchaseSucceeded
{
    //Do whatever you need to for a successful IAP here.
    [self.testProductButton setTitle:NSLocalizedString(@"TEST PRODUCT PURCHASED!!", @"Title for button after successful purchase") forState:UIControlStateNormal];
}

#pragma mark - In App Purchase Manager Delegate
-(void)productRetrievalFailed:(NSString *)errorMessage
{
    //Note: If you're getting an invalid product ID, make sure that you
    //have set up banking and tax info in iTunes Connect.
    //http://stackoverflow.com/questions/12736712/ios-in-app-purchases-sandbox-invalid-product-id
    [self.testProductButton setTitle:NSLocalizedString(@"IAP Retrieval Error", @"Error button title for failed IAP retreival") forState:UIControlStateNormal];
    [self showErrorAlertView:errorMessage];
}

-(void)productsRetrieved:(NSArray *)products
{
    if (products) {
        //Store your available products.
        self.availableProducts = products;
        
        //Refresh UI
        self.testProductButton.enabled = YES;
        [self.testProductButton setTitle:NSLocalizedString(@"Buy test product!", @"Button title for successful product retrieval") forState:UIControlStateNormal];
    } else {
        [self showErrorAlertView:@"No products retrieved from ITC!"];
    }
}

-(void)purchaseFailed:(NSString *)errorMessage
{
    [self showErrorAlertView:errorMessage];
    
    self.testProductButton.enabled = YES;
    [self.testProductButton setTitle:NSLocalizedString(@"Purchase failed. Tap to try again.", @"Purchase failed button title") forState:UIControlStateNormal];
}

-(void)purchaseCancelled
{
    self.testProductButton.enabled = YES;
    [self.testProductButton setTitle:NSLocalizedString(@"User cancelled purchase. Tap to try again.", @"User cancelled button title") forState:UIControlStateNormal];
}

-(void)purchaseSucceeded:(NSString *)productIdentifier
{
    if ([productIdentifier isEqualToString:kReplaceWithYourAdID]) {
        [self purchaseSucceeded];
    } //check other purchases with else-if statements here.
}

@end
