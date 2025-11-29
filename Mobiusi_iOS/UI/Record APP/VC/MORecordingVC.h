//
//  MORecordingVC.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/15.
//

#import "MOBaseViewController.h"
#import "MOTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MORecordingVC : MOBaseViewController

@property (nonatomic, strong) MOTaskListModel *taskListModel;

@property (nonatomic, assign) NSInteger task_status;
@property(nonatomic,copy)void(^taskStatusChangeed)(NSInteger taskStatus);
@end

NS_ASSUME_NONNULL_END
