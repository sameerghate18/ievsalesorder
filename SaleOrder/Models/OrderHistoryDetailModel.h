//
//  OrderHistoryDetailModel.h
//  SaleOrder
//
//  Created by Sameer Ghate on 14/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderHistoryDetailModel : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *dborcr;
@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSString *doc_ref;
@property (nonatomic, strong) NSString *im_lot;
@property (nonatomic, strong) NSNumber *line_taxes;
@property (nonatomic, strong) NSString *party_name;
@property (nonatomic, strong) NSNumber *qty;
@property (nonatomic, strong) NSNumber *rate;
@property (nonatomic, strong) NSString *rdoc_no;
@property (nonatomic, strong) NSString *rdoc_type;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSNumber *value;

+ (OrderHistoryDetailModel*)dictionaryToModel:(NSDictionary*)dictionary;

@end
