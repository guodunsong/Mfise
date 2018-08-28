//
//  ShareView.m
//  TYAlertControllerDemo
//
//  Created by tanyang on 15/10/26.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "UploadRateView.h"
#import "UIView+TYAlertView.h"
#import "CXDatePickerView.h"

@interface UploadRateView()
@property (weak, nonatomic) IBOutlet UILabel *uploadRateLbl;

@end

@implementation UploadRateView

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}

- (IBAction)onTextView:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    CXDatePickerView *datepicker = [[CXDatePickerView alloc] initWithZeroDayCompleteBlock:^(NSInteger days, NSInteger hours, NSInteger minutes) {
        NSString *dateStr = [NSString stringWithFormat:@"%02ld-%02ld-%02ld", (long)days, (long)hours, (long)minutes];
        NSLog(@"%@",dateStr);
        weakSelf.uploadRateLbl.text = dateStr;
        
        
    }];
    
    datepicker.dateLabelColor = RGBHex(0x1B97D2);//年-月-日-时-分 颜色
    datepicker.datePickerColor = RGBHex(0x1B97D2);//滚轮日期颜色
    datepicker.doneButtonColor = RGBHex(0x1B97D2);;//确定按钮的颜色
    datepicker.cancelButtonColor = datepicker.doneButtonColor;
    [datepicker show];
}

- (IBAction)onSureBtn:(id)sender {
    if ([_uploadRateLbl.text isEqualToString:@"点击选择上传频率"]) {
        [SVProgressHUD showInfoWithStatus:@"请选择上传频率"];
        return;
    }
    
    if (_complete) {
        _complete(_uploadRateLbl.text);
        [self hideView];
    }
}

@end
