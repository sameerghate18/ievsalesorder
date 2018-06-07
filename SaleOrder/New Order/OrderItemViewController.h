//
//  OrderItemViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 05/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SONewOrderItem.h"

typedef enum {
    ItemPopupTypeAdd,
    ItemPopupTypeEdit,
} ItemPopupType;

@protocol OrderItemViewControllerDelegate;

@interface OrderItemViewController: UIViewController

@property (nonatomic, unsafe_unretained) id<OrderItemViewControllerDelegate>delegate;
@property (nonatomic) ItemPopupType popupType;
@property (nonatomic, strong) NSArray *itemsForPicker, *itemsArray, *itemCodeArray, *alreadyOrderedItemsArray;

-(void)editOrderItem:(SONewOrderItem*)itemDetails;

@end

@protocol OrderItemViewControllerDelegate <NSObject>

-(void)itemDidUpdate:(SONewOrderItem*)updatedItem beforeEditItem:(SONewOrderItem*)beforeEditItem;
-(void)itemAdded:(SONewOrderItem*)newItem;

@end
