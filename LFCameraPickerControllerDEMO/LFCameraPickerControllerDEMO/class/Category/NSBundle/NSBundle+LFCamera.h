//
//  NSBundle+LFCamera.h
//  LFCameraPickerControllerDEMO
//
//  Created by TsanFeng Lam on 2019/3/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (LFCamera)

+ (instancetype)lf_cameraBundle;
+ (UIImage *)lf_camera_imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
