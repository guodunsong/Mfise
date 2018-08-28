//
//  GDSRequest.h
//  GDSUtils
//
//  Created by admin on 15/11/15.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ResModel.h"

@interface RequestTool : NSObject

/**
 单例
 @return CMRequest
 */
+ (RequestTool *)shared;


/**
 get数据请求

 @param url url description
 @param params params description
 @param callback callback description
 */
- (void)get:(NSString*)url params:(id)params callback:(void (^)(ResModel *response))callback;

/**
 post数据请求
 
 @param url url description
 @param params params description
 @param callback callback description
 */
- (void)post:(NSString*)url params:(id)params callback:(void (^)(ResModel *response))callback;

-(NSString*)getUTF8String:(NSString*)string;



@end
