//
//  BlePalletManager.h
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/8/7.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEManager.h"
#import "BLEPeripheral.h"
#import "BleSendModel.h"
#import "BleReceiveModel.h"


@class BlePalletManager;
@protocol BlePalletManagerDelegate<NSObject>
- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didResult:(NSString *)result;
- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didWithError:(NSString *)error;
- (void)blePalletManager:(BlePalletManager *)blePalletManager tag:(NSInteger)tag didConnectComplete: (NSNumber *)success error:(NSError *)error;

@end

@interface BlePalletManager : NSObject
@property (nonatomic, strong) BleSendModel *sendModel;      //蓝牙发送model
@property (nonatomic, strong) BleReceiveModel *receiveModel;//蓝牙接收数据model
@property(nonatomic, weak) id<BlePalletManagerDelegate> delegate;


/**
 初始化方法

 @return return value description
 */
- (instancetype)initWithDelegate:delegate;
- (void)connectBleDevice:(BLEPeripheral *)peripheral tag:(NSInteger)tag;
- (void)disconnect;


/**
 获取数据

 @param tag tag description
 @param params params description
 */
- (void)fetchWithTag:(NSInteger)tag params:(NSDictionary *)params;


/**
 睡眠蓝牙
 */
- (void)sleepBle:(NSString *)iccid;

@end
