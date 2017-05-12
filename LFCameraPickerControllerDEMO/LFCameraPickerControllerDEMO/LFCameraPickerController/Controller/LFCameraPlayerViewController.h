//
//  LFCameraPlayerViewController.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraBaseController.h"

@class SCRecordSession;

@protocol LFCameraPlayerDelegate;

@interface LFCameraPlayerViewController : LFCameraBaseController

@property (strong, nonatomic) SCRecordSession *recordSession;

@property (weak, nonatomic) id<LFCameraPlayerDelegate> delegate;

@end

@protocol LFCameraPlayerDelegate <NSObject>

- (void)lf_cameraPlayerDidCancel:(LFCameraPlayerViewController *)cameraPlayer;
- (void)lf_cameraPlayer:(LFCameraPlayerViewController *)cameraPlayer didFinishVideo:(NSURL *)videoURL;

@end
