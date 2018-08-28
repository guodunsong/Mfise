//
//  HomeController.m
//  BluetoothPallet
//
//  Created by issuser on 2018/8/20.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "HomeController.h"
#import "BindWarehouseController.h"
#import "WarehouseController.h"

@interface HomeController ()
@property (weak, nonatomic) IBOutlet UILabel *nickLbl;


@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.nickLbl.text = [NSString stringWithFormat:@"欢迎你，%@",[UserMgr shared].userName];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}


/**
 初始化视图
 */
- (void)initView {
    
    //给首页菜单添加阴影
    for(int i=1000; i<1000 + 5; i++) {
        UIView *view = [self.view viewWithTag:i];
        view.layer.shadowOffset = CGSizeMake(3, 3);
        view.layer.shadowOpacity = 0.2;
    }
    
}


/**
 push到库存controller

 @param type type 仓库操作类型
 */
- (void)pushWarehouseController:(WarehouseType)type {
    NSDictionary *warehouseDic = [UserMgr shared].warehouseDic;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Warehouse" bundle:nil];
    WarehouseController *warehouseController = [sb instantiateViewControllerWithIdentifier:@"WarehouseController"];
    warehouseController.type = type;
    if (warehouseDic) { //判断是否绑定了仓库
        [self.navigationController pushViewController:warehouseController animated:YES];
        return;
    }
    
    //没绑定仓库则弹出绑定仓库
    sb = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    BindWarehouseController *vc = [sb instantiateViewControllerWithIdentifier:@"BindWarehouseController"];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    vc.dismissBlock = ^(){
        [self.navigationController pushViewController:warehouseController animated:YES];
    };
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark -
#pragma mark Action method

/**
 信号列表
 @param sender sender description
 */
- (IBAction)onSingnallist:(id)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SingnallistController"];
    [self.navigationController pushViewController:vc animated:YES];
}


/**
 入库登记
 @param sender sender description
 */
- (IBAction)onInWarehouse:(id)sender {
    [self pushWarehouseController:(WarehouseTypeIn)];
}


/**
 出库登记
 @param sender sender description
 */
- (IBAction)onOutWarehouse:(id)sender {
    [self pushWarehouseController:(WarehouseTypeOut)];
}


/**
 盘点
 @param sender sender description
 */
- (IBAction)onInventory:(id)sender {
   [self pushWarehouseController:(WarehouseTypeInventory)];
}


/**
 系统设置
 @param sender sender description
 */
- (IBAction)onSetting:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SettingController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
