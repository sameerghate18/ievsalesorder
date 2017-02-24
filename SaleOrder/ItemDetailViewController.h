//
//  ItemDetailViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 11/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderHistoryDetailModel.h"

@interface ItemDetailViewController : UITableViewController

@property (nonatomic, strong) OrderHistoryDetailModel *selectedHistoryItem;

@end
