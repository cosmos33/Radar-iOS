//
//  Demo3ViewController.m
//  RadarDemo
//
//  Created by asnail on 2019/4/15.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "Demo3ViewController.h"
#import "RadarTest.h"

@interface Demo3ViewController ()

@property (nonatomic, strong) RadarTest *maTester;
@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maTester = [RadarTest new];
    [self.maTester generateMainThreadLagLog];

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
