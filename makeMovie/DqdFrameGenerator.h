//
//  DqdFrameGenerator.h
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Donated to the public domain.
//

@import Foundation;
@import CoreGraphics;
@import CoreMedia;

@protocol DqdFrameGenerator <NSObject>

@required

// You should return the same size every time I ask for it.
@property (nonatomic, readonly) CGSize frameSize;

// I'll ask for frames in a loop. On each pass through the loop, I'll start by asking if you have any more frames:
@property (nonatomic, readonly) BOOL hasNextFrame;

// If you say NO, I'll stop asking and end the video.

// If you say YES, I'll ask for the presentation time of the next frame:
@property (nonatomic, readonly) CMTime nextFramePresentationTime;

// Then I'll ask you to draw the next frame into a bitmap graphics context:
- (void)drawNextFrameInContext:(CGContextRef)gc;

// Then I'll go back to the top of the loop.

@end
