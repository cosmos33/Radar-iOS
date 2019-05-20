//
//  RadarTest.m
//  RadarDemo
//
//  Created by asnail on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "RadarTest.h"
#include <sys/sysctl.h>
#import <mach-o/ldsyms.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <limits.h>

@implementation RadarTest

+ (unsigned long long)ra_getUsedPhysMemory {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (unsigned long long) vmInfo.phys_footprint;
    } else {
        memoryUsageInByte = 0;
    }
    return memoryUsageInByte;
}

+ (uint64_t)getTotlePhysMemory {
    return [NSProcessInfo processInfo].physicalMemory;
}

@end
