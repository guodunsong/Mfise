//
//  CMResponse.m
//  CMBusiness
//
//  Created by guodunsong on 2017/6/14.
//  Copyright © 2017年 guodunsong. All rights reserved.
//

#import "ResModel.h"

@implementation ResModel

+(NSDictionary *)replacedKeyFromPropertyName {
    return @{@"desc" : @"description",@"_id" : @"id"};
    
}

@end
