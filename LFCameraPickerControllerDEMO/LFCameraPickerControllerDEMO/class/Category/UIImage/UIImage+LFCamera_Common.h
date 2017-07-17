//
//  UIImage+LFCamera_Common.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LFCamera_Common)


/**
 添加水印

 @param mask 水印层
 @return 图片
 */
- (UIImage *)LFCamera_imageWithWaterMask:(UIImage *)mask;


/**
 视图转图片

 @param view 视图
 @return 图片
 */
+ (UIImage *)LFCamera_imageWithView:(UIView *)view;

@end
