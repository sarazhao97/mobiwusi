//
//  MOUserTaskDataModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/27.
//

#import "MOUserTaskDataModel.h"

@implementation MOUserTaskDataModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"result":[MOUserTaskDataResultModel class],
        @"annotationInfo":[MOUserTaskDataAnnotationInfoModel class],
    };
}

@end

@implementation MOUserTaskDataResultModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
	return @{@"model_id" : @"id"};
}
@end

@implementation MOUserTaskDataAnnotationInfoModel
@end
