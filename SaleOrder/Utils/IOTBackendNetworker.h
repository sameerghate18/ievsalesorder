//
//  IOTBackendNetworker.h
//  IoT-PoC-iOS
//
//  Created by vispl on 4/14/16.
//  Copyright © 2016 vispl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IOTProducts;

typedef void (^operationSuccessBlock)(NSData* data);
typedef void (^arrayOutputBlock)(NSArray* outputArray);
typedef void (^dictionaryOutputBlock)(NSDictionary* outputDictionary);

typedef void (^operationFailureBlock)(NSError* error);

@interface IOTBackendNetworker : NSObject

+(id)singletonInstance;

-(void)performOpenIdAuthentication:(operationSuccessBlock)successBlock failure:(operationFailureBlock)failureBlock;
-(void)performSeamlessID:(operationSuccessBlock)successBlock failure:(operationFailureBlock)failureBlock;
-(void)performQRLoginForQRCode:(NSString*)string  success:(dictionaryOutputBlock)successBlock failure:(operationFailureBlock)failureBlock;

-(void)GETDeviceList:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock ;
-(void)GETUsersList:(arrayOutputBlock)output failure:(operationFailureBlock)failureBlock;
-(void)checkForAuthentication:(void (^)(BOOL boolOp))completionBlock failure:(operationFailureBlock)failureBlock;

-(void)GETRegisteredProducts:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock;
-(void)GETUnregisteredProducts:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock;
-(void)registerProduct:(IOTProducts*)freshProduct withCompletionBlock:(operationFailureBlock)completion;
-(void)purchasePlanForProductWithId:(NSString*)productId planId:(NSString*)planId completionBlock:(operationSuccessBlock) outputBlock failure:(operationFailureBlock)failureBlock;
@end
