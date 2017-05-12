//
//  LFCameraPlayerViewController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraPlayerViewController.h"
#import "LFCameraHeader.h"
#import "SCRecorder.h"

@interface LFCameraPlayerViewController ()

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

/** 取消 */
@property (weak, nonatomic) UIButton *cancelButton;
/** 完成 */
@property (weak, nonatomic) UIButton *finishButton;

@end

@implementation LFCameraPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 播放控件 */
    [self initPlayerView];
    
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
    if ([self.delegate respondsToSelector:@selector(lf_cameraPlayerDidCancel:)]) {
        [self.delegate lf_cameraPlayerDidCancel:self];
    }
}

- (void)finishAction
{
    if ([self.delegate respondsToSelector:@selector(lf_cameraPlayer:didFinishVideo:)]) {
        [self.delegate lf_cameraPlayer:self didFinishVideo:nil];
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
    cancelButton.frame = CGRectMake((CGRectGetMidX(toolsView.frame)-LFCamera_buttonHeight)/2, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [cancelButton setImage:LFCamera_bundleImageNamed(@"LFCamera_back") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [toolsView addSubview:cancelButton];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake((CGRectGetWidth(toolsView.frame)-LFCamera_buttonHeight)/2+CGRectGetWidth(toolsView.frame)/4, (CGRectGetHeight(toolsView.frame)-LFCamera_buttonHeight)/2, LFCamera_buttonHeight, LFCamera_buttonHeight);
    [finishButton setImage:LFCamera_bundleImageNamed(@"LFCamera_back") forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    [toolsView addSubview:finishButton];
}

#pragma mark - 初始化播放控件
- (void)initPlayerView
{
    _player = [SCPlayer player];
    _player.loopEnabled = YES;
    
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerView.frame = self.view.bounds;
    [self.view addSubview:playerView];
}

@end
