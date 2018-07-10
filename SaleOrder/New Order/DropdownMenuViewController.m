//
//  DropdownMenuViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 08/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "DropdownMenuViewController.h"
#import "MainViewController.h"
#import "SOMultiLineTableviewCell.h"
#import "TwoLineCellTableViewCell.h"
#import "SOTwoLineCellModel.h"

@interface DropdownMenuViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

{
    int currentCheckmarkIndex;
    NSString *selectedValue;
}

@property (nonatomic, strong) NSArray *searchResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation DropdownMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchResult = self.items;
}

- (void)viewWillAppear:(BOOL)animated {
    _searchBar.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadFiltersTableView {
    self.searchResult = self.items;
    [self.itemsTableview reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    return self.searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    UITableViewCell *cell;
    
    if (_cellType == cellTypeSingleLine) {
        SOMultiLineTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
        cell.multilineLabel.text = self.searchResult[indexPath.row];
        return cell;
    } else if (_cellType == cellTypeTwoLine) {
        TwoLineCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"twoLineIdentifier"];
        SOTwoLineCellModel *itemAtIndex = self.searchResult[indexPath.row];
        cell.titleLabel.text = itemAtIndex.line1Text;
        cell.descriptionLabel.text = [itemAtIndex.line2Text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return cell;
    }
    
//    cell.backgroundColor = [UIColor clearColor];
//    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger index = 0;
    
    if (_cellType == cellTypeSingleLine) {
        NSString  *searchSelectedValue = [self.searchResult objectAtIndex:indexPath.row];
        index = [self.items indexOfObject:searchSelectedValue];
        selectedValue = [self.items objectAtIndex:index];
    } else if (_cellType == cellTypeTwoLine) {
        SOTwoLineCellModel  *searchSelectedItem = [self.searchResult objectAtIndex:indexPath.row];
        index = [self.items indexOfObject:searchSelectedItem];
        SOTwoLineCellModel *selectedItem = [self.items objectAtIndex:index];
        selectedValue = selectedItem.line1Text;
    }
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    
    if ([_delegate respondsToSelector:@selector(dropdownMenu:selectedItemIndex:value:)]) {
        [_delegate dropdownMenu:self selectedItemIndex:index value:selectedValue];
        
        _searchBar.text = @"";
        [mainViewController hideRightViewAnimated:YES completionHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath   {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_cellType == cellTypeTwoLine) {
        return 56.0;
    } else if (_cellType == cellTypeSingleLine) {
        return 68.0;
    }
    return 56.0;
}

#pragma mark - Search delegate methods

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate;
    
    if (_cellType == cellTypeTwoLine) {
        resultPredicate = [NSPredicate
                           predicateWithFormat:@"SELF.line1Text contains[c] %@ OR SELF.line2Text contains[c] %@",
                           searchText, searchText];
    } else if (_cellType == cellTypeSingleLine) {
        resultPredicate = [NSPredicate
                           predicateWithFormat:@"SELF CONTAINS[c] %@",
                           searchText];
    }
    
    self.searchResult = [_items filteredArrayUsingPredicate:resultPredicate];
    [self.itemsTableview reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length == 0) {
        self.searchResult = self.items;
        [self.itemsTableview reloadData];
    }
    else {
        [self filterContentForSearchText:searchBar.text];
    }
}

-(IBAction)selectButtonAction:(id)sender    {
   
    if ([_delegate respondsToSelector:@selector(dropdownMenu:selectedItemIndex:value:)]) {
        
        NSInteger index = [self.items indexOfObject:selectedValue];
        [_delegate dropdownMenu:self selectedItemIndex:index value:selectedValue];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

-(IBAction)dimissView:(id)sender    {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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
