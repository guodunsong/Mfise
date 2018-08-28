//
//  UserMgr.h
//  Mfise
//
//  Created by issuser on 2018/8/23.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWarehouse  @"warehouseDic"

@interface UserMgr : NSObject

@property(nonatomic, strong) NSString *account;
@property(nonatomic, assign) NSInteger userId;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, assign) NSInteger companyId;
@property(nonatomic, strong) NSString *companyName;

@property(nonatomic, strong) NSDictionary *warehouseDic;

@property(nonatomic, strong) NSString *token;

+ (instancetype)shared;
- (void)saveDic:(NSDictionary *)dic;


@end
