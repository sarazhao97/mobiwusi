//
//  MOTaskDetailVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "MOBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOTaskDetailVC : MOBaseViewController
@property(nonatomic,copy)void(^didChangedRecevingTaskStatuts)(BOOL isGiveUp);
- (instancetype)initWithTaskId:(NSInteger)taskId userTaskId:(NSInteger)userTaskId;
@end

NS_ASSUME_NONNULL_END
