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

@property (weak, nonatomic) IBOutlet UISegmentedControl *type_segment;
@property (weak, nonatomic) IBOutlet UISwitch *flip_switch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *front_segment;
@property (weak, nonatomic) IBOutlet UISwitch *flash_switch;
@property (weak, nonatomic) IBOutlet UISwitch *pause_switch;
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
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    camera.videoUrl = [NSURL fileURLWithPath:[documentPath stringByAppendingPathComponent:@"video1.mp4"]];
    /** 模式 */
    LFCameraType type = LFCameraType_Both;
    switch (self.type_segment.selectedSegmentIndex) {
        case 0:
            type = LFCameraType_Photo;
            break;
        case 1:
            type = LFCameraType_Video;
            break;
        default:
            break;
    }
    
    camera.cameraType = type;
    
    /** 翻转 */
    camera.flipCamera = self.flip_switch.isOn;
    /** 前置 */
    camera.frontCamera = self.front_segment.selectedSegmentIndex == 0;
    /** 闪光灯 */
    camera.flash = self.flash_switch.isOn;
    /** 暂停 */
    camera.canPause = self.pause_switch.isOn;
    
    
    { /** 设置水印 */
        
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
        [[UIColor clearColor] setFill];
        [@"哈哈哈哈，测试用" drawInRect:CGRectMake(100, 100, 100, 100) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f], NSForegroundColorAttributeName:[UIColor redColor]}];
        
        // 从当前context中创建一个改变大小后的图片
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        camera.overlayView = imageView;
    }
    
    [self presentViewController:camera animated:YES completion:nil];
}
@end
