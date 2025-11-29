//
//  MOHomeTaskDetailVM.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/19.
//

#import "MOHomeTaskDetailVM.h"

@implementation MOHomeTaskDetailVM

- (void)getTaskDetailWithTaskId:(NSInteger)task_id
                   user_task_id:(NSInteger)user_task_id
                        success:(MOObjectBlock)success
                        failure:(MOErrorBlock)failure msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getTaskDetailWithTaskId:task_id user_task_id:user_task_id success:^(NSDictionary *dict) {
        MOTaskDetailModel *model = [MOTaskDetailModel yy_modelWithJSON:dict];
        
        NSMutableArray<MOTaskDetailTag *> *tags = [NSMutableArray new];
        for (NSDictionary *tag_dict in dict[@"tags"]) {
            MOTaskDetailTag *tagModel = [MOTaskDetailTag yy_modelWithJSON:tag_dict];
            [tags addObject:tagModel];
        }
        
        NSMutableArray<MOTaskDetailDescribe *> *task_describe = [NSMutableArray new];
        for (NSDictionary *task_describe_dict in dict[@"task_describe"]) {
            MOTaskDetailDescribe *task_describe_model = [MOTaskDetailDescribe yy_modelWithJSON:task_describe_dict];
            [task_describe addObject:task_describe_model];
        }
        
//        model.tags = tags;
        model.task_describe = task_describe;
        
        self.detailModel = model;
        success(model);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

@end
