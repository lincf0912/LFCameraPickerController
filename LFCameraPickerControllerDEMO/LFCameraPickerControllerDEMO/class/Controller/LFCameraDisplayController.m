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
#import "LFPhotoEditingController.h"

@interface LFCameraDisplayController () <SCPlayerDelegate, LFPhotoEditingControllerDelegate>

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) SCVideoPlayerView *playerView;

/** 图片编辑对象 */
@property (strong, nonatomic) LFPhotoEdit *photoEdit;

/** 底部栏 */
@property (weak, nonatomic) UIView *toolsView;
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
    
    /** 控制视图 */
    [self initView];
    
    /** 初始化控件 */
    if (self.recordSession == nil) {
        [self initImageView];
        [self startAmination];
    } else {
        [self initImageView];
        [self initPlayerView];
    }
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
            
            if (!exportSession.cancelled) {
                NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
            }
            
            NSError *error = exportSession.error;
            if (exportSession.cancelled) {
                NSLog(@"Export was cancelled");
                [cameraPicker hideProgressHUD];
                [weakSelf cancelAction];
            } else if (error == nil) {
                if (cameraPicker.autoSavePhotoAlbum) {
                    [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"Failed to save %@", error.localizedDescription);
                        }
                    }];
                }
                
                [cameraPicker hideProgressHUD];
                if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                    [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:exportSession.outputUrl];
                }
            } else {
                if (!exportSession.cancelled) {
                    [cameraPicker showProgressHUDText:error.localizedDescription];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [cameraPicker hideProgressHUD];
                        if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                            [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:nil];
                        }
                    });
                }
            }
            
        }];
    } else {
        if (cameraPicker.autoSavePhotoAlbum) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.imageView.image saveToCameraRollWithCompletion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"Failed to save %@", error.localizedDescription);
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cameraPicker hideProgressHUD];
                    if ([self.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishImage:)]) {
                        [self.delegate lf_cameraDisplay:self didFinishImage:self.imageView.image];
                    }
                });
            });
        } else {
            [cameraPicker hideProgressHUD];
            if ([self.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishImage:)]) {
                [self.delegate lf_cameraDisplay:self didFinishImage:self.imageView.image];
            }
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
    self.toolsView = toolsView;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor lightGrayColor];
    cancelButton.frame = CGRectMake((CGRectGetMidX(toolsView.frame)-LFCamera_buttonHeight)/2, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [cancelButton setImage:LFCamera_bundleImageNamed(@"LFCamera_cancel") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = YES;
    [self cornerButton:cancelButton];
    [toolsView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.backgroundColor = [UIColor whiteColor];
    finishButton.frame = CGRectMake((CGRectGetWidth(toolsView.frame)-LFCamera_buttonHeight)/2+CGRectGetWidth(toolsView.frame)/4, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [finishButton setImage:LFCamera_bundleImageNamed(@"LFCamera_finish") forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    finishButton.hidden = YES;
    [self cornerButton:finishButton];
    [toolsView addSubview:finishButton];
    self.finishButton = finishButton;
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

- (void)startAmination
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.toolsView.bounds), CGRectGetMidY(self.toolsView.bounds));
    
    CGRect cancelFrame = self.cancelButton.frame;
    self.cancelButton.center = center;
    CGRect finishFrame = self.finishButton.frame;
    self.finishButton.center = center;
 
    self.cancelButton.hidden = NO;
    self.finishButton.hidden = NO;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.cancelButton.frame = cancelFrame;
        self.finishButton.frame = finishFrame;
    } completion:nil];
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
    
    if (self.recordSession == nil) {        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat editWH = 40.f, editMargin = 20.f;
        editButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-editWH-editMargin, editMargin, editWH, editWH);
        [editButton setImage:LFCamera_bundleImageNamed(@"LFCamera_iconEdit") forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(photoEditAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editButton];
    }
}

- (void)photoEditAction
{
    LFPhotoEditingController *photoEdittingVC = [[LFPhotoEditingController alloc] init];
    /** 当前显示的图片 */
    if (self.photoEdit) {
        photoEdittingVC.photoEdit = self.photoEdit;
    } else {
        photoEdittingVC.editImage = self.imageView.image;
    }
    photoEdittingVC.delegate = self;
    [self.navigationController pushViewController:photoEdittingVC animated:NO];
}

#pragma mark - SCPlayerDelegate
- (void)player:(SCPlayer *__nonnull)player itemReadyToPlay:(AVPlayerItem *__nonnull)item
{
    [self.imageView removeFromSuperview];
    [self startAmination];
}

#pragma mark - LFPhotoEditingControllerDelegate
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEdittingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEdittingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit
{
    if (photoEdit) {
        self.imageView.image = photoEdit.editPreviewImage;
    } else {
        self.imageView.image = self.photo;
    }
    self.photoEdit = photoEdit;
    [self.navigationController popViewControllerAnimated:NO];
}

@end
