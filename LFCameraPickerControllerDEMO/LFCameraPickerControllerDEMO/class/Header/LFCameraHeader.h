//
//  LFCameraHeader.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBundle+LFCamera.h"

#ifndef LFCameraHeader_h
#define LFCameraHeader_h

#define LFCamera_bundleImageNamed(name) [NSBundle lf_camera_imageNamed:name]

extern CGFloat const LFCamera_bottomViewHeight;
extern CGFloat const LFCamera_bottomMargin;
extern CGFloat const LFCamera_recordButtonHeight;
extern CGFloat const LFCamera_buttonHeight;

extern const CGFloat LFCamera_topViewHeight;

#endif /* LFCameraHeader_h */
