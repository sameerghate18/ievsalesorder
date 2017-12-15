//
//  ConnectionHandler.m
//  ERPMobile
//
//  Created by Sameer Ghate on 31/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "ConnectionHandler.h"
#import "Reachability.h"

@implementation ConnectionHandler

-(void)fetchDataForURL:(NSString*)urlString body:(NSDictionary*)bodyParams completion:(void(^)(NSData *responseData, NSError *error))completionBlock
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] != NotReachable ) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
        [configuration setRequestCachePolicy:NSURLRequestUseProtocolCachePolicy];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completionBlock) {
                    completionBlock(data,error);
                }
                
                
                if ( resp.statusCode == 200) {
                    
                    if ([_delegate respondsToSelector:@selector(connectionHandler:didRecieveData:)]) {
                        [_delegate connectionHandler:self didRecieveData:data];
                    }
                }
                else    {
                    if ([_delegate respondsToSelector:@selector(connectionHandler:errorRecievingData:)]) {
                        [_delegate connectionHandler:self errorRecievingData:error];
                    }
                }
            });
        }];
        
        //        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request uploadProgress:NULL downloadProgress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //
        //
        //        }];
        
        [dataTask resume];
    }
}

- (void)fetchDataForPOSTURL:(NSString*)urlString body:(NSDictionary*)bodyParams completion:(void(^)(id responseData, NSError *error))completionBlock   {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] != NotReachable ) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800];
        request.HTTPMethod = @"POST";
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
        [configuration setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            completionBlock(data,error);
        }];
        [dataTask resume];
    }
}

- (void)fetchDataForPOSTURLwithStringOutput:(NSString*)urlString completion:(void(^)(NSData *responseData, NSError *error))completionBlock   {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] != NotReachable ) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
        [configuration setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800];
        request.HTTPMethod = khttp_Method_POST;
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (completionBlock) {
                    completionBlock(data,error);
                }
                
            });
        }];
        
        [dataTask resume];
    }
}

- (void)submitOrderToURL:(NSString*)urlString body:(NSDictionary*)bodyParams completion:(void(^)(id responseData, NSError *error))completionBlock   {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] != NotReachable ) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
        [configuration setRequestCachePolicy:NSURLRequestUseProtocolCachePolicy];
        
        AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800];
        request.HTTPMethod = khttp_Method_POST;
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request uploadProgress:NULL downloadProgress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionBlock(responseObject,error);
                
            });
        }];
        
        [dataTask resume];
    }
}

@end
