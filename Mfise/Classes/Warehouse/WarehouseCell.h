//
//  SingnallistCell.h
//  Mfise
//
//  Created by issuser on 2018/8/26.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEPeripheral.h"

@interface WarehouseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, strong) BLEPeripheral *peripheral;

@end
