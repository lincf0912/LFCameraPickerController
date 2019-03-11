//
//  NSBundle+LFCamera.m
//  LFCameraPickerControllerDEMO
//
//  Created by TsanFeng Lam on 2019/3/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "NSBundle+LFCamera.h"
#import "LFCameraPickerController.h"

NSString *const LFCameraStrings = @"LFCameraPickerController";

@implementation NSBundle (LFCamera)


+ (instancetype)lf_cameraBundle
{
    static NSBundle *lfCameraBundle = nil;
    if (lfCameraBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        lfCameraBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[LFCameraPickerController class]] pathForResource:LFCameraStrings ofType:@"bundle"]];
    }
    return lfCameraBundle;
}

+ (UIImage *)lf_camera_imageNamed:(NSString *)name
{
    //  [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", kBundlePath, name]]
    NSString *extension = name.pathExtension.length ? name.pathExtension : @"png";
    NSString *defaultName = [name stringByDeletingPathExtension];
    NSString *bundleName = [defaultName stringByAppendingString:@"@2x"];
    //    CGFloat scale = [UIScreen mainScreen].scale;
    //    if (scale == 3) {
    //        bundleName = [name stringByAppendingString:@"@3x"];
    //    } else {
    //        bundleName = [name stringByAppendingString:@"@2x"];
    //    }
    UIImage *image = [UIImage imageWithContentsOfFile:[[self lf_cameraBundle] pathForResource:bundleName ofType:extension]];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[[self lf_cameraBundle] pathForResource:defaultName ofType:extension]];
    }
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
