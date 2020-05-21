//
//  ViewController.m
//  vidotest
//
//  Created by huzhaohao on 2020/1/4.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ViewController.h"
#import "ZYVideoEditor.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kheight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    ZYVideoEditor *editor;
}
@property (nonatomic)AVPlayer *player;
@property (nonatomic)AVPlayerLayer *playerLayer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.cyanColor;
    editor = [[ZYVideoEditor alloc] init];
    [self initAssets];
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
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
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
      AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:editor.compostion];
      playItem.videoComposition = editor.videoComposition;
    
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
                       
                       
                   });
                  
                   break;
           }
       }];
}
#pragma mark ----生成视频名称---
- (NSString*)getVideoNameBaseCurrentTime {
   NSDateFormatter*vv_dateFormatter_vv = [[NSDateFormatter  alloc]init];
   [vv_dateFormatter_vv setDateFormat:@"yyyyMMddHHmmss"];
  return[[vv_dateFormatter_vv stringFromDate:[NSDate date]]stringByAppendingString:@".MOV"];
}
- (IBAction)didclIkcEC:(id)sender {
    [self composeVideo];
}

@end