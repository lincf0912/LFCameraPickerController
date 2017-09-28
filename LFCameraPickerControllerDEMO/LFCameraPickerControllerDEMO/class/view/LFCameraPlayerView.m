//
//  LFCameraPlayerView.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/9/28.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraPlayerView.h"

@implementation LFCameraPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
    [(AVPlayerLayer*)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

@end
