//
//  SOModels.h
//  SaleOrder
//
//  Created by Sameer Ghate on 07/06/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentModel : NSObject

@property (nonatomic, strong) NSString *docDescription;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *imLocation;
@property (nonatomic, strong) NSString *documentSR;

@property (nonatomic, strong) NSArray *partyModelsArray;

+ (DocumentModel*)dictionaryToModel:(NSDictionary*)dictionary;

@end

@interface PartyModel : NSObject

@property (nonatomic, strong) NSString *partyName;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *partyNumber;

@property (nonatomic, strong) NSArray *itemModelsArray;

+ (PartyModel*)dictionaryToModel:(NSDictionary*)dictionary;

@end

@interface ItemModel : NSObject

@property (nonatomic, strong) NSString *imCode;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *imDescription;
@property (nonatomic, strong) NSString *imSaleRate;

+ (ItemModel*)dictionaryToModel:(NSDictionary*)dictionary;
+ (NSDictionary*)modelToDictionary:(ItemModel*)itemModel;

@end

