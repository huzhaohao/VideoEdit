//
//  ZYClipeVideoEditor.m
//  vidotest
//
//  Created by huzhaohao on 2020/5/22.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ZYClipeVideoEditor.h"

@implementation ZYClipeVideoEditor

#pragma mark - 保存
- (void)exportWithPath:(NSString *)exportPath {
    NSLog(@"开始剪切");
    AVURLAsset *videoAsset = (AVURLAsset *)self.asset;
    CMTime start = CMTimeMakeWithSeconds(self.startTime, videoAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, videoAsset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    AVAssetTrack *videoAssetTrack = nil;
    AVAssetTrack *audioAssetTrack = nil;
    AVMutableAudioMix *audioMix = nil;
    
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    }
    if ([videoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    }
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    if (videoAssetTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:range ofTrack:videoAssetTrack atTime:start error:nil];
        
        [compositionVideoTrack setPreferredTransform:videoAssetTrack.preferredTransform];
    }
    
    if (audioAssetTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:range ofTrack:audioAssetTrack atTime:start error:nil];
    }
    
    AVMutableCompositionTrack *compositionAudioTrack = nil;
    if ([self.asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionAudioTrack insertTimeRange:range ofTrack:[[self.asset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:start error:nil];
        audioMix = [AVMutableAudioMix audioMix];
        
        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
        
//        [audioInputParams setVolume:1 atTime:range];
        //淡出
        [audioInputParams setVolumeRampFromStartVolume:1.0 toEndVolume:.0f timeRange:range];
        [audioInputParams setTrackID:compositionAudioTrack.trackID];
        audioMix.inputParameters = [NSArray arrayWithObject:audioInputParams];
    }
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
//    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    unlink([exportPath UTF8String]);
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = exportUrl;
    _assetExport.audioMix = audioMix;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    _assetExport.timeRange = range;

    [_assetExport exportAsynchronouslyWithCompletionHandler:^ {
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
                    NSLog(@"剪切完成");
                    if (self.flishCurrentBlock) {
                        self.flishCurrentBlock(exportPath);
                    }
               });
                break;
        }
        
    }];
}



@end
