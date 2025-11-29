//
//  MOMyTagVM.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/10/5.
//

#import "MOViewModel.h"
#import "MOMyTagTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMyTagVM : MOViewModel

@property (nonatomic, assign) NSInteger cate;

@property (nonatomic, strong) NSMutableArray<MOMyTagTypeModel *> *dataList;

@property (nonatomic, strong) NSMutableArray<MOMyTagTypeModel *> *noDataList;

///  获取已拥有标签数据
- (void)getUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

///  获取未拥有标签数据
- (void)getWithoutUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

@end

NS_ASSUME_NONNULL_END
