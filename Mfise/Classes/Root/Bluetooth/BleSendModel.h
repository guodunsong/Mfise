//
//  BleSendModel.h
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

#define kNotificationUUID @"35E2"   //订阅通知特征
#define kWriteUUID  @"35E1"         //写入特征

#define kBleWakeCode   @"D"    //蓝牙唤醒码
#define kBleDataCode   @"E"    //蓝牙透传（数据）码

#define kWakeOk     @"DWAKEUPBLE=OK"   //唤醒成功
#define kWakeNOk    @"DWAKEUPBLE=NOK"  //唤醒失败
#define kWakeUpCmd  @"DWAKEUPBLE"      //唤醒命令



@interface BleSendModel : NSObject

@property (nonatomic, assign) NSInteger pkgCount;
@property (nonatomic, assign) NSInteger pkgIndex;
@property (nonatomic, assign) NSInteger cmdIndex;

- (instancetype)initWithDic: (NSDictionary *)dic;
- (NSMutableData *)dataForPkgIndex:(NSInteger)index;

@end
