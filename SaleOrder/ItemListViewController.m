//
//  ItemListViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 11/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "ItemListViewController.h"
#import "TwoLineCellTableViewCell.h"
#import "OrderHistoryDetailModel.h"
#import "ItemDetailViewController.h"

@interface ItemListViewController ()

@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = FALSE;
    self.title = @"Items in this Order";
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
}

- (void)viewWillAppear:(BOOL)animated   {
    
}

- (void)viewWillDisappear:(BOOL)animated    {
    
    self.title = @"Items";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return self.orderHistoryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    TwoLineCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemBasicCell"];
    
    OrderHistoryDetailModel *item = self.orderHistoryItems[indexPath.row];
    cell.titleLabel.text = item.descr;
    cell.descriptionLabel.text =  [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",item.total] forCurrencyCode:@"INR"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    
    [self performSegueWithIdentifier:@"itemDetailSegue" sender:indexPath];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 58;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexpath = (NSIndexPath*)sender;
    ItemDetailViewController *itemDetailVC = [segue destinationViewController];
    OrderHistoryDetailModel *itemDetail = [self.orderHistoryItems objectAtIndex:indexpath.row];
    [itemDetailVC setSelectedHistoryItem:itemDetail];
    
}


@end
