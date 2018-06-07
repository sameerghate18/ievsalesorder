//
//  DropdownMenuViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 08/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "DropdownMenuViewController.h"

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifier"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = self.searchResult[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [UIColor clearColor];
    NSString  *searchSelectedValue = [self.searchResult objectAtIndex:indexPath.row];
    
    NSInteger index = [self.items indexOfObject:searchSelectedValue];
    selectedValue = [self.items objectAtIndex:index];
    
    if ([_delegate respondsToSelector:@selector(dropdownMenu:selectedItemIndex:value:)]) {
        [_delegate dropdownMenu:self selectedItemIndex:index value:selectedValue];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath   {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Search delegate methods

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF CONTAINS[c] %@",
                                    searchText];
    
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
