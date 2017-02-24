//
//  SearchCriteriaModel.h
//  SaleOrder
//
//  Created by Sameer Ghate on 16/02/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchCriteriaModel : NSObject

@property (nonatomic, strong) NSString *docDescription;
@property (nonatomic, strong) NSString *partyName;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end
