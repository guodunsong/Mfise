//
//  JobRecordCell.m
//  Mfise
//
//  Created by issuser on 2018/8/28.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "JobRecordCell.h"
@interface JobRecordCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *operatorLbl;
@property (weak, nonatomic) IBOutlet UILabel *storageLbl;
@property (weak, nonatomic) IBOutlet UILabel *operateTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;

@end


@implementation JobRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)setRowDic:(NSDictionary *)rowDic {
    _rowDic = rowDic;
    
    NSTimeInterval interval  = [rowDic[@"createTime"] doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _timeLbl.text = [formatter stringFromDate: date];
//    _operatorLbl.text =

    _storageLbl.text = [NSString stringWithFormat:@"仓库:%@",rowDic[@"storageName"]];
    NSArray *arr = @[@"入库",@"出库",@"盘点"];
    NSString *type = arr[[rowDic[@"changeType"] integerValue]];
    _operateTypeLbl.text = [NSString stringWithFormat:@"类型:%@",type];
    _countLbl.text = [NSString stringWithFormat:@"数量:%@",rowDic[@"quantity"]];
    
}



@end
