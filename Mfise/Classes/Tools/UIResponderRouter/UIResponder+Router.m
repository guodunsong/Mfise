//
//  UIResponder+Router.m
//  ResponderChainDemo
//
//  Created by issuser on 2018/1/16.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import "UIResponder+Router.h"


@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}


@end
