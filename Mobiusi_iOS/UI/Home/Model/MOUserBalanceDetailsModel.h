//
//  MOUserBalanceDetailsModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MOUserBalanceCountDataModel;
@class MOUserBalanceListItemModel;
@interface MOUserBalanceDetailsModel : MOModel
@property(nonatomic,assign)NSInteger limit;
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)NSInteger page_total;
@property(nonatomic,assign)NSInteger total;
@property(nonatomic,strong)MOUserBalanceCountDataModel* count_data;
@property(nonatomic,strong)NSMutableArray<MOUserBalanceListItemModel *>* list;
@end

@interface MOUserBalanceCountDataModel : MOModel
@property(nonatomic,copy)NSString* sum_val;
@property(nonatomic,copy)NSString* withdrawal_num;
@property(nonatomic,copy)NSString* income_num;
@property(nonatomic,copy)NSString* withdrawal_val;
@property(nonatomic,copy)NSString* income_val;
@end

@interface MOUserBalanceListItemModel : MOModel
@property(nonatomic,copy)NSString* date_name;
@property(nonatomic,copy)NSString* val;
@property(nonatomic,copy)NSString* category_name;
@property(nonatomic,assign)NSInteger category;
@property(nonatomic,assign)NSInteger relate_id;
@end

NS_ASSUME_NONNULL_END
