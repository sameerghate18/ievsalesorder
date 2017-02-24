//
//  OrderHistoryModel.h
//  SaleOrder
//
//  Created by Sameer Ghate on 11/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderHistoryModel : NSObject
@property (nonatomic, strong) NSString *ERRORMESSAGE;
//@property (nonatomic, strong) NSString *doc_date;
@property (nonatomic, strong) NSDate *doc_date;
@property (nonatomic, strong) NSString *doc_desc;
@property (nonatomic, strong) NSString *doc_no;
@property (nonatomic, strong) NSNumber *doc_taxs;
@property (nonatomic, strong) NSNumber *doc_type;
@property (nonatomic, strong) NSNumber *im_basic;
@property (nonatomic, strong) NSString *party_name;
@property (nonatomic, strong) NSNumber *seq_no;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *user_name;

+ (OrderHistoryModel*)dictionaryToModel:(NSDictionary*)dictionary;
+ (NSDictionary*)modelToDictionary:(OrderHistoryModel*)model;

@end
