//
//  LFCameraDisplayController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraDisplayController.h"
#import "LFCameraPickerController.h"
#import "LFCameraPlayerView.h"
#import "LFCameraHeader.h"
#import "UIImage+LFCamera_Common.h"
#import "LFCameraWatermarkOverlayView.h"

#import "SCRecorder.h"

#ifdef LF_MEDIAEDIT
#import "LFPhotoEditingController.h"
#import "LFVideoEditingController.h"
#endif

#define kCameraDisplayEditMargin 20.f

#ifdef LF_MEDIAEDIT
@interface LFCameraDisplayController () <SCPlayerDelegate, LFPhotoEditingControllerDelegate, LFVideoEditingControllerDelegate>
#else
@interface LFCameraDisplayController () <SCPlayerDelegate>
#endif

@property (strong, nonatomic) SCAssetExportSession *exportSession;

@property (weak, nonatomic) LFCameraPlayerView *playerView;
@property (strong, nonatomic) AVPlayer *player;

/** 水印 */
@property (weak, nonatomic) LFCameraWatermarkOverlayView *overlayView;

#ifdef LF_MEDIAEDIT
/** 图片编辑对象 */
@property (strong, nonatomic) LFPhotoEdit *photoEdit;
@property (strong, nonatomic) LFVideoEdit *videoEdit;
#endif

/** 底部栏 */
@property (weak, nonatomic) UIView *toolsView;
/** 取消 */
@property (weak, nonatomic) UIButton *cancelButton;
/** 完成 */
@property (weak, nonatomic) UIButton *finishButton;
/* 编辑 */
@property (weak, nonatomic) UIButton *editButton;

@end

@implementation LFCameraDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    /** 控制视图 */
    [self initImageView];
    [self initOverlayView];
    [self initToolsView];
    
    /** 初始化控件 */
    if (self.asset == nil) {
        [self startAmination];
    } else {
        [self initPlayer];
        [self startAmination];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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
    _toolsView.frame = CGRectMake(0, height-bottom-LFCamera_bottomViewHeight-LFCamera_bottomMargin, width, LFCamera_bottomViewHeight);
    CGRect tempEditRect = _editButton.frame;
    tempEditRect.origin.x = width-CGRectGetWidth(tempEditRect)-kCameraDisplayEditMargin;
    tempEditRect.origin.y = top+kCameraDisplayEditMargin;
    _editButton.frame = tempEditRect;
}

- (void)dealloc {
    
    [self removeMonitorPlayerItem:_player.currentItem];
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
    [self.player pause];
    if ([self.delegate respondsToSelector:@selector(lf_cameraDisplayDidCancel:)]) {
        [self.delegate lf_cameraDisplayDidCancel:self];
    }
}

- (void)finishAction
{
    LFCameraPickerController *cameraPicker = (LFCameraPickerController *)self.navigationController;
    
    [cameraPicker showProgressHUD];
    
    if (self.asset) {
        
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
        
        NSURL *videoUrl = cameraPicker.videoUrl;
#ifdef LF_MEDIAEDIT
        AVAsset *avasset = self.videoEdit.editFinalURL ? [AVURLAsset assetWithURL:self.videoEdit.editFinalURL] : self.asset;
#else
        AVAsset *avasset = self.asset;
#endif
        SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:avasset];
        exportSession.videoConfiguration.preset = preset;
        exportSession.audioConfiguration.preset = preset;
        exportSession.videoConfiguration.maxFrameRate = (CMTimeScale)cameraPicker.framerate;
        if (self.overlayView) {
            exportSession.videoConfiguration.overlay = self.overlayView;
        }
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"Failed to save %@", error.localizedDescription);
                            }
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cameraPicker hideProgressHUD];
                            [weakSelf.player pause];
                            if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                                [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:exportSession.outputUrl];
                            }
                        });
                    });
                } else {
                    [cameraPicker hideProgressHUD];
                    [weakSelf.player pause];
                    if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                        [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:exportSession.outputUrl];
                    }
                }
                
            } else {
                if (!exportSession.cancelled) {
                    [cameraPicker showProgressHUDText:error.localizedDescription];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [cameraPicker hideProgressHUD];
                        [weakSelf.player pause];
                        if ([weakSelf.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishVideo:)]) {
                            [weakSelf.delegate lf_cameraDisplay:weakSelf didFinishVideo:nil];
                        }
                    });
                }
            }
            
        }];
    } else if (self.photo) {
        UIImage *image = self.playerView.image;
        if (self.overlayImage) {
             image = [image LFCamera_imageWithWaterMask:self.overlayImage];
        }
        
        if (cameraPicker.autoSavePhotoAlbum) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [image saveToCameraRollWithCompletion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"Failed to save %@", error.localizedDescription);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cameraPicker hideProgressHUD];
                        if ([self.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishImage:)]) {
                            [self.delegate lf_cameraDisplay:self didFinishImage:image];
                        }
                    });
                }];
            });
        } else {
            [cameraPicker hideProgressHUD];
            if ([self.delegate respondsToSelector:@selector(lf_cameraDisplay:didFinishImage:)]) {
                [self.delegate lf_cameraDisplay:self didFinishImage:image];
            }
        }
    } else {
        [cameraPicker hideProgressHUD];
        if ([self.delegate respondsToSelector:@selector(lf_cameraDisplayDidClose:)]) {
            [self.delegate lf_cameraDisplayDidClose:self];
        }
    }
}

#pragma mark - 初始化UI
- (void)initToolsView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    /** 工具栏 */
    UIView *toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, height-LFCamera_bottomViewHeight-LFCamera_bottomMargin, width, LFCamera_bottomViewHeight)];
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
    
#ifdef LF_MEDIAEDIT
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat editWH = 40.f;
    editButton.frame = CGRectMake(width-editWH-kCameraDisplayEditMargin, kCameraDisplayEditMargin, editWH, editWH);
    [editButton setImage:LFCamera_bundleImageNamed(@"LFCamera_iconEdit") forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(photoEditAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    self.editButton = editButton;
#endif
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
- (void)initPlayer
{
    AVAsset *asset = self.asset;
    if (asset) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        _player = [AVPlayer playerWithPlayerItem:item];
        [self addMonitorPlayerItem:item];
        [self.playerView setPlayer:self.player];
    }
}

- (void)replacePlayerItemWithAsset:(AVAsset *)asset
{
    if (asset) {
        [_player pause];
        [self removeMonitorPlayerItem:self.player.currentItem];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [_player replaceCurrentItemWithPlayerItem:item];
        [self addMonitorPlayerItem:item];
    }
}

#pragma mark - 创建监听与通知
- (void)addMonitorPlayerItem:(AVPlayerItem *)item
{
    if (item) {
        [item addObserver:self
               forKeyPath:@"status"
                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
    }
}

- (void)removeMonitorPlayerItem:(AVPlayerItem *)item
{
    if (item) {
        [item removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:item];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

#pragma mark - 显示拍照图片
- (void)initImageView
{
    LFCameraPlayerView *playerView = [[LFCameraPlayerView alloc] initWithFrame:self.view.bounds];
    playerView.contentMode = UIViewContentModeScaleAspectFit;
    
    playerView.image = self.photo;
    [self.view addSubview:playerView];
    self.playerView = playerView;
}

- (void)initOverlayView
{
    if (self.overlayImage) {
        LFCameraWatermarkOverlayView *overlayView = [[LFCameraWatermarkOverlayView alloc] initWithFrame:self.view.bounds];
        [overlayView setImage:self.overlayImage];
        [self.view addSubview:overlayView];
        _overlayView = overlayView;
    }
}
#ifdef LF_MEDIAEDIT
- (void)photoEditAction
{
    if (self.asset == nil) {
        UIImage *image = self.playerView.image;
        
        LFPhotoEditingController *photoEditingVC = [[LFPhotoEditingController alloc] init];
        /** 当前显示的图片 */
        if (self.photoEdit) {
            photoEditingVC.photoEdit = self.photoEdit;
        } else {
            photoEditingVC.editImage = image;
        }
        photoEditingVC.delegate = self;
        [self.navigationController pushViewController:photoEditingVC animated:NO];
    } else {
        LFVideoEditingController *videoEditingVC = [[LFVideoEditingController alloc] init];
        videoEditingVC.operationAttrs = @{LFVideoEditClipMinDurationAttributeName:@(2)};
        if (self.videoEdit) {
            videoEditingVC.videoEdit = self.videoEdit;
        } else {
            [videoEditingVC setVideoAsset:self.asset placeholderImage:self.photo];
        }
        videoEditingVC.delegate = self;
        [self.navigationController pushViewController:videoEditingVC animated:NO];
        [self.player pause];
    }
}
#endif

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    switch (status)
    {
        case AVPlayerItemStatusReadyToPlay:
        {
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        }
            break;
        default:
            break;
    }
}

#ifdef LF_MEDIAEDIT
#pragma mark - LFPhotoEditingControllerDelegate
- (void)lf_PhotoEditingControllerDidCancel:(LFPhotoEditingController *)photoEditingVC
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEdittingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit
{
    if (photoEdit) {
        self.playerView.image = photoEdit.editPreviewImage;
    } else {
        self.playerView.image = self.photo;
    }
    self.photoEdit = photoEdit;
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - LFVideoEditingControllerDelegate
- (void)lf_VideoEditingControllerDidCancel:(LFVideoEditingController *)videoEditingVC
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit
{
    [self.navigationController popViewControllerAnimated:NO];
    if (videoEdit && videoEdit.editFinalURL) {
        self.playerView.image = videoEdit.editPreviewImage;
        [self replacePlayerItemWithAsset:[[AVURLAsset alloc] initWithURL:videoEdit.editFinalURL options:nil]];
    } else {
        self.playerView.image = self.photo;
        [self replacePlayerItemWithAsset:self.asset];
    }
    self.videoEdit = videoEdit;
}
#endif

@end
