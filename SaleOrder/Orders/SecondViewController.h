//
//  SecondViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderHistoryModel.h"

@interface SecondViewController : UIViewController

@end

@interface OrderHistoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *itemLabel;
@property (nonatomic, strong) IBOutlet UILabel *orderDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *partyNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (void)fillValuesAndStatus:(OrderHistoryModel*)singleOrder;

@end

