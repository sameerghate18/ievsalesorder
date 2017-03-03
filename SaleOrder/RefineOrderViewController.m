 //
//  RefineOrderViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 16/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "RefineOrderViewController.h"

typedef enum {
    PickerForDocument,
    PickerForPartyNames,
    PickerForStartDate,
    PickerForEndDate,
} PickerFor;

@interface RefineOrderViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    PickerFor pickertype;
    UIAlertController *actionSheet;
    NSArray *itemsForPicker;
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
    // Do any additional setup after loading the view.
    model = [[SearchCriteriaModel alloc] init];
    
//    self.pickerContainer.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
//    [self.view addSubview:self.pickerContainer];
    
    _dataPickerView = [[UIPickerView alloc] init];
    _dataPickerView.dataSource = self;
    _dataPickerView.delegate = self;
    
    datePickerView = [[UIDatePicker alloc] init];
    [datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
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
    
    itemsForPicker = [_items valueForKey:param];

    [UIView animateWithDuration:0.2 animations:^{
        self.pickerContainer.frame = CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200);
    } completion:^(BOOL finished) {
        [_dataPickerView reloadAllComponents];
    }];
}

- (IBAction)searchAction:(id)sender {
    
    if (model.startDate && model.endDate) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([_delegate respondsToSelector:@selector(searchController:searchCriteria:)]) {
                [_delegate searchController:self searchCriteria:model];
            }
        }];
    }
    else    {
        UIAlertController *datesReqAlert = [UIAlertController alertControllerWithTitle:@"Start and end dates must be selected." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [datesReqAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [datesReqAlert dismissViewControllerAnimated:YES completion:NULL];
            
        }]];
        
        [self presentViewController:datesReqAlert animated:YES completion:NULL];
    }
    
    
    
}

- (IBAction)clearAllAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView  {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component     {
    return itemsForPicker.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component       {
    return itemsForPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
    
    selectedValueFromPicker = [itemsForPicker objectAtIndex:row];
    
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
    
    if (textField.tag == 1000) {
        itemsForPicker = [_items valueForKey:@"doc_desc"];
        textField.inputView = _dataPickerView;
        pickertype = PickerForDocument;
    }
    else if (textField.tag == 1001) {
        itemsForPicker = [_items valueForKey:@"party_name"];
        textField.inputView = _dataPickerView;
        pickertype = PickerForPartyNames;
    }
    else if (textField.tag == 1002) {
        textField.inputView = datePickerView;
    }
    else if (textField.tag == 1003) {
        textField.inputView = datePickerView;
    }
    
    currentTextfield = textField;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
