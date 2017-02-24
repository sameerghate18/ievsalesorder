//
//  ItemDetailViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 11/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "TwoLineCellTableViewCell.h"

@interface ItemDetailViewController ()
{
    NSArray *titlesArray, *titleValues;
}
@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = FALSE;
    self.title = @"Item Details";
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
    titlesArray = @[@"Description", @"Code",@"Quantity",@"Rate",@"Value",@"Line Taxes"];
    titleValues = @[self.selectedHistoryItem.descr,
                    self.selectedHistoryItem.code,
                    [NSString stringWithFormat:@"%@",self.selectedHistoryItem.qty],
                    [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedHistoryItem.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                    [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedHistoryItem.value] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                    [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedHistoryItem.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    TwoLineCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemDetailCellIdentifier"];
    
    cell.titleLabel.text = titlesArray[indexPath.row];
    cell.descriptionLabel.text = titleValues[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 58;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
