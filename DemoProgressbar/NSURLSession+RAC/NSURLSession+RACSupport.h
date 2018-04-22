//
//  NSURLSession+RACSupport.h
//  Alaska
//
//  Created by woi on 6/13/17.
//  Copyright © 2017 BlackBerry Inc. All rights reserved.
//

@class RACTuple;
@class RACSignal<__covariant ValueType>;

#import <ReactiveObjC/ReactiveObjC.h>

@interface NSURLSession (RACSupport)

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request;

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate;

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                                        reAuthenticateBlock:(void(^)(void))reAuthenticateBlock;

+ (RACSignal<RACTuple *> *)rac_retriableUploadTaskWithRequest:(NSURLRequest *)request
                                                         data:(NSData *)data
                                                     delegate:(id<NSURLSessionDelegate>)delegate;

+ (RACSignal<RACTuple *> *)rac_dataTaskWithRequest:(NSURLRequest *)request
                                          delegate:(id<NSURLSessionDelegate>)delegate;

+ (RACSignal<RACTuple *> *)rac_uploadTaskWithRequest:(NSURLRequest *)request
                                                data:(NSData *)data
                                            delegate:(id<NSURLSessionDelegate>)delegate;

+ (RACSignal<RACTuple *> *)rac_downloadWithRequest:(NSURLRequest *)request
                                          delegate:(id<NSURLSessionDownloadDelegate>)delegate;

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                          isNeedReauthenticateForStatusCode:(NSArray<NSNumber *> *) statusCodes
                                        reAuthenticateBlock:(void(^)(void))reAuthenticateBlock;

+ (RACSignal<RACTuple *> *)rac_retriableDataTaskWithRequest:(NSURLRequest *)request
                                                   delegate:(id<NSURLSessionDelegate>)delegate
                                    checkAuthorizationError:(BOOL)checkAuthorizationError
                                        reAuthenticateBlock:(void(^)(void))reAuthenticateBlock;

+ (NSError *)convertHTTPResponseToError:(NSHTTPURLResponse *)response data:(NSData *)data;

@end
