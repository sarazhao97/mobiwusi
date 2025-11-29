//
//  MOWithdrawalRecordModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOWithdrawalRecordModel.h"

@implementation MOWithdrawalRecordModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"list":[MOWithdrawalRecordItemModel class]
    };
}
@end

@implementation MOWithdrawalRecordItemModel
@end
