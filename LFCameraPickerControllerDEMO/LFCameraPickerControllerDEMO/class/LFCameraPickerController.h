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

typedef NS_ENUM(NSUInteger, LFCameraPresetQuality) {
    /** 低 */
    LFCameraPresetQuality_Low,
    /** 中 */
    LFCameraPresetQuality_Medium,
    /** 高 */
    LFCameraPresetQuality_Highest,
};

typedef NS_ENUM(NSUInteger, LFCameraOverlayOrientation) {
    /** 竖屏 */
    LFCameraOverlayOrientation_Ver,
    /** 横屏 */
    LFCameraOverlayOrientation_Hor,
};

@protocol LFCameraPickerDelegate;

@interface LFCameraPickerController : UINavigationController

/** 代理 */
@property (nonatomic, weak) id<LFCameraPickerDelegate> pickerDelegate;

/** 模式 默认LFCameraType_Both */
@property (nonatomic, assign) LFCameraType cameraType;
/** 是否允许翻转摄像头，默认YES */
@property (nonatomic, assign) BOOL flipCamera;
/** 默认摄像头方向，默认NO，后摄像头，反之为前摄像头 */
@property (nonatomic, assign) BOOL frontCamera;
/** 是否支持闪光灯，默认NO */
@property (nonatomic, assign) BOOL flash;

/** =====以下属性仅cameraType 包含 LFCameraType_Video时有效===== */

/** 视频保存的地址 */
@property (nonatomic, strong) NSURL *videoUrl;
/** 是否可暂停，默认NO */
@property (nonatomic, assign) BOOL canPause;
/** 最短录制时间，默认0.3s （>=0s）canPause is YES，Invalid */
@property (nonatomic, assign) float minRecordSeconds;
/** 最长录制时间，默认7s (>minRecordSeconds) */
@property (nonatomic, assign) NSUInteger maxRecordSeconds;
/** 视频类型(AVFileTypeQuickTimeMovie、AVFileTypeMPEG4（默认）、AVFileTypeAppleM4V、AVFileTypeAppleM4A、AVFileType3GPP)*/
@property (nonatomic, copy) NSString *videoType;
/** 每秒帧数，默认30 （>0） */
@property (nonatomic, assign) NSUInteger framerate;
/** 视频、音频质量，默认LFCameraPresetQuality_Medium */
@property (nonatomic, assign) LFCameraPresetQuality presetQuality;

/** =====以上属性仅cameraType 包含 LFCameraType_Video时有效===== */

/** 个性化配置 */

/** 拍照与录制视频是否保存到系统相册，默认YES */
@property (nonatomic, assign) BOOL autoSavePhotoAlbum;
/** 默认显示等待的文字 */
@property (nonatomic, copy) NSString *processHintStr;

/** 水印层 默认NO 实现代理 lf_cameraPickerOverlayView: */
@property (nonatomic, assign) BOOL activeOverlay;

- (void)showProgressHUDText:(NSString *)text isTop:(BOOL)isTop;
- (void)showProgressHUDText:(NSString *)text;
- (void)showProgressHUD;
- (void)hideProgressHUD;
@end

@protocol LFCameraPickerDelegate <NSObject>

@optional
/** 拍照回调 */
- (void)lf_cameraPickerController:(LFCameraPickerController *)picker didFinishPickingImage:(UIImage *)image;
/** 视频回调 */
- (void)lf_cameraPickerController:(LFCameraPickerController *)picker didFinishPickingVideo:(NSURL *)videoUrl duration:(NSTimeInterval)duration;
/** 取消 */
- (void)lf_cameraPickerDidCancel:(LFCameraPickerController *)picker;

/** 水印视图(提供横屏与竖屏的水印图) activeOverlay = YES 有效 */
- (UIView *)lf_cameraPickerOverlayView:(LFCameraOverlayOrientation)overlayOrientation;

@end
