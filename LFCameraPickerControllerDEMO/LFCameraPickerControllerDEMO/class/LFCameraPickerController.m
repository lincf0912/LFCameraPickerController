//
//  LFCameraPickerController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraPickerController.h"
#import "LFCameraTakeViewController.h"

AVCaptureSessionPreset const AVCaptureSessionPresetAuto = @"AVCaptureSessionPresetAuto";

@interface LFCameraPickerController ()
{
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
}
@end

@implementation LFCameraPickerController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    /** 初始化数据 */
    [self defaultData];
    /** 关闭侧滑 */
    self.interactivePopGestureRecognizer.enabled = NO;
    
    /** 初始化拍摄 */
    LFCameraTakeViewController *cameraTake = [[LFCameraTakeViewController alloc] init];
    [self setViewControllers:@[cameraTake]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarHidden:YES];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVideoRecording error:&error];

    if (error) {
        NSLog(@"AVAudioSession error:%@", error);
    }
    
    /** 监听应用回到前台通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideProgressHUD];
}

- (void)dealloc
{
    [LFCameraBaseController freeCIContext];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        /** 恢复原来的音频 */
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        if (completion) {
            completion();
        }
    }];
}

- (void)applicationWillEnterForeground:(NSNotification *)notify
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            /** 代理回调 */
            if ([self.pickerDelegate respondsToSelector:@selector(lf_cameraPickerDidCancel:)]) {
                [self.pickerDelegate lf_cameraPickerDidCancel:self];
            }
        }];
    }
}

#pragma mark - 默认数据
- (void)defaultData
{
    _cameraType = LFCameraType_Both;
    _cameraPreset = AVCaptureSessionPresetAuto;
    _flipCamera = YES;
    _frontCamera = NO;
    _flash = NO;
    _canPause = NO;
    _minRecordSeconds = .3f;
    _maxRecordSeconds = 7.f;
    _framerate = 30;
    _videoType = AVFileTypeMPEG4;
    _presetQuality = LFCameraPresetQuality_Medium;
    
    _autoSavePhotoAlbum = YES;
    _processHintStr = @"正在处理...";
    
    _allowEditing = YES;
}

- (void)setMinRecordSeconds:(float)minRecordSeconds
{
    if (minRecordSeconds >= 0) {
        _minRecordSeconds = minRecordSeconds;
    }
}

- (void)setMaxRecordSeconds:(NSUInteger)maxRecordSeconds
{
    if (maxRecordSeconds > _minRecordSeconds) {
        _maxRecordSeconds = maxRecordSeconds;
    }
}

- (void)showProgressHUDText:(NSString *)text isTop:(BOOL)isTop
{
    [self hideProgressHUD];
    
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        _progressHUD.frame = [UIScreen mainScreen].bounds;
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 120) / 2, ([[UIScreen mainScreen] bounds].size.height - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.frame = CGRectMake(0,40, 120, 50);
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    
    _HUDLabel.text = text ? text : self.processHintStr;
    
    [_HUDIndicatorView startAnimating];
    UIView *view = isTop ? [[UIApplication sharedApplication] keyWindow] : self.view;
    [view addSubview:_progressHUD];
}

- (void)showProgressHUDText:(NSString *)text
{
    [self showProgressHUDText:text isTop:NO];
}

- (void)showProgressHUD {
    
    [self showProgressHUDText:nil];
    
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//支持正方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
            case UIInterfaceOrientationLandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeLeft;
            case UIInterfaceOrientationLandscapeRight:
                return UIInterfaceOrientationMaskLandscapeRight;
            case UIInterfaceOrientationPortraitUpsideDown:
                return UIInterfaceOrientationMaskPortraitUpsideDown;
            default:
                return UIInterfaceOrientationMaskPortrait;
        }
    }
}

/** present 后的首次显示方向 */
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

@end
