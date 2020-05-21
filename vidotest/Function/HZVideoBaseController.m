//
//  HZVideoBaseController.m
//  vidotest
//
//  Created by huzhaohao on 2020/5/21.
//  Copyright © 2020 huzhaohao. All rights reserved.
//

#import "HZVideoBaseController.h"

@interface HZVideoBaseController ()

@end

@implementation HZVideoBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
             [self dismissViewControllerAnimated:YES completion:nil];
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
