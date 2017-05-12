//
//  LFCameraPickerController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraPickerController.h"
#import "LFCameraTakeViewController.h"

@interface LFCameraPickerController ()

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
    
    /** 初始化拍摄 */
    LFCameraTakeViewController *cameraTake = [[LFCameraTakeViewController alloc] init];
    [self setViewControllers:@[cameraTake]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarHidden:YES];
}

#pragma mark - 默认数据
- (void)defaultData
{
    _cameraType = LFCameraType_Both;
    _flipCamera = YES;
    _frontCamera = YES;
    _flash = NO;
    _canPause = NO;
    _maxRecordSeconds = 7.f;
    _framerate = 30;
    _videoType = AVFileTypeMPEG4;
    
    _stopButtonTitle = @"stop";
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//phone只支持正方向，pad只支持左右横屏 （个别UI需要支持横屏，重写此方法即可）
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/** present 后的首次显示方向 */
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
