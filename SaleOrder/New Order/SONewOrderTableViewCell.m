//
//  SONewOrderTableViewCell.m
//  SaleOrder
//
//  Created by Sameer Ghate on 30/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import "SONewOrderTableViewCell.h"

@implementation SONewOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setCellTitle:(NSString *)cellTitle {
    [self.blankViewButton setTitle:cellTitle forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)editButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(parameterCell:didPressEditButton:)]) {
        [_delegate parameterCell:self didPressEditButton:self.editButton];
    }
}

-(IBAction)blankViewButtonPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(parameterCell:didPressEditButton:)]) {
        [_delegate parameterCell:self didPressEditButton:self.editButton];
        self.editButton.tag =  self.blankViewButton.tag;
//        [self.blankView setHidden:YES];
    }
}

@end
