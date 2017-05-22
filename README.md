# LFCameraPickerController

* 依赖SCRecorder库
* 支持拍照、录制视频（断点录制）
* 详细使用见LFCameraPickerController.h 的初始化方法

## Installation 安装

* CocoaPods：pod 'LFCameraPickerController'
* 手动导入：将LFCameraPickerControllerDEMO\class文件夹拽入项目中，导入头文件：#import "LFCameraPickerController.h"

## 调用代码

* LFCameraPickerController *camera = [[LFCameraPickerController alloc] init];
* camera.canPause = YES; //开启断点录制
* camera.flash = YES; //允许调节闪光灯
* [self presentViewController:camera animated:YES completion:nil];

* 设置代理方法，按钮实现
* camera.pickerDelegate;
