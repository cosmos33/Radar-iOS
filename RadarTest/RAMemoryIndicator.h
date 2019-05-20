//
//  ViewController.m
//  RadarDemo
//
//  Created by asnail on 2019/4/11.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAMemoryIndicator : UIView

+ (instancetype)indicator;

- (void)show:(BOOL)yn;

@property (nonatomic, assign) CGFloat memory;

- (void)setThreshhold:(double)value;

@end
