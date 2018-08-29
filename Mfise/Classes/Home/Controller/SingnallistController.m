//
//  SingnallistController.m
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "SingnallistController.h"
#import "BlePalletManager.h"
#import "BLEManager.h"
#import "BLEPeripheral.h"
#import "TerminalDetailController.h"
#import "SingnallistCell.h"
#import "UploadRateView.h"

@interface SingnallistController ()<UITableViewDataSource,UITableViewDelegate,BlePalletManagerDelegate> {
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary<NSString *,NSInvocation *> *eventStrategy;
@property (strong, nonatomic) UIButton *batchConfigBtn;   //批量配置
@property (nonatomic, strong) BLEManager *bleMgr;
@property (nonatomic, strong) BlePalletManager *blePalletMgr;

@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) NSMutableIndexSet *selectedIndexSet;
@property(nonatomic, strong) NSMutableArray *selectedArr;
@property(nonatomic, strong) NSString *uploadRate;

//批量配置的索引号
@property(nonatomic, assign) NSUInteger curIndex;
@property(nonatomic, assign) BOOL configuring;

@end

@implementation SingnallistController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeGradient)];
    [self.navigationController.navigationBar setHidden:NO];
    [self setupView];
    
    _curIndex = 0;
    _dataArr = [NSMutableArray array];
    _selectedIndexSet = [NSMutableIndexSet indexSet];
    _bleMgr = [BLEManager sharedInstance];
    _blePalletMgr = [[BlePalletManager alloc] initWithDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupView {
    [self.view addSubview:self.batchConfigBtn];
    [self.batchConfigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view).offset(-32);
        CGFloat height = self.batchConfigBtn.layer.cornerRadius * 2;
        make.size.mas_equalTo(CGSizeMake(height, height));
    }];
    
}

- (void)executeBatchConfig:(NSInteger) index {
    _curIndex = index;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    BLEPeripheral *peripheral = [self.selectedArr objectAtIndex:index];
    if (peripheral.state == BLEPeripheralStateUnknown) {
        [SVProgressHUD showWithStatus:@"正在连接设备"];
        [_blePalletMgr connectBleDevice:peripheral tag:1000+index];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在配置数据"];
    NSString *ICCID = [peripheral.peripheral.name stringByReplacingOccurrencesOfString:@"SP" withString:@""];
    NSDictionary *jsonDic = @{@"CMD":@(1),@"ICCID":ICCID,@"Upgrade":@(0),@"RTCVal":self.uploadRate};
    NSLog(@">>>>:%@",[jsonDic mj_JSONString]);
    [_blePalletMgr fetchWithTag:2000+index params:jsonDic];
}

#pragma mark -
#pragma mark get method
- (NSMutableArray *)selectedArr {
    if (_selectedArr == nil) {
        NSArray *arr = [_dataArr objectsAtIndexes:_selectedIndexSet];
        _selectedArr = [[NSMutableArray alloc] initWithArray:arr];
    }
    
    return _selectedArr;
}


- (UIButton *)batchConfigBtn {
    if (_batchConfigBtn == nil) {
        _batchConfigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _batchConfigBtn.backgroundColor = RGBHex(0x1B97D2);
        _batchConfigBtn.layer.cornerRadius = 30.0;
        _batchConfigBtn.titleLabel.numberOfLines = 0;
        _batchConfigBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        _batchConfigBtn.layer.shadowOffset = CGSizeMake(3, 3);
        _batchConfigBtn.layer.shadowOpacity = 0.3;
        [_batchConfigBtn addTarget:self action:@selector(onBatchConfigBtn:) forControlEvents:(UIControlEventTouchUpInside)];
        [_batchConfigBtn setTitle:@"批量\n配置" forState:(UIControlStateNormal)];
    }
    
    return _batchConfigBtn;
}


#pragma mark -
#pragma mark Action method
/**
 返回上一级

 @param sender sender description
 */
- (IBAction)onBack:(id)sender {
    if([self.refreshBtn.title isEqualToString:@"停止"]) {
        [self onRefresh:self.refreshBtn];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 扫描蓝牙设备

 @param sender sender description
 */
- (IBAction)onRefresh:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"停止"]) {
        [self.bleMgr stopScan];
        [sender setTitle:@"扫描"];
        self.title = @"蓝牙设备列表";
        return;
    }
    
    [sender setTitle:@"停止"];
    self.title = @"正在扫描...";
    [_dataArr removeAllObjects];
    [_tableView reloadData];
    
    __weak typeof(self) weakself = self;
    [self.bleMgr scanPeripheralWithUUIDs:nil resultCallback:^(NSDictionary *data, NSError *error) {
        __strong typeof(weakself) strongself = weakself;
        for (BLEPeripheral *peripheral in data.allValues) {
            if ([peripheral.peripheral.name containsString:@"SP"] &&
                [strongself.dataArr containsObject:peripheral] == NO) {
                [strongself.dataArr addObject:peripheral];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongself.countLbl.text = [NSString stringWithFormat:@"%@",@(strongself.dataArr.count)];
                    [strongself.tableView reloadData];
                });
            }
        }
        
    }];
}


/**
 批量配置

 @param sender sender description
 */
- (IBAction)onBatchConfigBtn:(id)sender {
    if (_selectedIndexSet.count == 0) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        
        CGFloat y = self.view.bounds.size.height - 64;
        style.cornerRadius = 3.0;
        [self.view makeToast:@"请选择要配置的设备" duration:1.5
                    position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x, y)] style:style];
        return;
    }
    
    
    
    UploadRateView *uploadRateView = [UploadRateView createViewFromNib];
    __typeof (self) __weak weakself = self;
    uploadRateView.complete = ^(NSString *str) {
        __strong __typeof(weakself)strongself = weakself;
        NSLog(@">>>:%@",str);
        strongself.uploadRate = str;
        strongself.configuring = YES;   //开始配置
        [strongself executeBatchConfig:0];
    };
    
    [uploadRateView showInWindow];
}


/**
 全选

 @param sender sender description
 */
- (IBAction)onCheckAllBtn:(UIButton *)sender {
    
    //全选的时候避免数据混乱则停止搜索设备列表
    if ([_refreshBtn.title isEqualToString:@"停止"]) {
        [self onRefresh:_refreshBtn];
    }
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_selectedIndexSet addIndexesInRange:NSMakeRange(0, _dataArr.count)];
    } else {
        [_selectedIndexSet removeAllIndexes];
    }
    [self.tableView reloadData];
}

- (void)onCheckBtn:(id)sender {
    NSLog(@">>>>>>>:%@",sender);
    NSIndexPath *indexPath= sender[@"indexPath"];
    if ([_selectedIndexSet containsIndex:indexPath.row]) {
        [_selectedIndexSet removeIndex:indexPath.row];
    } else {
        [_selectedIndexSet addIndex:indexPath.row];
    }
    
    [_tableView reloadData];
    
}


#pragma mark -
#pragma mark UITableViewDataSource method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SingnallistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingnallistCell"];
    BLEPeripheral *peripheral = _dataArr[indexPath.row];
    cell.checkBtn.selected = [_selectedIndexSet containsIndex:indexPath.row];
    [cell setValue:indexPath forKeyPath:@"indexPath"];
    [cell setValue:peripheral forKeyPath:@"peripheral"];
   
    cell.indicatorView.hidden = YES;
    [cell.indicatorView stopAnimating];
    if (self.configuring) {
        NSInteger index = [_dataArr indexOfObject: self.selectedArr[self.curIndex]];
        if (indexPath.row == index) {
            cell.indicatorView.hidden = NO;
            [cell.indicatorView startAnimating];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //进入下一级页面暂停扫描
    if([self.refreshBtn.title isEqualToString:@"停止"]) {
        [self onRefresh:self.refreshBtn];
    }
    
    TerminalDetailController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TerminalDetailController"];
    [vc setValue: _dataArr[indexPath.row] forKeyPath:@"peripheral"];
    vc.peripheral =  _dataArr[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark UIResponder+Router method
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    NSInvocation *invocation = self.eventStrategy[eventName];
    [invocation setArgument:&userInfo atIndex:2];
    [invocation invoke];
}

- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (_eventStrategy == nil) {
        _eventStrategy = @{@"onCheckBtn":[self createInvocationWithSelector:@selector(onCheckBtn:)]};
    }
    return _eventStrategy;
}

- (NSInvocation *)createInvocationWithSelector:(SEL)selector {
    NSMethodSignature *methodSign = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSign];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    return invocation;
}


#pragma mark -
#pragma mark BlePalletManagerDelegate method
- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didResult:(NSString *)result {
    [SVProgressHUD dismiss];
    NSInteger index = tag -2000;
    index = index + 1;
    if (index < self.selectedArr.count) {
        [self executeBatchConfig:index];
        return;
    }
    
    self.configuring = NO;
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"批量配置完成"];
}

- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didWithError:(NSString *)error {
    [SVProgressHUD dismiss];
}

- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didConnectComplete: (NSNumber *)success error:(NSError *)error {
    [SVProgressHUD dismiss];
    NSInteger index = tag - 1000;
    [self executeBatchConfig:index];
}

@end
