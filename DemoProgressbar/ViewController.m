//
//  ViewController.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "ViewController.h"
#import "CircularLoaderView.h"

@interface ViewController () <NSURLSessionDownloadDelegate, CircularLoaderViewDelegate> {
    NSURLSessionTask *task;
    NSURLSession *session;
    NSURLRequest *request;
}
@property (weak, nonatomic) IBOutlet CircularLoaderView *circularLoadView_;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str = @"http://ipv4.download.thinkbroadband.com/5MB.zip";
    NSURL *url = [NSURL URLWithString:str];
    request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    task = [session downloadTaskWithRequest:request];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.circularLoadView_.delegate = self;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progess = (float)totalBytesWritten / totalBytesExpectedToWrite;
        NSLog(@"progress: %f", progess);
        self.circularLoadView_.circleRadius = progess;
}

- (void)circularLoaderViewDidPressStart:(CircularLoaderView *)circularLoaderView {
    if (task.state != NSURLSessionTaskStateRunning) {
        task = [session downloadTaskWithRequest:request];
    }
    [task resume];
}

- (void)circularLoaderViewDidPressCancel:(CircularLoaderView *)circularLoaderView {
    [task suspend];
}

@end
