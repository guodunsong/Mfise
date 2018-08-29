//
//  TerminalDetailController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "TerminalDetailController.h"
#import "BlePalletManager.h"
#import "CXDatePickerView.h"
#import "LCActionSheet.h"
#import "UIAlertView+BlocksKit.h"

@interface TerminalDetailController ()<BlePalletManagerDelegate> {
  
}

@property (strong, nonatomic) NSMutableDictionary *terminalInfoDic;

@property (weak, nonatomic) IBOutlet UILabel *versionLbl;
@property (weak, nonatomic) IBOutlet UILabel *terminalIdLbl;
@property (weak, nonatomic) IBOutlet UILabel *locationLbl;
@property (weak, nonatomic) IBOutlet UILabel *faultLbl;
@property (weak, nonatomic) IBOutlet UILabel *voltageLbl;
@property (weak, nonatomic) IBOutlet UILabel *rssiLbl;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *uploadRateLbl;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadCurtBtn;

@property (nonatomic, strong) BlePalletManager *blePallteMgr;
@property (nonatomic, strong) NSMutableArray *historyArr;
@property (nonatomic, assign) NSInteger historyIndex;
@property (nonatomic, assign) BOOL fetchHistory;


@end

@implementation TerminalDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.0;
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeGradient)];
    _rssiLbl.text = [NSString stringWithFormat:@"%@",@(self.peripheral.rssi)];
    
    _blePallteMgr = [[BlePalletManager alloc] initWithDelegate:self];
    [SVProgressHUD showWithStatus:@"正在连接设备"];
    [_blePallteMgr connectBleDevice:self.peripheral tag:1000];
    _historyArr = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 获取历史数据
 */
- (void)fetchBleData {
    if (_peripheral.state == BLEPeripheralStateUnknown) {
        [SVProgressHUD showWithStatus:@"正在连接设备"];
        [_blePallteMgr connectBleDevice:self.peripheral tag:1000];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在读取数据"];
    NSString *ICCID = [self.peripheral.peripheral.name stringByReplacingOccurrencesOfString:@"SP" withString:@""];
    NSDictionary *jsonDic = @{@"CMD":@(0),@"ICCID":ICCID,@"Index":@(0)};
    NSLog(@">>>>:%@",[jsonDic mj_JSONString]);
    [_blePallteMgr fetchWithTag:1000 params:jsonDic];
}


#pragma mark -
#pragma mark set method

/** 示列数据
*#SP2DATA*{
    "ICCID": "898607B3221770072929",
    "CMD": 0,
    "Voltage": 3628,
    "SignalLevel": 27,
    "ChipInfoTime": "2018-08-24,05:14:40",
    "BaseSta1": "13112-32343-18",
    "BaseSta2": "13112-30121-11",
    "BaseSta3": "13112-33253-14",
    "BaseSta4": "13153-30051-5",
    "BaseSta5": "0-0-0",
    "FaultFlag": 0,
    "RTCTime": "00-04-00",
    "UserData": "NULL"
}# */
- (void)setTerminalInfoDic:(NSMutableDictionary *)terminalInfoDic {
    _terminalInfoDic = terminalInfoDic;
    
    NSMutableString *locationStr = [[NSMutableString alloc] init];
    [locationStr appendFormat:@"%@,",terminalInfoDic[@"BaseSta1"]];
    [locationStr appendFormat:@"%@,",terminalInfoDic[@"BaseSta2"]];
    [locationStr appendFormat:@"%@,",terminalInfoDic[@"BaseSta3"]];
    [locationStr appendFormat:@"%@,",terminalInfoDic[@"BaseSta4"]];
    [locationStr appendFormat:@"%@",terminalInfoDic[@"BaseSta5"]];
    
    
    _versionLbl.text = @"暂无";
    _terminalIdLbl.text = terminalInfoDic[@"ICCID"];
    _locationLbl.text = locationStr;
    _faultLbl.text = [NSString stringWithFormat:@"%@",terminalInfoDic[@"FaultFlag"]];
    _voltageLbl.text = [NSString stringWithFormat:@"%@",terminalInfoDic[@"Voltage"]];
    _updateTimeLbl.text = terminalInfoDic[@"ChipInfoTime"];
    _uploadRateLbl.text = terminalInfoDic[@"RTCTime"];
    [self.tableView reloadData];
}


- (NSMutableDictionary *)itemDic:(NSDictionary *)dic {
    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    itemDic[@"currentTimeString"] = currentTimeString;
    
    return itemDic;
}

#pragma mark -
#pragma mark action method

/**
 返回

 @param sender sender description
 */
- (IBAction)onBack:(id)sender {
    [SVProgressHUD dismiss];
    [self.blePallteMgr disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 重新获取数据

 @param sender sender description
 */
- (IBAction)onFetch:(id)sender {
    [self fetchBleData];
}


/**
 上传当前终端信息
 @param sender sender description
 */
- (IBAction)onUploadCurBtn:(id)sender {
    if (_terminalInfoDic == nil) {
        [SVProgressHUD showErrorWithStatus:@"设备数据不能为空"];
        return;
    }
    
    NSMutableDictionary *itemDic = [self itemDic:self.terminalInfoDic];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"positions"] = @[itemDic];
    
    [SVProgressHUD showWithStatus:@"正在上传数据"];
    [self reqSaveDeviceInfo:params];
}


/**
 上传所有终端信息
 @param sender sender description
 */
- (IBAction)onUploadAllBtn:(UIButton *)sender {
    _historyIndex = 0;
    [_historyArr removeAllObjects];
    [self fetchHistoryData:_historyIndex];
}

- (void)fetchHistoryData:(NSInteger) index {
    _fetchHistory = YES;
    
    if (index >= 14) {
        _fetchHistory = NO;
        if (self.historyArr.count <= 0) return;
        
        NSMutableArray *arr = [NSMutableArray array];
        for (NSMutableDictionary *dic in self.historyArr) {
            [arr addObject:[self itemDic:dic]];
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"positions"] = arr;
        [SVProgressHUD showWithStatus:@"正在上传历史数据"];
        [self reqSaveDeviceInfo:params];
        
        return;
    }
    
    _historyIndex = index;
    [SVProgressHUD showWithStatus:@"正在读取数据"];
    NSString *ICCID = [self.peripheral.peripheral.name stringByReplacingOccurrencesOfString:@"SP" withString:@""];
    NSDictionary *jsonDic = @{@"CMD":@(0),@"ICCID":ICCID,@"Index":@(index)};
    NSLog(@">>>>:%@",[jsonDic mj_JSONString]);
    [_blePallteMgr fetchWithTag:(3000 + index) params:jsonDic];
    
}


/**
 选择上传频率

 @param sender sender description
 */
- (IBAction)onUploadRate:(id)sender {
   
    __weak typeof(self) weakSelf = self;
    CXDatePickerView *datepicker = [[CXDatePickerView alloc] initWithZeroDayCompleteBlock:^(NSInteger days, NSInteger hours, NSInteger minutes) {
        NSString *dateStr = [NSString stringWithFormat:@"%02ld-%02ld-%02ld", (long)days, (long)hours, (long)minutes];
        NSLog(@"%@",dateStr);
        weakSelf.uploadRateLbl.text = dateStr;
        if ([dateStr isEqualToString:@"00-00-00"] ||
            [dateStr isEqualToString: weakSelf.terminalInfoDic[@"RTCTime"]] ) {
            weakSelf.sureBtn.enabled = NO;
            weakSelf.sureBtn.backgroundColor = [UIColor lightGrayColor];
            return;
        }
        
        weakSelf.sureBtn.enabled = YES;
        weakSelf.sureBtn.backgroundColor = RGBHex(0x1B97D2);
        
    }];
    
    datepicker.dateLabelColor = RGBHex(0x1B97D2);//年-月-日-时-分 颜色
    datepicker.datePickerColor = RGBHex(0x1B97D2);//滚轮日期颜色
    datepicker.doneButtonColor = RGBHex(0x1B97D2);;//确定按钮的颜色
    datepicker.cancelButtonColor = datepicker.doneButtonColor;
    [datepicker show];
}


/**
 确定配置
 {
    "CMD":1,
    "ICCID":"898607B3221770072988",
    "RTCVal":"0-0-10",
    "Upgrade":0
  }

 @param sender sender description
 */
- (IBAction)onSure:(id)sender {
    
    if (_peripheral.state == BLEPeripheralStateUnknown) {
        [SVProgressHUD showWithStatus:@"正在连接设备"];
        [_blePallteMgr connectBleDevice:self.peripheral tag:2000];
        return;
    }
 
    [SVProgressHUD showWithStatus:@"正在配置数据"];
    NSString *ICCID = [self.peripheral.peripheral.name stringByReplacingOccurrencesOfString:@"SP" withString:@""];
    NSDictionary *jsonDic = @{@"CMD":@(1),@"ICCID":ICCID,@"Upgrade":@(0),@"RTCVal":self.uploadRateLbl.text};
    NSLog(@">>>>:%@",[jsonDic mj_JSONString]);
    [_blePallteMgr fetchWithTag:2000 params:jsonDic];
}


#pragma mark -
#pragma mark request method

- (void)reqSaveDeviceInfo:(NSMutableDictionary *)params {
    NSString *url = [[URLTool shared] networkPath:@"user_storage_save"];
    [[RequestTool shared] post:url params:params callback:^(ResModel *response) {
        [SVProgressHUD dismiss];
        if (response.code == 200) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功."];
        } else {
            [SVProgressHUD showErrorWithStatus:response.message];
        }
        
    }];
}


#pragma mark -
#pragma mark BlePalletManagerDelegate method
- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didConnectComplete:(NSNumber *)success error:(NSError *)error {
    [SVProgressHUD dismiss];
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"蓝牙连接失败"];
        return;
    }
    
    if (tag == 1000) {
        [self fetchBleData];
        return;
    }
    
    if (tag == 2000) {
        [self onSure:nil];
        return;
    }
}

- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didResult:(NSString *)result {
    
    NSLog(@">>>>>>result:%@",result);

    NSString *str = [result stringByReplacingOccurrencesOfString:@"*#SP2DATA*" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] initWithDictionary:[str mj_JSONObject]];
    
    if (tag >= 3000) {
        NSInteger index = (tag - 3000) + 1;
        [_historyArr addObject:resDic];
        NSLog(@">>>>>>历史记录:%@",@(_historyArr.count));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self fetchHistoryData:index];
        });
        
        return;
    }
    
    [SVProgressHUD dismiss];
    //获取历史记录
    if (tag == 1000) {
        self.terminalInfoDic = resDic;
        return;
    }
    
    //配置信息回
    if (tag == 2000) {
        _terminalInfoDic[@"RTCTime"] = _uploadRateLbl.text;
        
        //更新按钮置为灰色
        _sureBtn.enabled = NO;
        _sureBtn.backgroundColor = [UIColor lightGrayColor];
        [SVProgressHUD showSuccessWithStatus:@"更新配置成功"];
    }
}

- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didWithError:(NSString *)error {
    if (_historyArr.count < 14 && _fetchHistory) {//获取历史记录
        UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"错误提示" message:@"获取历史记录中途失败，是否继续获取" cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self fetchHistoryData:self.historyIndex];
            } else if (buttonIndex == 0) {
                [SVProgressHUD dismiss];
            }
        }];
        [alertView show];
        
        return;
    }
    
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showInfoWithStatus:error];
    NSLog(@">>>>>error:%@",error);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return UITableViewAutomaticDimension;
    } else if(indexPath.row == 7) {
        return 270;
    }
    
    return 44.0;
}



@end
