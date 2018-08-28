//
//  CMURLUtils.m
//  CMBusiness
//
//  Created by guodunsong on 2017/6/14.
//  Copyright © 2017年 guodunsong. All rights reserved.
//

#import "URLTool.h"

@implementation URLTool
static URLTool *instance = nil;
+ (URLTool *)shared{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)networkPath:(NSString *)shortName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    if (!filePath) {
        NSLog(@"未找到文件路径.");
        return @"";
    }
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *hostName = [content objectForKey:@"host"];
    if ([shortName isEqualToString:@"host"]) {
        return hostName;
    }
    NSString *relativePath = [[content objectForKey:shortName] objectForKey:@"path"];
    NSString *path = [NSString stringWithFormat:@"%@%@", hostName, relativePath];
    return path;
}

- (NSString *)hostPath:(NSString *)shortName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    if (!filePath) {
        NSLog(@"未找到文件路径.");
        return @"";
    }
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *hostName = [content objectForKey: shortName];
    return hostName;
}

- (NSString *)fileNameFromURLString:(NSString *)urlString {
    if (urlString.length > 0) {
        NSArray *arr = [urlString componentsSeparatedByString:@"/"];
        if (arr.count > 0) {
            return [arr lastObject];
        }
    }
    return @"";
}

@end
