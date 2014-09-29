# DNSInAppPurchaseManager
----
A simple In-App Purchase manager that handles the absolute basics of making an In-App purchase, and restoring a purchase which was already made. 

Make sure to read [Apple's IAP documentation](https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnectInAppPurchase_Guide/Chapters/Introduction.html) before using this utility. Make sure you're using a [Sandbox Test User](https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SettingUpUserAccounts.html#//apple_ref/doc/uid/TP40011225-CH25-SW10), not your actual App store credentials. 

You will need to test on device, since [IAP does not work on the iOS Simulator](http://stackoverflow.com/a/15414340/681493).

Note: This utility does not track the purchases itself, simply abstracts the making of the purchases. You will need to track what purchases the user has made in your application, either via the `SKReciept` or via saving a record of what has been purchased. 


## Installation

DNSInAppPurchaseManager is available through [CocoaPods](http://cocoapods.org). To install it simply add the following line to your Podfile:

    pod "DNSInAppPurchaseManager"

## Author

Ellen Shapiro


## //TODO
- Add tests
- Add some kind of tracking of purchases. 
- ??? - file an issue!
