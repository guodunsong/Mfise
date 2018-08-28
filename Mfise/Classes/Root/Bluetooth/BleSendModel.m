//
//  BleSendModel.m
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BleSendModel.h"
#import "BleDataUtil.h"

static const NSInteger kPkgSize = 17;
static NSInteger kCmdIndex = 0;

@interface BleSendModel()
@property (nonatomic, strong) NSDictionary *jsonDic;
@property (nonatomic, strong) NSString *jsonStr;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSMutableArray *pkgDataArr;



@end

@implementation BleSendModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.jsonDic = dic;
        self.pkgIndex = 1;
        self.cmdIndex = kCmdIndex;
        kCmdIndex = kCmdIndex + 1;
        if (kCmdIndex > 3) {
            kCmdIndex = 0;
        }
        
        self.pkgDataArr = [NSMutableArray array];
        NSData *jsonData = [self.jsonStr dataUsingEncoding:(NSUTF8StringEncoding)];
        int8_t *jsonByte = malloc(jsonData.length);
        [jsonData getBytes:jsonByte range:NSMakeRange(0, jsonData.length)];
        
        //计算校验位
        long sum = 0;
        int len = 2;
        int8_t *checkbitByte = malloc(len);
        for (int i = 0; i < jsonData.length; i++) {
            long num = jsonByte[i] >= 0? jsonByte[i] : jsonByte[i] + 256;
            sum += num;
        }
        
        for (int i=0; i<len; i++) {
            checkbitByte[len - i - 1] = sum >> (i * 8) & 0xff;
        }
        
        self.jsonData = [[NSMutableData alloc] initWithData:jsonData];
        [self.jsonData appendBytes:checkbitByte length:2];
        NSLog(@">>>>data:%@",[BleDataUtil data2Hex:jsonData]);
        NSLog(@">>>>data:%@",[BleDataUtil data2Hex:self.jsonData]);
        
        //分包放入数组
        for (int i=0; i<self.pkgCount; i++) {
            NSInteger len = kPkgSize;
            if (i == (self.pkgCount - 1)) {
                len = self.jsonData.length - i * kPkgSize;
            }
            
            int8_t *partByte = malloc(len);
            [self.jsonData getBytes:partByte range:NSMakeRange(i * kPkgSize,len)];
            NSLog(@">>>>>partData:%@",[[NSData alloc] initWithBytes:partByte length:len]);
            [self.pkgDataArr addObject:[[NSData alloc] initWithBytes:partByte length:len]];
        }
    }
    
    return self;
}

- (NSString *)jsonStr {
    if (_jsonDic == nil) {
        return @"";
    }
    
    return [_jsonDic mj_JSONString];
}

- (NSInteger)pkgCount {
    return ceil(self.jsonData.length / (float)kPkgSize);
}

- (NSMutableData *)dataForPkgIndex: (NSInteger)index {
    self.pkgIndex = index;
    
    int8_t *pkgCmdByte = malloc(1);
    int8_t *pkgCountByte = malloc(1);
    
    //注意命令序号是高六位，所以需要乘2的6次方(64)
    pkgCmdByte[0] = self.cmdIndex * 64 + self.pkgIndex;
    pkgCountByte[0] = self.pkgCount;
    NSData *partData = self.pkgDataArr[index - 1];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[kBleDataCode dataUsingEncoding:NSUTF8StringEncoding]]; //功能代码
    [data appendBytes:pkgCmdByte length:1]; //命令序号和包序号
    [data appendBytes:pkgCountByte length:1];//包数量
    [data appendData:partData];//分包内容
    
    return data;
}

@end
