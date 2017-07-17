//
//  LFCameraWatermarkOverlayView.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoConfiguration.h"

@interface LFCameraWatermarkOverlayView : UIView <SCVideoOverlay>

@property (nonatomic, strong) UIView *overlayView;

@property (nonatomic, readonly) UIImage *overlayImage;

@end
