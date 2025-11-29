//
//  MOModel.m
//  YuYun
//
//  Created by x11 on 2023/4/21.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import "MOModel.h"
#import <objc/runtime.h>

@implementation MOModel
//解档
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        unsigned int count = 0;
        //获取类中所有成员变量名
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i = 0; i<count; i++) {
            Ivar iva = ivar[i];
            const char *name = ivar_getName(iva);
            NSString *strName = [NSString stringWithUTF8String:name];
            //进行解档取值
            id value = [decoder decodeObjectForKey:strName];
            if (value) {
                //利用KVC对属性赋值
                [self setValue:value forKey:strName];
            }
        }
        free(ivar);
    }
    return self;
}

//归档
- (void)encodeWithCoder:(NSCoder *)encoder {
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i=0; i<count; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        //利用KVC取值
        id value = [self valueForKey:strName];
        [encoder encodeObject:value forKey:strName];
    }
    free(ivar);
}

- (void)archivedModelWithKey:(NSString *)key {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (MOModel *)unarchiveModelWithKey:(NSString *)key {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (data!=nil) {
        MOModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return model;
    }else{
        return nil;
    }
}

// 从NSUserDefaults中移除model
+ (void)removeModelWithKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
