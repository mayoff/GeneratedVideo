//
//  TestFrameGenerator.h
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

@import Foundation;
#import "DqdFrameGenerator.h"

@interface TestFrameGenerator : NSObject<DqdFrameGenerator>

@property (nonatomic, readonly) int framesEmittedCount;
@property (nonatomic, readonly) int totalFramesCount;
@property (nonatomic, strong) dispatch_block_t frameGeneratedCallback;

@end
