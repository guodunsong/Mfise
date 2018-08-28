//
//  SingnallistCell.m
//  Mfise
//
//  Created by issuser on 2018/8/26.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "SingnallistCell.h"

@interface SingnallistCell()

@property (weak, nonatomic) IBOutlet UIView *wrapView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *rssiLbl;


@end

@implementation SingnallistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    _wrapView.layer.shadowOffset = CGSizeMake(3, 3);
//    _wrapView.layer.shadowOpacity = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPeripheral:(BLEPeripheral *)peripheral {
    _peripheral = peripheral;
    _titleLbl.text = peripheral.peripheral.name;
    _rssiLbl.text = [NSString stringWithFormat:@"%@",@(peripheral.rssi)];
}

/**
 选择事件

 @param sender sender description
 */
- (IBAction)onCheckBtn:(UIButton *)sender {
    [self routerEventWithName:@"onCheckBtn" userInfo:@{@"indexPath": _indexPath}];
}

@end
