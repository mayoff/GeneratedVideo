//
//  DqdGeneratedVideo.m
//  makeMovie
//
//  Created by Rob Mayoff on 4/25/15.
//  Copyright (c) 2015 Rob Mayoff. All rights reserved.
//

@import AVFoundation;
#import "DqdGeneratedVideo.h"
#import "DqdFrameGenerator.h"

#define fromCF (__bridge id)

NSString *const DqdGeneratedVideoErrorDomain = @"DqdGeneratedViedoErrorDomain";

@implementation DqdGeneratedVideo {
    CGSize size;
}

#pragma mark - NSObject overrides

- (instancetype)initWithOutputURL:(NSURL *)url frameGenerator:(NSObject<DqdFrameGenerator> *)frameGenerator {
    if (self = [super init]) {
        _url = [url copy];
        _frameGenerator = frameGenerator;
        size = _frameGenerator.frameSize;
    }
    return self;
}

- (void)whenVideoIsFullyWritten:(dispatch_block_t)doneBlock ifError:(void (^)(NSError *))userErrorBlock {
    void (^errorBlock)(NSError *error) = ^(NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{ userErrorBlock(error); });
    };

    dispatch_queue_t writerQueue = dispatch_queue_create("writer queue", 0);
    dispatch_queue_t adaptorQueue = dispatch_queue_create("adaptor queue", 0);

    dispatch_async(writerQueue, ^{
        [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
        NSError *error;
        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:self.url fileType:AVFileTypeAppleM4V error:&error];
        if (writer == nil) {
            errorBlock(error);
            return;
        }

        NSDictionary *outputSettings = [self videoOutputSettings];
        if (![writer canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo]) {
            errorBlock([self errorWithFormat:@"Can't write video output with settings %@", outputSettings]);
            return;
        }

        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
        if (![writer canAddInput:input]) {
            errorBlock([self errorWithFormat:@"Can't add video input to writer: %@", input]);
            return;
        }

        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:[self pixelBufferAttributes]];

        [writer addInput:input];
        [writer startWriting];
        [writer startSessionAtSourceTime:kCMTimeZero];

        __block BOOL didFail = NO;
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

        [input requestMediaDataWhenReadyOnQueue:adaptorQueue usingBlock:^{
            while (input.readyForMoreMediaData && self.frameGenerator.hasNextFrame) {
                CMTime time = self.frameGenerator.nextFramePresentationTime;

                CVPixelBufferRef buffer = 0;
                CVPixelBufferPoolRef pool = adaptor.pixelBufferPool;
                CVReturn code = CVPixelBufferPoolCreatePixelBuffer(0, pool, &buffer);
                if (code != kCVReturnSuccess) {
                    errorBlock([self errorWithFormat:@"could not create pixel buffer; CoreVideo error code %ld", (long)code]);
                    [input markAsFinished];
                    didFail = YES;
                } else {
                    CVPixelBufferLockBaseAddress(buffer, 0); {
                        CGContextRef gc = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(buffer), CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer), 8, CVPixelBufferGetBytesPerRow(buffer), rgb, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); {
                            [self.frameGenerator drawNextFrameInContext:gc];
                        } CGContextRelease(gc);
                        [adaptor appendPixelBuffer:buffer withPresentationTime:time];
                    } CVPixelBufferUnlockBaseAddress(buffer, 0);
                } CVPixelBufferRelease(buffer);
            }

            if (!didFail && !self.frameGenerator.hasNextFrame) {
                [input markAsFinished];
                [writer finishWritingWithCompletionHandler:^{
                    CGColorSpaceRelease(rgb);
                    if (didFail) {
                        [writer cancelWriting];
                    } else {
                        if (writer.status == AVAssetWriterStatusFailed) {
                            errorBlock(writer.error);
                        } else {
                            dispatch_async(dispatch_get_main_queue(), doneBlock);
                        }
                    }
                }];
            }
        }];
    });
}

- (NSDictionary *)videoOutputSettings {
    return @{
             AVVideoCodecKey: AVVideoCodecH264,
             AVVideoWidthKey: @((size_t)size.width),
             AVVideoHeightKey: @((size_t)size.height),
             AVVideoCompressionPropertiesKey: @{
                     AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline31,
                     AVVideoAverageBitRateKey: @(1200000) }};
}

- (NSDictionary *)pixelBufferAttributes {
    return @{
             fromCF kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
             fromCF kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
}

- (NSError *)errorWithFormat:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    return [NSError errorWithDomain:DqdGeneratedVideoErrorDomain code:0 userInfo:@{
                                                                                   NSLocalizedDescriptionKey: string }];
}


@end
