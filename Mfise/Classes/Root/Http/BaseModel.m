//
//  CMBaseModel.m
//  CMSmartAudio
//
//  Created by issuser on 2017/8/18.
//  Copyright © 2017年 guodunsong. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"_id" : @"id",@"desc":@"description"};
}

@end
