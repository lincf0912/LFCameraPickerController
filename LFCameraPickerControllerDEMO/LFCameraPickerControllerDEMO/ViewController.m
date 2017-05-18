//
//  ViewController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "ViewController.h"
#import "LFCameraPickerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)basicAction:(id)sender {
    LFCameraPickerController *camera = [[LFCameraPickerController alloc] init];
    camera.autoSavePhotoAlbum = NO;
    [self presentViewController:camera animated:YES completion:nil];
}

- (IBAction)intermittentAction:(id)sender {
    LFCameraPickerController *camera = [[LFCameraPickerController alloc] init];
    camera.canPause = YES;
    camera.flash = YES;
    [self presentViewController:camera animated:YES completion:nil];
}
@end
