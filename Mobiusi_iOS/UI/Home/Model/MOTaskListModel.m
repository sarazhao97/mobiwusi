//
//  MOTaskListModel.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/13.
//

#import "MOTaskListModel.h"

@implementation MOTaskListModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"task_id" : @"id"};
}

-(NSInteger)topic_type {
    
    // 1: 试做题目 2：正式题目
    NSInteger topic_type = 0;
    if (self.is_try == 0) {
        // 任务为不需要试做时 获取正式题目
        topic_type = 2;
    } else if (self.is_try == 1 && self.try_status == 1) {
        // 任务为需要试做且试做通过时 获取正式题目
        topic_type = 2;
    } else {
        // 其他都加载试做题目
        topic_type = 1;
    }
    
    return topic_type;
}
@end

@implementation MOTaskListTagModel
@end

@implementation MOTaskDescModel
@end

@implementation MOMyTaskListModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"user_task_id" : @"id"};
}
@end

@implementation MOTaskDetailNewModel
@end
