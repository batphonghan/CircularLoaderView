//
//  DownloadCellViewModel.h
//  DemoProgressbar
//
//  Created by Honey on 4/22/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RACSubject.h>

@interface DownloadCellViewModel : NSObject

@property (strong, nonatomic) RACSubject *percent;
@property (strong, nonatomic) RACSubject *tille;
@property (strong, nonatomic) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;

- (RACSignal<RACTuple *> *)startDownload;

- (void)stopDownload;
@end
