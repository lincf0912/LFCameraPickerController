//
//  LFRecordButton.m
//  SDRecordButton-Demo
//
//  Created by LamTsanFeng on 2017/5/10.
//  Copyright © 2017年 Sebastian Dobrincu. All rights reserved.
//

#import "LFRecordButton.h"

@interface LFRecordButton ()

@property (nonatomic, strong) CALayer *foreLayer;
@property (nonatomic, strong) CALayer *backLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *gradientMaskLayer;

/** 移动定点 */
@property (nonatomic, assign) CGPoint originPoint;

@end

@implementation LFRecordButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)layoutSubviews {
    
    _foreLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _foreLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    
    _backLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _backLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    
    [super layoutSubviews];
}

- (void)customInit
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    /** 添加手势 */
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LFRB_tapAction:)]];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LFRB_longAction:)]];
    
    _foreColor = [UIColor whiteColor];
    _backColor = [UIColor colorWithWhite:0.9 alpha:9.f];
    _progressColor = [UIColor colorWithRed:(26/255.0) green:(178/255.0) blue:(10/255.0) alpha:1.0];
    _zoomInScale = 1.5f;
    _progressWidth = 4.0f;
    _special = NO;
    
    [self drawButton];
}

- (void)drawButton {
    // Get the root layer
    CALayer *layer = self.layer;
    
    if (!_foreLayer) {
        
        _foreLayer = [CALayer layer];
        _foreLayer.backgroundColor = self.foreColor.CGColor;
        
        CGFloat size = self.frame.size.width/1.5;
        _foreLayer.bounds = CGRectMake(0, 0, size, size);
        _foreLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _foreLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        
        _foreLayer.cornerRadius = size/2;
        
        [layer insertSublayer:_foreLayer atIndex:0];
    }
    
    if (!_backLayer) {
        
        _backLayer = [CALayer layer];
        _backLayer.backgroundColor = self.backColor.CGColor;
        
        CGFloat size = self.bounds.size.width-1.5f;
        _backLayer.bounds = CGRectMake(0, 0, size, size);
        _backLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _backLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        
        _backLayer.cornerRadius = size/2;
        
        [layer insertSublayer:_backLayer atIndex:0];
    }
    
    if (!_progressLayer) {
        
        CGFloat startAngle = M_PI + M_PI_2;
        CGFloat endAngle = M_PI * 3 + M_PI_2;
        
        
        _gradientMaskLayer = [self gradientMask];
        CGPoint centerPoint = CGPointMake(_gradientMaskLayer.frame.size.width/2, _gradientMaskLayer.frame.size.height/2);
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:(self.frame.size.width*self.zoomInScale-self.progressWidth)/2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
        _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.strokeColor = [UIColor blackColor].CGColor;
        _progressLayer.lineWidth = self.progressWidth;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        
        _gradientMaskLayer.mask = _progressLayer;
        [layer addSublayer:_gradientMaskLayer];
    }
}

- (CAGradientLayer *)gradientMask {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.backgroundColor = [UIColor redColor].CGColor;
    CGSize size = CGSizeMake(self.bounds.size.width * self.zoomInScale, self.bounds.size.height * self.zoomInScale);
    CGRect bounds = (CGRect){{(self.bounds.size.width - size.width)/2, (self.bounds.size.height - size.height)/2}, size};
    gradientLayer.frame = bounds;
    gradientLayer.locations = @[@0.0, @1.0];
    
    UIColor *topColor = self.progressColor;
    UIColor *bottomColor = self.progressColor;
    
    gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
    
    return gradientLayer;
}

#pragma mark - setter
- (void)setForeColor:(UIColor *)foreColor
{
    _foreColor = foreColor;
    _foreLayer.backgroundColor = foreColor.CGColor;
}

- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    _backLayer.backgroundColor = backColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    _progressLayer.backgroundColor = progressColor.CGColor;
}

- (void)setProgressWidth:(CGFloat)progressWidth
{
    _progressWidth = progressWidth;
    /** 重新绘制进度部分 */
    [_gradientMaskLayer removeFromSuperlayer];
    _progressLayer = nil;
    [self drawButton];
}

- (void)setZoomInScale:(CGFloat)zoomInScale
{
    if (zoomInScale >= 1.f) {
        _zoomInScale = zoomInScale;
        /** 重新绘制进度部分 */
        [_gradientMaskLayer removeFromSuperlayer];
        _progressLayer = nil;
        [self drawButton];
    }
}

#pragma mark - 点击事件
- (void)LFRB_tapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_special || _progress == 0) {
            [self didTouchDownInSingle];
            if (self.didTouchSingle) {
                self.didTouchSingle();
            }
        }
    }
}

- (void)LFRB_longAction:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:[UIApplication sharedApplication].keyWindow];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.originPoint = point;
            [self didTouchDown];
            if (self.didTouchLongBegan) {
                self.didTouchLongBegan();
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.didTouchLongMove) {
                self.didTouchLongMove(point);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (!_special || _progress >= 1.f) {
                [self didTouchUp];
            }
            if (self.didTouchLongEnd) {
                self.didTouchLongEnd();
            }
        }
        default:
            break;
    }
}

- (void)didTouchDownInSingle {
    CGFloat duration = 0.15;
    _foreLayer.contentsGravity = @"center";
    
    // Animate fore circle
    CABasicAnimation *foreScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    foreScale.fromValue = @1.0;
    foreScale.toValue = @0.9;
    [foreScale setDuration:duration];
    
    [_foreLayer addAnimation:foreScale forKey:@"LFRB_foreCircleAnimations"];
}

- (void)didTouchDown {
    
    CGFloat duration = 0.15;
    _foreLayer.contentsGravity = @"center";
    
    // Animate fore circle
    CABasicAnimation *foreScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    foreScale.fromValue = [NSNumber numberWithFloat:[[_foreLayer.presentationLayer valueForKeyPath: @"transform.scale"] floatValue]];
    foreScale.toValue = @0.7;
    [foreScale setDuration:duration];
    foreScale.fillMode = kCAFillModeForwards;
    foreScale.removedOnCompletion = NO;
    
    // Animate back circle
    CABasicAnimation *backScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backScale.fromValue = [NSNumber numberWithFloat:[[_backLayer.presentationLayer valueForKeyPath: @"transform.scale"] floatValue]];
    backScale.toValue = @(self.zoomInScale);
    [backScale setDuration:duration];
    backScale.fillMode = kCAFillModeForwards;
    backScale.removedOnCompletion = NO;
    
    // Animate progress
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @(_progressLayer.opacity);
    fadeIn.toValue = @1.0;
    fadeIn.duration = duration;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    [_progressLayer addAnimation:fadeIn forKey:@"LFRB_progressAnimations"];
    [_backLayer addAnimation:backScale forKey:@"LFRB_backCircleAnimations"];
    [_foreLayer addAnimation:foreScale forKey:@"LFRB_foreCircleAnimations"];
}


- (void)didTouchUp {
    
    CGFloat duration = 0.15;
    
    // Animate fore circle
    CABasicAnimation *foreScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    foreScale.fromValue = @0.7;
    foreScale.toValue =   @1.0;
    [foreScale setDuration:duration];
    foreScale.fillMode = kCAFillModeForwards;
    foreScale.removedOnCompletion = NO;
    
    // Animate back circle
    CABasicAnimation *backScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backScale.fromValue = @(self.zoomInScale);
    backScale.toValue = @1.0;
    [backScale setDuration:duration];
    backScale.fillMode = kCAFillModeForwards;
    backScale.removedOnCompletion = NO;
    
    // Animate progress
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @1.0;
    fadeOut.toValue = @0.0;
    fadeOut.duration = duration-0.05;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    
    [_progressLayer addAnimation:fadeOut forKey:@"LFRB_progressAnimations"];
    [_backLayer addAnimation:backScale forKey:@"LFRB_backCircleAnimations"];
    [_foreLayer addAnimation:foreScale forKey:@"LFRB_foreCircleAnimations"];
}

- (void)removeAnimation
{
    [_progressLayer removeAnimationForKey:@"LFRB_progressAnimations"];
    [_backLayer removeAnimationForKey:@"LFRB_backCircleAnimations"];
    [_foreLayer removeAnimationForKey:@"LFRB_foreCircleAnimations"];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = MIN(MAX(progress, 0), 1);
    _progressLayer.strokeEnd = _progress;
}

/** 重置 */
- (void)reset
{
    [self removeAnimation];
    self.progress = 0.f;
}

@end
