//
//  CircularLoaderView.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "CircularLoaderView.h"



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
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    
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
            [self.delegate circularLoaderViewDidPressStart:self];
            break;
        case dowloading:
            [self stopDownload];
            [self.delegate circularLoaderViewDidPressCancel:self];
            self.status = canceled;
            break;
        case canceled:
            [self startDownload];
            [self.delegate circularLoaderViewDidPressStart:self];
            self.status = dowloading;
        case dowloaded:
            [self startDownload];
            [self.delegate circularLoaderViewDidPressStart:self];
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
}

- (void)stopDownload {
    
    self.image = self.downloadImage;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shapeLayer.strokeEnd = 0;
    [CATransaction commit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context != kCircleRadiusContext) return;
    
    if ([keyPath isEqualToString:kCircleRadius]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shapeLayer.strokeEnd = self.circleRadius;
            
            if (self.circleRadius >= 1.0) {
                [self doneDownload];
            }
        });
    }
}

@end
