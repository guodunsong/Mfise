//
//  BleDataUtil.m
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "BleDataUtil.h"

@implementation BleDataUtil

+ (NSData *)hex2Data:(NSString *) hexString{
    
    NSArray *arr = [hexString componentsSeparatedByString:@" "];
    NSMutableData *data = [[NSMutableData alloc]initWithCapacity:0];
    for (NSString *str in arr) {
        NSString *temp = [NSString stringWithFormat:@"0x%@",str];
        int8_t byte = strtoul([temp UTF8String],0,16);
        [data appendBytes:&byte length:sizeof(byte)];
    }
    
    return data;
}

+ (NSString *)byte2Hex:(int8_t *) bytes length:(NSUInteger)len{
    NSString *hexString = @"";
    for (int i = 0; i < len; i++) {
        NSString *newHexString = [NSString stringWithFormat:@"%x",bytes[i]&0xff];//16进制数
        if ([newHexString length] == 1){
            hexString = [NSString stringWithFormat:@"%@0%@ ",hexString,newHexString];
        }else {
            hexString = [NSString stringWithFormat:@"%@%@ ",hexString,newHexString];
        }
    }
    hexString = [hexString uppercaseString];
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return hexString;
}

+ (NSString *)data2Hex:(NSData *)data {
    int8_t *bytes = malloc(data.length);
    memcpy(bytes, [data bytes], data.length);
    return [BleDataUtil byte2Hex:bytes length:data.length];
}

+ (long long)dateTime2MilliSeconds:(NSDate *)date{
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}

+ (NSString *)byte2Unicode:(int8_t *)byte st:(int)st end:(int)end {
    int len = end - st;
    int8_t *temp = malloc(len);
    for (int i = 0; i<len; i++) {
        temp[i] = byte[st + i];
    }
    NSData *data = [[NSData alloc] initWithBytes:temp length:(len)];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    return str;
}

+ (NSString *)trim:(NSString *)str {
    NSCharacterSet *characterset = [NSCharacterSet whitespaceCharacterSet];
    return [str stringByTrimmingCharactersInSet: characterset];
}



@end
