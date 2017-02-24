//
//  OrderHistoryDetailModel.m
//  SaleOrder
//
//  Created by Sameer Ghate on 14/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "OrderHistoryDetailModel.h"

@implementation OrderHistoryDetailModel

+ (OrderHistoryDetailModel*)dictionaryToModel:(NSDictionary*)dictionary {
    
    OrderHistoryDetailModel *model = [[OrderHistoryDetailModel alloc] init];
    
    model.code = [dictionary valueForKey:@"code"];
    model.dborcr = [dictionary valueForKey:@"dborcr"];
    model.descr = [dictionary valueForKey:@"descr"];
    model.doc_ref = [dictionary valueForKey:@"doc_ref"];
    model.im_lot = [dictionary valueForKey:@"im_lot"];
    model.line_taxes = [NSNumber numberWithDouble:[[dictionary valueForKey:@"line_taxes"] doubleValue]];
    model.party_name = [dictionary valueForKey:@"party_name"];
    model.qty = [NSNumber numberWithDouble:[[dictionary valueForKey:@"qty"] doubleValue]];
    model.rdoc_no = [dictionary valueForKey:@"rdoc_no"];
    model.rdoc_type = [dictionary valueForKey:@"rdoc_type"];
    model.total = [NSNumber numberWithDouble:[[dictionary valueForKey:@"total"] doubleValue]];
    model.value = [NSNumber numberWithDouble:[[dictionary valueForKey:@"value"] doubleValue]];
    model.rate = [NSNumber numberWithDouble:[[dictionary valueForKey:@"rate"] doubleValue]];
    
    return model;
    
}

@end
