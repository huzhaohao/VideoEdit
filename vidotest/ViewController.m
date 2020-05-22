//
//  ViewController.m
//  vidotest
//
//  Created by huzhaohao on 2020/1/4.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ViewController.h"
#import "ZYSpliceVideoEditor.h"
#import "MixmusicViewController.h"
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    ZYSpliceVideoEditor *editor;
}
@property (nonatomic)AVPlayer *player;
@property (nonatomic)AVPlayerLayer *playerLayer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.cyanColor;
    editor = [[ZYSpliceVideoEditor alloc] init];
    [self initAssets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player pause];
}

- (void)initAssets{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    NSMutableArray *timeRanges = [[NSMutableArray alloc] init];
    for (int i = 1; i < 5; i ++ ) {
        NSString *name = [NSString stringWithFormat:@"test%d",i];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"MP4"];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVAsset *asset = [AVAsset assetWithURL:url];
        [assets addObject:asset];
        //截取视频前5秒
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        [timeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
    }
    editor.clips = assets;
    editor.clipRanges = timeRanges;
    [editor buildComposition];

    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:editor.compostion];
    playItem.videoComposition = editor.videoComposition;
    _player = [[AVPlayer alloc] initWithPlayerItem:playItem];
    _playerLayer = [[AVPlayerLayer alloc] init];
    _playerLayer.player = _player;
    _playerLayer.frame = CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height -100);
    _playerLayer.position = self.view.center;
    [self.view.layer addSublayer:_playerLayer];
    [_player play];

}

- (void)resetPlayerItem{
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:editor.compostion];
    playItem.videoComposition = editor.videoComposition;
    [_player replaceCurrentItemWithPlayerItem:playItem];
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (IBAction)didClickPlay:(UIButton *)sender {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (IBAction)videoRatioChanged:(UISegmentedControl *)sender {
    editor.videoRatio = sender.selectedSegmentIndex;
    editor.videoSize = CGSizeMake(1080, 1920);
    [editor buildComposition];
    [self resetPlayerItem];
}

- (IBAction)videoTrasitionChanged:(UISegmentedControl *)sender {
    editor.transitionType = sender.selectedSegmentIndex;
    [editor buildComposition];
    [self resetPlayerItem];
}

#pragma mark - 导出
- (void)composeVideo {
    NSLog(@"开始导出");
      CMTime start =  kCMTimeZero;
      CMTime duration = editor.compostion.duration;
      CMTimeRange range = CMTimeRangeMake(start, duration);
//      AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:editor.compostion];
//      playItem.videoComposition = editor.videoComposition;
      // 配置导出
      AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:editor.compostion presetName:AVAssetExportPresetHighestQuality];
    // 导出视频的临时保存路径
      NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getVideoNameBaseCurrentTime]];
      unlink([exportPath UTF8String]);
      NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
      // 导出视频的格式 .MOV
      _assetExport.videoComposition = editor.videoComposition;
      _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
      _assetExport.outputURL = exportUrl;
      _assetExport.shouldOptimizeForNetworkUse = YES;
      _assetExport.timeRange = range;
    
      // 导出视频
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
                       [self saveVideo:exportPath];
                       
                   });
                  
                   break;
           }
       }];
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
   NSDateFormatter*dateFormatter = [[NSDateFormatter  alloc]init];
   [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
  return[[dateFormatter stringFromDate:[NSDate date]]stringByAppendingString:@".MOV"];
}
- (IBAction)didclIkcEC:(id)sender {
//    [self composeVideo];
    MixmusicViewController *vc = [MixmusicViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
