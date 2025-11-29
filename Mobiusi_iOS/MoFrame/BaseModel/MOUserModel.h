//
//  MOUserModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOUserModel : MOModel
//用户ID
@property (nonatomic, copy)           NSString *modelId;
@property (nonatomic, copy)           NSString *name;
@property (nonatomic, copy)           NSString *describe;
@property (nonatomic, copy)           NSString *avatar;
@property (nonatomic, copy)           NSString *mobile;
@property (nonatomic, assign)         NSInteger sex;
@property (nonatomic, copy)           NSString *region;
@property (nonatomic, copy)           NSString *email;
@property (nonatomic, copy)           NSString *realname;
@property (nonatomic, assign)         NSInteger is_auth;
@property (nonatomic, assign)         NSInteger cert_type;
@property (nonatomic, copy)           NSString *cert_no;
@property (nonatomic, copy)           NSString *certify_ID;
@property (nonatomic, copy)           NSString *relative_path;
@property (nonatomic, copy)           NSString *create_time;
@property (nonatomic, copy)           NSString *unionid;
@property (nonatomic, copy)           NSString *openid;
@property (nonatomic, copy)           NSString *alipay_openid;
@property (nonatomic, copy)           NSString *sub;
@property (nonatomic, copy)           NSString *lord_identity;
@property (nonatomic, assign)         NSInteger country_code;


//余额
@property (nonatomic, copy)           NSString *account_balance;
//今日收益
@property (nonatomic, copy)           NSString *today_income;
//昨日收益
@property (nonatomic, copy)           NSString *yesterday_income;
//当月收益
@property (nonatomic, copy)           NSString *month_income;
//总收益
@property (nonatomic, copy)           NSString *income_val;
//总提现
@property (nonatomic, copy)           NSString *withdrawal_val;
//数据数量
@property (nonatomic, assign)         NSInteger data_count;
//任务关注数
@property (nonatomic, assign)         NSInteger task_follow_count;
//任务数
@property (nonatomic, assign)         NSInteger task_count;
//空间已用 kb
@property (nonatomic, assign)         NSInteger zone_size_used;
//空间总量 kb
@property (nonatomic, assign)         NSInteger zone_size_total;
//zone_size_used_txt
@property (nonatomic, copy)           NSString *zone_size_used_txt;
//空间总量 kb
@property (nonatomic, copy)           NSString *zone_size_total_txt;
@property (nonatomic, assign)         NSInteger uid;
@property (nonatomic, copy)           NSString *moid;
@property (nonatomic, copy)           NSString *is_auth_zh;
@property (nonatomic, copy)           NSString *token;
//全部标签数
@property (nonatomic, assign)         NSInteger all_tag_count;
//已获得标签数
@property (nonatomic, assign)         NSInteger has_tag_count;
//未获得标签数
@property (nonatomic, assign)         NSInteger no_tag_count;
//最近已获得标签数
@property (nonatomic, assign)         NSInteger has_tag_count_recently;

+ (MOUserModel *)unarchiveUserModel;

- (void)archivedUserModel;

+ (void)removeUserModel;

// 获取当前用户的 token
+ (NSString *)getCurrentUserToken;

// 验证 token 是否有效
+ (BOOL)isTokenValid;
@end

NS_ASSUME_NONNULL_END
