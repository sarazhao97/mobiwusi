//
//  AppToken.m
//  AppToken
//
//  Created by x11 on 2023/6/21.
//  Copyright © 2023年 yyy. All rights reserved.
//

#import "AppToken.h"
#import "NSString+MD5.h"

@implementation AppToken

+ (AppToken *)sharedToken {
    static dispatch_once_t pred;
    __strong static AppToken * sharedToken = nil;
    dispatch_once( &pred, ^{
        sharedToken = [[self alloc] init];
    });
    return sharedToken;
}

/*
 通用方法
 */
+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

+ (NSString *)getSystemVersion {
    NSString *version = [UIDevice currentDevice].systemVersion;
    DLog(@"sys version - %@", version);
    return version;
}

@end
