//
//  MOUserModel.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOUserModel.h"

static NSString * const userModelKey = @"mo_user_model_key";

@implementation MOUserModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"modelId" : @"id"};
}

+ (MOUserModel *)unarchiveUserModel {
    MOUserModel *userMode = (MOUserModel *)[MOUserModel unarchiveModelWithKey:userModelKey];
    return userMode;
}

- (void)archivedUserModel {
    [self archivedModelWithKey:userModelKey];
}

+ (void)removeUserModel {
    [MOUserModel removeModelWithKey:userModelKey];
}

// 获取当前用户的 token
+ (NSString *)getCurrentUserToken {
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    return user.token;
}

// 验证 token 是否有效
+ (BOOL)isTokenValid {
    NSString *token = [MOUserModel getCurrentUserToken];
    return token && token.length > 0;
}

@end
