//
//  CMURLUtils.h
//  CMBusiness
//
//  Created by guodunsong on 2017/6/14.
//  Copyright © 2017年 guodunsong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLTool : NSObject

/**
 单例
 @return CMRequest
 */
+ (URLTool *)shared;

/**
 获取网络地址路径
 
 @param shortName 写入urls.plist(root/res/urls.plist)中的参数
 @return return 网络地址路径
 */
- (NSString *)networkPath:(NSString *)shortName;
- (NSString *)hostPath:(NSString *)shortName;

//从url获取后面的文件名称
- (NSString *)fileNameFromURLString:(NSString *)urlString;


@end
