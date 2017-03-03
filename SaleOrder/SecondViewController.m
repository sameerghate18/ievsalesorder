//
//  SecondViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import "SecondViewController.h"
#import "ConnectionHandler.h"
#import "OrderItemDetailsViewController.h"
#import "SearchCriteriaModel.h"
#import "RefineOrderViewController.h"

@implementation OrderHistoryCell

- (void)fillValuesAndStatus:(OrderHistoryModel*)singleOrder {
    
    self.itemLabel.text = singleOrder.doc_desc;
    self.orderDateLabel.text =  [Utility stringFromDate:singleOrder.doc_date];
    self.partyNameLabel.text =  singleOrder.party_name;
    
    if ([singleOrder.status isEqualToString:@"Pending"]) {
        self.statusLabel.text = @"Pending";
        self.statusLabel.textColor = [UIColor redColor];
    }
    else if ([singleOrder.status isEqualToString:@"Approved"]) {
        self.statusLabel.text = @"Approved";
        self.statusLabel.textColor = [UIColor greenColor];
    }
    else if ([singleOrder.status isEqualToString:@"In progress"]) {
        self.statusLabel.text = @"In progress";
        self.statusLabel.textColor = [UIColor orangeColor];
    }
}

@end

@interface SecondViewController () <UITableViewDelegate, UITableViewDataSource, RefineOrderViewControllerDelegate>
{
    UIRefreshControl *refreshControl;
}

@property(nonatomic, strong) IBOutlet UITableView *ordersTableview;
@property(nonatomic, strong) NSMutableArray *orderItems;
@property(nonatomic, strong) NSArray *arrayForTableview;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getOrderHistory) forControlEvents:UIControlEventValueChanged];
    
    NSAttributedString *refreshString = [[NSAttributedString alloc] initWithString:@"Refreshing..." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    refreshControl.attributedTitle = refreshString;
    [self.ordersTableview addSubview:refreshControl];
    
    [self getOrderHistory];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getOrderHistory {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *orderConn = [[ConnectionHandler alloc] init];
    
    NSString *urlString = GET_ALL_ORDERS(appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID);
    
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    [orderConn fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!self.orderItems) {
                self.orderItems = [[NSMutableArray alloc] init];
            }
            [self.orderItems removeAllObjects];
            
            for (NSDictionary *dictionary in responseData) {
                
                OrderHistoryModel *aOrder = [OrderHistoryModel dictionaryToModel:dictionary];
                [self.orderItems addObject:aOrder];
            }
            
            [self.orderItems sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                
                OrderHistoryModel *model1 = (OrderHistoryModel*)obj1;
                OrderHistoryModel *model2 = (OrderHistoryModel*)obj2;
                
                return -[model1.doc_date compare:model2.doc_date];
            }];
            
            _arrayForTableview = self.orderItems ;
            [refreshControl endRefreshing];
            [_ordersTableview reloadData];
            
            [SVProgressHUD dismiss];
        });
        
    }];
}

- (IBAction)clearAllAction:(id)sender   {
    
    _arrayForTableview = _orderItems;
    [_ordersTableview reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    return _arrayForTableview.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    OrderHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCellIdentifier"];

    OrderHistoryModel *model = _arrayForTableview[indexPath.row];
    [cell fillValuesAndStatus:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"orderDetailsSegue" sender:indexPath];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender     {
    
    if ([segue.identifier isEqualToString:@"orderDetailsSegue"]) {
        
        NSInteger itemIdx = ((NSIndexPath*)sender).row;
        
        OrderHistoryModel *model = [_arrayForTableview objectAtIndex:itemIdx];
        
        OrderItemDetailsViewController *destVC = (OrderItemDetailsViewController*)segue.destinationViewController;
        [destVC setSelectedOrderModel:model];
    }
    else if ([segue.identifier isEqualToString:@"refineResultsSegue"])  {
        
        RefineOrderViewController *searchVC = (RefineOrderViewController*)[segue destinationViewController];
        searchVC.delegate = self;
        searchVC.items = _orderItems;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 100;
}

#pragma mark -RefineOrderViewControllerDelegate

- (void)searchController:(RefineOrderViewController*)controller searchCriteria:(SearchCriteriaModel*)searchModel  {
    
    if (searchModel.docDescription || searchModel.partyName) {
        
        NSArray *filteredArray;
        
        if (searchModel.startDate || searchModel.endDate) {
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(doc_date >= %@) AND (doc_date <= %@)", searchModel.startDate, searchModel.endDate];
            filteredArray = [_orderItems filteredArrayUsingPredicate:datePredicate];
            
            NSString *searchString = [NSString stringWithFormat:@"(doc_desc contains[c] '%@') AND (party_name contains[c] '%@')", searchModel.docDescription, searchModel.partyName];
            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:searchString];
            
            _arrayForTableview = [filteredArray filteredArrayUsingPredicate:namePredicate];
            
            if (filteredArray.count == 0) {
                
                UIAlertController *noItemAlert = [UIAlertController alertControllerWithTitle:@"No items found." message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                [noItemAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    [noItemAlert dismissViewControllerAnimated:YES completion:NULL];
                    
                }]];
                
                [self presentViewController:noItemAlert animated:YES completion:NULL];
                
                return;
            }
            
        }
        else    {
            NSString *searchString = [NSString stringWithFormat:@"(doc_desc contains[c] '%@') AND (party_name contains[c] '%@')", searchModel.docDescription, searchModel.partyName];
            NSPredicate *namePredicate = [NSPredicate predicateWithFormat:searchString];
            _arrayForTableview = [_orderItems filteredArrayUsingPredicate:namePredicate];
            
            if (filteredArray.count == 0) {
                
                UIAlertController *noItemAlert = [UIAlertController alertControllerWithTitle:@"No items found." message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                [noItemAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    [noItemAlert dismissViewControllerAnimated:YES completion:NULL];
                    
                }]];
                
                [self presentViewController:noItemAlert animated:YES completion:NULL];
                
                return;
            }
            else    {
                _arrayForTableview = filteredArray;
            }
            
        }

    }
    else {
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(doc_date >= %@) AND (doc_date <= %@)", searchModel.startDate, searchModel.endDate];
        NSArray *filteredArray = [_orderItems filteredArrayUsingPredicate:datePredicate];
        
        if (filteredArray.count == 0) {
            
            UIAlertController *noItemAlert = [UIAlertController alertControllerWithTitle:@"No items found for the selected dates." message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [noItemAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [noItemAlert dismissViewControllerAnimated:YES completion:NULL];
                
            }]];
            
            [self presentViewController:noItemAlert animated:YES completion:NULL];
            
            return;
        }
        else    {
            _arrayForTableview = filteredArray;
        }
    }
    
    [_ordersTableview reloadData];
}

- (void)searchControllerSearchAll:(RefineOrderViewController *)searchController {
    
}

- (void)searchControllerClearAll:(RefineOrderViewController *)searchController  {
    
}

@end
