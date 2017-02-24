//
//  OrderHistoryModel.m
//  SaleOrder
//
//  Created by Sameer Ghate on 11/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "OrderHistoryModel.h"

@implementation OrderHistoryModel

+ (OrderHistoryModel*)dictionaryToModel:(NSDictionary*)dictionary   {
    
    OrderHistoryModel *model = [[OrderHistoryModel alloc] init];

    model.ERRORMESSAGE = [dictionary valueForKey:@"ERRORMESSAGE"];
    model.doc_date = [Utility dateFromInputString:[dictionary valueForKey:@"doc_date"]];
    model.doc_desc = [[dictionary valueForKey:@"doc_desc"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    model.doc_no = [[dictionary valueForKey:@"doc_no"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.doc_taxs = [NSNumber numberWithDouble:[[dictionary valueForKey:@"doc_taxs"] doubleValue]];
    model.doc_type = [NSNumber numberWithDouble:[[dictionary valueForKey:@"doc_type"] doubleValue]];
    model.im_basic = [NSNumber numberWithDouble:[[dictionary valueForKey:@"im_basic"] doubleValue]];
    model.party_name = [[dictionary valueForKey:@"party_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.seq_no = [NSNumber numberWithDouble:[[dictionary valueForKey:@"seq_no"] doubleValue]];
    model.status = [[dictionary valueForKey:@"status"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.user_name = [[dictionary valueForKey:@"user_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return model;
}

+ (NSDictionary*)modelToDictionary:(OrderHistoryModel*)model    {
    return nil;
}

@end
