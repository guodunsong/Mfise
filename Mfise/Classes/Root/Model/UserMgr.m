//
//  UserMgr.m
//  Mfise
//
//  Created by issuser on 2018/8/23.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "UserMgr.h"
@interface UserMgr() {
    //这变量为了解决同时重写get set 方法
    NSDictionary *_warehouseDic;
}


@end

@implementation UserMgr

static UserMgr *instance = nil;

+ (instancetype)shared {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)saveDic:(NSDictionary *)dic {
    self.userId = [dic[@"userId"] integerValue];
    self.userName = dic[@"userName"];
    self.companyId = [dic[@"companyId"] integerValue];
    self.companyName = dic[@"companyName"];
    self.account = dic[@"mobile"];

    
    self.token = dic[@"token"];
}

- (void)setWarehouseDic:(NSDictionary *)warehouseDic {
    _warehouseDic = warehouseDic;
    [[NSUserDefaults standardUserDefaults] setObject:warehouseDic forKey:kWarehouse];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)warehouseDic {
    if (_warehouseDic) {
        return _warehouseDic;
    }

    return [[NSUserDefaults standardUserDefaults] objectForKey:kWarehouse];;
}

@end
