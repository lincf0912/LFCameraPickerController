//
//  LFCameraRecorderTools.h
//  LFCameraPickerControllerDEMO
//
//  Created by TsanFeng Lam on 2020/4/16.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFCameraRecorderTools : NSObject

/**
 Returns the best session preset that is compatible with all available video
 devices (front and back camera). It will ensure that buffer output from
 both camera has the same resolution.
 */
+ (NSString *__nonnull)bestCaptureSessionPresetCompatibleWithAllDevices:(CMTimeScale)frameRate;

+ (CMVideoDimensions)bestVideoDimensionsWithAllDevices:(CMTimeScale)frameRate;


+ (UInt64)bitrateWithCaptureSessionPreset:(NSString *)preset;
@end

NS_ASSUME_NONNULL_END
