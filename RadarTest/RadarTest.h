//
//  RadarTest.h
//  RadarDemo
//
//  Created by asnail on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadarTest : NSObject

+ (uint64_t)getTotlePhysMemory;
+ (unsigned long long)ra_getUsedPhysMemory;

@end

NS_ASSUME_NONNULL_END
