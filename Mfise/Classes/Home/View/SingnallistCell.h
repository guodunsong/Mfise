//
//  SingnallistCell.h
//  Mfise
//
//  Created by issuser on 2018/8/26.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEPeripheral.h"

@interface SingnallistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, strong) BLEPeripheral *peripheral;

@end
