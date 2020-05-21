//
//  ZYMixAudioEditor.h
//  vidotest
//
//  Created by huzhaohao on 2020/5/21.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZYMixAudioEditor : NSObject

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVURLAsset *auAsset;
- (void)buildAudioWithVideoVolume:(float)videoVolume BGMVolume:(float)BGMVolume;


@property (nonatomic)AVMutableComposition   *compostion;
@property (nonatomic, copy) AVAudioMix *audioMix;

@end

NS_ASSUME_NONNULL_END
