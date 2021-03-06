 //
//  RefineOrderViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 16/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "RefineOrderViewController.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "DropdownMenuViewController.h"

typedef enum {
    PickerForDocument,
    PickerForPartyNames,
    PickerForStartDate,
    PickerForEndDate,
} PickerFor;

@interface RefineOrderViewController () <UIPickerViewDelegate, UIPickerViewDataSource, DropdownMenuViewControllerDelegate>
{
    PickerFor pickertype;
    UIAlertController *actionSheet;
    NSArray *itemsForPicker, *uniqueItemsForPicker;
    SearchCriteriaModel *model;
    NSString *selectedValueFromPicker;
    UITextField *currentTextfield;
    UIDatePicker *datePickerView;
}

@property (nonatomic, strong) IBOutlet UIView *pickerContainer;
@property (nonatomic, strong) IBOutlet UIPickerView *dataPickerView;
@property (nonatomic, strong) IBOutlet UIButton *docButton, *partyNameButton, *startDateButton, *endDateButton;
@end

@implementation RefineOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    
    // Do any additional setup after loading the view.
    model = [[SearchCriteriaModel alloc] init];
//    model.docDescription = @"*";
//    model.partyName = @"* ";
    
//    self.pickerContainer.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
//    [self.view addSubview:self.pickerContainer];
    
    _dataPickerView = [[UIPickerView alloc] init];
    _dataPickerView.dataSource = self;
    _dataPickerView.delegate = self;
    
    datePickerView = [[UIDatePicker alloc] init];
    [datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [datePickerView setDatePickerMode:UIDatePickerModeDate];
    [datePickerView setMaximumDate:[NSDate date]];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectDocAction:(id)sender {
    
    pickertype = PickerForDocument;
    
    [self showPickerForValue:@"doc_desc"];
}

- (IBAction)partyNameAction:(id)sender {
    
    pickertype = PickerForPartyNames;
    
    [self showPickerForValue:@"party_name"];
}

- (IBAction)startDateAction:(id)sender {
    
    pickertype = PickerForStartDate;
    
    [self showPickerForValue:@"doc_date"];
}

- (IBAction)endDateAction:(id)sender {
    
    pickertype = PickerForEndDate;
    
    [self showPickerForValue:@"doc_date"];
}

- (void)showPickerForValue:(NSString*)param {
    if (!itemsForPicker) {
        itemsForPicker = [[NSArray alloc] init];
    }
    
    if (!uniqueItemsForPicker) {
        uniqueItemsForPicker = [[NSArray alloc] init];
    }
    
    itemsForPicker = [_items valueForKey:param];
    uniqueItemsForPicker = [itemsForPicker valueForKeyPath:@"@distinctUnionOfObjects.self"];

    [UIView animateWithDuration:0.2 animations:^{
        self.pickerContainer.frame = CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200);
    } completion:^(BOOL finished) {
        [_dataPickerView reloadAllComponents];
    }];
}

- (IBAction)searchAction:(id)sender {
    
//    if (model.startDate && model.endDate) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([_delegate respondsToSelector:@selector(searchController:searchCriteria:)]) {
                [_delegate searchController:self searchCriteria:model];
            }
        }];
//    }
//    else    {
//        UIAlertController *datesReqAlert = [UIAlertController alertControllerWithTitle:@"Start and end dates must be selected." message:nil preferredStyle:UIAlertControllerStyleAlert];
//        
//        [datesReqAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            
//            [datesReqAlert dismissViewControllerAnimated:YES completion:NULL];
//            
//        }]];
//        
//        [self presentViewController:datesReqAlert animated:YES completion:NULL];
//    }
    
    
    
}

- (IBAction)dismissAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView  {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component     {
    return uniqueItemsForPicker.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component       {
    return uniqueItemsForPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
    
    selectedValueFromPicker = uniqueItemsForPicker[row];
    
    switch (pickertype) {
        case PickerForDocument:
            
            model.docDescription = selectedValueFromPicker;
            break;

        case PickerForPartyNames:
            model.partyName = selectedValueFromPicker;
            break;
            
        default:
            break;
    }
    
    currentTextfield.text = selectedValueFromPicker;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    [textField resignFirstResponder];
    
    if (textField.tag == 1000) {
        textField.text = selectedValueFromPicker;
        model.docDescription = selectedValueFromPicker;
    }
    if (textField.tag == 1001) {
        textField.text = selectedValueFromPicker;
        model.partyName = selectedValueFromPicker;

    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField    {
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    DropdownMenuViewController *destVC = (DropdownMenuViewController*)mainViewController.rightViewController;
    destVC.delegate = self;
    
    currentTextfield = textField;
    
    if (textField.tag == 1000) {
        itemsForPicker = [_items valueForKey:@"doc_desc"];
        uniqueItemsForPicker = [itemsForPicker valueForKeyPath:@"@distinctUnionOfObjects.self"];
        destVC.cellType = cellTypeSingleLine;
        
        destVC.items = uniqueItemsForPicker;
        [destVC reloadFiltersTableView];
        [mainViewController showRightViewAnimated:nil];
        pickertype = PickerForDocument;
        return NO;
    }
    else if (textField.tag == 1001) {
        itemsForPicker = [_items valueForKey:@"party_name"];
        uniqueItemsForPicker = [itemsForPicker valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        destVC.items = uniqueItemsForPicker;
        [destVC reloadFiltersTableView];
        [mainViewController showRightViewAnimated:nil];
        pickertype = PickerForPartyNames;
        return NO;
    }
    else if (textField.tag == 1002) {
        textField.inputView = datePickerView;
    }
    else if (textField.tag == 1003) {
        textField.inputView = datePickerView;
    }
    
    [_dataPickerView reloadAllComponents];
    
    return YES;
}

-(void)datePickerValueChanged:(UIDatePicker*)datePicker   {
    
    if (currentTextfield.tag == 1002) {
        model.startDate = datePicker.date;
    }
    if (currentTextfield.tag == 1003) {
        model.endDate = datePicker.date;
    }
    
    currentTextfield.text = [Utility stringFromDate:datePicker.date];
}

-(void)dropdownMenu:(DropdownMenuViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex value:(NSString*)selectedValue {
    
    selectedValueFromPicker = uniqueItemsForPicker[selectedIndex];
    
    switch (pickertype) {
        case PickerForDocument:
            
            model.docDescription = selectedValueFromPicker;
            break;
            
        case PickerForPartyNames:
            model.partyName = selectedValueFromPicker;
            break;
            
        default:
            break;
    }
    
    currentTextfield.text = selectedValueFromPicker;
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
