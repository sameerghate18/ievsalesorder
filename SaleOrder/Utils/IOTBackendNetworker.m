//
//  IOTBackendNetworker.m
//  IoT-PoC-iOS
//
//  Created by vispl on 4/14/16.
//  Copyright © 2016 vispl. All rights reserved.
//

#import "IOTBackendNetworker.h"
#import "AFNetworking.h"
//#import "UIKit+AFNetworking.h"

typedef enum {
    GET_REQUEST_FOR_DEVICE_LIST = 0,
    GET_REQUEST_FOR_AUTHENTICATION,
    GET_OPENID_AUTHENTICATION,
    GET_SEAMLESS_ID,
    GET_REGISTERED_PRODUCTS,
    GET_UNREGISTERED_PRODUCTS,
    POST_REGISTER_PRODUCT,
    GET_PRODUCT_PURCHASE_PLAN
} RequestType;

typedef void (^GeneralOutputBlock)(id output);

static IOTBackendNetworker *staticInstance = nil;
static AFHTTPSessionManager *httpSessionManger = nil;

@interface IOTBackendNetworker ()
{
    RequestType type;
    operationSuccessBlock globalSuccessBlock;
    operationFailureBlock globalFailureBlock;
}

@property (nonatomic, strong) NSString *seamlessToken;
@end

@implementation IOTBackendNetworker

+(id)singletonInstance   {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[IOTBackendNetworker alloc] init];
        NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultConfiguration.HTTPShouldSetCookies = YES;
        defaultConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        defaultConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        defaultConfiguration.URLCache = [NSURLCache sharedURLCache];
        httpSessionManger = [[AFHTTPSessionManager manager] initWithSessionConfiguration:defaultConfiguration];
    });
    
    return staticInstance;
}

-(void)performOpenIdAuthentication:(operationSuccessBlock)successBlock failure:(operationFailureBlock)failureBlock    {
    
    type = GET_OPENID_AUTHENTICATION;
    
    globalSuccessBlock = successBlock;
    globalFailureBlock = failureBlock;
    NSURLRequest *urlRequest = [self requestObjectForRequestType:type];
    [self beginOperation:urlRequest output:^(id output) {
        
        [self performSeamlessID:^(NSData *data) {
            globalSuccessBlock(data);
        } failure:^(NSError *error) {
            globalFailureBlock(error);
        }];
    } failure:^(NSError *error) {
        globalFailureBlock(error);
    }];
}

-(void)performSeamlessID:(operationSuccessBlock)successBlock failure:(operationFailureBlock)failureBlock    {
    
    type = GET_SEAMLESS_ID;
    NSURLRequest *urlRequest = [self requestObjectForRequestType:type];
    [self beginOperation:urlRequest output:^(id output) {
        successBlock(output);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

-(void)checkForAuthentication:(void (^)(BOOL boolOp))completionBlock failure:(operationFailureBlock)failureBlock    {
    
    type = GET_REQUEST_FOR_AUTHENTICATION;
    NSURLRequest *urlRequest = [self requestObjectForRequestType:type];
    [self beginOperation:urlRequest output:^(id output) {
        completionBlock(YES);
    } failure:^(NSError *error) {
        failureBlock (NO);
    }];
}

-(void)GETDeviceList:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock    {
    
    type = GET_REQUEST_FOR_DEVICE_LIST;
    [self beginOperation:GET_REQUEST_FOR_DEVICE_LIST output:^(id output) {
        outputBlock(output);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

-(void)GETRegisteredProducts:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock    {
    type = GET_REGISTERED_PRODUCTS;
    NSURLRequest *urlRequest = [self requestObjectForRequestType:type];
    [self beginOperation:urlRequest output:^(id output) {
        outputBlock(output);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

-(void)GETUnregisteredProducts:(arrayOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock    {
    type = GET_UNREGISTERED_PRODUCTS;
    NSURLRequest *urlRequest = [self requestObjectForRequestType:type];
    
    [self beginOperation:urlRequest output:^(id output) {
        outputBlock(output);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

-(void)purchasePlanForProductWithId:(NSString*)productId planId:(NSString*)planId completionBlock:(operationSuccessBlock) outputBlock failure:(operationFailureBlock)failureBlock    {
    type = GET_PRODUCT_PURCHASE_PLAN;
    NSMutableURLRequest *urlRequest = [self requestObjectForRequestType:type];
    
    NSString *urlstr ;//= //[NSString stringWithFormat:@"%@/api/product/purchase/%@/plan/%@",API_BASE_URL,productId,planId];
    NSURL *url = [[NSURL alloc] initWithString:[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setURL:url];
    
    [self beginOperation:urlRequest output:^(id output) {
        outputBlock(output);
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

-(void)GETUsersList:(arrayOutputBlock)output failure:(operationFailureBlock)failureBlock  {
    
    
}

-(void)registerProduct:(IOTProducts*)freshProduct withCompletionBlock:(operationFailureBlock)completion     {
    type = POST_REGISTER_PRODUCT;
    NSDictionary *dic;// = //[freshProduct dictionaryRepresentation];
    NSError *err = nil;
    NSData *dataToSend = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err==nil) {
        NSURLRequest *req = [self requestObjectForType:type POSTdata:dataToSend];
        [self beginOperation:req output:^(id output) {
            completion(nil);
        } failure:^(NSError *error) {
            completion(error);
        }];
    }
}

-(void)beginOperation:(NSURLRequest*)urlRequest output:(GeneralOutputBlock)outputBlock failure:(operationFailureBlock)failureBlock    {
    
    httpSessionManger.requestSerializer.HTTPShouldHandleCookies = YES;
    
    NSLog(@"GET: %@", urlRequest.URL.absoluteString);
    NSLog(@"REQUEST Headers for %@: \n%@", urlRequest.URL, urlRequest.allHTTPHeaderFields);
    NSString *dataString = [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"REQUEST Body: %@",dataString);
    
    NSURLSessionDataTask *dataTask = [httpSessionManger dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
        
        NSLog(@"RESPONSE Headers for %@: \n%@",resp.URL.absoluteString, resp.allHeaderFields);
        NSLog(@"RESPONSE: %@", responseObject);
        
        if (!error) {
            
            if (resp.statusCode == 200) {
                outputBlock(responseObject);
            }
            else {
                failureBlock(error);
            }
        }
        else {
            failureBlock(error);
        }
    }];
    
    [dataTask resume];
}

-(NSMutableURLRequest*)requestObjectForRequestType:(RequestType)requestType  {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@""] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800.0];
    NSURL *url;
    
    switch (requestType) {
        case GET_REQUEST_FOR_AUTHENTICATION:
        {
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",API_BASE_URL, GET_USER_AUTHENTICATED];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_REQUEST_FOR_DEVICE_LIST:
        {
            httpSessionManger.requestSerializer = [AFHTTPRequestSerializer serializer];
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",API_BASE_URL, GET_DEVICES];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_SEAMLESS_ID:
        {
            httpSessionManger.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",LOGIN_BASE_URL, SEAMLESS_ID_LOGIN];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_OPENID_AUTHENTICATION:
        {
            NSString *encodedIdentifier;// = [LOGIN_BASE_URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//            NSString *urlstr = [NSString stringWithFormat:@"%@/openid_connect_login?identifier=%@&seamless_id_token=%@",API_BASE_URL, encodedIdentifier,self.seamlessToken];
            
            NSString *urlstr;// = OPENID_LOGIN(API_BASE_URL, encodedIdentifier, self.seamlessToken);

            httpSessionManger.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_REGISTERED_PRODUCTS:
        {
            httpSessionManger.requestSerializer = [AFHTTPRequestSerializer serializer];
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",API_BASE_URL, GET_PRODUCT_REGISTERED];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_UNREGISTERED_PRODUCTS:
        {
            httpSessionManger.requestSerializer = [AFHTTPRequestSerializer serializer];
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",API_BASE_URL, GET_PRODUCT_UNREGISTERED];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        case GET_PRODUCT_PURCHASE_PLAN :
        {
            httpSessionManger.requestSerializer = [AFHTTPRequestSerializer serializer];
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
//            NSString *urlstr = [NSString stringWithFormat:@"%@%@",API_BASE_URL, PURCHASE_PRODUCT_PLAN];
//            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        default:
            break;
    }

    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    [urlRequest setURL:url];
    
    return urlRequest;
}

-(NSURLRequest*)requestObjectForType:(RequestType)reqtype POSTdata:(NSData*)data  {
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@""] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800.0];
    NSURL *url;
    
    switch (reqtype) {
        case POST_REGISTER_PRODUCT:
        {
            httpSessionManger.requestSerializer = [AFJSONRequestSerializer serializer];
            httpSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSString *urlstr;// = [NSString stringWithFormat:@"%@%@",API_BASE_URL, POST_CREATE_PRODUCT];
            url = [NSURL URLWithString:urlstr];
        }
            break;
            
        default:
            break;
    }
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPShouldHandleCookies:YES];
    [urlRequest setURL:url];
    
    return urlRequest;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error  {
    NSLog(@"didCompleteWithError");
}


@end
