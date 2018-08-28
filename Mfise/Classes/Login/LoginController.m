//
//  LoginController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "LoginController.h"
#import "NSString+AES.h"
#import "RequestTool.h"
#import "URLTool.h"

@interface LoginController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 初始化视图
 */
- (void)initView {

    self.loginBtn.layer.shadowOffset = CGSizeMake(3, 3);
    self.loginBtn.layer.shadowOpacity = 0.3;
    self.loginBtn.layer.cornerRadius = 3.0;
}

/**
 登陆
 @param sender sender description
 */
- (IBAction)onLogin:(id)sender {
    NSString *account = _accountTextfield.text;
    NSString *pwd = _passwordTextfield.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"account"] = account;
    params[@"password"] = [self encryString:pwd];
    params[@"validateCode"] = @"23";
    params[@"loginIp"] = @"127.0.0.1";
    params[@"appFlag"] = @"keeper";

    
    NSString *url = [[URLTool shared] networkPath:@"login"];
    [SVProgressHUD showWithStatus:@"正在登录..."];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeGradient)];
    [[RequestTool shared] post:url params:params callback:^(ResModel *response) {
        [SVProgressHUD dismiss];
        if (response.code == 200) {
            
            [[UserMgr shared] saveDic:response.data];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            kAppDelegate.window.rootViewController = vc;
        } else {
//            [SVProgressHUD showErrorWithStatus:response.message];
            [self.view makeToast:response.message];
        }
        
    }];
}


/**
 密码编码(密码先通过aes加密，然后在转unicode)
 
 @param pwd pwd description
 @return return value description
 */
- (NSString *)encryString:(NSString *)pwd {
    NSString *aesStr = [pwd aci_encryptWithAES];
    NSString *unicodeStr = [self unicodeFromString:aesStr];

    return unicodeStr;
}


/**
 字符串unicode编码
 
 @param string string description
 @return return value description
 */
- (NSString *)unicodeFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *unicode=@"";
    for (int i = 0; i < [myD length]; i++) {
        NSString *newUnicode = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if ([newUnicode length] == 1)
            unicode = [NSString stringWithFormat:@"%@\\u0%@",unicode,newUnicode];
        else
            unicode = [NSString stringWithFormat:@"%@\\u%@",unicode,newUnicode];
    }
    return unicode;
}


#pragma mark -
#pragma mark UITextFieldDelegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self textField:textField highlight:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length <= 0) {
        [self textField:textField highlight:NO];
    }
}

//设置文本框的高亮状态
- (void)textField:(UITextField *)textField highlight:(BOOL)highlight {
    
    NSInteger tag = textField.tag;
    UIImageView *imgView = [self.view viewWithTag: tag + 1];
    UIView *view = [self.view viewWithTag:tag + 2];
    view.layer.borderColor = RGBHex(0x1B97D2).CGColor;
    view.layer.cornerRadius = 3.0;
    view.clipsToBounds = YES;


    if (highlight) {
        view.backgroundColor = [UIColor clearColor];
        view.layer.borderWidth = 1.0;
        imgView.highlighted = YES;
        
    } else {
        view.backgroundColor = RGBHex(0xeeeeee);
        view.layer.borderWidth = 0.0;
        imgView.highlighted = NO;
    }
    
}


@end
