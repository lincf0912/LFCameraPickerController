//
//  LFCameraBaseController.m
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFCameraBaseController.h"
#import <objc/runtime.h>

typedef void (^lf_camera_AlertViewBlock)(UIAlertView *alertView, NSInteger buttonIndex);

static char lf_camera_overAlertViewKey;

@interface UIAlertView (LF_Camera_Block)
//需要自定义初始化方法，调用Block
/** block回调代理 */
- (id)lf_camera_initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString*)otherButtonTitles
                        block:(lf_camera_AlertViewBlock)block;
@end

@implementation UIAlertView (LF_Camera_Block)

/** block回调代理 */
- (id)lf_camera_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles block:(lf_camera_AlertViewBlock)block
{
    objc_setAssociatedObject(self, &lf_camera_overAlertViewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];//注意这里初始化父类的
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //这里调用函数指针_block(要传进来的参数);
    lf_camera_AlertViewBlock block = (lf_camera_AlertViewBlock)objc_getAssociatedObject(self, &lf_camera_overAlertViewKey);
    if (block) {
        block(alertView, buttonIndex);
        objc_setAssociatedObject(self, &lf_camera_overAlertViewKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

@end

@interface LFCameraBaseController ()

@end

@implementation LFCameraBaseController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message complete:(void (^)(void))complete {
    if (@available(iOS 8.0, *)){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (complete) {
                complete();
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] lf_camera_initWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil block:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (complete) {
                complete();
            }
        }] show];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CIContext
- (CIContext *)cicontext
{
    return [[self class] cicontext];
}

static CIContext *lfCamera_CIContext = nil;
+ (CIContext *)cicontext
{
    if (lfCamera_CIContext == nil) {
        lfCamera_CIContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    }
    return lfCamera_CIContext;
}

+ (void)freeCIContext
{
    lfCamera_CIContext = nil;
}

@end
