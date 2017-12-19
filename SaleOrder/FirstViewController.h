//
//  FirstViewController.h
//  SaleOrder
//
//  Created by Sameer Ghate on 09/05/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SONewOrderItem.h"

@interface PCDropdownTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueLabel;
@property (nonatomic, retain) IBOutlet UIImageView *dropdownImage;

@end

@interface PCInputTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UITextField *inputTextfield;
@property (nonatomic, retain) IBOutlet UIImageView *dropdownImage;

@end

//newItemIdentifier

@interface PCItemOrderTableviewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *rateLabel;
@property (nonatomic, retain) IBOutlet UILabel *qtyLabel;
@property (nonatomic, retain) IBOutlet UILabel *amountLabel;
@property (nonatomic, retain) IBOutlet UIButton *deleteBtn;
@property (nonatomic, retain) IBOutlet UIButton *editBtn;
@property (nonatomic) NSInteger cellIndex;

-(void)fillValues:(SONewOrderItem*)orderItem;

@end

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

@interface FirstViewController : UIViewController


@end

