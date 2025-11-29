//
//  MOUserBalanceDetailsModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOUserBalanceDetailsModel.h"

@implementation MOUserBalanceDetailsModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"list":[MOUserBalanceListItemModel class]
    };
}
@end

@implementation MOUserBalanceCountDataModel

@end

@implementation MOUserBalanceListItemModel

@end
