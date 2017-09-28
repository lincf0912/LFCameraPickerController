//
//  LFCameraPlayerView.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/9/28.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LFCameraPlayerView : UIImageView

@property (nonatomic, readonly) AVPlayer *player;

- (void)setPlayer:(AVPlayer*)player;

@end
