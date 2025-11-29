//
//  MOTaskQuestionModel.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/2/24.
//

#import "MOTaskQuestionModel.h"

@implementation MOTaskQuestionModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"file_data":[MOTaskQuestionDataModel class],
        @"audio_data":[MOTaskQuestionDataModel class],
        @"video_data":[MOTaskQuestionDataModel class],
        @"picture_data":[MOTaskQuestionDataModel class],
		@"property":[MOTaskQuestionModelProperty class]
    };
}
@end

@implementation MOTaskQuestionDataModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
	return @{
		@"property":[MOTaskQuestionModelProperty class]
	};
}
@end

@implementation MOTaskQuestionModelProperty

@end
