//
//  MORecordTaskDetailModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/17.
//

#import "MOModel.h"
#import "MOTaskQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MORecordTaskDetailModel : MOModel

@property (nonatomic, strong) NSArray<MOTaskQuestionModel *> *data; // 任务数据
@property (nonatomic, assign) NSInteger count;                // 任务总数
@property (nonatomic, assign) NSInteger complete;             // 完成状态
@property (nonatomic, assign) NSInteger complete_duration;    // 完成时长
@property (nonatomic, copy) NSString *lang_ask;

@end

NS_ASSUME_NONNULL_END
