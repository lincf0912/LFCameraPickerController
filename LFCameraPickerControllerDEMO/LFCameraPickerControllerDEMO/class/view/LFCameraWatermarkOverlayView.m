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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (void)setOverlayView:(UIView *)overlayView
{
    _overlayView = overlayView;
    _overlayView.frame = self.bounds;
    [self addSubview:overlayView];
    
    _overlayImage = [UIImage LFCamera_imageWithView:overlayView];
}

@end
