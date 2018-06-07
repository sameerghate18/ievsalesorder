//
//  FirstViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SONewOrderItem.h"

@interface PCDropdownTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueLabel;
@property (nonatomic, retain) IBOutlet UIImageView *dropdownImage;

@end

@interface PCInputTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UITextField *inputTextfield;
@property (nonatomic, retain) IBOutlet UIImageView *dropdownImage;

@end

//newItemIdentifier

@interface PCItemOrderTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *rateLabel;
@property (nonatomic, retain) IBOutlet UILabel *qtyLabel;
@property (nonatomic, retain) IBOutlet UILabel *amountLabel;
@property (nonatomic, retain) IBOutlet UIButton *deleteBtn;
@property (nonatomic, retain) IBOutlet UIButton *editBtn;
@property (nonatomic) NSInteger cellIndex;

-(void)fillValues:(SONewOrderItem*)orderItem;

@end


@interface FirstViewController : UIViewController


@end

