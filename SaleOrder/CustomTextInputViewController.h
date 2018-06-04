//
//  CustomTextInputViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 30/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTextInputViewControllerDelegate;

@interface CustomTextInputViewController : UIViewController

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) IBOutlet UIToolbar *inputAccessory;
@property (nonatomic, unsafe_unretained) id<CustomTextInputViewControllerDelegate>delegate;
@end

@protocol CustomTextInputViewControllerDelegate <NSObject>

-(void)dropdownMenu:(CustomTextInputViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex;
-(void)dropdownMenu:(CustomTextInputViewController*)dropdown selectedItemIndex:(NSInteger)selectedIndex value:(NSString*)selectedValue;

@end
