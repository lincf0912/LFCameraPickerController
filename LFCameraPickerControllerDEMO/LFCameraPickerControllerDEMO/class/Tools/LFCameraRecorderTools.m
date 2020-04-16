//
//  LFCameraRecorderTools.m
//  LFCameraPickerControllerDEMO
//
//  Created by TsanFeng Lam on 2020/4/16.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import "LFCameraRecorderTools.h"

@implementation LFCameraRecorderTools

+ (NSString *)captureSessionPresetForDimension:(CMVideoDimensions)videoDimension {
    
    if (@available(iOS 9.0, *)) {
        if (videoDimension.width >= 3840 && videoDimension.height >= 2160) {
            return AVCaptureSessionPreset3840x2160;
        }
    }
    if (videoDimension.width >= 1920 && videoDimension.height >= 1080) {
        return AVCaptureSessionPreset1920x1080;
    }
    if (videoDimension.width >= 1280 && videoDimension.height >= 720) {
        return AVCaptureSessionPreset1280x720;
    }
    if (videoDimension.width >= 640 && videoDimension.height >= 480) {
        return AVCaptureSessionPreset640x480;
    }
    if (videoDimension.width >= 352 && videoDimension.height >= 288) {
        return AVCaptureSessionPreset352x288;
    }
    
    return AVCaptureSessionPresetHigh;
}

+ (CMVideoDimensions)bestVideoDimensionsWithAllDevices:(CMTimeScale)frameRate {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    CMVideoDimensions highestCompatibleDimension = (CMVideoDimensions){0, 0};
    BOOL lowestSet = NO;
    
    for (AVCaptureDevice *device in videoDevices) {
        CMVideoDimensions highestDeviceDimension;
        highestDeviceDimension.width = 0;
        highestDeviceDimension.height = 0;
        
        for (AVCaptureDeviceFormat *format in device.formats) {
            CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            
            if (dimension.width * dimension.height > highestDeviceDimension.width * highestDeviceDimension.height) {
                for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                    if (range.minFrameDuration.timescale >= frameRate && range.maxFrameDuration.timescale <= frameRate) {
                        highestDeviceDimension = dimension;
                    }
                }
            }
        }
        
        if (!lowestSet || (highestCompatibleDimension.width * highestCompatibleDimension.height > highestDeviceDimension.width * highestDeviceDimension.height)) {
            lowestSet = YES;
            highestCompatibleDimension = highestDeviceDimension;
        }
        
    }
    return highestCompatibleDimension;
}

+ (NSString *)bestCaptureSessionPresetCompatibleWithAllDevices:(CMTimeScale)frameRate
{
    CMVideoDimensions highestCompatibleDimension = [self bestVideoDimensionsWithAllDevices:frameRate];

    return [self captureSessionPresetForDimension:highestCompatibleDimension];
}

+ (UInt64)bitrateWithCaptureSessionPreset:(NSString *)preset
{
    if (@available(iOS 9.0, *)) {
        if ([preset isEqualToString:AVCaptureSessionPreset3840x2160]) {
            return 31000000;
        }
    }
    if ([preset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        return 7900000;
    }
    if ([preset isEqualToString:AVCaptureSessionPreset1280x720]) {
        return 3500000;
    }
    if ([preset isEqualToString:AVCaptureSessionPreset640x480]) {
        return 1200000;
    }
    if ([preset isEqualToString:AVCaptureSessionPreset352x288]) {
        return 770000;
    }
    
    return 3500000;
}

@end
