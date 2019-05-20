//
//  Radar.h
//  Radar
//
//  Created by asnail on 2019/3/18.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadarConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, RAPerformanceDetectorEnableOption) {
    RAPerformanceDetectorEnableOptionNone = 0,                    //不开启
    RAPerformanceDetectorEnableOptionMainThreadBlock = 1 << 0,    //主线程卡顿监控
    RAPerformanceDetectorEnableOptionPageOpenTimeCost = 1 << 1,   //页面打开耗时监控
    RAPerformanceDetectorEnableOptionMemoryPeak = 1 << 2,         //内存峰值监控
    RAPerformanceDetectorEnableOptionMemoryLeaks = 1 << 3,        //内存泄露监控
    RAPerformanceDetectorEnableOptionMemoryMallocChunk = 1 << 4,  //大内存分配监控
    
    RAPerformanceDetectorEnableOptionAll = 0                      //全部开启
    | RAPerformanceDetectorEnableOptionMainThreadBlock
    | RAPerformanceDetectorEnableOptionPageOpenTimeCost
    | RAPerformanceDetectorEnableOptionMemoryPeak
    | RAPerformanceDetectorEnableOptionMemoryLeaks
    | RAPerformanceDetectorEnableOptionMemoryMallocChunk
};

@interface Radar : NSObject

/**
 初始化radar
 @param appId 注册Radar 唯一标识.
 @param options 选择要开启的性能监控器.
 @param config radar 配置.
 */
+ (void)startWithAppId:(NSString *)appId
         enableOptions:(RAPerformanceDetectorEnableOption)options
                config:(RadarConfig * __nullable)config;

/**
 默认退后台会上传log信息,调用此方法可以选择在合适的时机上传.
 */
+ (void)testUpload;

/**
 关闭指定的性能监控器

 @param options 需要关闭的性能指标
 */
+ (void)stopWithOptions:(RAPerformanceDetectorEnableOption)options;

/**
 *  设置用户标识
 *
 *  @param userId 用户标识
 */
+ (void)setUserIdentifier:(NSString *)userId;

/**
 *  设置自定义关键数据，随基础信息上报
 *
 *  @param value value
 *  @param key key
 */
+ (void)setUserValue:(NSString *)value
              forKey:(NSString *)key;

/**
 *  获取关键数据
 *
 *  @return 关键数据
 */
+ (nullable NSDictionary *)allUserValues;

/**
 *  SDK 版本信息
 *
 *  @return SDK 版本信息
 */
+ (NSString *)sdkVersion;

/**
 *  SDK 版本信息
 *
 *  @return SDK 版本信息
 */
+ (NSUInteger)sdkVersionNumber;

@end

NS_ASSUME_NONNULL_END
