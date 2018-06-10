//
//  PCHomeViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 26/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCHomeViewController.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "PCTilesCollectionCell.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "MoreViewController.h"
#import "AppDelegate.h"
#import "PCSideMenuTableViewController.h"
#import "DropdownMenuViewController.h"

@interface PCHomeViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *titles, *images;
    AppDelegate *appDel;
}

@property (nonatomic, weak) IBOutlet UIView *headerview;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;

@end

@implementation PCHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    titles = [[NSMutableArray alloc] initWithObjects:@"Orders",@"New Order", @"About",@"Logout",nil];
    
    images = [[NSMutableArray alloc] initWithObjects:@"home_orders_tile",@"home_new_order", @"home_about",@"home_logout",nil];
    
    [_userLabel setText:[NSString stringWithFormat:@"Welcome, %@",appDel.loggedUser.USER_NAME]];
    
    [self.navigationItem setTitle:@"Home"];
    
    [self.navigationController.navigationItem hidesBackButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
//    mainViewController.leftViewController = nil;
//    mainViewController.rightViewController = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return titles.count;
}

static NSString *reportsCell = @"reportCell";
static NSString *transactionsCell = @"transactionCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCTilesCollectionCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reportsCell forIndexPath:indexPath];
    cell.titleLabel.text = [titles objectAtIndex:indexPath.row];
    cell.tileImageview.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        return CGSizeMake(100, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UINavigationController *mainNavController = (UINavigationController *)mainViewController.rootViewController;
    PCSideMenuTableViewController *leftMenuVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCSideMenuTableViewController"];
    
    switch (indexPath.row) {
        case 0:
        {
            if( [mainNavController.topViewController isKindOfClass:[FirstViewController class]] )
                
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
            else
            {
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
                UINavigationController *navcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"OrdersNavController"];
                DropdownMenuViewController *rightMenuVC = [kStoryboard instantiateViewControllerWithIdentifier:@"DropdownMenuViewController"];
                mainViewController.rootViewController = navcontroller;
                mainViewController.leftViewController = leftMenuVC;
                mainViewController.rightViewController = rightMenuVC;
            }
        }
            
            break;
            
        case 1:
        {
            if( [mainNavController.topViewController isKindOfClass:[SecondViewController class]] )
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
            else
            {
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
                DropdownMenuViewController *rightMenuVC = [kStoryboard instantiateViewControllerWithIdentifier:@"DropdownMenuViewController"];
                UINavigationController *navcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"CreateOrderNavController"];
                mainViewController.rootViewController = navcontroller;
                mainViewController.leftViewController = leftMenuVC;
                mainViewController.rightViewController = rightMenuVC;
            }
        }
            break;
            
        case 2:
        {
            if( [mainNavController.topViewController isKindOfClass:[MoreViewController class]] )
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
            else
            {
                [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
                UINavigationController *navcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"AboutRootNavController"];
                mainViewController.rootViewController = navcontroller;
                mainViewController.leftViewController = leftMenuVC;
                mainViewController.rightViewController = nil;
            }
        }
            break;
            
        case 3:
        {
            UIAlertController *confirmLogoutAlert = [UIAlertController alertControllerWithTitle:@"Logout?" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
            
            [confirmLogoutAlert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self logout];
            }]];
            
            [confirmLogoutAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [confirmLogoutAlert dismissViewControllerAnimated:true completion:nil];
            }]];
            
            [self presentViewController:confirmLogoutAlert animated:true completion:nil];
            
            return;
        }
    }
    
    mainViewController.leftViewCoverBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    mainViewController.rightViewCoverBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}

- (void)logout
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDel.loggedUser = nil;
    UINavigationController *navcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.rootViewController = navcontroller;
    [mainViewController hideLeftViewAnimated];
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 1) {
        // Add inset to the collection view if there are not enough cells to fill the width.
        CGFloat cellSpacing = ((UICollectionViewFlowLayout *) collectionViewLayout).minimumLineSpacing;
        CGFloat cellWidth = ((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
        NSInteger cellCount = [collectionView numberOfItemsInSection:section];
        CGFloat inset = (collectionView.bounds.size.width - (cellCount * (cellWidth + cellSpacing))) * 0.5;
        inset = MAX(inset, 0.0);
        
        inset = (collectionView.bounds.size.width*0.4 - cellWidth);
        return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0);
    }
    
    return  UIEdgeInsetsMake(20, 60, 20, 60);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section   {
    
    return 50;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
