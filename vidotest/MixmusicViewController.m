//
//  MixmusicViewController.m
//  GQWDY
//
//  Created by huzhaohao on 2020/5/20.
//  Copyright © 2020 JiaMin Kuang. All rights reserved.
//

#import "MixmusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kMusicKey @"MusicKey"

@interface MixmusicViewController ()<MPMediaPickerControllerDelegate>
{
    MPMediaPickerController *mpc;
}
@property (weak, nonatomic) IBOutlet UIButton *seleltBtn;

@property (nonatomic)AVPlayer *AAplayer;
@property (nonatomic)AVPlayerLayer *AAplayerLayer;
@property (weak, nonatomic) IBOutlet UISlider *slider0;
@property (weak, nonatomic) IBOutlet UISlider *slider1;

@property (weak, nonatomic) IBOutlet UILabel *lb0;
@property (weak, nonatomic) IBOutlet UILabel *lb1;

@end

@implementation MixmusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.seleltBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.seleltBtn.layer.borderWidth = 1;
    self.seleltBtn.layer.cornerRadius = 6;

    //创建播放器控制器
    mpc  = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    //设置代理
    mpc.delegate = self;
    mpc.prompt = @"请选择您要的背景音乐";
//    //
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:self.asset];
    _AAplayer = [[AVPlayer alloc] initWithPlayerItem:playItem];
    _AAplayerLayer = [[AVPlayerLayer alloc] init];
    _AAplayerLayer.player = _AAplayer;
    _AAplayerLayer.frame = CGRectMake(0,40,kScreenW, kScreenH -220);
    _AAplayerLayer.position = self.view.center;
    [self.view.layer addSublayer:_AAplayerLayer];
    [_AAplayer play];
    
    [self.view bringSubviewToFront:self.lb0];
    [self.view bringSubviewToFront:self.slider0];
     [self.view bringSubviewToFront:self.lb1];
    [self.view bringSubviewToFront:self.slider1];
    [self.view bringSubviewToFront:self.seleltBtn];
    
    [_slider0 addTarget:self action:@selector(didSliderChange) forControlEvents:UIControlEventValueChanged];
    [_slider1 addTarget:self action:@selector(didSliderChange) forControlEvents:UIControlEventValueChanged];
}

- (void)didSliderChange{
    NSLog(@"slider %0.1f ==%0.1f",self.slider0.value,self.slider1.value);
    [self initAssets];
}

- (IBAction)didClickSelectMusic:(id)sender {
   [_AAplayer pause];
  [self presentViewController:mpc animated:YES completion:nil];
}


#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:( MPMediaItemCollection *)mediaItemCollection {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    [musicPlayer setQueueWithItemCollection:mediaItemCollection];
    MPMediaItem *item = [mediaItemCollection.items firstObject];
    // 重点:编码对象(item)为NSData
    NSData *date = [NSKeyedArchiver archivedDataWithRootObject:item];
    // 存储编码后的NSData到plist文件
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kMusicKey];
    [self dismissViewControllerAnimated:YES completion:nil];
    // 取出data并播放
    [self playerMusic];
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
     [self dismissViewControllerAnimated:YES completion:nil];
}
  - (void)playerMusic {
    // 在任何其他文件都可以取出data进行音乐播放
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kMusicKey];
    // 解档还原item对象
    MPMediaItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    // 取出音乐.注意:MPMediaItemPropertyAssetURL属性可能为空. 这是因为iPhone自带软件Music对音乐版权的保护,对于所有进行过 DRM Protection(数字版权加密保护)的音乐都不能被第三方APP获取并播放.即使这些音乐已经下载到本地.但是还是可以播放本地未进行过数字版权加密的音乐.也就是您自己手动导入的音乐.
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
      
   if (assetURL) {
       self.auAsset = [AVURLAsset assetWithURL:assetURL];
   } else {
//       [SVProgressHUD showInfoWithStatus:@"音乐数字版权加密保护请选择本地未进行过数字版权加密的音乐也就是您自己手动导入的音乐."];
   }
    [self initAssets];
}
- (void)initAssets{
       AVAsset *asset = self.asset;
       AVAsset *audioAsset = self.auAsset;
       BOOL needOriginalVoice = NO;
       NSArray *tempArray =[asset tracksWithMediaType:AVMediaTypeAudio] ;
       if (tempArray.count > 0) {
          needOriginalVoice = YES;
        }
       //    分离素材
       AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];//视频素材
       AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];//音频素材
       
       //    编辑视频环境
       AVMutableComposition *composition = [[AVMutableComposition alloc]init];
        
       AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
       [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
       
       AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
       [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoCompositionTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
//       BOOL needOriginalVoice = YES;
       AVMutableCompositionTrack *originalAudioCompositionTrack = nil;
      
          if (needOriginalVoice) {
              AVAssetTrack *originalAudioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
              originalAudioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
              [originalAudioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:originalAudioAssetTrack atTime:kCMTimeZero error:nil];
          }
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:composition];
    playItem.audioMix =  [self buildAudioMixWithVideoTrack:originalAudioCompositionTrack VideoVolume:self.slider0.value BGMTrack:audioCompositionTrack BGMVolume:self.slider1.value controlVolumeRange:kCMTimeZero];
    
    [_AAplayer pause];
    [_AAplayerLayer removeFromSuperlayer];
    
    _AAplayer = [[AVPlayer alloc] initWithPlayerItem:playItem];
    _AAplayerLayer = [[AVPlayerLayer alloc] init];
    _AAplayerLayer.player = _AAplayer;
    _AAplayerLayer.frame = CGRectMake(0,40,kScreenW, kScreenH -220);
    _AAplayerLayer.position = self.view.center;
    [self.view.layer addSublayer:_AAplayerLayer];
    [_AAplayer play];
}
#pragma mark - 导出
- (void)composeVideo {
    
    NSLog(@"开始导出");
    if (self.auAsset ==nil) {
        return;
    }
    [_AAplayer pause];
    //    素材
    AVAsset *asset = self.asset;
    AVAsset *audioAsset = self.auAsset;
    BOOL needOriginalVoice = NO;
    NSArray *tempArray =[asset tracksWithMediaType:AVMediaTypeAudio] ;
    if (tempArray.count > 0) {
        needOriginalVoice = YES;
    }
    //    分离素材
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];//视频素材
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];//音频素材
    
    //    编辑视频环境
    AVMutableComposition *composition = [[AVMutableComposition alloc]init];
     
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
    //    导出素材
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    
    //    音量控制
    exporter.audioMix = [self buildAudioMixWithVideoTrack:originalAudioCompositionTrack VideoVolume:0.5 BGMTrack:audioCompositionTrack BGMVolume:1 controlVolumeRange:kCMTimeZero];
        
    // 导出视频的临时保存路径
        NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getVideoNameBaseCurrentTime]];
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
                         
                     });
                    
                     break;
             }
        }];

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

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    if (videoPath) {
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
        if (compatible) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        } else {

        }
    }
}
//保存视频完成之后的回调
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
         dispatch_async(dispatch_get_main_queue(), ^{
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存视频到相册失败。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
        NSLog(@"保存视频失败%@", error.localizedDescription);
    } else {
         dispatch_async(dispatch_get_main_queue(), ^{
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存视频到相册成功。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
        NSLog(@"保存视频成功");
    }
}

#pragma mark ----生成视频名称---
- (NSString*)getVideoNameBaseCurrentTime {
   NSDateFormatter*vv_dateFormatter_vv = [[NSDateFormatter  alloc]init];
   [vv_dateFormatter_vv setDateFormat:@"yyyyMMddHHmmss"];
  return[[vv_dateFormatter_vv stringFromDate:[NSDate date]]stringByAppendingString:@".MOV"];
}
@end
