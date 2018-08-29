//
//  BleReceiveModel.m
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BleReceiveModel.h"
#import "BleDataUtil.h"

@interface BleReceiveModel()

@end

@implementation BleReceiveModel

- (instancetype)init {
    if (self = [super init]) {
        self.dataArr = [NSMutableArray array];
        [self.dataArr removeAllObjects];
    }
    return self;
}

- (NSMutableData *)appendPartData:(NSData *)data {
    
    NSMutableData *anserData = [[NSMutableData alloc] init];
    int8_t *paramByte = malloc(3);
    [data getBytes:paramByte range:NSMakeRange(0, 3)];
    
    NSInteger len = data.length - 3;
    int8_t *partByte = malloc(len);
    [data getBytes:partByte range:NSMakeRange(3, len)];
    
    NSData *partData = [[NSData alloc] initWithBytes:partByte length:len];
    
    NSLog(@">>>>>总包数量:%@,分包序号:%@",@(paramByte[2]),@(paramByte[1] & 0x3F));
    //去掉重复包
    if ([self.dataArr containsObject:partData]) {
        NSLog(@">>>>>>>>>去掉重复包");
        return nil;
    }
    
    
    [_dataArr addObject: partData];
    int pkgCount = paramByte[2];        //包总数
    int pkgIndex = paramByte[1] & 0x3F; //分包序号获取低六位
    paramByte[2] = paramByte[2] + 0x40; //应答包高六位修改为1
    int unreceiveCount = pkgCount - pkgIndex;
    int8_t *unreceiveByte = malloc(1);
    unreceiveByte[0] = unreceiveCount;
    NSData *unreceivePkgData = [self unreceivePkg:pkgIndex pkgCount:pkgCount];
    
    [anserData appendBytes:paramByte length:3];
    [anserData appendBytes:unreceiveByte length:1];
    [anserData appendData: unreceivePkgData];
    
    return anserData;
}

//未接受的的数据包
- (NSData *)unreceivePkg:(int)pkgIndex pkgCount:(int)pkgCount {
    int len = pkgCount - pkgIndex > 4? 4: pkgCount - pkgIndex;
    int8_t *byte = malloc(len);
    
    //缺失包每次最大数是4
    for (int i=pkgIndex + 1; i<= pkgCount && i<= pkgIndex + 5; i++) {
        int index = i - (pkgIndex + 1);
        byte[index] = i;
    }
    
    return [[NSData alloc] initWithBytes:byte length:len];
}

//结果字符串
- (NSString *)result {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i=0; i< self.dataArr.count; i++) {
//        NSLog(@"########:%@",[BleDataUtil data2Hex:self.dataArr[i]]);
        [data appendData:self.dataArr[i]];
    }
    
    NSInteger len = data.length - 2;
    int8_t *checkbitByte = malloc(2);
    int8_t *dataByte = malloc(len);
    
    [data getBytes:dataByte range:NSMakeRange(0, len)];
    [data getBytes:checkbitByte range:NSMakeRange(len, 2)];
    NSString *str = [[NSString alloc] initWithBytes:dataByte length:len encoding:NSUTF8StringEncoding];
    
    return str;
}



@end


