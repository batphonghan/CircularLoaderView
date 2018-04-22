//
//  HNOperation.m
//  DemoProgressbar
//
//  Created by Honey on 4/22/18.
//  Copyright © 2018 IMac. All rights reserved.
//

#import "HNOperation.h"

@interface HNOperation ()

@end

@implementation HNOperation

@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ready = YES;
    }
    return self;
}

#pragma mark - State

- (void)setReady:(BOOL)ready {
    if (_ready != ready ) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isReady))];
        _ready = ready;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isReady))];
    }
}

- (BOOL)isReady {
    return _ready;
}

- (void)setExecuting:(BOOL)executing {
    if (_executing != executing ) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = executing;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
}

- (BOOL)isExecuting {
    return _executing;
}

- (void)setFinished:(BOOL)finished {
    if (_finished != finished ) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _finished = finished;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }
}

- (BOOL)isFinished {
    return _finished;
}

@end
