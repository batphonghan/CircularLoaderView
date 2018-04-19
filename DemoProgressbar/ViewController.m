//
//  ViewController.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "ViewController.h"
#import <DownloadButton/PKDownloadButton.h>

#import "CircularLoaderView.h"

@interface ViewController () <NSURLSessionDownloadDelegate> {
    CAShapeLayer* shapeLayer;
    NSURLSessionTask *task;
    NSURLSession *session;
    CircularLoaderView *circularLoaderView;
}

@end

@implementation ViewController

- (IBAction)reset:(id)sender {
    circularLoaderView.circleRadius = 0;
    [task cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *str = @"http://ipv4.download.thinkbroadband.com/20MB.zip";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    task = [session downloadTaskWithRequest:request];
    [task resume];
    [self.view addSubview:circularLoaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    circularLoaderView = [[CircularLoaderView alloc] initWithFrame:CGRectMake(100, 200, 30, 30)];
    
    UIGraphicsBeginImageContext(circularLoaderView.bounds.size);
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"icFileDownload"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    circularLoaderView.backgroundColor = [[UIColor alloc] initWithPatternImage:image];
}

- (IBAction)buttonTapped:(id)sender {
    [task resume];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            circularLoaderView.circleRadius = progess;
        });
}

@end
