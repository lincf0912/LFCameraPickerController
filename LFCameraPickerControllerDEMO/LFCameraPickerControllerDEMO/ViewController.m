//
//  ViewController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/9.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "ViewController.h"
#import "LFCameraPickerController.h"

@interface ViewController () <LFCameraPickerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *type_segment;
@property (weak, nonatomic) IBOutlet UISwitch *flip_switch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *front_segment;
@property (weak, nonatomic) IBOutlet UISwitch *flash_switch;
@property (weak, nonatomic) IBOutlet UISwitch *pause_switch;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
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
    camera.pickerDelegate = self;
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
    /** 水印 */
    camera.activeOverlay = YES;
    
    [self presentViewController:camera animated:YES completion:nil];
}

#pragma mark - LFCameraPickerDelegate
/** 拍照回调 */
- (void)lf_cameraPickerController:(LFCameraPickerController *)picker didFinishPickingImage:(UIImage *)image
{
    [self.showImageView setImage:image];
}
/** 视频回调 */
- (void)lf_cameraPickerController:(LFCameraPickerController *)picker didFinishPickingVideo:(NSURL *)videoUrl duration:(NSTimeInterval)duration
{
    NSLog(@"视频:%@", videoUrl);
}
- (UIView *)lf_cameraPickerOverlayView:(LFCameraOverlayOrientation)overlayOrientation
{
    switch (overlayOrientation) {
        case LFCameraOverlayOrientation_Ver:
        { /** 设置竖屏水印 */
            
            CGFloat width = self.view.bounds.size.width;
            CGFloat height = self.view.bounds.size.height;
            
            CGSize size = CGSizeMake(MIN(width, height), MAX(width, height));
            
            // 并把它设置成为当前正在使用的context
            UIGraphicsBeginImageContextWithOptions(size, NO, 0);
            [[UIColor clearColor] setFill];
            [@"哈哈哈哈，测试用" drawInRect:CGRectMake(100, 100, 200, 100) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f], NSForegroundColorAttributeName:[UIColor redColor]}];
            
            // 从当前context中创建一个改变大小后的图片
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            
            // 使当前的context出堆栈
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            [imageView setImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            return imageView;
        }
            break;
        case LFCameraOverlayOrientation_Hor:
        { /** 设置横屏水印 */
            
            CGFloat width = self.view.bounds.size.width;
            CGFloat height = self.view.bounds.size.height;
            
            CGSize size = CGSizeMake(MAX(width, height), MIN(width, height));
            
            // 并把它设置成为当前正在使用的context
            UIGraphicsBeginImageContextWithOptions(size, NO, 0);
            [[UIColor clearColor] setFill];
            [@"哈哈哈哈，测试用" drawInRect:CGRectMake(30, 30, 200, 100) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f], NSForegroundColorAttributeName:[UIColor redColor]}];
            
            // 从当前context中创建一个改变大小后的图片
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            
            // 使当前的context出堆栈
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            [imageView setImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            return imageView;
        }
            break;
    }
    return nil;
}

@end
