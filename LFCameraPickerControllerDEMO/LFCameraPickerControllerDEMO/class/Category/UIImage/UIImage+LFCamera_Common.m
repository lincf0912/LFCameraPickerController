//
//  UIImage+LFCamera_Common.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "UIImage+LFCamera_Common.h"

@implementation UIImage (LFCamera_Common)

- (UIImage *)LFCamera_imageWithWaterMask:(UIImage *)mask
{
    return [self LFCamera_imageWithWaterMask:mask inRect:CGRectMake(0, 0, self.size.width, self.size.height)];
}

- (UIImage *)LFCamera_imageWithWaterMask:(UIImage *)mask inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    
    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //水印图
    [mask drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic; 
}

+ (UIImage *)LFCamera_imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.layer.contentsScale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return maskImage;
}

@end
