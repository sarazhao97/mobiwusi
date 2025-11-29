//
//  AppToken.h
//  AppToken
//
//  Created by x11 on 2023/6/21.
//  Copyright © 2023年 yyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppToken : NSObject

+ (AppToken *)sharedToken;

+ (NSString *)getAppVersion;

+ (NSString *)getSystemVersion;

@end
