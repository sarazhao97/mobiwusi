//
//  MOHomeProfitReminderVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeProfitReminderVC : MOBaseViewController
@property(nonatomic,copy)void(^didClickViewDetail)(void);

-(instancetype)initWithRevenueAmount:(NSString *)revenueAmount;
@end

NS_ASSUME_NONNULL_END
