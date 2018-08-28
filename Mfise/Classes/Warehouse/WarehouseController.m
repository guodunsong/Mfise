//
//  WarehouseController.m
//  Mfise
//
//  Created by issuser on 2018/8/23.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "WarehouseController.h"
#import "TerminalDetailController.h"
#import "YBPopupMenu.h"
#import "WarehouseCell.h"
#import "BLEManager.h"
#import "LCActionSheet.h"

@interface WarehouseController ()<UITableViewDataSource,UITableViewDelegate,YBPopupMenuDelegate>  {
    NSMutableArray *_dataArr;
}

@property(nonatomic, strong) UIButton *titleBtn;
@property(nonatomic, strong) NSArray *titles;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (nonatomic, strong) NSDictionary<NSString *,NSInvocation *> *eventStrategy;
@property (nonatomic, strong) BLEManager *bleMgr;
@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) NSMutableIndexSet *selectedIndexSet;
@property(nonatomic, strong) NSMutableArray *selectedArr;


@end

@implementation WarehouseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.titleView = self.titleBtn;

    _dataArr = [NSMutableArray array];
    _selectedIndexSet = [NSMutableIndexSet indexSet];
    _bleMgr = [BLEManager sharedInstance];
    
    NSString *title  = [NSString stringWithFormat:@"%@▼",self.titles[self.type]];
    [self.titleBtn setTitle:title forState:(UIControlStateNormal)];
    [self.titleBtn setTitle:title forState:(UIControlStateHighlighted)];
    
    NSString *submitTitle = [NSString stringWithFormat:@"确定%@",self.titles[self.type]];
    [self.submitBtn setTitle:submitTitle forState:(UIControlStateNormal)];
    [self.submitBtn setTitle:submitTitle forState:(UIControlStateHighlighted)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark -
#pragma mark get method

- (UIButton *)titleBtn {
    if (_titleBtn == nil) {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted)];
        
        [_titleBtn setTitle:@"入库▼" forState:(UIControlStateNormal)];
        [_titleBtn setTitle:@"入库▼" forState:(UIControlStateHighlighted)];
        [_titleBtn addTarget:self action:@selector(onTitleBtn:) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    
    return _titleBtn;
}

- (NSArray *)titles {
    if (_titles == nil) {
        _titles = @[@"入库",@"出库",@"盘点"];
    }
    return _titles;
}

- (NSMutableArray *)selectedArr {
    if (_selectedArr == nil) {
        NSArray *arr = [_dataArr objectsAtIndexes:_selectedIndexSet];
        _selectedArr = [[NSMutableArray alloc] initWithArray:arr];
    }
    
    return _selectedArr;
}

#pragma mark -
#pragma mark Action method

- (IBAction)onBack:(UIButton *)sender {
    if([self.refreshBtn.title isEqualToString:@"停止"]) {
        [self onRefresh:self.refreshBtn];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTitleBtn:(UIButton *)sender {
    
    CGPoint center = [sender convertPoint:sender.center toView:self.navigationController.navigationBar];
    center.y = self.navigationController.navigationBar.bounds.size.height;
    [YBPopupMenu showAtPoint:center titles:self.titles icons:nil menuWidth:110 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.isShowShadow = YES;
        popupMenu.delegate = self;
        popupMenu.offset = 10;
        popupMenu.type = YBPopupMenuTypeDefault;
    }];
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


/**
 选择
 @param sender sender description
 */
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


/**
 确定提交
 @param sender sender description
 */
- (IBAction)onSureBtn:(UIButton *)sender {
    if (_selectedIndexSet.count == 0) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        
        CGFloat y = self.view.bounds.size.height - 64;
        style.cornerRadius = 3.0;
        [self.view makeToast:@"请选择设备" duration:1.5
                    position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x, y)] style:style];
        return;
    }
    
    NSString *title = [NSString stringWithFormat:@"确定要将【%@】所选的设备进行【%@】",[UserMgr shared].warehouseDic[@"storageName"],self.titles[self.type]];
    LCActionSheet *sheet = [LCActionSheet sheetWithTitle:title cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reqSaveData];
            });
        }
    } otherButtonTitles:@"确定", nil];
    [sheet show];
   
}


#pragma mark -
#pragma mark request method

- (void)reqSaveData {
    NSArray *urlPaths = @[@"user_storage_in",@"user_storage_out",@"user_storage_check"];
    NSString *url = [[URLTool shared] networkPath:urlPaths[self.type]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    
    params[@"storageId"] = [UserMgr shared].warehouseDic[@"storageId"];
    NSMutableArray *eids = [NSMutableArray array];
    for (BLEPeripheral *peripheral in self.selectedArr) {
        [eids addObject:[peripheral.peripheral.name substringFromIndex:2]];
    }
    params[@"eids"] = eids;
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在%@",self.titles[self.type]]];
    [[RequestTool shared] post:url params:params callback:^(ResModel *response) {
        [SVProgressHUD dismiss];
        if (response.code == 200) {
            [SVProgressHUD showSuccessWithStatus:@"操作成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self onBack:nil];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:response.message];
            
        }
    }];
    
}

#pragma mark -
#pragma mark UITableViewDataSource method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WarehouseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WarehouseCell"];

    BLEPeripheral *peripheral = _dataArr[indexPath.row];
    cell.checkBtn.selected = [_selectedIndexSet containsIndex:indexPath.row];
    [cell setValue:indexPath forKeyPath:@"indexPath"];
    [cell setValue:peripheral forKeyPath:@"peripheral"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //进入下一级页面暂停扫描
    if([self.refreshBtn.title isEqualToString:@"停止"]) {
        [self onRefresh:self.refreshBtn];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    TerminalDetailController *vc = [sb instantiateViewControllerWithIdentifier:@"TerminalDetailController"];
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
#pragma mark YBPopupMenuDelegate method
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    self.type = index;
    NSString *title  = [NSString stringWithFormat:@"%@▼",self.titles[index]];
    [self.titleBtn setTitle:title forState:(UIControlStateNormal)];
    [self.titleBtn setTitle:title forState:(UIControlStateHighlighted)];
    
    NSString *submitTitle = [NSString stringWithFormat:@"确定%@",self.titles[index]];
    [self.submitBtn setTitle:submitTitle forState:(UIControlStateNormal)];
    [self.submitBtn setTitle:submitTitle forState:(UIControlStateHighlighted)];
}




@end
