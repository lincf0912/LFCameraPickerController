//
//  UIImage+LFCamera_Orientation.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/15.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LFCamera_Orientation)

// 使用内存太高，建议使用easyRotateImageOrientation
- (UIImage *)easyFixDeviceOrientation;

- (UIImage *)easyRotateImageOrientation:(UIImageOrientation)orient context:(nullable CIContext *)context;

@end

NS_ASSUME_NONNULL_END
