//
//  ZYSpeedVideoEditor.h
//  vidotest
//
//  Created by huzhaohao on 2020/5/22.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZYSpeedVideoEditor : NSObject

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, assign) CGFloat scale;

@property (copy ,nonatomic) void(^flishCurrentBlock)(NSString *path);
- (void)exportWithPath:(NSString *)exportPath;

@end

NS_ASSUME_NONNULL_END
