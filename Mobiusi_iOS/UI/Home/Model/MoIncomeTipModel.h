//
//  MoIncomeTipModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOIncomeTipModel : MOModel
@property(nonatomic,copy)NSString *income_val_unread;
@property(nonatomic,assign)NSInteger income_count_unread;
@property(nonatomic,copy)NSString * income_val;
@property(nonatomic,assign)NSInteger income_count;
@end

NS_ASSUME_NONNULL_END
