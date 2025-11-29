//
//  MOCateOptionModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MOCateOptionModel.h"

@implementation MOCateOptionModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"audio_cate":[MOCateOptionItem class],
        @"cert_type":[MOCateOptionItem class],
        @"complaint_type":[MOCateOptionItem class],
        @"feedback_type":[MOCateOptionItem class],
        @"image_cate":[MOCateOptionItem class],
        @"task_type":[MOCateOptionItem class],
        @"text_cate":[MOCateOptionItem class],
        @"user_file_type":[MOCateOptionItem class],
        @"video_cate":[MOCateOptionItem class],
        @"withdrawal_money":[MOCateOptionItem class],
        @"work_type":[MOCateOptionItem class],
        @"work_income":[MOCateOptionItem class],
    };
}
@end


@implementation MOCateOptionItem
@end
