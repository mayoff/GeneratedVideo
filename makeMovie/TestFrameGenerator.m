//
//  TestFrameGenerator.m
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

@import UIKit;
#import "TestFrameGenerator.h"

@implementation TestFrameGenerator {
    UIImage *baseImage;
    CMTime nextTime;
}

#pragma mark - NSObject overrides

- (instancetype)init {
    if (self = [super init]) {
        baseImage = [UIImage imageNamed:@"baseImage.jpg"];
        _totalFramesCount = 100;
        nextTime = CMTimeMake(0, 30);
    }
    return self;
}

- (CGSize)frameSize {
    return baseImage.size;
}

- (BOOL)hasNextFrame {
    return self.framesEmittedCount < self.totalFramesCount;
}

- (CMTime)nextFramePresentationTime {
    return nextTime;
}

- (void)drawNextFrameInContext:(CGContextRef)gc {
    CGContextTranslateCTM(gc, 0, baseImage.size.height);
    CGContextScaleCTM(gc, 1, -1);
    UIGraphicsPushContext(gc); {
        [baseImage drawAtPoint:CGPointZero];

        [[UIColor redColor] setFill];
        UIRectFill(CGRectMake(0, 0, baseImage.size.width, baseImage.size.height * self.framesEmittedCount / self.totalFramesCount));
    } UIGraphicsPopContext();

    ++_framesEmittedCount;

    if (self.frameGeneratedCallback != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.frameGeneratedCallback();
        });
    }

    if (self.framesEmittedCount < self.totalFramesCount / 2) {
        nextTime.value += 1;
    } else {
        nextTime.value += 2;
    }
}

@end
