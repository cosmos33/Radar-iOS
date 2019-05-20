//
//  Demo2ViewController.m
//  RadarDemo
//
//  Created by asnail on 2019/4/12.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

#import "Demo2ViewController.h"

@interface LeakedObject1 : NSObject

@property (nonatomic, strong) id p_objc;

@end

@implementation LeakedObject1
@end

@interface LeakedObject2 : LeakedObject1

@end

@implementation LeakedObject2
@end

@interface LeakedObject3 : LeakedObject1

@end

@implementation LeakedObject3
@end

@interface LeakedObject4 : LeakedObject1

@end

@implementation LeakedObject4
@end


@interface Demo2ViewController ()

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, strong) id leakedObject;

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LeakedObject1 *lko1 = [LeakedObject1 new];
    lko1.p_objc = self;
    
    LeakedObject2 *lko2 = [LeakedObject2 new];
    lko2.p_objc = lko1;
    
    LeakedObject3 *lko3 = [LeakedObject3 new];
    lko3.p_objc = lko2;
    
    LeakedObject4 *lko4 = [LeakedObject4 new];
    lko4.p_objc = lko3;
    
    self.leakedObject = lko4;
}
#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController popViewControllerAnimated:YES];
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
