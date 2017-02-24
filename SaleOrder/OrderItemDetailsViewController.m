//
//  OrderItemDetailsViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 10/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "OrderItemDetailsViewController.h"
#import "ConnectionHandler.h"
#import "ItemListViewController.h"
#import "TwoLineCellTableViewCell.h"

@interface OrderItemDetailsViewController ()
{
    NSMutableArray *orderHistory, *orderItemsArray;
    NSDictionary *titlesDictionary;
    NSArray *titlesArray, *titleValues;
    ItemListViewController *itemListVC;
}
@end

@implementation OrderItemDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchOrderDetails];
    
}

- (void)viewWillAppear:(BOOL)animated   {

    titlesArray = @[@"Order Date", @"Sales Order ID",@"Party Name",@"Tax",@"Total amount",@"Order Status",@"Narration"];
    titleValues = @[[Utility stringFromDate:self.selectedOrderModel.doc_date],
                    self.selectedOrderModel.doc_no,
                    self.selectedOrderModel.party_name,
                    [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedOrderModel.doc_taxs] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                    [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedOrderModel.im_basic] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                    self.selectedOrderModel.status,
                    self.selectedOrderModel.doc_desc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchOrderDetails   {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *urlStr = GET_ORDER_DETAIL(appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID,self.selectedOrderModel.doc_type,self.selectedOrderModel.doc_no);
    
    ConnectionHandler *orderDetails = [[ConnectionHandler alloc] init];
    
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    [orderDetails fetchDataForPOSTURL:urlStr body:nil completion:^(id responseData, NSError *error) {
        
        if (!orderItemsArray) {
            orderItemsArray = [[NSMutableArray alloc] init];
        }
        [orderItemsArray removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (NSDictionary *dict in responseData) {
                OrderHistoryDetailModel *itemDet = [OrderHistoryDetailModel dictionaryToModel:dict];
                [orderItemsArray addObject:itemDet];
            }
            
            [itemListVC setOrderHistoryItems:orderItemsArray];
            [itemListVC.tableView reloadData];
            
            [SVProgressHUD dismiss];
        });
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    return titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    TwoLineCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailCellIdentifier"];
    
    cell.titleLabel.text = titlesArray[indexPath.row];
    cell.descriptionLabel.text = titleValues[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 58;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedseg"]) {
        UINavigationController * navViewController = (UINavigationController *) [segue destinationViewController];
        
        navViewController.view.layer.cornerRadius = 10.0;
        navViewController.view.layer.masksToBounds = YES;
        navViewController.view.layer.borderWidth = 1.0;
        navViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
        
        itemListVC = (ItemListViewController*)[navViewController viewControllers][0];
    }
}


@end
