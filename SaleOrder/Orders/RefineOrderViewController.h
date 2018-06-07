//
//  RefineOrderViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 16/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCriteriaModel.h"

@protocol RefineOrderViewControllerDelegate;

@interface RefineOrderViewController : UIViewController

@property (nonatomic, unsafe_unretained) id <RefineOrderViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *items;

@end

@protocol RefineOrderViewControllerDelegate <NSObject>

- (void)searchController:(RefineOrderViewController*)controller searchCriteria:(SearchCriteriaModel*)searchModel;
- (void)searchControllerSearchAll:(RefineOrderViewController *)searchController;
- (void)searchControllerClearAll:(RefineOrderViewController *)searchController;

@end
