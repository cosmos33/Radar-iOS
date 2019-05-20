//
//  RadarConfig.h
//  Radar
//
//  Created by asnail on 2019/3/18.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

@protocol RadarDelegate <NSObject>

@optional

/**
 获取视图控制器的名字,如果不实现此方法或者返回空,默认取class作为当前视图控制器的名字.
 通常你不需要实现此方法.
 - (NSString *)aliasForViewController:(UIViewController *)viewController {
     if ([viewController isKindOfClass:[DemoViewController class]] {
         return @"demo";
     })
     return nil;
 }
 @return alias for viewController.
 */
- (NSString *)aliasForViewController:(UIViewController *)viewController;

@end

@interface RadarConfig : NSObject

/**
 *  设置自定义版本号,如果不设置则取 CFBundleVersion
 */
@property (nonatomic, copy) NSString *customAppVersion;;

/**
 *  设置自定义设备唯一标识
 */
@property (nonatomic, copy) NSString *deviceId;

/**
 *  设置自定义渠道标识
 */
@property (nonatomic, copy) NSString *channel;

/**
 *  SDK回调
 */
@property (nonatomic, assign) id<RadarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
