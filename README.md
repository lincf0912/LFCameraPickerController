# LFCameraPickerController

* 支持拍照、录制视频（断点录制）
* 详细使用见LFCameraPickerController.h 的初始化方法

## 调用代码

* LFCameraPickerController *camera = [[LFCameraPickerController alloc] init];
* camera.canPause = YES; //开启断点录制
* camera.flash = YES; //开始闪光灯
* [self presentViewController:camera animated:YES completion:nil];

* 设置代理方法，按钮实现
* imagePicker.delegate;
