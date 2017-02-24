//
//  OrderItemDetailsViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 10/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderHistoryModel.h"
#import "OrderHistoryDetailModel.h"

@interface OrderItemDetailsViewController : UIViewController

@property (nonatomic, strong) OrderHistoryModel *selectedOrderModel;
@property (nonatomic, strong) NSString *ORDER_ID;

@end
