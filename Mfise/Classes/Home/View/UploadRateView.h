//
//  ShareView.h
//  TYAlertControllerDemo
//
//  Created by tanyang on 15/10/26.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+TYAlertView.h"

typedef void(^CompleteCallback) (NSString *str);
@interface UploadRateView : UIView
@property(nonatomic, copy) CompleteCallback complete;

@end
