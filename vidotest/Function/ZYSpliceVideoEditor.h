//
//  ZYVideoEditor.h
//  vidotest
//
//  Created by huzhaohao on 2020/1/4.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef enum : NSUInteger {
    Opacity,
    SwipeLeft,
    SwipeUp,
} ZYTransition;

typedef enum : NSUInteger {
    Ratio9_16,
    Ratio16_9,
} ZYVideoRatio;


@interface ZYSpliceVideoEditor : NSObject

@property (nonatomic)NSArray<AVAsset *>     *clips;
@property (nonatomic)NSArray                *clipRanges;
@property (nonatomic)AVMutableComposition   *compostion;
@property (nonatomic)AVMutableVideoComposition  *videoComposition;

@property (nonatomic)CMTime         trasitionTime;
@property (nonatomic)ZYTransition   transitionType;
@property (nonatomic)CGSize         videoSize;
@property (nonatomic)ZYVideoRatio   videoRatio;

- (void)buildComposition;
@end

