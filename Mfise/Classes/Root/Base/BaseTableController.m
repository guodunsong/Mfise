//
//  BaseTableController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BaseTableController.h"

@interface BaseTableController ()

@end

@implementation BaseTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar lt_setBackgroundColor:RGBHex(0x1B97D2)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}




@end
