//
//  SONewOrderItem.h
//  SaleOrder
//
//  Created by Sameer Ghate on 05/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SONewOrderItem : NSObject

@property (nonatomic, strong) NSString *itemCode;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *quantity;
@property (nonatomic) double amount;

+ (NSDictionary*)modelToDictionary:(SONewOrderItem*)model;
+ (NSString*)modelToString:(SONewOrderItem*)model;

@end
