//
//  UserInfoController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "UserInfoController.h"

@interface UserInfoController ()
@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UILabel *accountLbl;
@property (weak, nonatomic) IBOutlet UILabel *companyLbl;
@property (weak, nonatomic) IBOutlet UILabel *warehouseLbl;


@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [self initView];
    
    _accountLbl.text = [UserMgr shared].account;
    _companyLbl.text = [UserMgr shared].companyName;
    if ([UserMgr shared].warehouseDic) {
        _warehouseLbl.text = [UserMgr shared].warehouseDic[@"storageName"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    self.accountView.layer.cornerRadius = 3.0;
    self.accountView.layer.borderColor = RGBHex(0x1B97D2).CGColor;
    self.accountView.layer.borderWidth = 1.0;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar lt_setBackgroundColor:RGBHex(0x1B97D2)];

}

- (IBAction)onBack:(id)sender {
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
