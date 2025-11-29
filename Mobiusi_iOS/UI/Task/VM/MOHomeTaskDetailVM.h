//
//  MOHomeTaskDetailVM.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/19.
//

#import "MOViewModel.h"
#import "MOTaskDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeTaskDetailVM : MOViewModel

@property (nonatomic, assign) NSInteger task_id;

@property (nonatomic, strong) MOTaskDetailModel *detailModel;

/// 任务详情
/// - Parameters:
///   - task_id: 任务ID
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getTaskDetailWithTaskId:(NSInteger)task_id
                   user_task_id:(NSInteger)user_task_id
                        success:(MOObjectBlock)success
                        failure:(MOErrorBlock)failure msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;

@end

NS_ASSUME_NONNULL_END
