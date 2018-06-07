//
//  FirstViewController.m
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import "FirstViewController.h"
#import "SONewOrderItem.h"
#import "DropdownMenuViewController.h"
#import "ConnectionHandler.h"
#import "AppDelegate.h"
#import "CustomTextInputViewController.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "OrderItemViewController.h"
#import "SOModels.h"

static NSString *dropdownIdentifier = @"dropdownIdentifier";
static NSString *textfieldIdentifer = @"textfieldIdentifer";
static NSString *submitIdentifer = @"submitIdentifer";
static NSString *newItemIdentifier = @"newItemIdentifier";
static NSString *noitemIdentifier = @"noitemIdentifier";

typedef enum {
    DropDownForDocSeries,
    DropDownForPartyNames,
    DropDownForIMLocation,
    DropDownForItemNames
} DropDownFor;

@implementation PCDropdownTableviewCell
@end

@implementation PCInputTableviewCell
@end


@implementation PCItemOrderTableviewCell

-(void)fillValues:(SONewOrderItem*)orderItem    {
    
    self.headerLabel.text = orderItem.itemCode;
    self.rateLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@", orderItem.rate] forCurrencyCode:@"INR"];
    self.qtyLabel.text = orderItem.quantity;

    self.amountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%.2f", orderItem.amount] forCurrencyCode:@"INR"];
}

@end


@interface FirstViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, DropdownMenuViewControllerDelegate, OrderItemViewControllerDelegate>
{
    NSString *selectedValueFromPicker, *selectedValueFromTextfield, *selectedDocSR, *selectedPartyName, *selectedItemRate;
    UIAlertController *actionSheet;
    NSMutableArray *orderItems;
    NSArray *itemsForPicker;
    double totalAmount;
    DocumentModel *selectedDocument;
    PartyModel *selectedParty;
    DropDownFor dropdownFor;
    UITextField *currentTextfield, *rateTextfield;
    NSInteger editItemIndex;
    
}
@property (nonatomic, strong) NSMutableArray *docSeriesArray, *partyNamesArray, *documentsArray, *itemsArray, *itemCodeArray;
@property (nonatomic, strong) IBOutlet UITableView *inputTableview;
@property (nonatomic, strong) IBOutlet UIView *pickerViewContainer;
@property (nonatomic, strong) IBOutlet UIPickerView *dataPickerView;
@property (nonatomic, strong) IBOutlet UILabel *totalAmountLabel;
@property (nonatomic, strong) IBOutlet UIButton *placeOrderButton;
@property (strong, nonatomic) id textValidationBlock;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    _placeOrderButton.backgroundColor = [UIColor lightGrayColor];
    [_placeOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _dataPickerView = [[UIPickerView alloc] init];
    _dataPickerView.dataSource = self;
    _dataPickerView.delegate = self;
    
    itemsForPicker = [[NSArray alloc] init];
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.rightViewSwipeGestureEnabled = FALSE;
    mainViewController.rootViewCoverColorForRightView= [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [self getDocSeries];
    totalAmount = 0;
    _totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@",[Utility stringWithCurrencySymbolForValue:@"0" forCurrencyCode:DEFAULT_CURRENCY_CODE]];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [currentTextfield resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)getDocSeries {
    
    [SVProgressHUD showWithStatus:@"Getting documents..."];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *urlstr = GET_DOC_SERIES(appDel.selectedCompany.CO_CD,appDel.loggedUser.USER_ID,kDefaultDocType)
    
    ConnectionHandler *docSeriesConn = [[ConnectionHandler alloc] init];
    
    
    [docSeriesConn fetchDataForPOSTURL:urlstr body:nil completion:^(id responseData, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error==nil) {
                
                if (!self.documentsArray) {
                    self.documentsArray = [[NSMutableArray alloc] init];
                }
                
                [self.documentsArray removeAllObjects];
                
                NSError *jsonerror = nil;
                NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
                
                for (NSDictionary *dict in array) {
                    
                    DocumentModel *aDoc = [DocumentModel dictionaryToModel:dict];
                    [self.documentsArray addObject:aDoc];
                }
            }
            
            [SVProgressHUD dismiss];
            
        });
        
    }];
}

-(void)getPartyNames    {
    
    if (!self.partyNamesArray) {
        self.partyNamesArray = [[NSMutableArray alloc] init];
    }
    [_partyNamesArray removeAllObjects];
    
    if (selectedDocument.partyModelsArray.count > 0) {
        [_partyNamesArray addObjectsFromArray:selectedDocument.partyModelsArray];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Getting parties..."];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *urlstr = GET_PARTY_URL(appDel.selectedCompany.CO_CD, kDefaultPartySt, kDefaultDocType, selectedDocument.documentSR);
    
    ConnectionHandler *partyConn = [[ConnectionHandler alloc] init];
    
    [partyConn fetchDataForPOSTURL:urlstr body:nil completion:^(id responseData, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error) {
                
                [_partyNamesArray removeAllObjects];
                
                NSError *jsonerror = nil;
                NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
                
                for (NSDictionary *dict in array) {
                    
                    PartyModel *aParty = [PartyModel dictionaryToModel:dict];
                    
                    [_partyNamesArray addObject:aParty];
                }
                [selectedDocument setPartyModelsArray:_partyNamesArray];
            }

            [SVProgressHUD dismiss];
        });
    }];
    
}

-(void)getItems    {
    
    if (!self.itemsArray) {
        self.itemsArray = [[NSMutableArray alloc] init];
    }
    [_itemsArray removeAllObjects];
    if (selectedParty.itemModelsArray > 0) {
        [_itemsArray addObjectsFromArray:selectedParty.itemModelsArray];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Getting items..."];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *urlstr = GET_ITEM_URL(appDel.selectedCompany.CO_CD, selectedDocument.documentSR, selectedParty.partyNumber, selectedDocument.imLocation);
    
    ConnectionHandler *itemConn = [[ConnectionHandler alloc] init];
    
    [itemConn fetchDataForPOSTURL:urlstr body:nil completion:^(id responseData, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (!error) {
                
                [_itemsArray removeAllObjects];
                
                NSError *jsonerror = nil;
                NSArray *itemsArr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
                
                for (NSDictionary *dict in itemsArr) {
                    
                    ItemModel *aParty = [ItemModel dictionaryToModel:dict];
                    
                    [_itemsArray addObject:aParty];
                }
                [selectedParty setItemModelsArray:_itemsArray];
            }
            [SVProgressHUD dismiss];
        });
    }];
    
}

-(IBAction)showNewItemSheet:(id)sender  {
    
    if (!selectedDocument || !selectedParty) {
        
        UIAlertController *msgActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Select document series and party name to add a new item." preferredStyle:UIAlertControllerStyleAlert];
        [msgActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }]];
        
        [self presentViewController:msgActionSheet animated:YES completion:NULL];
        
        return;
    }
    
    if (_itemsArray.count == 0) {
      
        UIAlertController *noItemActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"No items are available for the selected document and party name. Try choosing different values." preferredStyle:UIAlertControllerStyleAlert];
        [noItemActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }]];
        
        [self presentViewController:noItemActionSheet animated:YES completion:NULL];
        return;
    }
    
    // TODO: Replace with OrderViewController
    
    [self performSegueWithIdentifier:@"newItemSegue" sender:nil];
    /*
    UIAlertController *newItemAlert = [UIAlertController alertControllerWithTitle:@"Add a new item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [newItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Item code";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1000;
        textField.delegate = self;
    }];
    
    [newItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Rate";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        rateTextfield = textField;
        textField.tag = 1003;
        textField.delegate = self;
    }];
    
    [newItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Quantity";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1004;
        textField.delegate = self;
    }];
    
    __block BOOL shouldDismiss = YES;
    
    [newItemAlert addAction:[UIAlertAction actionWithTitle:@"Add item" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (UITextField *tf in newItemAlert.textFields) {
            if (tf.text.length == 0) {
                tf.text = @"Cannot be left blank";
                shouldDismiss = NO;
                return ;
            }
            selectedItemRate = rateTextfield.text;
        }
        
//        if (currentTextfield.text == nil) {
//            currentTextfield.text = @"Cannot be left blank";
//            return;
//        }
        
        SONewOrderItem *newItem = [[SONewOrderItem alloc] init];

        newItem.itemCode = selectedValueFromPicker;
        NSString *rateText = newItemAlert.textFields[1].text;
        
        NSString *rateStr = [selectedItemRate stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        newItem.rate = [rateStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        newItem.quantity = newItemAlert.textFields.lastObject.text;
        
        double rate = [newItem.rate doubleValue];
        double qty = [newItem.quantity doubleValue];
        double amount = rate*qty;
        
        newItem.amount = amount;
        
        [self addNewItem:newItem];
        
    }]];
    
    [newItemAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [newItemAlert dismissViewControllerAnimated:YES completion:NULL];
        
    }]];
    
    [self presentViewController:newItemAlert animated:YES completion:NULL];
    */
}

-(void)addNewItem:(SONewOrderItem*)orderItem    {
    
    if (!orderItems)
        orderItems = [[NSMutableArray alloc] init];
    [orderItems addObject:orderItem];
    
    [_inputTableview beginUpdates];
    [_inputTableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:orderItems.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [_inputTableview endUpdates];
    
    totalAmount += orderItem.amount;
    
    NSString *currencyStr = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%.2f", totalAmount] forCurrencyCode:DEFAULT_CURRENCY_CODE];
    self.totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@", currencyStr];
    
    _placeOrderButton.backgroundColor = [UIColor colorWithRed:0 green:0.513725 blue:0 alpha:1.0];
    [_placeOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField  {
    [textField resignFirstResponder];
    
    if (textField.tag == 1000) {
        textField.text = selectedValueFromPicker;
        return YES;
    }
    else if (textField.tag == 1001) {
        selectedDocSR = selectedDocument.documentSR;
        [self getPartyNames];
    }
    else if (textField.tag == 1002) {
        [self getItems];
    }
    else if (textField.tag == 1003) {
        selectedItemRate = textField.text;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string    {
    
    if (textField.tag == 1003) {
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    currentTextfield = nil;
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    
    if (textField.tag == 1000) {
        itemsForPicker = [_itemsArray valueForKey:@"imCode"];
        if (dropdownFor != DropDownForItemNames) {
            [_dataPickerView selectRow:0 inComponent:0 animated:YES];
        }
        dropdownFor = DropDownForItemNames;
//        textField.inputView = _dataPickerView;
    }
    else if (textField.tag == 1001) {
         itemsForPicker = [self.documentsArray valueForKey:@"docDescription"];
        
//        CustomTextInputViewController *input = [[CustomTextInputViewController alloc] initWithNibName:@"CustomTextInputViewController" bundle:[NSBundle mainBundle]];
//        input.items = itemsForPicker;
//        textField.inputView = input.view;
//        textField.inputAccessoryView = input.inputAccessory;
//        if (dropdownFor != DropDownForDocSeries) {
//            [_dataPickerView selectRow:0 inComponent:0 animated:YES];
//        }
        dropdownFor = DropDownForDocSeries;
//        textField.inputView = _dataPickerView;
    }
    else if (textField.tag == 1002) {
         itemsForPicker = [self.partyNamesArray valueForKey:@"partyName"];
//        if (dropdownFor != DropDownForPartyNames) {
//            [_dataPickerView selectRow:0 inComponent:0 animated:YES];
//        }
        dropdownFor = DropDownForPartyNames;
//        textField.inputView = _dataPickerView;
        
        if (!selectedDocument) {
            UIAlertController *msgActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Select document series first." preferredStyle:UIAlertControllerStyleAlert];
            [msgActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }]];
            
            [self presentViewController:msgActionSheet animated:YES completion:NULL];
            return NO;
        }
    }
//    [_dataPickerView reloadAllComponents];
        currentTextfield = textField;
    
    DropdownMenuViewController *destVC = (DropdownMenuViewController*)mainViewController.rightViewController;
    destVC.delegate = self;
    destVC.items = itemsForPicker;
    [destVC reloadFiltersTableView];
    
    [mainViewController showRightViewAnimated:nil];
    
//    [self performSegueWithIdentifier:@"newtodropdown" sender:itemsForPicker];
    return NO;
}


- (IBAction)deleteItemAction:(id)sender     {
    
    NSIndexPath *indexPath = (NSIndexPath*)sender;
    
    SONewOrderItem *itemToDelete = orderItems[indexPath.row];
    
    [_inputTableview beginUpdates];
    [orderItems removeObject:itemToDelete];
    [_inputTableview deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [_inputTableview endUpdates];
    
    totalAmount -= itemToDelete.amount;
    
    NSString *currencyStr = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%.2f", totalAmount] forCurrencyCode:DEFAULT_CURRENCY_CODE];
    self.totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@", currencyStr];
    
    if (orderItems.count == 0) {
        _placeOrderButton.backgroundColor = [UIColor lightGrayColor];
        [_placeOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

-(IBAction)editItemAction:(id)sender {
    
    NSIndexPath *indexPath = (NSIndexPath*)sender;
    editItemIndex = indexPath.row;
    SONewOrderItem *itemToEdit = orderItems[indexPath.row];
    double amountBefore = itemToEdit.amount;
    
    [self performSegueWithIdentifier:@"editItemSegue" sender:itemToEdit];
    
    /*
    
    UIAlertController *editItemAlert = [UIAlertController alertControllerWithTitle:@"Edit item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [editItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Item code";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1000;
        textField.delegate = self;
        textField.text = itemToEdit.itemCode;
    }];
    
    [editItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Rate";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        rateTextfield = textField;
        textField.tag = 1003;
        textField.delegate = self;
        textField.text = [Utility stringWithCurrencySymbolForValue:itemToEdit.rate forCurrencyCode:DEFAULT_CURRENCY_CODE];
    }];
    
    [editItemAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Quantity";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1004;
        textField.delegate = self;
        textField.text = itemToEdit.quantity;
    }];
    
    __block BOOL shouldDismiss = YES;
    
    [editItemAlert addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (UITextField *tf in editItemAlert.textFields) {
            if (tf.text.length == 0) {
                tf.text = @"Cannot be left blank";
                shouldDismiss = NO;
                return ;
            }
            selectedItemRate = rateTextfield.text;
        }
        
        itemToEdit.itemCode = selectedValueFromPicker;
        NSString *rateText = editItemAlert.textFields[1].text;
        
        NSString *rateStr = [selectedItemRate stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        itemToEdit.rate = [rateStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        itemToEdit.quantity = editItemAlert.textFields.lastObject.text;
        
        double rate = [itemToEdit.rate doubleValue];
        double qty = [itemToEdit.quantity doubleValue];
        double amount = rate*qty;
        
        itemToEdit.amount = amount;
        
        [orderItems replaceObjectAtIndex:indexPath.row withObject:itemToEdit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_inputTableview reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            
            totalAmount = totalAmount + (itemToEdit.amount - amountBefore);
            NSString *currencyStr = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%.2f", totalAmount] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            self.totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@", currencyStr];
        });
        
    }]];
     
        [editItemAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [editItemAlert dismissViewControllerAnimated:YES completion:NULL];
            
        }]];
        
        [self presentViewController:editItemAlert animated:YES completion:NULL];
     
     */
}

#pragma mark - UITableviewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    if (section == 0) {
        return 4;
    }
    else  {
        
//        if (orderItems.count == 0) {
//            return 1;
//        }
//        else    {
            return orderItems.count;
//        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    PCInputTableviewCell *inputCell = [tableView dequeueReusableCellWithIdentifier:textfieldIdentifer];
    PCDropdownTableviewCell *dropdownCell = [tableView dequeueReusableCellWithIdentifier:dropdownIdentifier];
    PCItemOrderTableviewCell *orderItemCell = [tableView dequeueReusableCellWithIdentifier:newItemIdentifier];
    UITableViewCell *noItemsCell = [tableView dequeueReusableCellWithIdentifier:noitemIdentifier];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0 :
                inputCell.headerLabel.text  =@"Document Series";
                inputCell.inputTextfield.tag = 1001;
                inputCell.dropdownImage.hidden = FALSE;
                inputCell.inputTextfield.text = selectedDocument.docDescription;
                inputCell.inputTextfield.delegate = self;
                return inputCell;
                
            case 1 :
                
                dropdownCell.headerLabel.text = @"Location : ";
                dropdownCell.valueLabel.text = selectedDocument.imLocation;
                dropdownCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dropdownCell.dropdownImage.hidden = TRUE;
                return dropdownCell;
                
                break;
                
            case 2 :

                inputCell.headerLabel.text  = @"Party Name";
                inputCell.inputTextfield.tag = 1002;
                inputCell.dropdownImage.hidden = FALSE;
                inputCell.inputTextfield.text = selectedParty.partyName;
                inputCell.inputTextfield.delegate = self;
                return inputCell;
                
                break;
                
            case 3 :
                
                dropdownCell.headerLabel.text = @"Party Code : ";
                dropdownCell.valueLabel.text = selectedParty.partyNumber;
                dropdownCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dropdownCell.dropdownImage.hidden = TRUE;
                
                return dropdownCell;
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section==1)  {
        
        if (orderItems.count == 0) {
            return noItemsCell;
        }
        
        orderItemCell.deleteBtn.tag = indexPath.row;
        orderItemCell.editBtn.tag = indexPath.row;
        orderItemCell.cellIndex = indexPath.row;
        NSLog(@"orderItemCell deleteBtn.tag - %ld, editBtn.tag - %ld", (long)indexPath.row, (long)indexPath.row);
        [orderItemCell fillValues:[orderItems objectAtIndex:indexPath.row]];
        
        return orderItemCell;
    }
    return dropdownCell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   {
    
    if (section == 1) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        headerLabel.text = @"Items in this order";
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor darkGrayColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        return _pickerViewContainer;
    }
    return _pickerViewContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section   {
     if (section == 1) {
         return 45;
     }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    float rowHeight = 0.0;
    
    if (indexPath.section == 0) {
        
        if ((indexPath.row == 0) || (indexPath.row == 2))  {
            rowHeight = 100.0;
        }
        else if ((indexPath.row == 1) || (indexPath.row == 3))  {
            rowHeight = 50.0;
        }
    }
    else if (indexPath.section == 1)    {
        
        if (orderItems.count == 0) {
            rowHeight = 76.0;
        }
        else    {
            rowHeight = 130.0;
        }
    }
    return rowHeight                                                      ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//        
//            dropdownFor = DropDownForDocSeries;
//            NSArray *objectsArray = [self.documentsArray valueForKey:@"docDescription"];
//            [self performSegueWithIdentifier:@"newtodropdown" sender:objectsArray];
//        }
//        else if (indexPath.row == 2)   {
//            
//            if (!selectedDocument) {
//                UIAlertController *msgActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Select document series first." preferredStyle:UIAlertControllerStyleAlert];
//                [msgActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [self dismissViewControllerAnimated:YES completion:NULL];
//                }]];
//                
//                [self presentViewController:msgActionSheet animated:YES completion:NULL];
//                return;
//            }
//            
//            dropdownFor = DropDownForPartyNames;
//            NSArray *objectsArray = [self.partyNamesArray valueForKey:@"partyName"];
//            [self performSegueWithIdentifier:@"newtodropdown" sender:objectsArray];
//        }
//    }
    
    if (indexPath.section == 1)    {
        
        if (orderItems.count == 0) {
        }
        else    {
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath   {
    
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (indexPath.section == 1) {
        
        UITableViewRowAction *editOption = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            [self editItemAction:indexPath];
            
        }];
        editOption.backgroundColor = [UIColor blueColor];
        
        UITableViewRowAction *deleteOption = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self deleteItemAction:indexPath];
        }];
        deleteOption.backgroundColor = [UIColor redColor];
        
        return @[deleteOption, editOption];
    }
    
    return nil;
}


#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender    {
    
    if ([segue.identifier isEqualToString:@"newtodropdown"]) {
        DropdownMenuViewController *destVC = segue.destinationViewController;
        destVC.delegate = self;
        destVC.items = (NSArray*)sender;
        destVC.title = @"Select a document series";
        self.definesPresentationContext = YES;
        destVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]; // can be with 'alpha'
        destVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    else if ([segue.identifier isEqualToString:@"newItemSegue"]) {
        OrderItemViewController *newItmeVC = segue.destinationViewController;
        newItmeVC.delegate = self;
        newItmeVC.popupType = ItemPopupTypeAdd;
        newItmeVC.itemsForPicker = [_itemsArray valueForKey:@"imCode"];
        newItmeVC.itemsArray = _itemsArray;
        newItmeVC.alreadyOrderedItemsArray = orderItems;
    }
    else if ([segue.identifier isEqualToString:@"editItemSegue"]) {
        OrderItemViewController *editItemVC = segue.destinationViewController;
        editItemVC.delegate = self;
        editItemVC.popupType = ItemPopupTypeEdit;
        editItemVC.itemsForPicker = [_itemsArray valueForKey:@"imCode"];
        editItemVC.itemsArray = _itemsArray;
        editItemVC.alreadyOrderedItemsArray = orderItems;
        SONewOrderItem *itemToEdit = (SONewOrderItem*)sender;
        [editItemVC editOrderItem:itemToEdit];
    }
}

-(void)presentDropdownMenu:(NSIndexPath*)selectedRow  {
    
    actionSheet = [UIAlertController alertControllerWithTitle:@"Select a value" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    actionSheet.view.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.pickerViewContainer.bounds];
    [self.pickerViewContainer addSubview:blurEffectView];
    
//    // Vibrancy effect
//    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
//    [vibrancyEffectView setFrame:self.pickerViewContainer.bounds];
//
//    [[blurEffectView contentView] addSubview:vibrancyEffectView];
    
    self.pickerViewContainer.frame = actionSheet.view.bounds;
    [actionSheet.view addSubview:self.pickerViewContainer];
    
    [self presentViewController:actionSheet animated:YES completion:^{
        
    }];
}

-(void)dropdownMenu:(DropdownMenuViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex value:(NSString*)selectedValue {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideLeftViewAnimated];
    });
    
     currentTextfield.text = selectedValue;
    
    switch (dropdownFor) {
        case DropDownForDocSeries:
            selectedDocument = self.documentsArray[selectedIndex];
            selectedDocSR = selectedDocument.documentSR;
            [self getPartyNames];
            selectedParty = nil;
            break;
            
        case DropDownForPartyNames:
            selectedParty = self.partyNamesArray[selectedIndex];
            [self getItems];
            break;
            
        case DropDownForItemNames:
        {
            ItemModel *selItem = _itemsArray[selectedIndex];
            selectedValueFromPicker = _itemCodeArray[selectedIndex];
            currentTextfield.text = selectedValueFromPicker;
            selectedItemRate = selItem.imSaleRate;
            rateTextfield.text = [Utility stringWithCurrencySymbolForValue:selectedItemRate forCurrencyCode:DEFAULT_CURRENCY_CODE];
        }
            break;
            
        default:
            break;
    }
    
    currentTextfield.text = selectedValueFromPicker = itemsForPicker[selectedIndex];
    
    [_inputTableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(IBAction)dismissActionSheet:(id)sender   {
    [actionSheet dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)doneSelectingValue:(id)sender  {
    [actionSheet dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIPickerViewDelegate

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
    
    switch (dropdownFor) {
        case DropDownForDocSeries:
            selectedDocument = self.documentsArray[row];
            selectedParty = nil;
            break;
            
        case DropDownForPartyNames:
            selectedParty = self.partyNamesArray[row];
            break;
            
        case DropDownForItemNames:
        {
            ItemModel *selItem = _itemsArray[row];
            selectedValueFromPicker = _itemCodeArray[row];
            currentTextfield.text = selectedValueFromPicker;
            selectedItemRate = selItem.imSaleRate;
            rateTextfield.text = [Utility stringWithCurrencySymbolForValue:selectedItemRate forCurrencyCode:DEFAULT_CURRENCY_CODE];
        }
            break;
            
        default:
            break;
    }
    
    currentTextfield.text = selectedValueFromPicker = itemsForPicker[row];
    
    [_inputTableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    tView.text = itemsForPicker[row];
    return tView;
}

#pragma mark -

-(IBAction)placeOrderAction:(id)sender  {
    
    if (orderItems.count == 0) {
        
        UIAlertController *noItemAlert = [UIAlertController alertControllerWithTitle:@"No items added in the order." message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [noItemAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [noItemAlert dismissViewControllerAnimated:YES completion:NULL];
            
        }]];
        
        [self presentViewController:noItemAlert animated:YES completion:NULL];
        
        return;
    }
    
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Confirm Order Submit" message:@"Are you sure you want to submit the order?" preferredStyle:UIAlertControllerStyleAlert];
    
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [confirmAlert dismissViewControllerAnimated:false completion:nil];
    }]];
    
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Place order" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self initiateOrderSubmission];
    }]];
    
    [self presentViewController:confirmAlert animated:YES completion:NULL];
}

- (void)initiateOrderSubmission  {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSMutableString *itemsString = [[NSMutableString alloc] initWithString:@"["];
    
    for (SONewOrderItem *item in orderItems) {
        
        NSString *str = [SONewOrderItem modelToString:item];
        
        [itemsString appendString:str];
        [itemsString appendString:@","];
    }
    
    [itemsString replaceCharactersInRange:NSMakeRange(itemsString.length-1, 1) withString:@""];
    [itemsString appendString:@"]"];
    
    NSString *param = [itemsString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    param = [param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *urlString = GET_SUBMIT_ORDER_URL(appDel.baseURL, appDel.selectedCompany.CO_CD,appDel.loggedUser.USER_ID,kDefaultDocType,selectedDocument.documentSR,selectedDocument.imLocation,selectedParty.partyNumber,param,[defaults valueForKey:kPhoneNumber]);
    
    ConnectionHandler *postOrder = [[ConnectionHandler alloc] init];
    
    [SVProgressHUD showWithStatus:@"Placing order..."];
    
    [postOrder fetchDataForPOSTURLwithStringOutput:urlString completion:^(NSData *responseData, NSError *error) {
        
        if (error)  {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                UIAlertController *orderError = [UIAlertController alertControllerWithTitle:@"Submit Order" message:@"There was a problem submitting this order.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                [orderError addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil]];
                [self presentViewController:orderError animated:YES completion:NULL];
            });
            return ;
        }
        
        NSString *opStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Place order output - %@", opStr);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD showSuccessWithStatus:@"Order Placed"];
            
            UIAlertController *orderError = [UIAlertController alertControllerWithTitle:@"Submit Order" message:opStr preferredStyle:UIAlertControllerStyleAlert];
            
            [orderError addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //                    dispatch_async(dispatch_get_main_queue(), ^{
                [self clearFields];
                //                    });
                
                [orderError dismissViewControllerAnimated:YES completion:^{
                }];
            }]];
            
            [self presentViewController:orderError animated:YES completion:NULL];
        });
    }];
}

-(IBAction)clearAllAction:(id)sender    {
    
    UIAlertController *confirmResetAlert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to reset the current order?" preferredStyle:UIAlertControllerStyleAlert];
    
    [confirmResetAlert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [confirmResetAlert dismissViewControllerAnimated:YES completion:^{
            //            dispatch_async(dispatch_get_main_queue(), ^{
            
            //            });
        }];
        [self clearFields];
    }]];
    
    [confirmResetAlert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:NULL];
        });
    }]];
    
    [self presentViewController:confirmResetAlert animated:YES completion:NULL];
}

- (void)clearFields {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _placeOrderButton.backgroundColor = [UIColor lightGrayColor];
        [_placeOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        selectedValueFromTextfield = @"";
        selectedDocument = nil;
        selectedParty = nil;
        totalAmount = 0;
        _totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@",[Utility stringWithCurrencySymbolForValue:@"0" forCurrencyCode:DEFAULT_CURRENCY_CODE]];
        [orderItems removeAllObjects];
        [_inputTableview reloadData];
    });
}

-(void)itemDidUpdate:(SONewOrderItem*)updatedItem beforeEditItem:(SONewOrderItem*)beforeEditItem {
    
    SONewOrderItem *beforeUpdate = [orderItems objectAtIndex:editItemIndex];
    
    [orderItems replaceObjectAtIndex:editItemIndex withObject:updatedItem];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_inputTableview reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        double amountBefore = beforeUpdate.amount;
        totalAmount = totalAmount + (updatedItem.amount - amountBefore);
        NSString *currencyStr = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%.2f", totalAmount] forCurrencyCode:DEFAULT_CURRENCY_CODE];
        self.totalAmountLabel.text = [NSString stringWithFormat:@"Total: %@", currencyStr];
    });
    
}

-(void)itemAdded:(SONewOrderItem*)newItem {
    [self addNewItem:newItem];
}

@end
