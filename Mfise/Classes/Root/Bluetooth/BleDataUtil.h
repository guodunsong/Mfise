//
//  BleDataUtil.h
//  PalletBluetoothDemo
//
//  Created by issuser on 2018/7/31.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BleDataUtil : NSObject

/**
 指令转NSData
 
 @param hexString hex字符串
 @return NSData
 */
+ (NSData *)hex2Data:(NSString *) hexString;


/**
 字节数组转Hex字符串
 
 @param bytes 字节数组
 @param len 数组长度
 @return hex字符串
 */
+ (NSString *)byte2Hex:(int8_t *) bytes length:(NSUInteger)len;


/**
 data 转hex字符串
 
 @param data data
 @return hex字符串
 */
+ (NSString *)data2Hex:(NSData *)data;

/**
 时间戳转毫秒
 
 @param date 日期时间
 @return 毫秒
 */
+ (long long)dateTime2MilliSeconds:(NSDate *)date;


/**
 byte转字符串
 
 @param byte 字节数组
 @param st st description
 @param end end description
 @return (String)
 */
+ (NSString *)byte2Unicode:(int8_t *)byte st:(int)st end:(int)end ;

/**
 去掉前后空格
 @param str 字符串
 @return (NSString)
 */
+ (NSString *)trim:(NSString *)str;


@end
