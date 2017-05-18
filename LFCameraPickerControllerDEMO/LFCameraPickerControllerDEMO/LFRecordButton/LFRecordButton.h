//
//  LFRecordButton.h
//  SDRecordButton-Demo
//
//  Created by LamTsanFeng on 2017/5/10.
//  Copyright © 2017年 Sebastian Dobrincu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^didTouchSingle)();
typedef void(^didTouchLongBegan)();
typedef void(^didTouchLongMove)(CGPoint screenPoint);
typedef void(^didTouchLongEnd)();

@interface LFRecordButton : UIView
/** 前圆的颜色，default whiteColor */
@property (nonatomic, strong) UIColor *foreColor;
/** 后圆的颜色，default whiteColor 0.9 */
@property (nonatomic, strong) UIColor *backColor;
/** 进度条颜色，default greenColor */
@property (nonatomic, strong) UIColor *progressColor;
/** 随机进度条颜色，default NO, set YES progressColor will be invalid */
@property (nonatomic, assign) BOOL randomProgressColor;
/** 进度宽度，default 4.0 */
@property (nonatomic, assign) CGFloat progressWidth;
/** 长按点击放大倍数,default 1.5 (>1) */
@property (nonatomic, assign) CGFloat zoomInScale;
/** 更新进度 0~1 */
@property (nonatomic, assign) CGFloat progress;

/** 特别模式 defautl NO :当progress>0时，长按结束不会恢复原来状态，并且不会再触发单击事件，直到progress=1时，恢复原来状态；progress=0时才能触发单击事件 */
@property (nonatomic, assign) BOOL special;
/** 进度分割线 default YES,it work when special is YES */
@property (nonatomic, assign) BOOL progressSeparator;
/** 进度分隔符颜色 default grayColor */
@property (nonatomic, strong) UIColor *progressSeparatorColor;
/** 选中进度的颜色 defalut readColor */
@property (nonatomic, strong) UIColor *selectedProgressColor;

/** 重置 */
- (void)reset;
/** 选中上一段进度 */
- (void)selectedLastProgress;
/** 删除选中的进度部分 */
- (void)deleteSelectedProgress;

/** 回调 */

/** 单击 */
@property (nonatomic, copy) didTouchSingle didTouchSingle;
/** 长按开始 */
@property (nonatomic, copy) didTouchLongBegan didTouchLongBegan;
/** 长按滑动（相对于屏幕的移动点） */
@property (nonatomic, copy) didTouchLongMove didTouchLongMove;
/** 长按结束 */
@property (nonatomic, copy) didTouchLongEnd didTouchLongEnd;

@end
