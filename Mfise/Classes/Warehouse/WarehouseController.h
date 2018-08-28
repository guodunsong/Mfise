//
//  WarehouseController.h
//  Mfise
//
//  Created by issuser on 2018/8/23.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BaseController.h"

typedef NS_ENUM(NSInteger, WarehouseType) {
    WarehouseTypeIn = 0,    //入库
    WarehouseTypeOut,       //出库
    WarehouseTypeInventory  //盘点
};

@interface WarehouseController : BaseController
@property(nonatomic, assign) WarehouseType type;

@end
