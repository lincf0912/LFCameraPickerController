//
//  LFCameraDisplayController.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraBaseController.h"
#import <AVFoundation/AVFoundation.h>

@protocol LFCameraDisplayDelegate;

@interface LFCameraDisplayController : LFCameraBaseController

/** 图片预览 */
@property (strong, nonatomic) UIImage *photo;
/** 视频预览 */
@property (strong, nonatomic) AVAsset *asset;
/** 水印图片 */
@property (strong, nonatomic) UIImage *overlayImage;



@property (weak, nonatomic) id<LFCameraDisplayDelegate> delegate;

@end

@protocol LFCameraDisplayDelegate <NSObject>

- (void)lf_cameraDisplayDidCancel:(LFCameraDisplayController *)cameraDisplay;
- (void)lf_cameraDisplay:(LFCameraDisplayController *)cameraDisplay didFinishVideo:(NSURL *)videoURL;
- (void)lf_cameraDisplay:(LFCameraDisplayController *)cameraDisplay didFinishImage:(UIImage *)image;

@end
