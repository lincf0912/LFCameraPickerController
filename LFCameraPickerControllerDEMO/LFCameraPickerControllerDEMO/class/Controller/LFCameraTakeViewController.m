//
//  LFCameraTakeViewController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraTakeViewController.h"
#import "LFCameraHeader.h"
#import "LFCameraPickerController.h"
#import "LFCameraDisplayController.h"
#import "LFCameraWatermarkOverlayView.h"

#import "LFCameraRecorderTools.h"

#import "UIImage+LFCamera_Orientation.h"

#import "LFRecordButton.h"
#import "SCRecorder.h"

#import <CoreMotion/CoreMotion.h>

@interface LFCameraTakeViewController () <SCRecorderDelegate, LFCameraDisplayDelegate>

/** 录制神器 */
@property (strong, nonatomic) SCRecorder *recorder;
/** 拍照图片 */
@property (strong, nonatomic) UIImage *photo;
/** 图片方向 */
@property (assign, nonatomic) UIImageOrientation imageOrientation;
/** 预览视图 */
@property (weak, nonatomic) UIView *previewView;
/** 录制视图 */
@property (strong, nonatomic) SCRecorderToolsView *focusView;
/** 水印层 */
@property (strong, nonatomic) LFCameraWatermarkOverlayView *overlayView;
/* 顶部栏 */
@property (weak, nonatomic) UIView *topView;
/* 底部栏 */
@property (weak, nonatomic) UIView *bottomView;


/** 闪光灯 */
@property (weak, nonatomic) UIButton *flashButton;
/** 摄像头切换 */
@property (weak, nonatomic) UIButton *flipCameraButton;
/** 回制按钮 */
@property (weak, nonatomic) UIButton *backToRecord;
/** 停止按钮 */
@property (weak, nonatomic) UIButton *stopButton;

/** 提示消息 */
@property (weak, nonatomic) UILabel *tipsLabel;

/** 录制按钮 */
@property (weak, nonatomic) LFRecordButton *recordButton;

/** 陀螺仪 */
@property (strong, nonatomic) CMMotionManager *mManager;
@property (assign, nonatomic) UIInterfaceOrientation myOrientation;

/** 实际preview的尺寸 */
@property (assign, nonatomic) CGSize previewSize;

@end

@implementation LFCameraTakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    _myOrientation = UIInterfaceOrientationUnknown;

    /** 监听设备方向改变(这种方式受系统方向锁影响) */
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [self showAlertViewWithTitle:@"提示" message:@"请允许应用访问你的相机" complete:nil];
    } else {
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            [self showAlertViewWithTitle:@"提示" message:@"请允许应用访问你的麦克风" complete:nil];
        }
    }
    
    /** 初始化陀螺仪 */
    _mManager = [[CMMotionManager alloc] init];
    
    /** 初始化视图 */
    [self initView];
    
    /** 初始化Recorder */
    [self initRecorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)interfaceOrientationDidChange:(UIInterfaceOrientation)orientation
{
    if (self.myOrientation != orientation) {
        self.myOrientation = orientation;
        CGFloat angle = 0;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = M_PI_2;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = -M_PI_2;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationUnknown:
                break;
        }
        //    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
            {
                self.imageOrientation = UIImageOrientationUp;
                switch ([UIApplication sharedApplication].statusBarOrientation) {
                    case UIInterfaceOrientationPortrait:
                        self.imageOrientation = UIImageOrientationUp;
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        self.imageOrientation = UIImageOrientationLeft;
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        self.imageOrientation = UIImageOrientationRight;
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        self.imageOrientation = UIImageOrientationDown;
                        break;
                    default:
                        break;
                }
                if (self.recorder.session.segments.count == 0 && self.recorder.isRecording == NO) {
                    self.recorder.videoConfiguration.affineTransform = CGAffineTransformMakeRotation(0-angle);
                    [self.recorder.session deinitialize];
                    [self getOverlayView:orientation];
                    [UIView animateWithDuration:0.25f animations:^{
                        self.overlayView.transform = CGAffineTransformMakeRotation(0+angle);
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    }];
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.flashButton.transform = CGAffineTransformMakeRotation(0+angle);
                    self.flipCameraButton.transform = CGAffineTransformMakeRotation(0+angle);
                }];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                self.imageOrientation = UIImageOrientationLeft;
                switch ([UIApplication sharedApplication].statusBarOrientation) {
                    case UIInterfaceOrientationPortrait:
                        self.imageOrientation = UIImageOrientationLeft;
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        self.imageOrientation = UIImageOrientationDown;
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        self.imageOrientation = UIImageOrientationUp;
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        self.imageOrientation = UIImageOrientationRight;
                        break;
                    default:
                        break;
                }
                if (self.recorder.session.segments.count == 0 && self.recorder.isRecording == NO) {
                    self.recorder.videoConfiguration.affineTransform = CGAffineTransformMakeRotation(-M_PI_2-angle);
                    [self.recorder.session deinitialize];
                    [self getOverlayView:orientation];
                    [UIView animateWithDuration:0.25f animations:^{
                        self.overlayView.transform = CGAffineTransformMakeRotation(M_PI_2+angle);
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    } completion:^(BOOL finished) {
                        /** 首次启动时，无法在动画中修改位置 */
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    }];
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.flashButton.transform = CGAffineTransformMakeRotation(M_PI_2+angle);
                    self.flipCameraButton.transform = CGAffineTransformMakeRotation(M_PI_2+angle);
                }];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                self.imageOrientation = UIImageOrientationRight;
                switch ([UIApplication sharedApplication].statusBarOrientation) {
                    case UIInterfaceOrientationPortrait:
                        self.imageOrientation = UIImageOrientationRight;
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        self.imageOrientation = UIImageOrientationUp;
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        self.imageOrientation = UIImageOrientationDown;
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        self.imageOrientation = UIImageOrientationLeft;
                        break;
                    default:
                        break;
                }
                if (self.recorder.session.segments.count == 0 && self.recorder.isRecording == NO) {
                    self.recorder.videoConfiguration.affineTransform = CGAffineTransformMakeRotation(M_PI_2-angle);
                    [self.recorder.session deinitialize];
                    [self getOverlayView:orientation];
                    [UIView animateWithDuration:0.25f animations:^{
                        self.overlayView.transform = CGAffineTransformMakeRotation(-M_PI_2+angle);
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    } completion:^(BOOL finished) {
                        /** 首次启动时，无法在动画中修改位置 */
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    }];
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.flashButton.transform = CGAffineTransformMakeRotation(-M_PI_2+angle);
                    self.flipCameraButton.transform = CGAffineTransformMakeRotation(-M_PI_2+angle);
                }];
            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                self.imageOrientation = UIImageOrientationDown;
                switch ([UIApplication sharedApplication].statusBarOrientation) {
                    case UIInterfaceOrientationPortrait:
                        self.imageOrientation = UIImageOrientationDown;
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        self.imageOrientation = UIImageOrientationRight;
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        self.imageOrientation = UIImageOrientationLeft;
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        self.imageOrientation = UIImageOrientationUp;
                        break;
                    default:
                        break;
                }
                if (self.recorder.session.segments.count == 0 && self.recorder.isRecording == NO) {
                    self.recorder.videoConfiguration.affineTransform = CGAffineTransformMakeRotation(M_PI-angle);
                    [self.recorder.session deinitialize];
                    [self getOverlayView:orientation];
                    [UIView animateWithDuration:0.25f animations:^{
                        self.overlayView.transform = CGAffineTransformMakeRotation(M_PI+angle);
                        self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
                        self.overlayView.center = self.view.center;
                    }];
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.flashButton.transform = CGAffineTransformMakeRotation(M_PI+angle);
                    self.flipCameraButton.transform = CGAffineTransformMakeRotation(M_PI+angle);
                }];
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /** 开启陀螺仪 */
    [self startUpdateAccelerometer];
    
    /** 激活摄像头 */
    [self prepareSession];
    
    [UIView animateWithDuration:0.25f delay:.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tipsLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:4.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.tipsLabel.alpha = 0.f;
        } completion:^(BOOL finished) {
            
        }];
    }];
    [self.recorder startRunning];
    [self.recorder focusCenter];
    // 记录相机的显示大小，正常来说它是全屏的。但刘海屏手机是不会全屏。
    self.previewSize = [self.recorder.previewLayer rectForMetadataOutputRectOfInterest:CGRectMake(0, 0, 1, 1)].size;
    // 重新调整水印层并获取水印
    self.overlayView.frame = (CGRect){CGPointZero, self.previewSize};
    self.overlayView.center = self.view.center;
    [self getOverlayView:self.myOrientation];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGFloat top = 0, bottom = 0;
    if (@available(iOS 11.0, *)) {
        top += self.view.safeAreaInsets.top;
        bottom += self.view.safeAreaInsets.bottom;
    }
    _topView.frame = CGRectMake(0, top, width, LFCamera_topViewHeight);
    _bottomView.frame = CGRectMake(0, height-bottom-LFCamera_bottomViewHeight-LFCamera_bottomMargin, width, LFCamera_bottomViewHeight);
    CGRect tempTipsRect = _tipsLabel.frame;
    tempTipsRect.origin.x = (width-CGRectGetWidth(tempTipsRect))/2;
    tempTipsRect.origin.y = CGRectGetMinY(_bottomView.frame)-CGRectGetHeight(tempTipsRect)-5;
    _tipsLabel.frame = tempTipsRect;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopUpdateAccelerometer];
    
    self.tipsLabel.alpha = 0.f;
    /** 还原缩放 */
    _recorder.videoZoomFactor = 1;
    /** 在 session 完全停止下来之前会始终阻塞线程，拍照系统需要播放声音 */
    [self.recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _mManager = nil;
    _recorder.previewView = nil;
    [_recorder.session cancelSession:nil];
    
}

#pragma mark - SCRecorder 操作
- (void)prepareSession {
    
    if (_recorder.session == nil) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    [self retakeRecordSession];
    [self updateTimeRecorded];
}

- (void)updateTimeRecorded {
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    CGFloat time = CMTimeGetSeconds(currentTime);
    self.recordButton.progress = time / cameraPicker.maxRecordSeconds;
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    /** 非暂停模式才启用最小限制 */
    if (!cameraPicker.canPause && CMTimeGetSeconds(recordSession.duration) < cameraPicker.minRecordSeconds) {
        [self takePhoto];
    } else {
        [self showVideoView];
    }
    /** 重置录制按钮 */
    [self.recordButton reset];
    
}

- (void)retakeRecordSession {

    self.photo = nil;
    self.backToRecord.selected = NO;
    self.backToRecord.enabled = NO;
    self.stopButton.enabled = NO;
    
    SCRecordSession *recordSession = _recorder.session;

    if (recordSession != nil) {
        [recordSession deinitialize];
        [recordSession removeAllSegments:YES];
    }
}

- (void)takePhoto
{
#if TARGET_OS_SIMULATOR
    [self showImageView];
#else
    __weak typeof(self) weakSelf = self;
    [self.recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            weakSelf.photo = image;
            [weakSelf showImageView];
        } else {
            [weakSelf showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription complete:nil];
        }
    }];
#endif
}


#pragma mark - SCRecorderDelegate
//- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
//    NSLog(@"Skipped video buffer");
//}
//
//- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
//    NSLog(@"Reconfigured audio input: %@", audioInputError);
//}
//
//- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
//    NSLog(@"Reconfigured video input: %@", videoInputError);
//}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

//- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
//    if (error == nil) {
//        NSLog(@"Initialized audio in record session");
//    } else {
//        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
//    }
//}
//
//- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
//    if (error == nil) {
//        NSLog(@"Initialized video in record session");
//    } else {
//        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
//    }
//}
//
//- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
//    NSLog(@"Began record segment: %@", error);
//}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    self.backToRecord.enabled = YES;
    self.stopButton.enabled = YES;
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecorded];
}

#pragma mark - LFCameraDisplayDelegate
- (void)lf_cameraDisplayDidCancel:(LFCameraDisplayController *)cameraDisplay
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)lf_cameraDisplayDidClose:(LFCameraDisplayController *)cameraDisplay
{
    [self closeAction];
}
- (void)lf_cameraDisplay:(LFCameraDisplayController *)cameraDisplay didFinishVideo:(NSURL *)videoURL
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    NSTimeInterval duration = CMTimeGetSeconds(self.recorder.session.duration);
    [cameraPicker dismissViewControllerAnimated:YES completion:^{
        /** 代理回调 */
        if ([cameraPicker.pickerDelegate respondsToSelector:@selector(lf_cameraPickerController:didFinishPickingVideo:duration:)]) {
            [cameraPicker.pickerDelegate lf_cameraPickerController:cameraPicker didFinishPickingVideo:videoURL duration:duration];
        }
    }];
}
- (void)lf_cameraDisplay:(LFCameraDisplayController *)cameraDisplay didFinishImage:(UIImage *)image
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    [cameraPicker dismissViewControllerAnimated:YES completion:^{
        /** 代理回调 */
        if ([cameraPicker.pickerDelegate respondsToSelector:@selector(lf_cameraPickerController:didFinishPickingImage:)]) {
            [cameraPicker.pickerDelegate lf_cameraPickerController:cameraPicker didFinishPickingImage:image];
        }
    }];
}

#pragma mark - 点击事件操作
- (void)closeAction
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    [cameraPicker dismissViewControllerAnimated:YES completion:^{
        /** 代理回调 */
        if ([cameraPicker.pickerDelegate respondsToSelector:@selector(lf_cameraPickerDidCancel:)]) {
            [cameraPicker.pickerDelegate lf_cameraPickerDidCancel:cameraPicker];
        }
    }];
}

- (void)stopAction
{
    __weak typeof(self) weakSelf = self;
    [self.recorder pause:^{
        [weakSelf saveAndShowSession:weakSelf.recorder.session];
    }];
}

- (void)flipCameraAction
{
    [_recorder switchCaptureDevices];
}

- (void)flashAction:(UIButton *)button
{
    switch (_recorder.flashMode) {
        case SCFlashModeOff:
            _recorder.flashMode = SCFlashModeAuto;
            [button setImage:LFCamera_bundleImageNamed(@"LFCamera_flashlight_auto") forState:UIControlStateNormal];
            break;
        case SCFlashModeAuto:
            _recorder.flashMode = SCFlashModeOn;
            [button setImage:LFCamera_bundleImageNamed(@"LFCamera_flashlight_on") forState:UIControlStateNormal];
            break;
        case SCFlashModeOn:
            _recorder.flashMode = SCFlashModeLight;
            [button setImage:LFCamera_bundleImageNamed(@"LFCamera_flashlight_light") forState:UIControlStateNormal];
            break;
        case SCFlashModeLight:
            _recorder.flashMode = SCFlashModeOff;
            [button setImage:LFCamera_bundleImageNamed(@"LFCamera_flashlight_off") forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)selectedOrDeleteLastProgress:(UIButton *)button
{
    if (button.isSelected) {
        [self.recordButton deleteSelectedProgress];
        [self.recorder.session removeLastSegment];
        button.selected = NO;
        /** 删除后，进度被重置，关闭按钮 */
        if (self.recordButton.progress == 0) {
            self.backToRecord.enabled = NO;
            self.stopButton.enabled = NO;
        }
    } else {
        button.selected = [self.recordButton selectedLastProgress];
    }
    
}

#pragma mark - previte
#pragma mark - 初始化视图
- (void)initView
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    __weak typeof(self) weakSelf = self;
    __weak typeof(cameraPicker) weakCameraPicker = cameraPicker;
    
    /** 预览视图 */
    UIView *previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    previewView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:previewView];
    self.previewView = previewView;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    /** 底部工具栏 */
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height-LFCamera_bottomViewHeight-LFCamera_bottomMargin, width, LFCamera_bottomViewHeight)];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    
    /** 底部工具栏 - 开始按钮 */
    LFRecordButton *recordButton = [[LFRecordButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(bottomView.frame)-LFCamera_recordButtonHeight)/2, (CGRectGetHeight(bottomView.frame)-LFCamera_recordButtonHeight)/2, LFCamera_recordButtonHeight, LFCamera_recordButtonHeight)];
    recordButton.onlySingleTap = (cameraPicker.cameraType == LFCameraType_Photo);
    recordButton.onlyLongTap = (cameraPicker.cameraType == LFCameraType_Video);
    recordButton.special = (cameraPicker.cameraType&LFCameraType_Video && cameraPicker.canPause);
    /** 单击 */
    recordButton.didTouchSingle = ^{
        [weakSelf stopUpdateAccelerometer];
        [weakSelf takePhoto];
    };
    /** 长按开始 */
    recordButton.didTouchLongBegan = ^{
        [weakSelf stopUpdateAccelerometer];
        weakSelf.backToRecord.selected = NO;
        [weakSelf.recorder record];
    };
    /** 长按结束 */
    recordButton.didTouchLongEnd = ^{
        
        if (weakCameraPicker.canPause) { /** 拍摄暂停模式 */
            [weakSelf.recorder pause];
        } else {
            [weakSelf stopAction];
        }
    };
    
    
    /** 移动 */
    recordButton.didTouchLongMove = ^(CGPoint screenPoint) {
        /**
         * 公式1：(x+y)/2+y=中间值
         * 公式2：z/(x+y)*(x1+y1)=z1 顺序
         * 公式3：(x1+y1)-z/(x+y)*(x1+y1)=z1 倒序
         */
        CGFloat x = 0, y = 0, z = screenPoint.y, x1 = weakSelf.focusView.minZoomFactor, y1 = weakSelf.focusView.maxZoomFactor, z1 = 0;
        /** 从下往上 递减 */
        x = CGRectGetHeight(weakSelf.view.frame)*.6;
        y = CGRectGetHeight(weakSelf.view.frame)*.4;
        
        /** 代入公式 */
        z1 = (x1+y1)-z/(x+y)*(x1+y1);
        weakSelf.recorder.videoZoomFactor = MIN(MAX(z1, x1), y1);
    };
    [bottomView addSubview:recordButton];
    self.recordButton = recordButton;
    
    if (cameraPicker.cameraType&LFCameraType_Video && cameraPicker.canPause) {
        /** 底部工具栏 - 选择／删除按钮 */
        UIButton *backToRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        backToRecord.frame = CGRectMake((CGRectGetMinX(recordButton.frame)-LFCamera_buttonHeight)/2, (CGRectGetHeight(bottomView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
        [backToRecord setImage:LFCamera_bundleImageNamed(@"LFCamera_backTo") forState:UIControlStateNormal];
        [backToRecord setImage:LFCamera_bundleImageNamed(@"LFCamera_DeleteBtn") forState:UIControlStateSelected];
        [backToRecord addTarget:self action:@selector(selectedOrDeleteLastProgress:) forControlEvents:UIControlEventTouchUpInside];
        backToRecord.enabled = NO;
        [bottomView addSubview:backToRecord];
        self.backToRecord = backToRecord;
        /** 底部工具栏 - 完成按钮 */
        UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        stopButton.frame = CGRectMake((CGRectGetWidth(bottomView.frame)-CGRectGetMaxX(recordButton.frame)-LFCamera_buttonHeight)/2+CGRectGetMaxX(recordButton.frame), (CGRectGetHeight(bottomView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
        [stopButton setImage:LFCamera_bundleImageNamed(@"LFCamera_stop") forState:UIControlStateNormal];
        [stopButton addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
        stopButton.enabled = NO;
        [bottomView addSubview:stopButton];
        self.stopButton = stopButton;
    } else {
        /** 底部工具栏 - 关闭按钮 */
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake((CGRectGetMinX(recordButton.frame)-LFCamera_buttonHeight)/2, (CGRectGetHeight(bottomView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
        [closeButton setImage:LFCamera_bundleImageNamed(@"LFCamera_back") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:closeButton];
    }
    
    /** 顶部栏 */
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, LFCamera_topViewHeight)];
    [self.view addSubview:topView];
    _topView = topView;
    
    /** 顶部栏 - 关闭按钮 */
    if (cameraPicker.cameraType&LFCameraType_Video && cameraPicker.canPause) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(10, 0, CGRectGetHeight(topView.frame) - 10, CGRectGetHeight(topView.frame));
        [closeButton setImage:LFCamera_bundleImageNamed(@"LFCamera_close") forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:closeButton];
    }
    
    /** 顶部栏 - 摄像头切换按钮 */
    UIButton *flipCameraButton = nil;
    if (cameraPicker.flipCamera) {
        flipCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        flipCameraButton.frame = CGRectMake(width - CGRectGetHeight(topView.frame) - 10, 0, CGRectGetHeight(topView.frame)-10, CGRectGetHeight(topView.frame));
        [flipCameraButton setImage:LFCamera_bundleImageNamed(@"LFCamera_flip_camera") forState:UIControlStateNormal];
        [flipCameraButton addTarget:self action:@selector(flipCameraAction) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:flipCameraButton];
        self.flipCameraButton = flipCameraButton;
    }
    
    /** 顶部栏 - 闪光灯按钮 */
    if (cameraPicker.flash) {
        UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat tmpWidth = flipCameraButton ? CGRectGetMinX(flipCameraButton.frame) : width;
        flashButton.frame = CGRectMake(tmpWidth - CGRectGetHeight(topView.frame) - 10, 0, CGRectGetHeight(topView.frame)-10, CGRectGetHeight(topView.frame));
        [flashButton setImage:LFCamera_bundleImageNamed(@"LFCamera_flashlight_auto") forState:UIControlStateNormal];
        [flashButton addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:flashButton];
        self.flashButton = flashButton;
    }
    
    
    /** 提示消息 */
    UILabel *tipsLabel = [[UILabel alloc] init];
    NSMutableString *text = [@"" mutableCopy];
    if (cameraPicker.cameraType&LFCameraType_Photo) {
        [text appendString:@"轻触拍照"];
    }
    if (cameraPicker.cameraType&LFCameraType_Video) {
        if (text.length) {
            [text appendString:@"，"];
        }
        [text appendString:@"按住摄像"];
    }
    tipsLabel.text = [text copy];
    tipsLabel.font = [UIFont boldSystemFontOfSize:13.f];
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.highlighted = YES;
    tipsLabel.highlightedTextColor = [UIColor whiteColor];
    tipsLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    tipsLabel.layer.shadowOpacity = 1.f;
    tipsLabel.layer.shadowOffset = CGSizeMake(0, 0);
    tipsLabel.layer.shadowRadius = 8;
    CGSize tipsTextSize = [tipsLabel.text sizeWithAttributes:@{NSFontAttributeName:tipsLabel.font, NSForegroundColorAttributeName:tipsLabel.textColor}];
    tipsLabel.frame = CGRectMake((width-tipsTextSize.width)/2, CGRectGetMinY(bottomView.frame)-tipsTextSize.height-5, tipsTextSize.width, tipsTextSize.height);
    tipsLabel.alpha = 0.f;
    [self.view insertSubview:tipsLabel belowSubview:bottomView];
    self.tipsLabel = tipsLabel;
}

#pragma mark - 初始化Recorder
- (void)initRecorder
{
#if !TARGET_OS_SIMULATOR
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    
    _recorder = [SCRecorder recorder];
    if ([cameraPicker.cameraPreset isEqualToString:AVCaptureSessionPresetAuto]) {
        _recorder.captureSessionPreset = [LFCameraRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices:(CMTimeScale)cameraPicker.framerate];
    } else {
        _recorder.captureSessionPreset = cameraPicker.cameraPreset;
    }
    _recorder.maxRecordDuration = CMTimeMake(cameraPicker.framerate * cameraPicker.maxRecordSeconds, (int32_t)cameraPicker.framerate);
    
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            _recorder.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            _recorder.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            _recorder.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _recorder.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    
    //    _recorder.fastRecordMethodEnabled = YES;
    if (cameraPicker.frontCamera) {
        _recorder.device = AVCaptureDevicePositionFront;
    }
    if (cameraPicker.flash) {
        _recorder.flashMode = SCFlashModeAuto;
    }
    
    _recorder.delegate = self;
    //    _recorder.autoSetVideoOrientation = YES; //YES causes bad orientation for video from camera roll
    _recorder.videoConfiguration.profileLevel = AVVideoProfileLevelH264HighAutoLevel;
    _recorder.videoConfiguration.bitrate = [LFCameraRecorderTools bitrateWithCaptureSessionPreset:_recorder.captureSessionPreset];
    
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    {
        // 改变内部适配方式
        _recorder.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    
    self.previewSize = previewView.bounds.size;
    if (cameraPicker.activeOverlay) {
        self.overlayView = [[LFCameraWatermarkOverlayView alloc] initWithFrame:previewView.bounds];
        [previewView addSubview:self.overlayView];
    }
    
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = LFCamera_bundleImageNamed(@"LFCamera_scan_focus");
    //    self.focusView.insideFocusTargetImage = LFCamera_bundleImageNamed(@"LFCamera_scan_focus");
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    
    CMVideoDimensions videoDimensions = [LFCameraRecorderTools bestVideoDimensionsWithAllDevices:(CMTimeScale)cameraPicker.framerate];
    [_recorder setActiveFormatWithFrameRate:(CMTimeScale)cameraPicker.framerate width:videoDimensions.width andHeight:videoDimensions.height error:&error];
    if (error) {
        NSLog(@"set frameRate error: %@", error.localizedDescription);
    }
    
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
#endif
    
    /** 设备不支持闪光灯 */
    if (self.flashButton && self.recorder.deviceHasFlash == NO) {
        [self.flashButton removeFromSuperview];
        self.flashButton = nil;
    }
}

#pragma mark - 显示拍照图片
- (void)showImageView
{
    LFCameraDisplayController *cameraDisplay = [[LFCameraDisplayController alloc] init];
    cameraDisplay.delegate = self;
    cameraDisplay.photo = [self.photo easyRotateImageOrientation:self.imageOrientation context:self.cicontext];
    cameraDisplay.overlayImage = self.overlayView.image;
    [self.navigationController pushViewController:cameraDisplay animated:NO];
}

#pragma mark - 显示录制视频
- (void)showVideoView
{
    /** iOS11录制视频需要马上关闭录制，否则影响AVPlayer的播放 */
    [_recorder stopRunning];
    AVAsset *asset = self.recorder.session.assetRepresentingSegments;
    
    LFCameraDisplayController *cameraDisplay = [[LFCameraDisplayController alloc] init];
    cameraDisplay.delegate = self;
    cameraDisplay.photo = ((SCRecordSessionSegment *)self.recorder.session.segments.firstObject).thumbnail;
    cameraDisplay.asset = asset;
    cameraDisplay.overlayImage = self.overlayView.image;
    // 因为视频是旋转的，需要调整水印层的方向与视频实际方向一致。
    UIImageOrientation overlayOrientation = UIImageOrientationUp;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            overlayOrientation = UIImageOrientationRight;
            break;
        case UIImageOrientationLeftMirrored:
            overlayOrientation = UIImageOrientationRightMirrored;
            break;
        case UIImageOrientationRight:
            overlayOrientation = UIImageOrientationLeft;
            break;
        case UIImageOrientationRightMirrored:
            overlayOrientation = UIImageOrientationLeftMirrored;
        break;
        default:
            break;
    }
    cameraDisplay.overlayOrientation = overlayOrientation;
    [self.navigationController pushViewController:cameraDisplay animated:NO];
}

#pragma mark - 获取水印
- (void)getOverlayView:(UIInterfaceOrientation)orientation
{
    if (self.recorder.captureSession.isRunning) {
        
        LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
        
        if (cameraPicker.activeOverlay) {
            if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
                if (self.overlayView.overlayImage_Hor) {
                    [self.overlayView setImage:self.overlayView.overlayImage_Hor];
                } else {
                    if ([cameraPicker.pickerDelegate respondsToSelector:@selector(lf_cameraPickerController:overlayViewSize:overlayOrientation:)]) {
                        UIView *overlayView = [cameraPicker.pickerDelegate lf_cameraPickerController:cameraPicker overlayViewSize:self.previewSize overlayOrientation:LFCameraOverlayOrientation_Hor];
                        self.overlayView.overlayView_Hor = overlayView;
                        [self.overlayView setImage:self.overlayView.overlayImage_Hor];
                    }
                }
            } else {
                if (self.overlayView.overlayImage_Ver) {
                    [self.overlayView setImage:self.overlayView.overlayImage_Ver];
                } else {
                    if ([cameraPicker.pickerDelegate respondsToSelector:@selector(lf_cameraPickerController:overlayViewSize:overlayOrientation:)]) {
                        UIView *overlayView = [cameraPicker.pickerDelegate lf_cameraPickerController:cameraPicker overlayViewSize:self.previewSize overlayOrientation:LFCameraOverlayOrientation_Ver];
                        self.overlayView.overlayView_Ver = overlayView;
                        [self.overlayView setImage:self.overlayView.overlayImage_Ver];
                    }
                }
            }
        }
    }
}

#pragma mark - 陀螺仪
- (void)startUpdateAccelerometer
{
    if ([self.mManager isAccelerometerAvailable] == YES) {
        //回调会一直调用,建议获取到就调用下面的停止方法，需要再重新开始，当然如果需求是实时不间断的话可以等离开页面之后再stop
        [self.mManager setAccelerometerUpdateInterval:.5f];
        [self.mManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             double x = accelerometerData.acceleration.x;
             double y = accelerometerData.acceleration.y;
             if (fabs(y) >= fabs(x))
             {
                 if (y >= 0){
                     //Down
                     [self interfaceOrientationDidChange:UIInterfaceOrientationPortraitUpsideDown];
                 }
                 else{
                     //Portrait
                     [self interfaceOrientationDidChange:UIInterfaceOrientationPortrait];
                 }
             }
             else
             {
                 if (x >= 0){
                     //Right
                     [self interfaceOrientationDidChange:UIInterfaceOrientationLandscapeRight];
                 }
                 else{
                     //Left
                     [self interfaceOrientationDidChange:UIInterfaceOrientationLandscapeLeft];
                 }
             }
         }];
    }
}

- (void)stopUpdateAccelerometer
{
    if ([self.mManager isAccelerometerActive] == YES)
    {
        [self.mManager stopAccelerometerUpdates];
    }
}

@end
