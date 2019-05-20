//
//  ViewController.m
//  RadarDemo
//
//  Created by asnail on 2019/4/11.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "RAMemoryIndicator.h"

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

@interface RAMemoryIndicator()
@property (nonatomic, strong) CAShapeLayer *waveLayer;
@property (nonatomic, strong) NSByteCountFormatter *formatter;
@property (nonatomic, assign) double threshold;
@property (nonatomic, strong) UILabel *label;
@end

@implementation RAMemoryIndicator
{
    NSTimer *_timer;
    BOOL _isShowing;
    NSTimer *_waveTimer;
}

+ (instancetype)indicator
{
    RAMemoryIndicator *indicator = [RAMemoryIndicator new];
    indicator.frame = CGRectMake(0, 0, 80, 80);
    return indicator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)show:(BOOL)yn
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (yn) {
        self.center = CGPointMake(keyWindow.bounds.size.width * 0.5, keyWindow.bounds.size.height - self.frame.size.height * 0.5 - 30);
        [keyWindow addSubview:self];
    } else {
        [self removeFromSuperview];
    }
    _isShowing = yn;
}

- (void)setMemory:(CGFloat)memory
{
    _memory = memory;
    
    if (!_isShowing) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (!weakSelf) {
            return;
        }
        weakSelf.label.text = [weakSelf.formatter stringFromByteCount:memory];
        CGFloat ratio = 1.0 * memory / weakSelf.threshold;
        if (ratio < 0.3) {
            ratio = 0;
        }
        weakSelf.layer.borderColor = [[UIColor colorWithRed:ratio  green:MAX((1 - ratio), 0) blue:0 alpha:1] colorWithAlphaComponent:0.7].CGColor;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
    self.label.font = [UIFont systemFontOfSize:self.frame.size.width * 0.2];
    self.waveLayer.frame = self.bounds;
    self.layer.cornerRadius = self.frame.size.width * 0.5;
    self.layer.borderWidth = self.frame.size.width * 0.04;
}

- (void)setup
{
    _threshold = 300;
    _formatter = [NSByteCountFormatter new];
    _formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    
    self.waveLayer = [CAShapeLayer new];
    self.waveLayer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6].CGColor;
    self.waveLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:self.waveLayer];
    
    self.backgroundColor = [UIColor whiteColor];
    
    
    self.layer.borderColor = [[UIColor greenColor] colorWithAlphaComponent:0.7].CGColor;
    self.clipsToBounds = YES;
    
    self.label = [UILabel new];
    self.label.textColor = [UIColor blackColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];

    [self setCurrentWaveLayerPath];
    
    _waveTimer = [NSTimer scheduledTimerWithTimeInterval:0.022 target:self selector:@selector(setCurrentWaveLayerPath) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_waveTimer forMode:NSRunLoopCommonModes];
}

- (void)dealloc
{
    [_waveTimer invalidate];
    _waveTimer = nil;
}

- (void)onLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scale) userInfo:nil repeats:YES];
        }
    } else {
        [_timer invalidate];
        _timer = nil;
    }
    
}

- (void)scale
{
    static BOOL flag = YES;
    static CGFloat scale = 1;

    if (flag) {
        scale += 0.04;
        if (scale > 2) {
            scale = 2;
            flag = NO;
        }
    } else {
        scale -= 0.04;
        if (scale < 0.2) {
            scale = 0.2;
            flag = YES;
        }
    }
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)onPan:(UIGestureRecognizer *)recognizer
{
    self.center = [recognizer locationInView:self.superview];
}

- (void)setCurrentWaveLayerPath
{
    
    if (!_isShowing) {
        return;
    }
    
    // 正弦曲线公式：y=Asin(ωx+φ)+k
    
    CGFloat wh = self.bounds.size.width;
    if (0 == wh) {
        return;
    }
    CGFloat persent = 1 - MIN(1, self.memory / _threshold);
    CGFloat s_ω = 2 * M_PI / wh;
    CGFloat s_k = wh * persent;
    CGFloat s_φ = 0;
    CGFloat s_A = 1.3f * wh / 80.f;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, wh * persent)];
    
    static CGFloat controlX = 0;
    s_φ = controlX;
    
    for (float x = 0.f; x <= wh; x += 2)
    {
        CGFloat y = s_A * sin(s_ω * x + s_φ) + s_k;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    
    [path addLineToPoint:CGPointMake(wh, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path closePath];
    
    controlX += 0.4 / M_PI;;
    
    self.waveLayer.path = [path CGPath];
}

- (void)setThreshhold:(double)value
{
    _threshold = value;
}

@end
