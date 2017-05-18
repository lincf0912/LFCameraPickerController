//
//  UIImage+LFCamera_Orientation.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/15.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "UIImage+LFCamera_Orientation.h"

@implementation UIImage (LFCamera_Orientation)

- (UIImage *)easyFixDeviceOrientation
{
    UIImageOrientation orientation = self.imageOrientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    
    return [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:orientation];
}
@end
