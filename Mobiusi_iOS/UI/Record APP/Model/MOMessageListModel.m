//
//  MOMessageListModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOMessageListModel.h"

@implementation MOMessageListModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"list":[MOMessageListItemModel class],
    };
}
@end

@implementation MOMessageListItemModel

@end


@implementation MOSummarizeMessageItemModel

@end
