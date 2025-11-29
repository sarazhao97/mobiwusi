//
//  MOSearchResultModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOSearchResultModel.h"

@implementation MOSearchResultModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"audio_list":[MOSearchResultCateModel class],
        @"image_list":[MOSearchResultCateModel class],
        @"text_list":[MOSearchResultCateModel class],
        @"video_list":[MOSearchResultCateModel class],
    };
}

@end


@implementation MOSearchResultCateModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}
@end

@implementation MOSearchResultSetcionModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"setcionDataList":[MOSearchResultCateModel class],
    };
}
@end
