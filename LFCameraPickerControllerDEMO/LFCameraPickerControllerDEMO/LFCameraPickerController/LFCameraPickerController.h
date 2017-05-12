//
//  LFCameraPickerController.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, LFCameraType) {
    /** 拍照 */
    LFCameraType_Photo = 1 << 0,
    /** 视频 */
    LFCameraType_Video = 1 << 1,
    /** 拍照与视频 */
    LFCameraType_Both = ~0UL,
};

@protocol LFCameraPickerDelegate;

@interface LFCameraPickerController : UINavigationController

/** 代理 */
@property (nonatomic, weak) id<LFCameraPickerDelegate> pickerDelegate;

/** 模式 默认LFCameraType_Both */
@property (nonatomic, assign) LFCameraType cameraType;
/** 是否允许翻转摄像头，默认YES */
@property (nonatomic, assign) BOOL flipCamera;
/** 默认摄像头方向，默认YES，后摄像头，反之为前摄像头 */
@property (nonatomic, assign) BOOL frontCamera;
/** 是否支持闪光灯，默认NO */
@property (nonatomic, assign) BOOL flash;

/** =====以下属性仅cameraType 包含 LFCameraType_Video时有效===== */

/** 是否可暂停，默认NO */
@property (nonatomic, assign) BOOL canPause;
/** 最长录制时间，默认7s (>0s) */
@property (nonatomic, assign) NSUInteger maxRecordSeconds;
/** 每秒帧数，默认30 （>0） */
@property (nonatomic, assign) NSUInteger framerate;
/** 视频类型(AVFileTypeQuickTimeMovie、AVFileTypeMPEG4（默认）、AVFileTypeAppleM4V、AVFileTypeAppleM4A、AVFileType3GPP)*/
@property (nonatomic, copy) NSString *videoType;

/** =====以上属性仅cameraType 包含 LFCameraType_Video时有效===== */

/** 个性化配置 */

/** 停止录制按钮名称 it work when canPause is YES  */
@property (nonatomic, copy) NSString *stopButtonTitle;

@end

@protocol LFCameraPickerDelegate <NSObject>

@optional
/** 拍照回调 */

/** 视频回调 */

@end
