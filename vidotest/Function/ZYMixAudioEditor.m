//
//  ZYMixAudioEditor.m
//  vidotest
//
//  Created by huzhaohao on 2020/5/21.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ZYMixAudioEditor.h"

@implementation ZYMixAudioEditor


- (void)buildAudioWithVideoVolume:(float)videoVolume BGMVolume:(float)BGMVolume{
      
       AVAsset *asset = self.asset;
       AVAsset *audioAsset = self.auAsset;
    
       BOOL needOriginalVoice = NO;
       //视频原音
       NSArray *tempArray =[asset tracksWithMediaType:AVMediaTypeAudio] ;
       if (tempArray.count > 0) {
           needOriginalVoice = YES;
        }
       //    分离素材
       AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];//视频素材
       AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];//音频素材
       
       //    编辑视频环境
       AVMutableComposition *composition = [[AVMutableComposition alloc]init];
       self.compostion = composition;
       AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
       [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
       
       AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
       [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoCompositionTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
       AVMutableCompositionTrack *originalAudioCompositionTrack = nil;
      
      if (needOriginalVoice) {
          AVAssetTrack *originalAudioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
          originalAudioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
          [originalAudioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:originalAudioAssetTrack atTime:kCMTimeZero error:nil];
      }
    self.audioMix =  [self buildAudioMixWithVideoTrack:originalAudioCompositionTrack VideoVolume:videoVolume BGMTrack:audioCompositionTrack BGMVolume:BGMVolume controlVolumeRange:kCMTimeZero];
}

#pragma mark - 调节合成的音量
- (AVAudioMix *)buildAudioMixWithVideoTrack:(AVCompositionTrack *)videoTrack VideoVolume:(float)videoVolume BGMTrack:(AVCompositionTrack *)BGMTrack BGMVolume:(float)BGMVolume controlVolumeRange:(CMTime)volumeRange {
    //    创建音频混合类
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    if (videoTrack == nil) {
        //    设置背景音乐音量
            AVMutableAudioMixInputParameters *BGMparameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:BGMTrack];
            [BGMparameters setVolume:BGMVolume atTime:volumeRange];
        //    加入混合数组
            audioMix.inputParameters = @[BGMparameters];
    } else {
        //    拿到视频声音轨道设置音量
            AVMutableAudioMixInputParameters *Videoparameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:videoTrack];
            [Videoparameters setVolume:videoVolume atTime:volumeRange];
            
        //    设置背景音乐音量
            AVMutableAudioMixInputParameters *BGMparameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:BGMTrack];
            [BGMparameters setVolume:BGMVolume atTime:volumeRange];
            
        //    加入混合数组
            audioMix.inputParameters = @[Videoparameters,BGMparameters];
    }
    
    return audioMix;
}

- (void)exportWithPath:(NSString *)exportPath{
     NSLog(@"混音开始");
    //    导出素材
     AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:self.compostion presetName:AVAssetExportPresetMediumQuality];
     //    音量控制
     exporter.audioMix = self.audioMix;
//     // 导出视频的临时保存路径
//     NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getVideoNameBaseCurrentTime]];
     unlink([exportPath UTF8String]);
     NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
     //    设置输出路径
     exporter.outputURL = exportUrl ;
     exporter.outputFileType = AVFileTypeMPEG4;//指定输出格式
    // 导出视频
      [exporter exportAsynchronouslyWithCompletionHandler:
          ^(void ) {
              switch ([exporter status]) {
                  case AVAssetExportSessionStatusFailed:
                      NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                      break;
                  case AVAssetExportSessionStatusCancelled:
                      NSLog(@"Export canceled");
                      break;
                  default:
                      NSLog(@"NONE");
                      dispatch_async(dispatch_get_main_queue(), ^{
                             NSLog(@"混音完成");
                             if (self.flishCurrentBlock) {
                                 self.flishCurrentBlock(exportPath);
                             }
                      });
                  break;
              }
         }];
}



@end
