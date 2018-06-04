//
//  AppDelegate.h
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCompanyModel.h"
#import "PCUserModel.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) PCUserModel *loggedUser;
@property (strong, nonatomic) PCCompanyModel *selectedCompany;
@property (strong, nonatomic) NSString *selectedUserName, *selectedCompanyName, *baseURL, *userPhoneNumber, *accessCode;
@property (nonatomic) BOOL userLoggedIn;
@property (strong, nonatomic) NSString *appUniqueIdentifier;

@property (strong, nonatomic) LGSideMenuController *slideViewController;

@property (strong, nonatomic) UIWindow *window;

- (void)instantiateAppFlowWithNavController:(UINavigationController *)rootNav;

@end

