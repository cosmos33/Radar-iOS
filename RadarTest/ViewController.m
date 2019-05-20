//
//  ViewController.m
//  RadarDemo
//
//  Created by asnail on 2019/4/11.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "ViewController.h"
#import "RadarTest.h"
#import <sys/time.h>
#import <Radar/Radar.h>
#import "Demo2ViewController.h"
#import "Demo3ViewController.h"
#import "RAMemoryIndicator.h"

#define Tick() CFAbsoluteTime __s = CFAbsoluteTimeGetCurrent()
#define Tock(s) NSLog(s "cost : %.2f ms", (CFAbsoluteTimeGetCurrent() - __s) *  1000)

#define KColorBlue ColorFromRGBA(52, 98, 255, 1.0)
#define KColorRed ColorFromRGBA(255, 45, 85, 1.0)
#define KColorWhite ColorFromRGBA(255, 255, 255, 1.0)
#define ColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface ViewController ()

@property (nonatomic, strong) RAMemoryIndicator *memIndicator;
@property (nonatomic, strong) RadarTest *maTester;
@property (nonatomic, assign) BOOL needUI;

@end

@implementation ViewController {
    int allocatedMB;
    Byte *p[10000];
    NSTimer *_memUpdater;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maTester = [RadarTest new];
        self.needUI = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Radar Demos";
    
    if (!self.needUI) {
        return;
    }
    
    CGFloat left = 20;
    CGFloat btnHeight = 50.;
    CGFloat margin = 20;
    CGFloat btnWidth = CGRectGetWidth(self.view.bounds) - 2 * margin;
    
    __block CGFloat top = 100;
    dispatch_block_t move = ^{
        top += btnHeight + margin;
    };
    
    [self addButtonWithFrame:CGRectMake(left, top, btnWidth, btnHeight) backgroundColor:KColorBlue title:@"Block Main Thread A While" action:@selector(testForegroundMainthreadLog)];
    move();
    [self addButtonWithFrame:CGRectMake(left, top, btnWidth, btnHeight) backgroundColor:KColorBlue title:@"Check Page Time" action:@selector(testPageTimeCost)];
    move();
    [self addButtonWithFrame:CGRectMake(left, top, (btnWidth - margin) / 2, btnHeight) backgroundColor:KColorRed title:@"⤴️ Mem(40M)" action:@selector(increaseMem)];
    [self addButtonWithFrame:CGRectMake(left + (btnWidth - margin) / 2 + margin, top, (btnWidth - margin) / 2, btnHeight) backgroundColor:KColorRed title:@"⬇️ Mem(40M)" action:@selector(decreaseMem)];
    move();
    [self addButtonWithFrame:CGRectMake(left, top, btnWidth, btnHeight) backgroundColor:KColorRed title:@"Push Leak Page" action:@selector(testLeakPage)];
    move();
    [self addButtonWithFrame:CGRectMake(left, top, btnWidth, btnHeight) backgroundColor:KColorRed title:@"Check Mem Chunk" action:@selector(testChunk)];
    move();
    [self addButtonWithFrame:CGRectMake(left, top, btnWidth, btnHeight) backgroundColor:KColorRed title:@"Test Upload" action:@selector(testUpload)];
    move();
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memFuck:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    // mem indicator
    _memUpdater = [NSTimer timerWithTimeInterval:0.03 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_memUpdater forMode:NSRunLoopCommonModes];
}

- (void)timerFired {
    [self.memIndicator setMemory:[RadarTest ra_getUsedPhysMemory]];
}

- (void)memFuck:(NSNotification *)ntf {
//    float free = [RAUtility freeMemory:YES];
//    NSLog(@"memory warning! currentMem:%lu  free:%f", (unsigned long)[RAUtility freeMemoryRatio], free);
}

- (void)testForegroundMainthreadLog
{
    NSLog(@"Test Foreground Main Thread Log");
    NSLog(@"wait.. 1s");
    [self.maTester generateMainThreadLagLog];
}

- (void)testPageTimeCost {
    UIViewController *vc = [UIViewController new];
//    [self presentViewController:vc animated:YES completion:nil]; //520ms
    
//    Demo3ViewController *demo = [Demo3ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)testLeakPage {
    Demo2ViewController *demo = [Demo2ViewController new];
    [self.navigationController pushViewController:demo animated:YES];
}

- (void)increaseMem {
    size_t size = 40 * 1048576;
    p[allocatedMB] = malloc(size);
    memset(p[allocatedMB], 0, size);
    allocatedMB ++;
}

- (void)decreaseMem {
    if (allocatedMB > 0) {
        free(p[allocatedMB-1]);
        p[allocatedMB-1] = NULL;
        allocatedMB--;
    }
}

- (void)testChunk {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        p[allocatedMB] = malloc(100 * 1048576);
        memset(p[allocatedMB], 0, 100 * 1048576);
        allocatedMB += 1;
    });
}

- (void)testUpload {
    [Radar testUpload];
}

- (UIButton *)addButtonWithFrame:(CGRect)btnFrame
                 backgroundColor:(UIColor *)color
                           title:(NSString *)title
                          action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] initWithFrame:btnFrame];
    [btn setBackgroundColor:color];
    [btn setTitleColor:KColorWhite forState:UIControlStateNormal];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [self.view addSubview:btn];
    return btn;
}

- (RAMemoryIndicator *)memIndicator {
    if (!_memIndicator) {
        _memIndicator = [RAMemoryIndicator indicator];
        CGFloat wh = 80;
        _memIndicator.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - wh) / 2, CGRectGetHeight(self.view.bounds) - 50, wh, wh);
        [_memIndicator setThreshhold:[RadarTest getTotlePhysMemory] * 0.4];
        [_memIndicator show:YES];
    }
    return _memIndicator;
}

@end
