//
//  LFCameraBaseController.h
//  LFCameraPickerControllerDEMO
//
//  Created by LamTsanFeng on 2017/5/11.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFCameraBaseController : UIViewController

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message complete:(void (^)(void))complete;
@end
