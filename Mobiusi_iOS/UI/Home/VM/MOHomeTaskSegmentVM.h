//
//  MOHomeTaskSegmentVM.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/13.
//

#import "MOViewModel.h"
#import "MOTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeTaskSegmentVM : MOViewModel

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger limit;

@property (nonatomic, assign) NSInteger cate;

@property (nonatomic, assign) NSInteger is_follow;

@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, assign) NSInteger data_cate;

@property (nonatomic, strong) NSMutableArray <MOTaskListModel *> *dataList;

/// 首页-任务列表
/// - Parameters:
///   - cate: 数据类型 0全部 1音频 2图片 3文本 4：视频
///   - keyword: 关键词 支持任务标题，任务编号
///   - follow: 1：我关注的任务
///   - data_cate: 数据二级类型： 1-语言； 2-控制； 3-音色； 4-声纹； 5-环境； 6-动物；
///   - page: page
///   - limit: limit
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getHomeTaskListWithCate:(NSInteger)cate keyword:(NSString *)keyword follow:(NSInteger)follow lat:(double)lat lng:(double)lng data_cate:(NSInteger)data_cate page:(NSInteger)page limit:(NSInteger)limit success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


@end

NS_ASSUME_NONNULL_END
