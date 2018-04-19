//
//  CircularLoaderView.h
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CircularLoaderView;
@protocol CircularLoaderViewDelegate <NSObject>

- (void)circularLoaderViewDidPressStart:(CircularLoaderView *)circularLoaderView;
- (void)circularLoaderViewDidPressCancel:(CircularLoaderView *)circularLoaderView;

@end

@interface CircularLoaderView : UIView

@property (nonatomic, assign) CGFloat  circleRadius;

@property (nonatomic, weak) id<CircularLoaderViewDelegate> delegate;

- (void)startDownload;
- (void)stopDownload;

@end
