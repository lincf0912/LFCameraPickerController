//
//  LFCameraDisplayController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraDisplayController.h"
#import "LFCameraPickerController.h"
#import "LFCameraHeader.h"
#import "SCRecorder.h"

@interface LFCameraDisplayController () <SCPlayerDelegate>

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) SCVideoPlayerView *playerView;

/** 取消 */
@property (weak, nonatomic) UIButton *cancelButton;
/** 完成 */
@property (weak, nonatomic) UIButton *finishButton;

@end

@implementation LFCameraDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    /** 初始化控件 */
    if (self.recordSession == nil) {
        [self initImageView];
    } else {
        [self initImageView];
        [self initPlayerView];
    }
    
    /** 控制视图 */
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AVAsset *asset = _recordSession.assetRepresentingSegments;
    if (asset) {
        [_player setItemByAsset:asset];
        [_player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (void)dealloc {
    [_player pause];
    _player = nil;
    [self cancelSaveToCameraRoll];
}

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击事件操作
- (void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(lf_cameraDisplayDidCancel:)]) {
        [self.delegate lf_cameraDisplayDidCancel:self];
    }
}

- (void)finishAction
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    
    [cameraPicker showProgressHUD];
    
    if (self.recordSession) {
        
        NSString *preset = SCPresetMediumQuality;
        switch (cameraPicker.presetQuality) {
            case LFCameraPresetQuality_Low:
                preset = SCPresetLowQuality;
                break;
            case LFCameraPresetQuality_Highest:
                preset = SCPresetHighestQuality;
            default:
                break;
        }
        
        NSURL *videoUrl = (cameraPicker.videoUrl == nil ? self.recordSession.outputUrl : cameraPicker.videoUrl);
        
        SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
        exportSession.videoConfiguration.preset = preset;
        exportSession.audioConfiguration.preset = preset;
        exportSession.videoConfiguration.maxFrameRate = (CMTimeScale)cameraPicker.framerate;
        exportSession.outputUrl = videoUrl;
        exportSession.outputFileType = cameraPicker.videoType;
        //    exportSession.delegate = self;
        exportSession.contextType = SCContextTypeAuto;
        self.exportSession = exportSession;
        
        CFTimeInterval time = CACurrentMediaTime();
        __weak typeof(self) weakSelf = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            [cameraPicker hideProgressHUD];
            
            if (!exportSession.cancelled) {
                NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
            }
            
            NSError *error = exportSession.error;
            if (exportSession.cancelled) {
                NSLog(@"Export was cancelled");
                [weakSelf cancelAction];
            } else if (error == nil) {
                if (cameraPicker.autoSavePhotoAlbum) {
                    [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"Failed to save %@", error.localizedDescription);
                        }
                    }];
                }
                
                if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                    [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:exportSession.outputUrl];
                }
            } else {
                if (!exportSession.cancelled) {
                    [weakSelf showAlertViewWithTitle:@"Failed to export" message:error.localizedDescription];
                }
            }
            
        }];
    } else {
        if (cameraPicker.autoSavePhotoAlbum) {
            [cameraPicker hideProgressHUD];
            [self.photo saveToCameraRollWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to save %@", error.localizedDescription);
                }
            }];
        }
        if ([self.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishImage:)]) {
            [self.delegate lf_cameraDisplay:self didFinishImage:self.photo];
        }
    }
}

#pragma mark - 初始化UI
- (void)initView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    /** 工具栏 */
    UIView *toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, height-LFCamera_boomViewHeight-LFCamera_boomMargin, width, LFCamera_boomViewHeight)];
    [self.view addSubview:toolsView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor lightGrayColor];
    cancelButton.frame = CGRectMake((CGRectGetMidX(toolsView.frame)-LFCamera_buttonHeight)/2, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [cancelButton setImage:LFCamera_bundleImageNamed(@"LFCamera_cancel") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self cornerButton:cancelButton];
    [toolsView addSubview:cancelButton];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.backgroundColor = [UIColor whiteColor];
    finishButton.frame = CGRectMake((CGRectGetWidth(toolsView.frame)-LFCamera_buttonHeight)/2+CGRectGetWidth(toolsView.frame)/4, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [finishButton setImage:LFCamera_bundleImageNamed(@"LFCamera_finish") forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    [self cornerButton:finishButton];
    [toolsView addSubview:finishButton];
    
    CGPoint center = CGPointMake(CGRectGetMidX(toolsView.bounds), CGRectGetMidY(toolsView.bounds));
    
    CGRect cancelFrame = cancelButton.frame;
    cancelButton.center = center;
    CGRect finishFrame = finishButton.frame;
    finishButton.center = center;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        cancelButton.frame = cancelFrame;
        finishButton.frame = finishFrame;
    } completion:nil];
}

- (void)cornerButton:(UIButton *)button
{
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.layer.cornerRadius = CGRectGetWidth(button.frame)/2;
    button.layer.masksToBounds = YES;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(1, 1);
    button.layer.shadowOpacity = 0.5f;
    button.layer.shadowRadius = 2.f;
}

#pragma mark - 初始化播放控件
- (void)initPlayerView
{
    _player = [SCPlayer player];
    _player.loopEnabled = YES;
    _player.delegate = self;
    
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerView.frame = self.view.bounds;
    [self.view addSubview:playerView];
    self.playerView = playerView;
}

#pragma mark - 显示拍照图片
- (void)initImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.image = self.photo;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

@end
