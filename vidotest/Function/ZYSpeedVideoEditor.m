//
//  ZYSpeedVideoEditor.m
//  vidotest
//
//  Created by huzhaohao on 2020/5/22.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ZYSpeedVideoEditor.h"

@implementation ZYSpeedVideoEditor

- (void)exportWithPath:(NSString *)exportPath{
    
    AVURLAsset *videoAsset = (AVURLAsset *)self.asset;
    AVAssetTrack *videoAssetTrack = nil;
    AVAssetTrack *audioAssetTrack = nil;
    AVMutableAudioMix *audioMix = nil;
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    }
    if ([videoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
  
        if (videoAssetTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) ofTrack:videoAssetTrack atTime:insertionPoint error:&error];
            
            [compositionVideoTrack setPreferredTransform:videoAssetTrack.preferredTransform];
            
            [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) toDuration:CMTimeMake(videoAsset.duration.value * self.scale , videoAsset.duration.timescale)];
        }
        
        if (audioAssetTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) ofTrack:audioAssetTrack atTime:insertionPoint error:&error];
            
            [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) toDuration:CMTimeMake(videoAsset.duration.value * self.scale, videoAsset.duration.timescale)];
            
            AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
            
            AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack] ;
            [audioInputParams setTrackID:compositionAudioTrack.trackID];
            audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
        }
        
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
        
        _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
        _assetExport.outputURL = exportUrl;
        _assetExport.audioMix = audioMix;
        _assetExport.shouldOptimizeForNetworkUse = YES;
        
        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
            switch ([_assetExport status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[_assetExport error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                           NSLog(@"变速完成");
                           if (self.flishCurrentBlock) {
                               self.flishCurrentBlock(exportPath);
                           }
                    });
                    break;
            }
        }];
}

@end
