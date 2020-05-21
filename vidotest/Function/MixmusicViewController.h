//
//  MixmusicViewController.h
//  GQWDY
//
//  Created by huzhaohao on 2020/5/20.
//  Copyright © 2020 JiaMin Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface MixmusicViewController : UIViewController

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVURLAsset *auAsset;

@end

NS_ASSUME_NONNULL_END
