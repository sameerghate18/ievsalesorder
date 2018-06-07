//
//  SOModels.m
//  SaleOrder
//
//  Created by Sameer Ghate on 07/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import "SOModels.h"

@implementation DocumentModel

+ (DocumentModel*)dictionaryToModel:(NSDictionary*)dictionary   {
    
    DocumentModel *model = [[DocumentModel alloc] init];
    model.docDescription = [[dictionary valueForKey:@"DOC_DESCR"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.errorMessage = [dictionary valueForKey:@"ERRORMESSAGE"];
    model.imLocation = [[dictionary valueForKey:@"IM_LOC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.documentSR = [[dictionary valueForKey:@"SR"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return model;
}
@end

@implementation PartyModel

+ (PartyModel*)dictionaryToModel:(NSDictionary*)dictionary  {
    
    PartyModel *model = [[PartyModel alloc] init];
    model.partyName = [[dictionary valueForKey:@"PARTY_NAME"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    model.errorMessage = [dictionary valueForKey:@"ERRORMESSAGE"];
    model.partyNumber = [[dictionary valueForKey:@"PARTY_NO"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return model;
    
}

@end

@implementation ItemModel

+ (ItemModel*)dictionaryToModel:(NSDictionary*)dictionary {
    
    ItemModel *model = [[ItemModel alloc] init];
    model.imCode = [dictionary valueForKey:@"IM_CODE"];
    model.errorMessage = [dictionary valueForKey:@"ERRORMESSAGE"];
    model.imDescription = [dictionary valueForKey:@"IM_DESCR"];
    model.imSaleRate = [dictionary valueForKey:@"IM_SALERT"];
    return model;
    
}


@end

