//
//  LFCameraWatermarkOverlayView.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraWatermarkOverlayView.h"
#import "UIImage+LFCamera_Common.h"

@interface LFCameraWatermarkOverlayView ()

@end

@implementation LFCameraWatermarkOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setOverlayView_Hor:(UIView *)overlayView_Hor
{
    _overlayView_Hor = overlayView_Hor;
    
    _overlayImage_Hor = [UIImage LFCamera_imageWithView:overlayView_Hor];
}

- (void)setOverlayView_Ver:(UIView *)overlayView_Ver
{
    _overlayView_Ver = overlayView_Ver;
    
    _overlayImage_Ver = [UIImage LFCamera_imageWithView:overlayView_Ver];
}


@end
