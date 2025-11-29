//
//  MOModel.h
//  YuYun
//
//  Created by x11 on 2023/4/21.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOModel : NSObject <NSCoding>

// model类型归档到NSUserDefaults
- (void)archivedModelWithKey:(NSString *)key;

// model类型从NSUserDefaults中解档
+ (MOModel *)unarchiveModelWithKey:(NSString *)key;

// 从NSUserDefaults中移除model
+ (void)removeModelWithKey:(NSString *)key;

@end
