//
//  DqdGeneratedVideo.h
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DqdFrameGenerator;

@interface DqdGeneratedVideo : NSObject

- (instancetype)initWithOutputURL:(NSURL *)url frameGenerator:(NSObject<DqdFrameGenerator> *)frameGenerator;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSObject<DqdFrameGenerator> *frameGenerator;

// I generate the video on a background thread when you send me this. I call either `doneBlock` or `errorBlock` on the main thread when I'm finished.
- (void)whenVideoIsFullyWritten:(dispatch_block_t)doneBlock ifError:(void (^)(NSError *error))errorBlock;

@end

extern NSString *const DqdGeneratedVideoErrorDomain;
