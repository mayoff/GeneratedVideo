//
//  TestFrameGenerator.h
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Donated to the public domain.
//

@import Foundation;
#import "DqdFrameGenerator.h"

@interface TestFrameGenerator : NSObject<DqdFrameGenerator>

@property (nonatomic, readonly) int framesEmittedCount;
@property (nonatomic, readonly) int totalFramesCount;
@property (nonatomic, strong) dispatch_block_t frameGeneratedCallback;

@end
