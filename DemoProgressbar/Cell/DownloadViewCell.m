//
//  DownloadViewCell.m
//  DemoProgressbar
//
//  Created by Honey on 4/22/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "DownloadViewCell.h"
#import "CircularLoaderView.h"
#import "DownloadCellViewModel.h"
#import "RACDisposable.h"

@interface DownloadViewCell () <CircularLoaderViewDelegate>

@property (weak, nonatomic) IBOutlet CircularLoaderView *processView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *customImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activiti;

@property (strong, nonatomic) RACDisposable *downloadSignal;
@property (assign, nonatomic) NSNumber *indexHash;
@property (strong, nonatomic) DownloadCellViewModel *viewModel;
@end

@implementation DownloadViewCell

+ (NSMutableDictionary *)indexHashDict {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        dictionary = [NSMutableDictionary new];
    });
    return dictionary;
}

- (void)configViewModel:(DownloadCellViewModel *)viewModel
              indexPath:(NSIndexPath *)path {
    self.viewModel = viewModel;
    self.processView.delegate = self;
    
    self.indexHash =  @([self keyForIndexPath:path]);
    [self.viewModel.percent subscribeNext:^(NSNumber *percent) {
        self.processView.circleRadius = [percent floatValue];
    }];
    
    [self.viewModel.tille subscribeNext:^(NSString *title) {
        self.title.text = title;
    }];
    
    BOOL isDownloading = [[[DownloadViewCell indexHashDict] objectForKey:self.indexHash] boolValue];
    if (isDownloading) {
        [self.processView startDownload];
    } else {
        [self.processView stopDownload];
    }
}


- (NSUInteger)keyForIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath class] == [NSIndexPath class]) {
        return [indexPath hash];
    }
    return [[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] hash];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.viewModel = nil;
}

- (void)circularLoaderViewDidPressStart:(CircularLoaderView *)circularLoaderView {
     self.downloadSignal = [[self.viewModel startDownload] subscribeNext:^(RACTuple * result) {

    }];
    
    [[DownloadViewCell indexHashDict] setObject:@(YES) forKey: self.indexHash];
}

- (void)circularLoaderViewDidPressCancel:(CircularLoaderView *)circularLoaderView {
//    [self.downloadSignal dispose];
    [[DownloadViewCell indexHashDict] setObject:@(NO) forKey:self.indexHash];
}


@end
