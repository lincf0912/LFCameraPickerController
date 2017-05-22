//
//  LFRecordButton.m
//  SDRecordButton-Demo
//
//  Created by LamTsanFeng on 2017/5/10.
//  Copyright © 2017年 Sebastian Dobrincu. All rights reserved.
//

#import "LFRecordButton.h"

NSString *const LFRB_progressAnimations = @"LFRB_progressAnimations";
NSString *const LFRB_backCircleAnimations = @"LFRB_backCircleAnimations";
NSString *const LFRB_foreCircleAnimations = @"LFRB_foreCircleAnimations";
NSString *const LFRB_progressStrokeAnimation = @"LFRB_progressStrokeAnimation";

@interface LFRecordButton ()
{
    UILongPressGestureRecognizer *_longPressGR;
}
@property (nonatomic, strong) CALayer *foreLayer;
@property (nonatomic, strong) CALayer *backLayer;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*progressLayers;
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*progressSeparatorLayers;

/** 被选中的layer */
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*selectedProgressLayers;

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
    
    [super layoutSubviews];
    _foreLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _foreLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    
    _backLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _backLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};

    _progressLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _progressLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
}

- (void)customInit
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    /** 添加手势 */
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LFRB_tapAction:)]];
    _longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LFRB_longAction:)];
    [self addGestureRecognizer:_longPressGR];
    
    _progressLayers = [@[] mutableCopy];
    _progressSeparatorLayers = [@[] mutableCopy];
    _selectedProgressLayers = [@[] mutableCopy];
    
    _foreColor = [UIColor whiteColor];
    _backColor = [UIColor colorWithWhite:0.9 alpha:9.f];
    _progressColor = [UIColor colorWithRed:(26/255.0) green:(178/255.0) blue:(10/255.0) alpha:1.0];
    _randomProgressColor = NO;
    _zoomInScale = 1.5f;
    _progressWidth = 4.0f;
    _special = NO;
    _progressSeparator = YES;
    _progressSeparatorColor = [UIColor grayColor];
    _selectedProgressColor = [UIColor redColor];
    
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
        
        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        _progressLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _progressLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _progressLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        _progressLayer.opacity = 0.0;
        [layer addSublayer:_progressLayer];
    }
}

- (void)createPrgoressLayer
{
    CGFloat startAngle = M_PI + M_PI_2;
    CGFloat endAngle = M_PI * 3 + M_PI_2;
    
    CGPoint centerPoint = CGPointMake(self.progressLayer.bounds.size.width/2, self.progressLayer.bounds.size.height/2);
    
    /** 创建分隔符 */
    if (self.progressSeparator && self.progressLayers.count) {
        CGFloat lineWidth = self.progressWidth+3;
        CAShapeLayer *separator = [CAShapeLayer layer];
        separator.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:(self.frame.size.width*self.zoomInScale-lineWidth)/2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
        separator.backgroundColor = [UIColor clearColor].CGColor;
        separator.fillColor = nil;
        separator.strokeColor = self.progressSeparatorColor.CGColor;
        separator.lineWidth = lineWidth;
        separator.strokeStart = self.progress-0.005;
        separator.strokeEnd = self.progress;
        [self.progressLayer addSublayer:separator];
        [self.progressSeparatorLayers addObject:separator];
    }
    
    CAShapeLayer *subProgressLayer = [CAShapeLayer layer];
    subProgressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:(self.frame.size.width*self.zoomInScale-self.progressWidth)/2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    subProgressLayer.backgroundColor = [UIColor clearColor].CGColor;
    subProgressLayer.fillColor = nil;
    subProgressLayer.strokeColor = self.progressColor.CGColor;
    subProgressLayer.lineWidth = self.progressWidth;
    subProgressLayer.strokeStart = self.progress;
    subProgressLayer.strokeEnd = self.progress;
    
    [self.progressLayer addSublayer:subProgressLayer];
    [self.progressLayers addObject:subProgressLayer];
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

- (void)setZoomInScale:(CGFloat)zoomInScale
{
    if (zoomInScale >= 1.f) {
        _zoomInScale = zoomInScale;
    }
}

#pragma mark - 点击事件
- (void)LFRB_tapAction:(UITapGestureRecognizer *)gesture
{
    if (self.onlyLongTap) {
        return;
    }
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
    if (self.onlySingleTap) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            if (!_special || _progress == 0) {
                [self didTouchDownInSingle];
                if (self.didTouchSingle) {
                    self.didTouchSingle();
                }
            }
        }
        return;
    }
    
    CGPoint point = [gesture locationInView:[UIApplication sharedApplication].keyWindow];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            /** 恢复选中的进度条颜色 */
            if (self.selectedProgressLayers.count) {
                for (CAShapeLayer *subProgressLayer in self.selectedProgressLayers) {
                    [subProgressLayer removeAnimationForKey:LFRB_progressAnimations];
                }
                [self.selectedProgressLayers removeAllObjects];
            }
            /** 开启随机颜色 */
            if (self.randomProgressColor) {
                int R = (arc4random() % 256) ;
                int G = (arc4random() % 256) ;
                int B = (arc4random() % 256) ;
                
                self.progressColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
            }
            /** 创建进度条 */
            if (self.special && self.progress < 1.f) {
                [self createPrgoressLayer];
            } else if (self.progressLayers.count == 0) {
                [self createPrgoressLayer];
            }
            
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
    /** 特别模式时 解决闪烁问题 */
    fadeIn.fromValue = (self.special && self.progress > 0.f && self.progress < 1.f) ? @1.0 : @(_progressLayer.opacity);
    fadeIn.toValue = @1.0;
    fadeIn.duration = duration;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    [_progressLayer addAnimation:fadeIn forKey:LFRB_progressAnimations];
    [_backLayer addAnimation:backScale forKey:LFRB_backCircleAnimations];
    [_foreLayer addAnimation:foreScale forKey:LFRB_foreCircleAnimations];
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
    
    [_progressLayer addAnimation:fadeOut forKey:LFRB_progressAnimations];
    [_backLayer addAnimation:backScale forKey:LFRB_backCircleAnimations];
    [_foreLayer addAnimation:foreScale forKey:LFRB_foreCircleAnimations];
}

- (void)removeAnimation
{
    [_progressLayer removeAnimationForKey:LFRB_progressAnimations];
    [_backLayer removeAnimationForKey:LFRB_backCircleAnimations];
    [_foreLayer removeAnimationForKey:LFRB_foreCircleAnimations];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = MIN(MAX(progress, 0), 1);
    CAShapeLayer *subProgressLayer = self.progressLayers.lastObject;
    subProgressLayer.strokeEnd = _progress;
}

/** 重置 */
- (void)reset
{
    [self removeAnimation];
    [[self.progressLayer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.progressLayers removeAllObjects];
    [self.progressSeparatorLayers removeAllObjects];
    [self.selectedProgressLayers removeAllObjects];
    self.progress = 0.f;
}

/** 选中上一段进度 */
- (BOOL)selectedLastProgress
{
    NSInteger index = self.progressLayers.count - self.selectedProgressLayers.count - 1;
    if (index >= 0) {
        CAShapeLayer *subProgressLayer = [self.progressLayers objectAtIndex:index];
//        subProgressLayer.strokeColor = self.selectedProgressColor.CGColor;
        CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        strokeAnimation.fromValue = (__bridge id _Nullable)(subProgressLayer.strokeColor);
        strokeAnimation.toValue = (__bridge id _Nullable)(self.selectedProgressColor.CGColor);
        strokeAnimation.duration = 0.15f;
        strokeAnimation.fillMode = kCAFillModeForwards;
        strokeAnimation.removedOnCompletion = NO;
        [subProgressLayer addAnimation:strokeAnimation forKey:LFRB_progressAnimations];
        [self.selectedProgressLayers addObject:subProgressLayer];
        
        return YES;
    }
    
    return NO;
}

/** 删除选中的进度部分 */
- (BOOL)deleteSelectedProgress
{
    if (self.selectedProgressLayers.count) {
        for (CAShapeLayer *subProgressLayer in self.selectedProgressLayers) {
            NSInteger index = [self.progressLayers indexOfObject:subProgressLayer];
            index--; /** 分隔符会比实际进度少一个 */
            [self.progressLayers removeObject:subProgressLayer];
            [subProgressLayer removeFromSuperlayer];
            if (index < 0 || index > self.progressSeparatorLayers.count-1) {
                continue;
            }
            CAShapeLayer *separatorLayer = [self.progressSeparatorLayers objectAtIndex:index];
            [self.progressSeparatorLayers removeObject:separatorLayer];
            [separatorLayer removeFromSuperlayer];
        }
        [self.selectedProgressLayers removeAllObjects];
        /** 更新进度 */
        CAShapeLayer *progressLayer = self.progressLayers.lastObject;
        _progress = progressLayer.strokeEnd;
        if (_progress == 0) {
            [self reset];
        }
        return YES;
    }
    
    return NO;
}
@end
