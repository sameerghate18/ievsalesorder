//
//  MoreViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 30/11/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *itemsArray, *itemImagesArray;
}
@end

@implementation MoreViewController


- (void)viewDidLoad {
    itemsArray = @[@"About SaleOrder app", @"Logout"];
    itemImagesArray = @[@"info",@"logout"];
}

- (IBAction)logoutAction:(id)sender {
    
    __block AppDelegate *appDel;
    
    UIAlertController *confirmLogout = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [confirmLogout addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [confirmLogout dismissViewControllerAnimated:YES completion:^{
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            UINavigationController *rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
            [appDel instantiateAppFlowWithNavController:rootNav];
        });
        
    }]];
    
    [confirmLogout addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [confirmLogout dismissViewControllerAnimated:YES completion:NULL];
        
    }]];
    
    [self.navigationController.tabBarController presentViewController:confirmLogout animated:YES completion:NULL];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    cell.imageView.image = [UIImage imageNamed:itemImagesArray[indexPath.row]];
    cell.textLabel.text = itemsArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self logoutAction:nil];
    }
    else if (indexPath.row == 0)    {
        [self performSegueWithIdentifier:@"moreToAboutSegue" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return 70;
}


@end
