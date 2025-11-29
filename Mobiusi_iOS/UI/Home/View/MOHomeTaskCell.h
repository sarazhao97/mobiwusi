//
//  MOHomeTaskCell.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/29.
//

#import "MOTableViewCell.h"
#import "MOTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeTaskCell : MOTableViewCell
// 首页任务列表
- (void)configHomeCellWithModel:(MOTaskListModel *)model;
// 我的/关注任务列表
- (void)configMyTaskCellWithModel:(MOTaskListModel *)model;

@end

NS_ASSUME_NONNULL_END
