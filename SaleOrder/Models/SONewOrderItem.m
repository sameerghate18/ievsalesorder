//
//  SONewOrderItem.m
//  SaleOrder
//
//  Created by Sameer Ghate on 05/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "SONewOrderItem.h"

@implementation SONewOrderItem

+ (NSDictionary*)modelToDictionary:(SONewOrderItem*)model   {

    NSDictionary *aDcit = @{@"item_code":model.itemCode,
                            @"item_rate":model.rate,
                            @"item_qty":model.quantity
                            };
    return aDcit;
}

+ (NSString*)modelToString:(SONewOrderItem*)model   {
    NSString *str = [[NSString alloc] initWithFormat:@"{\"item_code\":\"%@\",\"item_rate\":\"%@\",\"item_qty\":%@}",model.itemCode,model.rate,model.quantity];
    return str;
}
@end
