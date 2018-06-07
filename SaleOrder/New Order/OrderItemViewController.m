//
//  OrderItemViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 05/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import "OrderItemViewController.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "DropdownMenuViewController.h"
#import "SONewOrderItem.h"
#import "SOModels.h"

@interface OrderItemViewController () <UITextFieldDelegate, DropdownMenuViewControllerDelegate>
{
    NSString *selectedValueFromPicker, *selectedItemRate;
    UITextField *currentTextfield;
}
@property (nonatomic, weak) IBOutlet UITextField *titleTextfield, *itemCodeTextfield, *itemQtyTextfield, *itemRateTextfield;
@property (nonatomic, weak) IBOutlet UIButton *addButton, *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) SONewOrderItem *editItemObj, *beforeEditItem;

@end

@implementation OrderItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    if (_popupType == ItemPopupTypeAdd) {
        [self.addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.titleLabel.text = @"Add a new item";
        [self.addButton setTitle:@"Add item" forState:UIControlStateNormal];
    } else if (_popupType == ItemPopupTypeEdit) {
        [self.addButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.titleLabel.text = @"Edit item";
        [self editOrderItem:_editItemObj];
        [self.addButton setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [currentTextfield resignFirstResponder];
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editOrderItem:(SONewOrderItem*)itemDetails {
    
    [self.addButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = @"Edit item";
    
    _editItemObj = itemDetails;
    _beforeEditItem = itemDetails ;
    
    selectedValueFromPicker = _beforeEditItem.itemCode;
    
    self.titleLabel.text = @"Edit Item";
    [self.addButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
    self.itemCodeTextfield.text = _beforeEditItem.itemCode;
    self.itemQtyTextfield.text = [NSString stringWithFormat:@"%@", _beforeEditItem.quantity];
    self.itemRateTextfield.text = [Utility stringWithCurrencySymbolForValue:_beforeEditItem.rate forCurrencyCode:DEFAULT_CURRENCY_CODE];
}

- (IBAction)addButtonAction:(id)sender {

    if (!(_itemCodeTextfield.text.length>0 && _itemQtyTextfield.text.length>0 && _itemRateTextfield.text.length>0)) {
        return;
    }
    
    SONewOrderItem *newItem = [[SONewOrderItem alloc] init];
    newItem.itemCode = selectedValueFromPicker;
    
    selectedItemRate = _itemRateTextfield.text;
    
    NSString *rateStr = [selectedItemRate stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    newItem.rate = [rateStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    newItem.quantity = _itemQtyTextfield.text;
    
    double rate = [newItem.rate doubleValue];
    double qty = [newItem.quantity doubleValue];
    double amount = rate*qty;
    
    newItem.amount = amount;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:true completion:^{
            if ([self.delegate respondsToSelector:@selector(itemAdded:)]) {
                [self.delegate itemAdded:newItem];
            }
        }];
    });
}

- (IBAction)editButtonAction:(id)sender {
    
    if (!(_itemCodeTextfield.text.length>0 && _itemQtyTextfield.text.length>0 && _itemRateTextfield.text.length>0)) {
        return;
    }
    
    SONewOrderItem *newEditedItem = [[SONewOrderItem alloc] init];
    
    newEditedItem.itemCode = selectedValueFromPicker;
//    _editItemObj.itemCode = selectedValueFromPicker;
    selectedItemRate = _itemRateTextfield.text;
    
    NSString *rateStr = [selectedItemRate stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    newEditedItem.rate = [rateStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    newEditedItem.quantity = _itemQtyTextfield.text;
    
    double rate = [newEditedItem.rate doubleValue];
    double qty = [newEditedItem.quantity doubleValue];
    double amount = rate*qty;
    
    newEditedItem.amount = amount;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:true completion:^{
            if ([self.delegate respondsToSelector:@selector(itemDidUpdate:beforeEditItem:)]) {
                [self.delegate itemDidUpdate:newEditedItem beforeEditItem:_beforeEditItem];
            }
        }];
    });
}

- (IBAction)dismiss:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
 }


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    
    if (textField.tag == 100) {
        DropdownMenuViewController *destVC = (DropdownMenuViewController*)mainViewController.rightViewController;
        destVC.delegate = self;
        destVC.items = self.itemsForPicker;
        [destVC reloadFiltersTableView];
        [mainViewController showRightViewAnimated:nil];
        return NO;
    } else if (textField.tag == 101) {
        currentTextfield = textField;
        return YES;
    } else if (textField.tag == 102) {
        currentTextfield = textField;
        return YES;
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 101) {
        NSLog(@"shouldChangeCharactersInRange - %@", string);
        NSMutableString *mStr = [[NSMutableString alloc] initWithString:string];
        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            return NO;
        }
        else {
            selectedItemRate = textField.text;
            return  YES;
        }
    }
    return YES;
}

-(void)dropdownMenu:(DropdownMenuViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex value:(NSString*)selectedValue {
    
    selectedValueFromPicker = selectedValue;
    
    for (SONewOrderItem *item in self.alreadyOrderedItemsArray) {
        
        if ([item.itemCode isEqualToString:selectedValueFromPicker]) {
            
            UIAlertController *duplicateItemActionSheet = [UIAlertController alertControllerWithTitle:@"Item code" message:@"This item is already added.\nPlease edit the existing item to make changes." preferredStyle:UIAlertControllerStyleAlert];
            [duplicateItemActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [duplicateItemActionSheet dismissViewControllerAnimated:true completion:nil];
            }]];
            
            [self presentViewController:duplicateItemActionSheet animated:YES completion:NULL];
            return;
        }
    }
    
    _itemCodeTextfield.text = selectedValue;
    
    ItemModel *selItem = _itemsArray[selectedIndex];
    selectedItemRate = selItem.imSaleRate;
    _itemRateTextfield.text = [Utility stringWithCurrencySymbolForValue:selectedItemRate forCurrencyCode:DEFAULT_CURRENCY_CODE];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideRightViewAnimated];
    });
    
    
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
