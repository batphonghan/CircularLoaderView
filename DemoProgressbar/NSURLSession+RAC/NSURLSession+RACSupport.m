//
//  NSURLSession+RACSupport.m
//  Alaska
//
//  Created by woi on 6/13/17.
//  Copyright © 2017 BlackBerry Inc. All rights reserved.
//

#import "NSURLSession+RACSupport.h"

#define MAX_RETRY 5
#define RETRY_INTERVAL_INCREMENTAL 5
#define INITIAL_INTERVAL 0.000001

@implementation NSURLSession (RACSupport)

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
{
    return [NSURLSession rac_retriableDataTaskWithRequest:request delegate:nil];
}

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
{
    return [NSURLSession rac_retriableDataTaskWithRequest:request
                                                 delegate:delegate
                                      reAuthenticateBlock:nil];
}

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                          isNeedReauthenticateForStatusCode:(NSArray<NSNumber *> *) statusCodes
                                        reAuthenticateBlock:(void(^)(void))reAuthenticateBlock {
    __block NSTimeInterval delayInterval = INITIAL_INTERVAL;
    
    return [[[[[[[RACSignal return:nil]
                 flattenMap:^RACSignal *(id value) {
                     return [[RACSignal interval:delayInterval onScheduler:[RACScheduler currentScheduler]]
                             take:1];
                 }]
                flattenMap:^RACSignal *(NSDate *value) {
                    return [NSURLSession rac_dataTaskWithRequest:request delegate:delegate];
                }]
               flattenMap:^RACSignal<RACTuple *> *(RACTuple* tuple) {
                   NSHTTPURLResponse *response = tuple.first;
                   if([statusCodes containsObject:[NSNumber numberWithInteger:response.statusCode]]) {
                       NSLog(@"%ld %@", (long)response.statusCode,
                                  response.URL.absoluteString);
                       NSData *data = tuple.second;
                       NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                       
                       return [RACSignal error:error];
                   }
                   return [RACSignal return:tuple];
               }]
              doError:^(NSError *error) {
                  delayInterval += RETRY_INTERVAL_INCREMENTAL;
                  
                  if ([NSURLSession isAuthenticationFailError:error] && reAuthenticateBlock) {
                      reAuthenticateBlock();
                  }
                  
                  NSLog(@"error requesting %@.\nError: %@.\nRetrying in %f s",
                              request, error, delayInterval);
              }]
             retry:MAX_RETRY]
            flattenMap:^RACSignal<RACTuple *> *(RACTuple *tuple) {
                NSHTTPURLResponse *response = tuple.first;
                if (response.statusCode < 200 || response.statusCode >= 300) {
                    NSData *data = tuple.second;
                    NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                    
                    return [RACSignal error:error];
                }
                return [RACSignal return:tuple];
            }];
}

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                                        reAuthenticateBlock:(void(^)())reAuthenticateBlock
{
    int serviceUnavailableCode = 503;
    NSArray<NSNumber *> *statusCodesForReauthenticate = [[NSArray alloc]
                                                         initWithObjects:[NSNumber numberWithInt:serviceUnavailableCode], nil];
    return [self rac_retriableDataTaskWithRequest:request
                                         delegate:delegate
                isNeedReauthenticateForStatusCode:statusCodesForReauthenticate
                              reAuthenticateBlock:reAuthenticateBlock
            ];
}

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                                    checkAuthorizationError:(BOOL)checkAuthorizationError
                                        reAuthenticateBlock:(void(^)())reAuthenticateBlock
{
    __block NSTimeInterval delayInterval = INITIAL_INTERVAL;
    
    return [[[[[[[RACSignal return:nil]
                 flattenMap:^RACSignal *(id value) {
                     return [[RACSignal interval:delayInterval onScheduler:[RACScheduler currentScheduler]]
                             take:1];
                 }]
                flattenMap:^RACSignal *(NSDate *value) {
                    return [NSURLSession rac_dataTaskWithRequest:request delegate:delegate];
                }]
               flattenMap:^RACSignal<RACTuple *> *(RACTuple* tuple) {
                   NSHTTPURLResponse *response = tuple.first;
                   if (response.statusCode == 503) {
                       NSLog(@"service unavailable on requesting %@",
                                  response.URL.absoluteString);
                       NSData *data = tuple.second;
                       NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                       
                       return [RACSignal error:error];
                   }
                   return [RACSignal return:tuple];
               }]
              doError:^(NSError *error) {
                  delayInterval += RETRY_INTERVAL_INCREMENTAL;
                  
                  if ([NSURLSession isAuthenticationFailError:error] && reAuthenticateBlock) {
                      reAuthenticateBlock();
                  }
                  
                  NSLog(@"error requesting %@.\nError: %@.\nRetrying in %f s",
                              request, error, delayInterval);
              }]
             retry:MAX_RETRY]
            flattenMap:^RACSignal<RACTuple *> *(RACTuple *tuple) {
                NSHTTPURLResponse *response = tuple.first;
                if (checkAuthorizationError) {
                    return [RACSignal return:tuple];
                }
                
                if (response.statusCode < 200 || response.statusCode >= 300) {
                    NSData *data = tuple.second;
                    NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                    
                    return [RACSignal error:error];
                }
                
                return [RACSignal return:tuple];
            }];
}

+ (RACSignal<RACTuple *> *)rac_retriableUploadTaskWithRequest:(NSURLRequest *)request
                                                         data:(NSData *)data
                                                     delegate:(id<NSURLSessionTaskDelegate>)delegate
{
    __block NSTimeInterval delayInterval = INITIAL_INTERVAL;
    
    return [[[[[[[RACSignal return:nil]
        flattenMap:^RACSignal *(id value) {
            return [[RACSignal interval:delayInterval onScheduler:[RACScheduler currentScheduler]]
                    take:1];
        }]
        flattenMap:^RACSignal *(NSDate *value) {
            return [NSURLSession rac_uploadTaskWithRequest:request data:data delegate:delegate];
        }]
        flattenMap:^RACSignal<RACTuple *> *(RACTuple* tuple) {
            NSHTTPURLResponse *response = tuple.first;
            if (response.statusCode == 503) {
                NSLog(@"service unavailable on requesting %@",
                           response.URL.absoluteString);
                NSData *data = tuple.second;
                NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                
                return [RACSignal error:error];
            }
            return [RACSignal return:tuple];
        }]
        doError:^(NSError *error) {
            delayInterval += RETRY_INTERVAL_INCREMENTAL;
            NSLog(@"error uploading %@.\nError: %@.\nRetrying in %f s",
                        request, error, delayInterval);
        }]
        retry:MAX_RETRY]
        flattenMap:^RACSignal<RACTuple *> *(RACTuple *tuple) {
            NSHTTPURLResponse *response = tuple.first;
            if (response.statusCode < 200 || response.statusCode >= 300) {
                NSData *data = tuple.second;
                NSError *error = [NSURLSession convertHTTPResponseToError:response data:data];
                
                return [RACSignal error:error];
            }
            return [RACSignal return:tuple];
        }];
}

+ (RACSignal<RACTuple *> *)rac_dataTaskWithRequest:(NSURLRequest *)request
                                          delegate:(id<NSURLSessionDelegate>)delegate
{
    NSLog(@"requesting %@", request);
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
            NSURLSession* session = [NSURLSession createSessionWithDelegate:delegate];

            [[session dataTaskWithRequest:request completionHandler:
                ^(NSData *data, NSURLResponse *response, NSError *error){
                if (response == nil || data == nil) {
                    NSLog(@"response or data nil on requesting %@",
                               response.URL.absoluteString);
                    [subscriber sendError:error];
                } else {
                    NSLog(@"response received : %@", response);
                    [subscriber sendNext:RACTuplePack(response, data)];
                    [subscriber sendCompleted];
                }
            }] resume];

            return [RACDisposable disposableWithBlock:^{
                [session invalidateAndCancel];
            }];
        }]
        setNameWithFormat:@"+rac_sendAsynchronousRequest: %@", request];
}

+ (RACSignal<RACTuple *> *)rac_uploadTaskWithRequest:(NSURLRequest *)request
                                                data:(NSData *)data
                                            delegate:(id<NSURLSessionTaskDelegate>)delegate
{
    NSLog(@"uploading %@", request);
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSURLSession *session = delegate == nil?
        [NSURLSession createSession]:
        [NSURLSession createSessionWithDelegate:delegate];
        
        NSURLSessionUploadTask *uploadTask =
        [session uploadTaskWithRequest:request fromData:data
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         if (response == nil || data == nil) {
                             NSLog(@"response or data nil on requesting %@",
                                        response.URL.absoluteString);
                             [subscriber sendError:error];
                         } else {
                             NSLog(@"response received : %@", response);
                             [subscriber sendNext:RACTuplePack(response, data)];
                             [subscriber sendCompleted];
                         }
                     }];
        
        [uploadTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [session invalidateAndCancel];
        }];
    }]
            setNameWithFormat:@"+rac_sendAsynchronousRequest: %@", request];
}

+ (RACSignal<RACTuple *> *)rac_downloadWithRequest:(NSURLRequest *)request
                                          delegate:(id<NSURLSessionDownloadDelegate>)delegate
{
    NSLog(@"requesting %@", request);
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSURLSession* session = [NSURLSession createSessionWithDelegate:delegate];
        [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (response == nil || location == nil) {
                NSLog(@"response or data nil on requesting %@",
                           response.URL.absoluteString);
                [subscriber sendError:error];
            } else {
                NSLog(@"response received : %@", response);
                [subscriber sendNext:RACTuplePack(response, location)];
                [subscriber sendCompleted];
            }
        }] resume];
        
        return [RACDisposable disposableWithBlock:^{
            [session invalidateAndCancel];
        }];
    }]
    setNameWithFormat:@"+rac_sendAsynchronousRequest: %@", request];
}

+ (NSURLSession*) createSession {
    
    NSURLSessionConfiguration* sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    return [NSURLSession sessionWithConfiguration:sessionConfig
                                         delegate:nil
                                    delegateQueue:nil];
}

+ (NSURLSession*) createSessionWithDelegate:(id<NSURLSessionTaskDelegate>)delegate {
    
    NSURLSessionConfiguration* sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    return [NSURLSession sessionWithConfiguration:sessionConfig
                                         delegate:delegate
                                    delegateQueue:nil];
}

+ (BOOL)isAuthenticationFailError:(NSError *)error {
    return error.code == NSURLErrorCancelled;
}

+ (NSError *)convertHTTPResponseToError:(NSHTTPURLResponse *)response data:(NSData *)data {
    NSString *httpStatus = [NSString stringWithFormat:@"HTTP %ld", (long)response.statusCode];
    NSString *errorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *fullErrorDescription = [NSString stringWithFormat:@"%@ %@", httpStatus, errorMessage];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: fullErrorDescription};
    return [NSError errorWithDomain:httpStatus
                               code:response.statusCode
                           userInfo:userInfo];
}

@end
