//
//  CircularLoaderView.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "CircularLoaderView.h"

typedef enum : NSUInteger {
    notDowloaded,
    dowloading,
    canceled,
    dowloaded
} DownloadStatus;


static void * kCircleRadiusContext = &kCircleRadiusContext;
static NSString * kCircleRadius    = @"circleRadius";

@interface CircularLoaderView ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) DownloadStatus status;

@property (nonatomic, strong) UIImage *downloadImage;
@property (nonatomic, strong) UIImage *stopImage;

@end



@implementation CircularLoaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        [self configure];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
        [self configure];
    }
    return self;
}


- (UIImage *)downloadImage {
    if (!_downloadImage) {
        _downloadImage = [UIImage imageNamed:@"icVoiceDownload"];
    }
    
    return _downloadImage;
}
- (UIImage *)stopImage {
    if (!_stopImage) {
        _stopImage = [UIImage imageNamed:@"icVoiceCancel"];
    }
    
    return _stopImage;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kCircleRadius];
}

- (void)configure {
    self.status = notDowloaded;
    self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    [self p_customDraw];
    [self p_addGesture];
    [self addObserver:self forKeyPath:kCircleRadius
              options:NSKeyValueObservingOptionNew context:kCircleRadiusContext];
    
    
    self.image = self.downloadImage;
}

- (void)p_customDraw {
    [self p_drawProcess];
}

- (void)p_addGesture {
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
    singleFingerTap.numberOfTapsRequired = 1;
}

- (void)p_drawProcess {
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.shapeLayer.frame = CGRectInset(self.bounds, 5.0f, 5.0f);

    self.shapeLayer.path = [[UIBezierPath bezierPathWithOvalInRect:self.shapeLayer.bounds ] CGPath];
    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;

    [self.layer addSublayer:self.shapeLayer];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    switch (self.status) {
        case notDowloaded:
            [self startDownload];
            self.status = dowloading;
            break;
        case dowloading:
            [self stopDownload];
            self.status = canceled;
            break;
        case canceled:
            [self startDownload];
            self.status = dowloading;
        case dowloaded:
            [self startDownload];
            self.status = dowloading;
        default:
            break;
    }
}

- (void)doneDownload {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.status = dowloaded;
        [self setHidden:YES];
    });
}

- (void)startDownload {
    self.image = self.stopImage;
    [self.delegate circularLoaderViewDidPressStart:self];
}

- (void)stopDownload {
    [self.delegate circularLoaderViewDidPressCancel:self];
    
    
    self.image = self.downloadImage;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shapeLayer.strokeEnd = 0;
    [CATransaction commit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context != kCircleRadiusContext) return;
    
    if ([keyPath isEqualToString:kCircleRadius]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shapeLayer.strokeEnd = self.circleRadius;
        });
    }
}


//
//- (void)p_drawDownloadIcon {
//    CAShapeLayer *downloadIcon = [CAShapeLayer new];
////    downloadIcon.fillColor = [[UIColor whiteColor] CGColor];
//    downloadIcon.lineWidth = 2;
//    downloadIcon.strokeColor = [[UIColor whiteColor] CGColor];
//
////    CGRect rect = self.bounds;
//    CGSize size = self.bounds.size;
//    CGPoint origin = self.bounds.origin;
//    CGFloat inset = size.height / 7;
//
//    CGPoint start = CGPointMake(origin.x + size.width / 2, origin.y + inset);
//    CGPoint end = CGPointMake(origin.x + size.height / 2, origin.y + size.height - inset);
//    CGPoint left = CGPointMake(origin.x + inset, size.height / 2);
////    CGPoint right = CGPointMake(origin.x + size.width - inset, size.height / 2);
//
//
//    UIBezierPath *downloadPath = [UIBezierPath new];
//    [downloadPath moveToPoint:start];
//    [downloadPath addLineToPoint:end];
//    [downloadPath addLineToPoint:left];
////    [downloadPath fill];
//
//    [downloadPath moveToPoint:end];
////    [downloadPath addLineToPoint:right];
//
//    [downloadPath stroke];
//    downloadIcon.path = downloadPath.CGPath;
//
//    [self.layer addSublayer:downloadIcon];
//}

//- (void)p_drawCircle {
//    CAShapeLayer *circle = [[CAShapeLayer alloc] init];
//    circle.fillColor = [[UIColor blueColor] CGColor];
//    circle.frame = self.bounds;
//    circle.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 2.0f, 2.0f)] CGPath];
//    circle.strokeColor = [[UIColor blueColor] CGColor];
//    [self.layer insertSublayer:circle below: _shapeLayer] ;
//}
@end


