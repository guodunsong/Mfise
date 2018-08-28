//
//  BindWarehouseController.h
//  Mfise
//
//  Created by issuser on 2018/8/22.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BaseController.h"



typedef void(^DismissBlock)(void);
@interface BindWarehouseController : BaseController

@property (nonatomic, copy) DismissBlock dismissBlock;

@end
