//
//  ZYVideoEditor.m
//  vidotest
//
//  Created by huzhaohao on 2020/1/4.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "ZYVideoEditor.h"

@interface ZYVideoEditor ()


@end

@implementation ZYVideoEditor

- (instancetype)init
{
    self = [super init];
    if (self) {
        //默认过渡动画时间1秒 淡出
        _trasitionTime = CMTimeMake(1, 1);
        _transitionType = Opacity;
        _videoSize = CGSizeMake(1080, 1920);
        _videoRatio = Ratio9_16;
    }
    return self;
}

- (void)buildComposition {
    if(_clips.count == 0 && _clips == nil ){
        _compostion = nil;
        _videoComposition = nil;
        return;
    }
    AVMutableComposition *muComposition = [[AVMutableComposition alloc] init];
    AVMutableVideoComposition *muVideoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:muComposition];
    [self buildTransitionCompositionAndRepairVideoSize:muComposition with:muVideoComposition];
    muVideoComposition.frameDuration = CMTimeMake(1, 30);
    muVideoComposition.renderSize = _videoSize;
    _compostion = muComposition;
    _videoComposition = muVideoComposition;
}

- (void)buildTransitionCompositionAndRepairVideoSize:(AVMutableComposition *)muComposition with:(AVMutableVideoComposition *)muVideoComposition {
    if(_videoRatio == Ratio16_9){
        _videoSize = CGSizeMake(_videoSize.height,_videoSize.width);
        muComposition.naturalSize = _videoSize;
    }
    muComposition.naturalSize = _videoSize;
    NSMutableArray *comVideoTracks = [[NSMutableArray alloc] init];
    for (int i=0; i < 2; i++) {
       AVMutableCompositionTrack  *track = [muComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [comVideoTracks addObject:track];
    }
    NSMutableArray *passThroughTimeRanges = [[NSMutableArray alloc] init];
    NSMutableArray *transitionTimeRanges = [[NSMutableArray alloc] init];
    CMTime startTime = kCMTimeZero;
    for (int i = 0; i < _clips.count; i++) {
        AVAsset *asset = _clips[i];
        AVAssetTrack *oriVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        if (oriVideoTrack == nil) {
            return;
        }
        AVMutableCompositionTrack *comVideoTrack = comVideoTracks[i % 2];
        CMTimeRange clipRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
        [comVideoTrack insertTimeRange:clipRange ofTrack:oriVideoTrack atTime:startTime error:nil];
        CMTimeRange tempRange = CMTimeRangeMake(startTime, clipRange.duration);
        if (i > 0) {
            tempRange.start = CMTimeAdd(tempRange.start, _trasitionTime);
            tempRange.duration = CMTimeSubtract(tempRange.duration, _trasitionTime);
        }
        if (i+1 < _clips.count) {
           tempRange.duration = CMTimeSubtract(tempRange.duration, _trasitionTime);
        }
        NSValue *value =  [NSValue valueWithCMTimeRange:tempRange];
        [passThroughTimeRanges addObject:value];


        startTime = CMTimeAdd(startTime, clipRange.duration);
        startTime = CMTimeSubtract(startTime, _trasitionTime);
        if (i + 1 < _clips.count){
            NSValue *value =  [NSValue valueWithCMTimeRange:CMTimeRangeMake(startTime, _trasitionTime)];
            [transitionTimeRanges addObject:value];
        }
    }
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    for (int i = 0; i < _clips.count; i++) {
        AVAsset *asset = _clips[i];
        AVMutableCompositionTrack *comVideoTrack = comVideoTracks[i % 2];
        AVMutableVideoCompositionInstruction *passThroughInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        NSValue *value0 = passThroughTimeRanges[i];
        passThroughInstruction.timeRange = [value0 CMTimeRangeValue];
        AVMutableVideoCompositionLayerInstruction  *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:comVideoTrack];
        [self changeVideoSize:asset with:passThroughLayer];

        passThroughInstruction.layerInstructions = [[NSArray alloc] initWithObjects:passThroughLayer, nil];
        [instructions addObject: passThroughInstruction];

        if (i+1 < _clips.count) {
            AVMutableVideoCompositionInstruction *transitionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
            NSValue *value0 = transitionTimeRanges[i];
            transitionInstruction.timeRange = [value0 CMTimeRangeValue];
            AVMutableVideoCompositionLayerInstruction* fromLayer =  [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:comVideoTrack];
            AVMutableVideoCompositionLayerInstruction* toLayer =  [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:comVideoTracks[1 - i % 2]];
            [self changeVideoSize:asset with:fromLayer];
            [self changeVideoSize:_clips[i + 1] with:toLayer];
            [self videoTransitionFromLayer:fromLayer ToLayer:toLayer of:asset Range:[value0 CMTimeRangeValue]];

            transitionInstruction.layerInstructions = [[NSArray alloc] initWithObjects:fromLayer,toLayer, nil];
            [instructions addObject:transitionInstruction];
         }

    }
        muVideoComposition.instructions = instructions;
}
- (void)videoTransitionFromLayer:(AVMutableVideoCompositionLayerInstruction*)fromLayer ToLayer:(AVMutableVideoCompositionLayerInstruction*)toLayer of:(AVAsset*)asset Range:(CMTimeRange)timeRange{
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *oriVideoTrack = [tracks firstObject];
    CGSize natureSize = oriVideoTrack.naturalSize;
    switch (_transitionType) {
        case Opacity:{
            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0 timeRange:timeRange];
            [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:timeRange];
        }
            break;
        case SwipeLeft:{
            [fromLayer setCropRectangleRampFromStartCropRectangle:CGRectMake(0, 0,_videoSize.width, _videoSize.height) toEndCropRectangle:CGRectMake(0, 0,0, _videoSize.height) timeRange:timeRange];
        }
            break;
        case SwipeUp: {
            if ([self degressFromVideo:asset] == 90) {
                [fromLayer setCropRectangleRampFromStartCropRectangle:CGRectMake(0, 0,_videoSize.width, _videoSize.height) toEndCropRectangle:CGRectMake(0, 0,0, _videoSize.height) timeRange:timeRange];
            } else {
                CGFloat width = natureSize.width > _videoSize.width ? natureSize.width : _videoSize.width;
                [fromLayer setCropRectangleRampFromStartCropRectangle:CGRectMake(0, 0,width, _videoSize.height) toEndCropRectangle:CGRectMake(0, 0,width, 0) timeRange:timeRange];
            }

        }
            break;

        default:
            break;
    }
}


- (void)changeVideoSize:(AVAsset *)asset with:(AVMutableVideoCompositionLayerInstruction *)passThroughLayer {
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *oriVideoTrack = [tracks firstObject];
    CGSize natureSize = oriVideoTrack.naturalSize;
    if ([self degressFromVideo:asset] == 90) {
        natureSize = CGSizeMake(natureSize.height, natureSize.width);
    }
    if ((int)natureSize.width % 2 != 0) {
        natureSize.width += 1.0;
    }

    if (_videoRatio == Ratio9_16) {
        if ([self degressFromVideo:asset] == 90){
            CGFloat height = _videoSize.width * natureSize.height / natureSize.width;
            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation( _videoSize.width, _videoSize.height/2-natureSize.height/2);
            CGAffineTransform  t = CGAffineTransformScale(translateToCenter,_videoSize.width/natureSize.width, height/natureSize.height);
            CGAffineTransform mixedTransform = CGAffineTransformRotate(t, M_PI/2);
            [passThroughLayer setTransform:mixedTransform atTime:kCMTimeZero];
        }else{
            CGFloat height = _videoSize.width * natureSize.height / natureSize.width;
            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(0, _videoSize.height/2 - height/2);
            CGAffineTransform  t = CGAffineTransformScale(translateToCenter,_videoSize.width/natureSize.width, height/natureSize.height);
            [passThroughLayer setTransform:t atTime:kCMTimeZero];
        }
    } else {
        if ([self degressFromVideo:asset] == 90){
            CGFloat width = _videoSize.height * natureSize.width / natureSize.height;
            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation( _videoSize.width/2 + width/2, 0);
            CGAffineTransform  t = CGAffineTransformScale(translateToCenter,width/natureSize.width, _videoSize.height/natureSize.height);
            CGAffineTransform mixedTransform = CGAffineTransformRotate(t, M_PI/2);
            [passThroughLayer setTransform:mixedTransform atTime:kCMTimeZero];
        }else{
            CGFloat width = _videoSize.height * natureSize.width / natureSize.height;
            CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(_videoSize.width/2 - width/2, 0);
            CGAffineTransform  t = CGAffineTransformScale(translateToCenter,width/natureSize.width, _videoSize.height/natureSize.height);
            [passThroughLayer setTransform:t atTime:kCMTimeZero];
        }
    }

}
//判断角度
- (NSInteger)degressFromVideo:(AVAsset *)asset {
    NSInteger degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        AVAssetTrack *videoTrack = [tracks firstObject];
        CGAffineTransform t = videoTrack.preferredTransform;
         if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
              // Portrait
              degress = 90;
          }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
              // PortraitUpsideDown
              degress = 270;
          }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
              // LandscapeRight
              degress = 0;
          }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
              // LandscapeLeft
              degress = 180;
          }
    }
    return degress;
}


@end
