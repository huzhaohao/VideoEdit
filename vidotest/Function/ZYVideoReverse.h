//
//  ZYVideoReverse.h
//  vidotest
//
//  Created by huzhaohao on 2020/6/11.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol ZYVideoReverseDelegate <NSObject>

@optional
- (void)didFinishReverse:(bool)success withError:(NSError *)error;
@end


@interface ZYVideoReverse : NSObject

@property (weak, nonatomic)         id<ZYVideoReverseDelegate> delegate;
@property (readwrite, nonatomic)    BOOL showDebug;
@property (strong, nonatomic)       NSDictionary* readerOutputSettings;


- (void)reverseVideoAtPath:(NSString *)inputPath outputPath:(NSString *)outputPath;


@end


