//
//  SONewOrderTableViewCell.h
//  SaleOrder
//
//  Created by Sameer Ghate on 30/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SONewOrderTableViewCellDelegate;

@interface SONewOrderTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *parameter1TitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *parameter1ValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *parameter2TitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *parameter2ValueLabel;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *blankViewButton;
@property (nonatomic, strong) IBOutlet UIView *blankView;
@property (nonatomic, strong) NSString *cellTitle;
@property (nonatomic, unsafe_unretained) id<SONewOrderTableViewCellDelegate>delegate;

@end

@protocol SONewOrderTableViewCellDelegate <NSObject>

-(void)parameterCell:(SONewOrderTableViewCell*)cell didPressEditButton:(UIButton*)editButton;

@end
