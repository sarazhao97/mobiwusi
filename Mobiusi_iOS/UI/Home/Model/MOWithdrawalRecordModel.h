//
//  MOWithdrawalRecordModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MOWithdrawalRecordItemModel;
@interface MOWithdrawalRecordModel : MOModel
@property(nonatomic,assign)NSInteger limit;
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)NSInteger page_total;
@property(nonatomic,assign)NSInteger total;
@property(nonatomic,strong)NSMutableArray<MOWithdrawalRecordItemModel *> *list;
@end

@interface MOWithdrawalRecordItemModel : MOModel
@property(nonatomic,copy)NSString *date_name;
@property(nonatomic,copy)NSString *money;
@property(nonatomic,copy)NSString *status_name;
//提现状态：0审核中 1打款中 2已打款 3审核失败 4打款失败
@property(nonatomic,assign)NSInteger status;
@end

NS_ASSUME_NONNULL_END
