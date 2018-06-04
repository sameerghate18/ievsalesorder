//
//  CustomTextInputViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 30/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "CustomTextInputViewController.h"

@interface CustomTextInputViewController () <UIPickerViewDelegate, UIPickerViewDelegate, UISearchBarDelegate>

{
    int currentCheckmarkIndex;
    NSString *selectedValue;
}

@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic, strong) IBOutlet UIPickerView *dropdownPicker;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation CustomTextInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchResult = self.items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView  {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component     {
    return self.searchResult.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component       {
    return self.searchResult[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        [tView setFont:[UIFont systemFontOfSize:16]];
        [tView setTextAlignment:NSTextAlignmentCenter];
    }
    // Fill the label text here
    tView.text = self.searchResult[row];
    return tView;
}

#pragma mark - Search delegate methods

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF CONTAINS %@",
                                    searchText];
    
    self.searchResult = [_searchResult filteredArrayUsingPredicate:resultPredicate];
    [self.dropdownPicker reloadAllComponents];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length == 0) {
        self.searchResult = self.items;
        [self.dropdownPicker reloadAllComponents];
    }
    else {
        [self filterContentForSearchText:searchBar.text];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar    {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar   {
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF CONTAINS %@",
                                    searchBar.text];
    
    self.searchResult = [_searchResult filteredArrayUsingPredicate:resultPredicate];
    [self.dropdownPicker reloadAllComponents];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar   {
    self.searchResult = self.items;
    [self.dropdownPicker reloadAllComponents];
}

-(IBAction)selectButtonAction:(id)sender    {
    
    if ([_delegate respondsToSelector:@selector(dropdownMenu:selectedItemIndex:value:)]) {

        NSInteger index = [self.items indexOfObject:selectedValue];
        [_delegate dropdownMenu:self selectedItemIndex:index value:selectedValue];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)dimissView:(id)sender    {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
