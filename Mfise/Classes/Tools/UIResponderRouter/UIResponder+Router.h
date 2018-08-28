//
//  UIResponder+Router.h
//  ResponderChainDemo
//
//  Created by issuser on 2018/1/16.
//  Copyright © 2018年 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
