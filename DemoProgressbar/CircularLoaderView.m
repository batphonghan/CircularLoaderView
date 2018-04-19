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

- (void)dealloc {
    [self removeObserver:self forKeyPath:kCircleRadius];
}

- (CGRect) imageRect{
    return CGRectMake(self.bounds.origin.x,
                      self.bounds.origin.y,
                      self.bounds.size.width * 2 / 3,
                      self.bounds.size.width * 2 / 3);
}

- (void)configure {
    
    self.status = notDowloaded;
    self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.shapeLayer.frame = CGRectInset([self imageRect], 3.0f, 3.0f);
    
    self.shapeLayer.path = [[UIBezierPath bezierPathWithOvalInRect:self.shapeLayer.bounds ] CGPath];
    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    
    [self.layer addSublayer:self.shapeLayer];
    
    
    
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"icVoiceDownload"] drawInRect:[self imageRect]];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
    singleFingerTap.numberOfTapsRequired = 1;
    
    [self addObserver:self forKeyPath:kCircleRadius
              options:NSKeyValueObservingOptionNew context:kCircleRadiusContext];
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

- (void)startDownload {
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"icVoiceCancel"] drawInRect:[self imageRect]];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [self.delegate circularLoaderViewDidPressStart:self];
}

- (void)stopDownload {
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"icVoiceDownload"] drawInRect:[self imageRect]];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
    [self.delegate circularLoaderViewDidPressCancel:self];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shapeLayer.actions = @{@"strokeEnd": [NSNull null]};
    self.shapeLayer.strokeEnd = 0;
    [CATransaction commit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context != kCircleRadiusContext) return;
    
    if ([keyPath isEqualToString:kCircleRadius]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shapeLayer.strokeEnd = self.circleRadius;
            if (self.circleRadius >= 1.0) {
                self.status = dowloaded;
                [self stopDownload];
            }
        });
    }
}

@end


