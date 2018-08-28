//
//  TerminalDetailController.h
//  Mfise
//
//  Created by issuser on 2018/8/21.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BaseTableController.h"
#import "BLEPeripheral.h"

@interface TerminalDetailController : BaseTableController
@property (nonatomic, strong) BLEPeripheral *peripheral;

@end
