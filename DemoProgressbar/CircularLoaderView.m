//
//  CircularLoaderView.m
//  DemoProgressbar
//
//  Created by Hung Nguyen on 4/19/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "CircularLoaderView.h"

@interface CircularLoaderView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation CircularLoaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [self configure];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"circleRadius"];
}

- (void)configure {
    self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    self.shapeLayer.frame = CGRectInset(self.bounds, 3.0f, 3.0f);
    self.shapeLayer.path = [[UIBezierPath bezierPathWithOvalInRect:self.shapeLayer.bounds] CGPath];
    self.shapeLayer.lineWidth = 2;
    self.shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    
    
    [self.layer addSublayer:self.shapeLayer];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"icFileDownload"];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CGRect imagePosition = CGRectMake((self.bounds.size.width / 2)  - (backgroundImage.size.width / 2),
                                      (self.bounds.size.height / 2) - (backgroundImage.size.height / 2),
                                      backgroundImage.size.width,
                                      backgroundImage.size.height);
    
    [backgroundImage drawInRect:imagePosition];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.backgroundColor = [[UIColor alloc] initWithPatternImage:image];
    
    [self addObserver:self forKeyPath:@"circleRadius" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"circleRadius"]) {
        self.shapeLayer.strokeEnd = self.circleRadius;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
}

@end
