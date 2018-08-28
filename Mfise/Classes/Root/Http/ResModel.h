//
//  CMResponse.h
//  CMBusiness
//
//  Created by guodunsong on 2017/6/14.
//  Copyright © 2017年 guodunsong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResModel : NSObject

@property(nonatomic, assign) NSInteger code;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, assign) id data;

@end
