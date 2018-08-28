//
//  BaseController.m
//  BluetoothPallet
//
//  Created by issuser on 2018/8/20.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BaseController.h"

@interface BaseController ()

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navShadowImgView.hidden = YES;
    [SVProgressHUD setDefaultStyle:(SVProgressHUDStyleDark)];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeClear)];
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

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] &&
        view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;

    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (UIImageView *)navShadowImgView {
    if (_navShadowImgView == nil) {
        _navShadowImgView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    }
    return _navShadowImgView;
}

@end
