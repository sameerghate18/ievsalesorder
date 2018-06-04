//
//  UINavigationController+ExtraMethods.m
//  SaleOrder
//
//  Created by Sameer Ghate on 31/05/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import "UINavigationController+ExtraMethods.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"

@implementation UINavigationController (ExtraMethods)

-(IBAction)showSideMenu:(id)sender {
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    [mainViewController showRightViewAnimated:true completionHandler:nil];
}
@end
