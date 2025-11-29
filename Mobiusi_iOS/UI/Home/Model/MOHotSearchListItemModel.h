//
//  MOHotSearchListItemModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/14.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHotSearchListItemModel : MOModel
@property(nonatomic,copy)NSString *title;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,assign)NSInteger click_num;
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,assign)BOOL is_follow;
@property(nonatomic,assign)BOOL is_try;
@property(nonatomic,assign)BOOL try_status;
@property(nonatomic,copy)NSString *task_no;
@end

NS_ASSUME_NONNULL_END
