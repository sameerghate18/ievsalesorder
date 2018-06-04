//
//  DropdownMenuViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 08/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DropdownMenuViewControllerDelegate;

@interface DropdownMenuViewController : UIViewController

@property (nonatomic, strong) NSArray *items;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableview;
@property (nonatomic, unsafe_unretained) id<DropdownMenuViewControllerDelegate>delegate;

-(void)reloadFiltersTableView;

@end

@protocol DropdownMenuViewControllerDelegate <NSObject>

-(void)dropdownMenu:(DropdownMenuViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex;
-(void)dropdownMenu:(DropdownMenuViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex value:(NSString*)selectedValue;

@end
