//
//  MOHomeTaskSegmentVM.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/13.
//

#import "MOHomeTaskSegmentVM.h"

@implementation MOHomeTaskSegmentVM

- (void)getHomeTaskListWithCate:(NSInteger)cate keyword:(NSString *)keyword follow:(NSInteger)follow lat:(double)lat lng:(double)lng data_cate:(NSInteger)data_cate page:(NSInteger)page limit:(NSInteger)limit success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getHomeTaskListWithCate:self.cate keyword:keyword follow:self.is_follow lat:lat lng:lng data_cate:data_cate page:self.page limit:self.limit success:^(NSArray *array) {
        if (self.page == 1) {
            [self.dataList removeAllObjects];
        }
        
        NSMutableArray<MOTaskListModel *> *dataArr = [NSMutableArray new];
        for (NSDictionary *dict in array) {
            MOTaskListModel *model = [MOTaskListModel yy_modelWithJSON:dict];
            
            // 暂时注释tags
//            NSMutableArray<MOTaskListTagModel *> *tags = [NSMutableArray new];
//            for (NSDictionary *tag_dict in dict[@"tags"]) {
//                MOTaskListTagModel *tagModel = [MOTaskListTagModel yy_modelWithJSON:tag_dict];
//                [tags addObject:tagModel];
//            }
//            model.tags = tags;

            NSMutableArray<MOTaskDescModel *> *task_describe = [NSMutableArray new];
            for (NSDictionary *task_describe_dict in dict[@"task_describe"]) {
                MOTaskDescModel *task_describe_model = [MOTaskDescModel yy_modelWithJSON:task_describe_dict];
                [task_describe addObject:task_describe_model];
            }
            
            model.task_describe = task_describe;
            
            [dataArr addObject:model];
        }
        success(dataArr);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
    
}

- (NSMutableArray<MOTaskListModel *> *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
