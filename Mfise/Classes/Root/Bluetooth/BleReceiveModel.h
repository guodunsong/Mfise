//
//  BleReceiveModel.h
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BleReceiveModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataArr;
- (NSMutableData *)appendPartData:(NSData *)data;
- (NSString *)result;


@end
