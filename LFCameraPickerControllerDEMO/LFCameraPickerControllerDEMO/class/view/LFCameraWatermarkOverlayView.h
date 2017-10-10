//
//  LFCameraWatermarkOverlayView.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoConfiguration.h"

@interface LFCameraWatermarkOverlayView : UIImageView <SCVideoOverlay>

@property (nonatomic, strong) UIView *overlayView_Ver;
@property (nonatomic, strong) UIView *overlayView_Hor;

@property (nonatomic, readonly) UIImage *overlayImage_Ver;
@property (nonatomic, readonly) UIImage *overlayImage_Hor;

@end
