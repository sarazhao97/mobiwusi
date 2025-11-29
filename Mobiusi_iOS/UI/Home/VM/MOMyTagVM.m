//
//  MOMyTagVM.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/10/5.
//

#import "MOMyTagVM.h"

@implementation MOMyTagVM

///  获取已拥有标签数据
- (void)getUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getUserTagWithCate:cate success:^(NSArray *array) {
        [self.dataList removeAllObjects];
        for (NSDictionary *dict in array) {
            MOMyTagTypeModel *model = [MOMyTagTypeModel yy_modelWithJSON:dict];
            NSMutableArray<MOMyTagModel *> *tags = [NSMutableArray new];
            for (NSDictionary *tagDict in dict[@"tags"]) {
                MOMyTagModel *tagModel = [MOMyTagModel yy_modelWithJSON:tagDict];
                [tags addObject:tagModel];
            }
            model.tags = tags;
            [self.dataList addObject:model];
        }
        success(self.dataList);
        
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  获取未拥有标签数据
- (void)getWithoutUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getWithoutUserTagWithCate:cate success:^(NSArray *array) {
        [self.noDataList removeAllObjects];
        for (NSDictionary *dict in array) {
            MOMyTagTypeModel *model = [MOMyTagTypeModel yy_modelWithJSON:dict];
            NSMutableArray<MOMyTagModel *> *tags = [NSMutableArray new];
            for (NSDictionary *tagDict in dict[@"tags"]) {
                MOMyTagModel *tagModel = [MOMyTagModel yy_modelWithJSON:tagDict];
                [tags addObject:tagModel];
            }
            model.tags = tags;
            [self.noDataList addObject:model];
        }
        success(self.noDataList);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (NSMutableArray<MOMyTagTypeModel *> *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}


- (NSMutableArray<MOMyTagTypeModel *> *)noDataList {
    if (_noDataList == nil) {
        _noDataList = [NSMutableArray new];
    }
    return _noDataList;
}

@end
