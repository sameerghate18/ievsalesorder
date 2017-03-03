//
//  AppDelegate.m
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import "AppDelegate.h"
#import "SSKeychain.h"

#define kAppIdentiier @"com.pcsofterp.IEV"
#define kAppKeychainIdentifier @"appUniqueCode"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)instantiateAppFlowWithNavController:(UINavigationController *)rootNav
{
    
//    UITabBarController *homeVC = (UITabBarController*)[kStoryboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    
//    PCSideMenuTableViewController *pcsvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCSideMenuTableViewController"];
//    
//    _slideViewController = [[MKDSlideViewController alloc] initWithMainViewController:rootNav];
//    _slideViewController.leftViewController = pcsvc;
//    _slideViewController.rightViewController = nil;
    
    self.window.rootViewController = rootNav;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSString *retrieveuuid = [SSKeychain passwordForService:kAppIdentiier account:kAppKeychainIdentifier];
    if (retrieveuuid == nil) {
        NSString *uuid  = [self createNewUUID];
        
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:kAppIdentiier account:kAppKeychainIdentifier];
        
        retrieveuuid = [uuid copy];
    }
    _appUniqueIdentifier = retrieveuuid;
    
    _loggedUser = [[PCUserModel alloc] init];
    _selectedCompany = [[PCCompanyModel alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _baseURL = [defaults valueForKey:kCompanyBaseURL];
    [defaults synchronize];
    
    UINavigationController *rootNav;
    
    BOOL isRegistered = [defaults boolForKey:IS_REGISTRATION_COMPLETE_KEY];
    
    if (isRegistered) {
        _baseURL = [defaults valueForKey:kCompanyBaseURL];
        _selectedCompany.CO_CD = [defaults valueForKey:@"selectedCompanyCode"];
        _selectedCompany.LONG_CO_NM = [defaults valueForKey:@"selectedCompanyLongName"];
        _selectedCompany.NAME = [defaults valueForKey:@"selectedCompanyName"];
        
        [defaults synchronize];
        
        rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
    }
    else {
        
        [defaults setBool:YES forKey:kPaymentAuthPwdEnabled];
        rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavController"];
    }
    
    [self instantiateAppFlowWithNavController:rootNav];

    
    return YES;
}

- (NSString *)createNewUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)(string);
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController  {
    
    if (tabBarController.selectedIndex == 3) {
        
        UIAlertController *confirmLogout = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [confirmLogout addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [confirmLogout dismissViewControllerAnimated:YES completion:^{
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
                [self instantiateAppFlowWithNavController:rootNav];
            });
            
        }]];
        
        [confirmLogout addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [confirmLogout dismissViewControllerAnimated:YES completion:NULL];
            
        }]];
        
        [tabBarController presentViewController:confirmLogout animated:YES completion:NULL];
        
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
