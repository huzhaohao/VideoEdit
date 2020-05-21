//
//  HZVideoBaseController.h
//  vidotest
//
//  Created by huzhaohao on 2020/5/21.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZVideoBaseController : UIViewController

- (void)saveVideo:(NSString *)videoPath;
- (NSString*)getVideoNameBaseCurrentTime;

@end

NS_ASSUME_NONNULL_END
