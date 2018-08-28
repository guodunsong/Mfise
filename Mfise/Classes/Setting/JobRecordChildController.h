//
//  JobRecordChildController.h
//  Mfise
//
//  Created by issuser on 2018/8/28.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JobRecordType) {
    JobRecordTypeIn = 0,    //入库
    JobRecordTypeOut,       //出库
    JobRecordTypeInventory  //盘点
};

@interface JobRecordChildController : UIViewController
@property (nonatomic, assign) JobRecordType type;


@end
