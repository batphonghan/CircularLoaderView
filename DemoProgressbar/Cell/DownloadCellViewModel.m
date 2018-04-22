//
//  DownloadCellViewModel.m
//  DemoProgressbar
//
//  Created by Honey on 4/22/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "DownloadCellViewModel.h"
#import "NSURLSession+RACSupport.h"

@interface DownloadCellViewModel () <NSURLSessionDownloadDelegate>


@end

@implementation DownloadCellViewModel

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _percent = [RACSubject subject];
        _tille = [RACSubject subject];
        
//        _url = url;
        
        [self setupRx];
    }
    return self;
}

- (void)setupRx {
    [RACObserve(self, url) subscribeNext:^(NSURL *url) {
        NSString *title = [url URLByDeletingPathExtension].lastPathComponent;
        [self.tille sendNext:title];
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [self.percent sendCompleted];
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float percent = (totalBytesWritten / (totalBytesExpectedToWrite *1.0f));
    [self.percent sendNext:@(percent)];
    if (percent >= 1.0) {
        [self.percent sendCompleted];
    }
}

- (RACSignal<RACTuple *> *)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    return [NSURLSession rac_downloadWithRequest:request delegate:self] ;
}

- (void)stopDownload {
    
}

@end
