//
//  GDSRequest.m
//  GDSUtils
//
//  Created by admin on 15/11/15.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "RequestTool.h"

@interface RequestTool()
@property (nonatomic, strong)AFHTTPSessionManager *manager;

@end

@implementation RequestTool

+ (RequestTool *)shared{
    static RequestTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)post:(NSString*)url params:(id)params callback:(void (^)(ResModel *response))callback {
    NSLog(@"url     >> %@",url);
    NSLog(@"params  >> %@",params);
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDictionary *resultDic = responseObject;
        NSLog(@"result  >> %@", [resultDic description]);
        if (callback) {
            ResModel *response = [ResModel mj_objectWithKeyValues:responseObject];
            callback(response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"error:%@",error);
        ResModel *response = [ResModel new];
        response.code = 0;
        response.message = @"请求数据失败";
        if (callback) {
            callback(response);
        }
    }];
}

- (void)get:(NSString*)url params:(id)params callback:(void (^)(ResModel *response))callback {
    NSLog(@"url     >> %@",url);
    NSLog(@"params  >> %@",params);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDictionary *resultDic = responseObject;
        NSLog(@"result  >> %@", [resultDic description]);
        if (callback) {
            ResModel *response = [ResModel mj_objectWithKeyValues:responseObject];
            callback(response);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"error:%@",error);
        ResModel *response = [ResModel new];
        response.code = 0;
        response.message = @"请求数据失败";
        if (callback) {
            callback(response);
        }
        
    }];
    
}

- (NSString*)getUTF8String:(NSString*)string {
    return  [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html", nil];
    }
    
    //设置token
    if ([UserMgr shared].token.length > 0) {
        [_manager.requestSerializer setValue:[UserMgr shared].token forHTTPHeaderField:@"access-token"];
    }
    
    return _manager;
}




@end
