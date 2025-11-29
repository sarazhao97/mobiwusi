//
//  MOUserBalanceCenterModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOUserBalanceCenterModel : MOModel
//今日收入
@property(nonatomic,copy)NSString *today_income;
//总提现
@property(nonatomic,copy)NSString *withdrawal_val;
//昨日收入
@property(nonatomic,copy)NSString *yesterday_income;
//月收入
@property(nonatomic,copy)NSString *month_income;
//总收入
@property(nonatomic,copy)NSString *income_val;
//余额
@property(nonatomic,copy)NSString *account_balance;
@end

NS_ASSUME_NONNULL_END
