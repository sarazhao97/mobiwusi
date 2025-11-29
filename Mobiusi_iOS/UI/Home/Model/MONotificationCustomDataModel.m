//
//  MONotificationCustomDataModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/7.
//

#import "MONotificationCustomDataModel.h"


@implementation MONotificationUserInfoModel
@end

@implementation MONotificationAPSModel
@end

@implementation MONotificationAlertModel
@end

@implementation MONotificationBodyModel
@end

@implementation MONotificationCustomDataModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}
@end
