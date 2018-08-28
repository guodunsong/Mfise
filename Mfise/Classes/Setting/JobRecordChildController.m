//
//  JobRecordChildController.m
//  Mfise
//
//  Created by issuser on 2018/8/28.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "JobRecordChildController.h"
#import "WSDatePickerView.h"
#import "JobRecordCell.h"

@interface JobRecordChildController ()<UITableViewDelegate,UITableViewDataSource> {
    
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *startDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *endDateLbl;

@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSString *curDateStr;

@end

@implementation JobRecordChildController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    _startDateLbl.text = [NSString stringWithFormat:@"%@-01-01",@(components.year)];
    self.endDateLbl.text = self.curDateStr;
    
    _dataArr = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onStartDate:(id)sender {
    
    WSDatePickerView *datePicker = [[WSDatePickerView alloc] initWithDateStyle:(DateStyleShowYearMonthDay) CompleteBlock:^(NSDate *date) {
        NSString *dateStr = [date stringWithFormat:@"yyyy-MM-dd"];
        self.startDateLbl.text = dateStr;
    }];
    
    datePicker.doneButtonColor =  RGBHex(0x1B97D2);
    datePicker.maxLimitDate = [NSDate date];
    [datePicker show];
}

- (IBAction)onEndDate:(id)sender {
    WSDatePickerView *datePicker = [[WSDatePickerView alloc] initWithDateStyle:(DateStyleShowYearMonthDay) CompleteBlock:^(NSDate *date) {
        NSString *dateStr = [date stringWithFormat:@"yyyy-MM-dd"];
        self.endDateLbl.text = dateStr;
    }];
    
    datePicker.doneButtonColor =  RGBHex(0x1B97D2);
    datePicker.maxLimitDate = [NSDate date];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    NSDate *minDate = [format dateFromString:_startDateLbl.text];
    datePicker.minLimitDate = minDate;
    
    [datePicker show];
}


- (IBAction)onSearch:(id)sender {
    [self reqData];
}

#pragma mark -
#pragma mark request method
- (void)reqData {
    
    NSString *url = [[URLTool shared] networkPath:@"user_storage_query"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"startTime"] = self.startDateLbl.text;
    params[@"endTime"] = self.endDateLbl.text;
    params[@"operType"] = @(self.type);
    
    [SVProgressHUD showWithStatus:@"正在请求数据"];
    [[RequestTool shared] get:url params:params callback:^(ResModel *response) {
        [SVProgressHUD dismiss];
        
        if (response.code == 200) {
            NSDictionary *resDic = response.data;
            NSArray *arr = resDic[@"list"];
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            
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
    JobRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobRecordCell"];
    cell.rowDic = self.dataArr[indexPath.row];
    return cell;
}

- (NSString *)curDateStr {
    if (_curDateStr == nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _curDateStr = [formatter stringFromDate:[NSDate date]];
    }
    
    return _curDateStr;
}

@end
