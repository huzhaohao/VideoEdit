//
//  temMode.m
//  vidotest
//
//  Created by huzhaohao on 2020/6/4.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "temMode.h"
#import <AVFoundation/AVFoundation.h>


@implementation temMode

- (void)reverseVideo {
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"MP4"]];
    NSError *error;
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetReaderTrackOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:readerOutputSettings];
    readerOutput.alwaysCopiesSampleData = NO;
    // 在开始读取之前给reader指定一个output
    [reader addOutput:readerOutput];
    [reader startReading];
    
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    CMSampleBufferRef sample;
    while ((sample = [readerOutput copyNextSampleBuffer])) {
        [samples addObject:(__bridge id)sample];
        CFRelease(sample);
    }
    
    NSString *outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ReverseMovie.mp4"];
    unlink([outputPath UTF8String]);   // 删除当前该路径下的文件
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:@(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey, nil];
    NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          AVVideoCodecH264, AVVideoCodecKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                          videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
    [writerInput setExpectsMediaDataInRealTime:NO];
    writerInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    [writer addInput:writerInput];
    [writer startWriting];
    [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
    for (NSInteger i = 0; i < samples.count; i ++) {
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[i]);
        CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
        while (!writerInput.readyForMoreMediaData) {
            [NSThread sleepForTimeInterval:0.1];
        }
        [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
    }
    [writer finishWritingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self saveVideoToLibrary:outputPath];
        });
    }];
}
@end
