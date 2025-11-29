//
//  MONetDataServer.m
//  Translate
//
//  Created by 11 on 16/8/22.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MONetDataServer.h"
#import "NSDictionary+Conversion.h"
#import "NSData+Base64.h"
#import "HBRSAHandler.h"
#import "NSString+Encrypt3DESandBase64.h"

@interface MONetDataServer ()

@end

@implementation MONetDataServer

SINGLETON_GCD(MONetDataServer)

///  获取验证码
- (void)getVerifyCodeWithMobile:(NSString *)mobile
                      sms_event:(NSInteger)sms_event
                   country_code:(NSInteger)country_code
                    channel_type:(NSInteger)channel_type
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure
                            msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail {
    NSMutableDictionary *param = [@{@"mobile":mobile,@"sms_event":@(sms_event),@"country_code":@(country_code)} mutableCopy];
    if (channel_type > 0) {
        [param setObject:@(channel_type) forKey:@"channel_type"];
    }
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/getCode", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"获取验证码 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  登录接口
- (void)loginWithMobile:(NSString *)mobile
           country_code:(NSInteger)country_code
                   code:(NSString *)code
                account:(NSString *)account
               password:(NSString *)password
              checkType:(NSInteger)checkType
                   name:(nullable NSString *)name
                 avatar:(nullable NSString *)avatar
                    sex:(int)sex
                unionid:(nullable NSString *)unionid
                 openid:(nullable NSString *)openid
                    sub:(nullable NSString *)sub
                  email:(nullable NSString *)email
          alipay_openid:(nullable NSString *)alipay_openid
                success:(MODictionaryBlock)success
                failure:(MOErrorBlock)failure
                    msg:(MOStringBlock)msg
              loginFail:(MOBlock)loginFail {
    NSMutableDictionary *param = @{@"mobile":mobile, @"code":code, @"account":account, @"password":password, @"checkType":@(checkType),@"country_code":@(country_code)}.mutableCopy;
    if (sex >= 0) {
        [param setValue:@(sex) forKey:@"sex"];
    }
    if (name) {
        [param setValue:name forKey:@"name"];
    }
    if (name) {
        [param setValue:avatar forKey:@"avatar"];
    }
    if (unionid) {
        [param setValue:unionid forKey:@"unionid"];
    }
    if (openid) {
        [param setValue:openid forKey:@"openid"];
    }
    if (sub) {
        [param setValue:sub forKey:@"sub"];
    }
    if (email) {
        [param setValue:email forKey:@"email"];
    }
    if (alipay_openid) {
        [param setValue:alipay_openid forKey:@"alipay_openid"];
    }
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/login", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 注销用户
- (void)deleteUserSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.user/cancelUser", API_HOST];
    [self PostWithUrl:request_url paraDict:nil success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"注销用户 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)registWithMobile:(NSString *)mobile
                    code:(NSString *)code
                password:(NSString *)password
         second_password:(NSString *)second_password
                 success:(MODictionaryBlock)success
                 failure:(MOErrorBlock)failure
                     msg:(MOStringBlock)msg
               loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"mobile":mobile, @"code":code, @"password":password, @"second_password":second_password};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/register", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)resetPasswordWithMobile:(NSString *)mobile
                           code:(NSString *)code
                       password:(NSString *)password
                   country_code:(NSInteger)country_code
         second_password:(NSString *)second_password
                 success:(MOBoolBlock)success
                 failure:(MOErrorBlock)failure
                     msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail{
    NSDictionary *param = @{@"mobile":mobile, @"code":code, @"password":password, @"second_password":second_password,@"country_code":@(country_code)};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/resetPassword", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success([dic[@"data"] boolValue]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)weChatLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                        msg:(MOStringBlock)msg{
    NSDictionary *param = @{ @"code":code};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/weChatLogin", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"微信登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
    }];
    
}




- (void)alipayLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                        msg:(MOStringBlock)msg{
    NSDictionary *param = @{ @"code":code};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/alipayLogin", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"支付宝登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
    }];
}

- (void)appleLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                        msg:(MOStringBlock)msg{
    NSDictionary *param = @{ @"code":code};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.login/appleLogin", API_HOST];
    [self PostWithUrl:request_url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
    }];
}


- (void)getCountryCodeWithSuccess:(MOArrayBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg{
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.Login/getCountryCode", API_HOST];
    [self PostWithUrl:request_url paraDict:@{} success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
    }];
}

- (void)bindWeChatWithCode:(NSString *)wxAuthCode
                   vercode:(NSString *)vercode
                   Success:(MODictionaryBlock)success
                   failure:(MOErrorBlock)failure
                       msg:(MOStringBlock)msg
                 loginFail:(MOBlock)loginFail{
    
    NSDictionary *parm = @{@"code":wxAuthCode,@"vercode":vercode};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.user/bindWeChat", API_HOST];
    [self PostWithUrl:request_url paraDict:parm success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)bindAliPayWithCode:(NSString *)alipayCode
                   vercode:(NSString *)vercode
                   Success:(MODictionaryBlock)success
                   failure:(MOErrorBlock)failure
                       msg:(MOStringBlock)msg
                 loginFail:(MOBlock)loginFail{
    
    NSDictionary *parm = @{@"code":alipayCode,@"vercode":vercode};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.user/bindAlipay", API_HOST];
    [self PostWithUrl:request_url paraDict:parm success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)bindAppleWithCode:(NSString *)authId
                  vercode:(NSString *)vercode
                  Success:(MODictionaryBlock)success
                  failure:(MOErrorBlock)failure
                      msg:(MOStringBlock)msg
                loginFail:(MOBlock)loginFail{
    
    NSDictionary *parm = @{@"code":authId,@"vercode":vercode};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.user/bindApple", API_HOST];
    [self PostWithUrl:request_url paraDict:parm success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)unbindThirdAccountWithAccountType:(NSInteger)account_type
                                  Success:(MODictionaryBlock)success
                                  failure:(MOErrorBlock)failure
                                      msg:(MOStringBlock)msg
                                loginFail:(MOBlock)loginFail{
    
    NSDictionary *parm = @{@"account_type":@(account_type)};
    NSString *request_url = [NSString stringWithFormat:@"%@/v1.user/unbindThirdAccount", API_HOST];
    [self PostWithUrl:request_url paraDict:parm success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"苹果登录接口 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}




///  分类选项
- (void)getCateOptionSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail; {
    NSString *url = [NSString stringWithFormat:@"%@/v1.cateOption/index", API_HOST];
    [self PostWithUrl:url paraDict:nil success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"分类选项 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  个人资料
- (void)getUserInfoSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSString *url = [NSString stringWithFormat:@"%@/v1.user/userInfo", API_HOST];
    [self PostWithUrl:url paraDict:nil success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"个人资料 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  获取标签数据
- (void)getUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"cate":@(cate)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.userTag/all", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"获取标签数据 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 获取标签选项
- (void)getUserTagOptionsWithType:(NSInteger)type sub_type:(NSInteger)sub_type success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"type":@(type), @"sub_type":@(sub_type)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.userTag/options", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"获取标签选项 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  获取标签数据（类型）  获取标签数据，按照标签分类维度返回数据
- (void)getWithoutUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"cate":@(cate)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.userTag/allSubType", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"获取标签数据（类型） errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///  收益中心余额统计
- (void)getUserBalanceCenterSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSString *url = [NSString stringWithFormat:@"%@/v1.userBalance/center", API_HOST];
    [self PostWithUrl:url paraDict:nil success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"收益中心余额统计 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)getUserBalanceDetailsWithMonth:(NSString *)month
                                  page:(NSInteger)page
                                 limit:(NSInteger)limit
                                  type:(NSInteger)type
                              get_type:(NSInteger)get_type
                               success:(MODictionaryBlock)success
                               failure:(MOErrorBlock)failure
                                   msg:(MOStringBlock)msg
                             loginFail:(MOBlock)loginFail {
    
    NSDictionary *para = @{
        @"month":month,
        @"page":@(page),
        @"limit":@(limit),
        @"type":@(type),
        @"get_type":@(get_type)
        
    };
    NSString *url = [NSString stringWithFormat:@"%@/v1.userBalance/details", API_HOST];
    [self PostWithUrl:url paraDict:para success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"收益中心余额统计 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)userWithdrawalSaveWithMoney:(NSString *)money
                     bank_user_name:(NSString *)bank_user_name
                          bank_name:(NSString *)bank_name
                            bank_no:(NSString *)bank_no
                               type:(NSInteger)type
                    transferChannel:(NSInteger)transfer_channel
                            success:(MODictionaryBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail {
    
    NSDictionary *para = @{
        @"money":money,
        @"bank_user_name":bank_user_name,
        @"bank_name":bank_name,
        @"bank_no":bank_no,
        @"type":@(type),
        @"transfer_channel":@(transfer_channel)
        
    };
    NSString *url = [NSString stringWithFormat:@"%@/v1.UserWithdrawal/save", API_HOST];
    [self PostWithUrl:url paraDict:para success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"申请提现 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)userWithdrawaRecordWithPage:(NSInteger)page
                              limit:(NSInteger)limit
                            success:(MODictionaryBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail {
    
    NSDictionary *para = @{
        @"page":@(page),
        @"limit":@(limit),
        
    };
    NSString *url = [NSString stringWithFormat:@"%@/v1.UserWithdrawal/list", API_HOST];
    [self PostWithUrl:url paraDict:para success:^(NSDictionary *dic) {
        success(dic[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"申请提现 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


/// 首页-任务列表
- (void)getHomeTaskListWithCate:(NSInteger)cate keyword:(NSString *)keyword follow:(NSInteger)follow lat:(double)lat lng:(double)lng data_cate:(NSInteger)data_cate page:(NSInteger)page limit:(NSInteger)limit success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
	NSDictionary *param = @{@"cate":@(cate), @"keyword":keyword, @"follow":@(follow),@"lat":@(lat),@"lng":@(lng), @"data_cate":@(data_cate), @"page":@(page), @"limit":@(limit)};

    NSString *url = [NSString stringWithFormat:@"%@/v2.task/all", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"任务列表 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 任务详情
- (void)getTaskDetailWithTaskId:(NSInteger)task_id
                   user_task_id:(NSInteger)user_task_id
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"task_id":@(task_id),@"user_task_id":@(user_task_id)};

    NSString *url = [NSString stringWithFormat:@"%@/v2.task/detail", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"任务详情 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 任务题目
- (void)getUserTaskTopicWithTaskId:(NSInteger)task_id user_task_id:(NSInteger)user_task_id task_status:(NSInteger)task_status topic_type:(NSInteger)topic_type success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"task_id":@(task_id), @"user_task_id":@(user_task_id), @"task_status":@(task_status), @"topic_type":@(topic_type)};

    NSString *url = [NSString stringWithFormat:@"%@/v2.task/getUserTaskTopicList", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"任务题目 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)followTaskWithTaskId:(NSInteger)task_id
                      action:(NSInteger)action
                     success:(MOIndexBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"id":@(task_id), @"action":@(action)};

    NSString *url = [NSString stringWithFormat:@"%@/v1.task/followTask", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success([dict[@"data"] integerValue]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"任务关注errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)checkVersionWithAppType:(unsigned int)app_type
                          appId:(unsigned int)app_id
                         success:(MODictionaryBlock)success
                         failure:(MOErrorBlock)failure
                             msg:(MOStringBlock)msg
                       loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{@"app_type":@(app_type), @"app_id":@(app_id)};

    NSString *url = [NSString stringWithFormat:@"%@/v1.version/checkVersion", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"任务关注errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
    
}



/// 完成音频题目
- (void)finishTopicWithTaskId:(NSInteger)task_id
                 user_task_id:(NSInteger)user_task_id
                    result_id:(NSInteger)result_id
                    text_data:(NSString *)text_data
                 picture_data:(NSString *)picture_data
                   audio_data:(NSString *)audio_data
                    file_data:(NSString *)file_data
                   video_data:(NSString *)video_data
                      success:(MODictionaryBlock)success
                      failure:(MOErrorBlock)failure
                          msg:(MOStringBlock)msg
                    loginFail:(MOBlock)loginFail {
    NSMutableDictionary *param = @{
        @"task_id":@(task_id),
        @"user_task_id":@(user_task_id),
        @"result_id":@(result_id)
    }.mutableCopy;
    if ([text_data length]) {
        [param setValue:text_data forKey:@"text_data"];
    }
    if ([picture_data length]) {
        [param setValue:picture_data forKey:@"picture_data"];
    }
    if ([audio_data length]) {
        [param setValue:audio_data forKey:@"audio_data"];
    }
    if ([file_data length]) {
        [param setValue:file_data forKey:@"file_data"];
    }
    if ([video_data length]) {
        [param setValue:video_data forKey:@"video_data"];
    }

    NSString *url = [NSString stringWithFormat:@"%@/v2.task/finishTopic", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"完成音频题目 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 我的任务
- (void)getMyTaskListWithCate_id:(NSInteger)cate_id task_status:(NSInteger)task_status page:(NSInteger)page limit:(NSInteger)limit success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"cate_id":@(cate_id), @"task_status":@(task_status), @"page":@(page), @"limit":@(limit)};

    NSString *url = [NSString stringWithFormat:@"%@/v1.task/myReceiveTask", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"我的任务列表 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


/// 首页收入提醒
- (void)getincomeTipWithSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{};

    NSString *url = [NSString stringWithFormat:@"%@/v1.UserBalance/incomeTip", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"首页收入提醒 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 领取任务
- (void)receiveATaskWithTaskid:(NSInteger)task_id lat:(double)lat lng:(double)lng success:(MOIndexBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
	NSDictionary *param = @{@"task_id":@(task_id),@"lat":@(lat),@"lng":@(lng)};

    NSString *url = [NSString stringWithFormat:@"%@/v1.task/receiveTask", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success([dict[@"data"] integerValue]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"我的任务列表 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)receiveATaskV2WithTaskid:(NSInteger)task_id lat:(double)lat lng:(double)lng success:(MOIndexBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
	NSDictionary *param = @{@"task_id":@(task_id),@"lat":@(lat),@"lng":@(lng)};

	NSString *url = [NSString stringWithFormat:@"%@/v2.task/receiveTask", API_HOST];

	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success([dict[@"data"] integerValue]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@"我的任务列表 errMsg - %@", string);

		msg(string);
	} loginFail:^{
		loginFail();
	}];
}


/// 我的数据
- (void)getUserDataWithCate_id:(NSInteger)cate_id
				  user_task_id:(NSInteger)user_task_id
			  user_paste_board:(BOOL)user_paste_board
                          page:(NSInteger)page
                         limit:(NSInteger)limit
                       success:(MOArrayBlock)success
                       failure:(MOErrorBlock)failure
                           msg:(MOStringBlock)msg
                     loginFail:(MOBlock)loginFail {
	NSDictionary *param = @{@"cate_id":@(cate_id),@"user_task_id":@(user_task_id),@"user_paste_board":@(user_paste_board),@"page":@(page),@"limit":@(limit)};

    NSString *url = [NSString stringWithFormat:@"%@/v2.userData/index", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"我的数据 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 热搜
- (void)getHotSearchListWithCate_id:(NSInteger)cate_id
                               page:(NSInteger)page
                              limit:(NSInteger)limit
                            success:(MOArrayBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{@"cate_id":@(cate_id),@"page":@(page),@"limit":@(limit)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.task/hotList", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"热搜 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

///搜索-增加任务点击
- (void)hostSearchAddClickWithTask_id:(NSInteger )task_id
                                 success:(MOObjectBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{@"task_id":@(task_id)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.task/addClick", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"搜索-增加任务点击 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)getMultiSearchWithKeyword:(NSString *)keyword
                            limit:(NSInteger)limit
                          success:(MODictionaryBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{@"keyword":keyword,@"limit":@(limit)};
    NSString *url = [NSString stringWithFormat:@"%@/v2.task/multiSearch", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"搜索 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)getMessageListWithData_id:(NSInteger)data_id
						 dataCate:(NSInteger)dataCate
				 userTaskResultId:(NSInteger)user_task_result_id
                             page:(NSInteger)page
                            limit:(NSInteger)limit
                          success:(MODictionaryBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail {
    
	NSDictionary *param = @{@"data_id":@(data_id),@"page":@(page),@"limit":@(limit),@"user_task_result_id":@(user_task_result_id),@"data_cate":@(dataCate)};
    NSString *url = [NSString stringWithFormat:@"%@/v1.message/list", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"搜索 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)getlevelInfoWithSuccess:(MODictionaryBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{};
    NSString *url = [NSString stringWithFormat:@"%@/v1.user/levelInfo", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"搜索 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)signInWithDate:(NSString *)date
               Success:(MODictionaryBlock)success
               failure:(MOErrorBlock)failure
                   msg:(MOStringBlock)msg
             loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{@"date":date?:@""};
    NSString *url = [NSString stringWithFormat:@"%@/v1.user/signIn", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"签到 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)saveAuthWithAuthType:(NSInteger)auth_type
           identityCardFront:(nullable NSString *)identity_card_front
            identityCardBack:(nullable NSString *)identity_card_back
           driverLicenceMain:(nullable NSString *)driver_licence_main
         driverLicenceDeputy:(nullable NSString *)driver_licence_deputy
                 workCompany:(nullable NSString *)work_company
                  workIncome:(NSInteger)work_income
              educationImage:(nullable NSString *)education_image
                    workType:(NSInteger)work_type
                     success:(MODictionaryBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail {
    
    NSDictionary *param = @{
        @"auth_type":@(auth_type),
        @"identity_card_front":identity_card_front?:@"",
        @"identity_card_back":identity_card_back?:@"",
        @"driver_licence_main":driver_licence_main?:@"",
        @"driver_licence_deputy":driver_licence_deputy?:@"",
        @"work_company":work_company?:@"",
        @"work_income":@(work_income),
        @"education_image":education_image?:@"",
        @"work_type":@(work_type)
        
    };
    NSString *url = [NSString stringWithFormat:@"%@/v1.userAuth/saveAuth", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"签到 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)unlimitedUploadDataWithCateId:(NSInteger)cate_id
                                 idea:(nullable NSString *)idea
                             location:(nullable NSString *)location
                            user_data:(NSString *)user_data
                           content_id:(NSInteger)content_id
                         is_summarize:(BOOL)is_summarize
                              Success:(MOBlock)success
                              failure:(MOErrorBlock)failure
                                  msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail {
    
    NSMutableDictionary *param = @{@"cate_id":@(cate_id),@"user_data":user_data,@"is_summarize":@(is_summarize)}.mutableCopy;
    if (location) {
        [param addEntriesFromDictionary:@{@"location":location}];
    }
    if (idea) {
        [param addEntriesFromDictionary:@{@"idea":idea}];
    }
    if (content_id != 0) {
        [param addEntriesFromDictionary:@{@"content_id":@(content_id)}];
    }
    NSString *url = [NSString stringWithFormat:@"%@/v2.UserData/unlimitedUploadData", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"上传 errMsg - %@", string);

        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)annotationWithCateId:(NSInteger)cate_id
						 lat:(double)lat
						 lng:(double)lng
                        page:(NSInteger)page
                       limit:(NSInteger)limit
                     success:(MOArrayBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail {
    
	NSMutableDictionary *param = @{@"cate_id":@(cate_id),@"lat":@(lat),@"lng":@(lng),@"page":@(page),@"limit":@(limit)}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/index", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@" errMsg - %@", string);
        DLog(@"上传 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}
    
-(void)parsePasteboardContentWithContent:(NSString *)content
                                 success:(MODictionaryBlock)success
                                 failure:(MOErrorBlock)failure
                                     msg:(MOStringBlock)msg
                               loginFail:(MOBlock)loginFail{
    
    NSMutableDictionary *param = @{@"content":content}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.userData/parsePasteboardContent", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@" errMsg - %@", string);
        DLog(@"上传 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)annotationCreateOrderWithCateId:(NSInteger)cate_id
                                dataId:(NSInteger)data_id
								 taskId:(NSInteger)task_id
									lat:(double)lat
									lng:(double)lng
                                success:(MOIndexBlock)success
                                failure:(MOErrorBlock)failure
                                    msg:(MOStringBlock)msg
                              loginFail:(MOBlock)loginFail {
    
	NSMutableDictionary *param = @{@"cate_id":@(cate_id),@"data_id":@(data_id),@"task_id":@(task_id),@"lat":@(lat),@"lng":@(lng)}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/createOrder", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success([dict[@"data"] integerValue]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@" errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
    
}


-(void)writePasteboardContentWithcontentId:(NSInteger)content_id isSummarize:(BOOL)is_summarize
                                   success:(MOBlock)success
                                   failure:(MOErrorBlock)failure
                                       msg:(MOStringBlock)msg
                                 loginFail:(MOBlock)loginFail {
    
    NSMutableDictionary *param = @{@"content_id":@(content_id),@"is_summarize":@(is_summarize)}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.userData/writePasteboardContent", API_HOST];

    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"Mobiwusi 总结 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (void)annotationDetailWithResultId:(NSInteger)result_id
						  metaDataId:(NSInteger)meta_data_id
							 success:(MODictionaryBlock)success
							 failure:(MOErrorBlock)failure
								 msg:(MOStringBlock)msg
						   loginFail:(MOBlock)loginFail {
    
										NSMutableDictionary *param = @{@"result_id":@(result_id),@"meta_data_id":@(meta_data_id)}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/detail", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@" errMsg - %@", string);
        DLog(@"Mobiwusi 总结 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
    
}


- (void)annotationOrderListWithCateId:(NSInteger)cateId
								 page:(NSInteger)page
								limit:(NSInteger)limit
							  success:(MOArrayBlock)success
							  failure:(MOErrorBlock)failure
								  msg:(MOStringBlock)msg
							loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"cate_id":@(cateId),@"page":@(page),@"limit":@(limit)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/annotationListV2", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"Mobiwusi 总结 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)cateOptionProcessPropertyWithSuccess:(MOArrayBlock)success
									 failure:(MOErrorBlock)failure
										 msg:(MOStringBlock)msg
								   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v1.cateOption/processProperty", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"Mobiwusi 总结 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}




-(void)getSummaryDetailWithCate:(NSInteger)cate
                       resultId:(NSInteger)result_id
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure
                            msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail {
    NSMutableDictionary *param = @{@"cate":@(cate),@"id":@(result_id)}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/v2.userData/getSummaryDetail", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@" errMsg - %@", string);
        DLog(@"Mobiwusi 总结 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)annotationSaveWithResultId:(NSInteger)result_id
						metaDataId:(NSInteger)meta_data_id
							status:(NSInteger)status
						 audioData:(NSString *)audio_data
						   success:(MOBlock)success
						   failure:(MOErrorBlock)failure
							   msg:(MOStringBlock)msg
						 loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"result_id":@(result_id),@"meta_data_id":@(meta_data_id),@"status":@(status),@"audio_data":audio_data}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/save", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success();
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"Mobiwusi 总结 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)speechToTextWithDataId:(NSInteger)data_id
					 startTime:(NSInteger)start_time
					   endTime:(NSInteger)end_time
					   success:(MOStringBlock)success
					   failure:(MOErrorBlock)failure
						   msg:(MOStringBlock)msg
					 loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"meta_data_id":@(data_id),@"start_time":@(start_time),@"end_time":@(end_time)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/speechToText", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"Mobiwusi 总结 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}


- (void)deleteAudioAnnotationWithId:(NSInteger)segmentId
							success:(MOIndexBlock)success
							failure:(MOErrorBlock)failure
								msg:(MOStringBlock)msg
						  loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"id":@(segmentId)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.annotation/deleteAudioAnnotation", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"Mobiwusi 总结 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)recycleTaskWithUserTaskId:(NSInteger)userTaskId
									success:(MOIndexBlock)success
									failure:(MOErrorBlock)failure
										msg:(MOStringBlock)msg
								  loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"id":@(userTaskId)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.task/recycleTask", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"放弃标注任务 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}



- (void)transPictureWithPath:(NSString *)path
					 success:(MODictionaryBlock)success
					 failure:(MOErrorBlock)failure
						 msg:(MOStringBlock)msg
				   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"path":path}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.tool/transPicture", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)transPictureWithPath:(NSString *)path
			   parentPostID:(nullable NSString *)parentPostID
					 success:(MODictionaryBlock)success
					 failure:(MOErrorBlock)failure
						 msg:(MOStringBlock)msg
				   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"path":path}.mutableCopy;
	if (parentPostID.length > 0) {
		param[@"parent_post_id"] = parentPostID;
	}
	NSString *url = [NSString stringWithFormat:@"%@/v2.tool/transPicture", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void) analysisFoodWithUrl:(NSString *)url
					 success:(MODictionaryBlock)success
					 failure:(MOErrorBlock)failure
						 msg:(MOStringBlock)msg
				   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"url":url}.mutableCopy;
	NSString *requestURL = [NSString stringWithFormat:@"%@/v2.foodAnalysis/create", API_HOST];
	[self PostWithUrl:requestURL paraDict:param success:^(NSDictionary *dict) {
		id data = dict[@"data"];
		NSDictionary *payload = nil;
		if ([data isKindOfClass:[NSDictionary class]]) {
			payload = (NSDictionary *)data;
		} else if (data && ![data isKindOfClass:[NSNull class]]) {
			payload = @{@"data": data};
		} else {
			payload = @{};
		}
		success(payload);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)analysisFoodWithUrl:(NSString *)url
			   parentPostID:(nullable NSString *)parentPostID
					 success:(MODictionaryBlock)success
					 failure:(MOErrorBlock)failure
						 msg:(MOStringBlock)msg
				   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"url":url}.mutableCopy;
	if (parentPostID.length > 0) {
		param[@"parent_post_id"] = parentPostID;
	}
	NSString *requestURL = [NSString stringWithFormat:@"%@/v2.foodAnalysis/create", API_HOST];
	[self PostWithUrl:requestURL paraDict:param success:^(NSDictionary *dict) {
		id data = dict[@"data"];
		NSDictionary *payload = nil;
		if ([data isKindOfClass:[NSDictionary class]]) {
			payload = (NSDictionary *)data;
		} else if (data && ![data isKindOfClass:[NSNull class]]) {
			payload = @{@"data": data};
		} else {
			payload = @{};
		}
		success(payload);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)summaryExampleWithSuccess:(MODictionaryBlock)success
						  failure:(MOErrorBlock)failure
							  msg:(MOStringBlock)msg
						loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.userData/summaryExample", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)transPictureListWithPage:(NSInteger)page
						   limit:(NSInteger)limit
						 success:(MODictionaryBlock)success
						 failure:(MOErrorBlock)failure
							 msg:(MOStringBlock)msg
					   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"page":@(page),@"limit":@(limit)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.tool/transPictureList", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}

- (void)foodSafeHistoryListWithPage:(NSInteger)page
						   limit:(NSInteger)limit
						 success:(MODictionaryBlock)success
						 failure:(MOErrorBlock)failure
							 msg:(MOStringBlock)msg
					   loginFail:(MOBlock)loginFail {
	
	NSMutableDictionary *param = @{@"page":@(page),@"limit":@(limit)}.mutableCopy;
	NSString *url = [NSString stringWithFormat:@"%@/v2.foodAnalysis/history", API_HOST];
	[self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
		success(dict[@"data"]);
	} failure:^(NSError *error) {
		failure(error);
	} msg:^(NSString *string) {
		DLog(@" errMsg - %@", string);
		DLog(@"总结样例 errMsg - %@", string);
		msg(string);
	} loginFail:^{
		loginFail();
	}];
	
}



#pragma mark - 个人中心

/// 修改个人信息
- (void)modifyUserInfoWithUserName:(NSString *)name avatar:(NSString *)avatar sex:(NSInteger)sex mobile:(NSString *)mobile describe:(NSString *)describe native_city:(NSString *)native_city native_city_code:(NSString *)native_city_code native_province:(NSString *)native_province native_province_code:(NSString *)native_province_code success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"name":name, @"avatar":avatar, @"sex":@(sex), @"mobile":mobile, @"describe":describe, @"native_city":native_city, @"native_city_code":native_city_code, @"native_province":native_province, @"native_province_code":native_province_code};
    
    NSString *url = [NSString stringWithFormat:@"%@/v1.user/saveUser", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"修改个人信息 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

/// 意见反馈
- (void)feedbackWithType:(NSInteger)type content:(NSString *)content contact_info:(NSString *)contact_info detail_img:(NSString *)detail_img success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *param = @{@"type":@(type), @"content":content, @"contact_info":contact_info, @"detail_img":detail_img};
    
    NSString *url = [NSString stringWithFormat:@"%@/v1.feedback/save", API_HOST];
    [self PostWithUrl:url paraDict:param success:^(NSDictionary *dict) {
        success(dict[@"data"]);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        DLog(@"意见反馈 errMsg - %@", string);
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

- (NSURLSessionDataTask *)uploadImage:(UIImage *)image success:(MODictionaryBlock)success failure:(MOErrorBlock)failure loginFail:(MOBlock)loginFail {
    NSDictionary *rsaDict = [self configRSAParameter:nil];

    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *mimeType = @"image/jpeg";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
    NSString *url = [NSString stringWithFormat:@"%@/v1.upload/upload", API_HOST];
    
    [[NetWorkManager shareManager].requestSerializer setValue:@"1" forHTTPHeaderField:@"system-id"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getAppVersion] forHTTPHeaderField:@"app-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getSystemVersion] forHTTPHeaderField:@"device-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:@"iphone" forHTTPHeaderField:@"os"];
    // 统一补充语言与 token 头，避免 code=2 登录失效
    NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
    NSString *localeLanguage = @"en-us";
    if ([preferredLanguages.firstObject containsString:@"zh-Hans"]) {
        localeLanguage = @"zh-cn";
    }
    [[NetWorkManager shareManager].requestSerializer setValue:localeLanguage forHTTPHeaderField:@"think-lang"];
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    if (user != nil) {
        [[NetWorkManager shareManager].requestSerializer setValue:user.token forHTTPHeaderField:@"token"];
    }  else {
        [[NetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    }
    
    NSURLSessionDataTask *task = [[NetWorkManager shareManager] POST:url.exchangeNull parameters:rsaDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:mimeType];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            NSDictionary *response = [NSDictionary exchangeNull:responseObject];
            if ([response isKindOfClass:[NSDictionary class]]) {
                if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"1"]) {
                    success(response[@"data"]);
                } else if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"2"]) {
                    [self handleLogOut];
                    loginFail();
                } else {
                    DLog(@"uploadAvatarImage - %@", response[@"msg"]);
                    failure(0);
                }
            } else {
                failure(0);
            }
            DLog(@"response - %@",response);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    return task;
}

- (NSURLSessionDataTask *)uploadAudioFileWithFileName:(NSString *)fileName filePath:(NSString *)filePath success:(MODictionaryBlock)success failure:(MOErrorBlock)failure loginFail:(MOBlock)loginFail {
    NSDictionary *rsaDict = [self configRSAParameter:nil];
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSData *header = WriteWavFileHeader(fileData.length,fileData.length+36,44100,1,88200);
    NSMutableData *wavDatas = [[NSMutableData alloc]init];
    [wavDatas appendData:header];
    [wavDatas appendData:fileData];
    
    NSString *mimeType = @"audio/x-wav";
    
    NSString *url = [NSString stringWithFormat:@"%@/v1.upload/upload", API_HOST];
    
    [[NetWorkManager shareManager].requestSerializer setValue:@"1" forHTTPHeaderField:@"system-id"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getAppVersion] forHTTPHeaderField:@"app-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getSystemVersion] forHTTPHeaderField:@"device-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:@"iphone" forHTTPHeaderField:@"os"];
    // 统一补充语言与 token 头，避免 code=2 登录失效
    NSArray<NSString *> *preferredLanguages2 = [NSLocale preferredLanguages];
    NSString *localeLanguage2 = @"en-us";
    if ([preferredLanguages2.firstObject containsString:@"zh-Hans"]) {
        localeLanguage2 = @"zh-cn";
    }
    [[NetWorkManager shareManager].requestSerializer setValue:localeLanguage2 forHTTPHeaderField:@"think-lang"];
    MOUserModel *user2 = [MOUserModel unarchiveUserModel];
    if (user2 != nil) {
        [[NetWorkManager shareManager].requestSerializer setValue:user2.token forHTTPHeaderField:@"token"];
    }  else {
        [[NetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    }
    
    NSURLSessionDataTask *task = [[NetWorkManager shareManager] POST:url.exchangeNull parameters:rsaDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:wavDatas name:@"file" fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *response = [NSDictionary exchangeNull:responseObject];
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"1"]) {
                success(response[@"data"]);
            } else if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"2"]) {
                [self handleLogOut];
                loginFail();
            } else {
                DLog(@"uploadAudioFileWithFileName - %@", response[@"msg"]);
                failure(0);
            }
        } else {
            failure(0);
        }
        DLog(@"response - %@",response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    return task;
}


- (NSURLSessionDataTask *)uploadFileWithFileName:(NSString *)fileName
                                        fileData:(NSData *)fileData
                                        mimeType:(NSString *)mimeType
                                         success:(MODictionaryBlock)success
                                         failure:(MOErrorBlock)failure
                                       loginFail:(MOBlock)loginFail {
    
    NSDictionary *rsaDict = [self configRSAParameter:nil];
    NSString *url = [NSString stringWithFormat:@"%@/v1.upload/upload", API_HOST];
    
    [[NetWorkManager shareManager].requestSerializer setValue:@"1" forHTTPHeaderField:@"system-id"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getAppVersion] forHTTPHeaderField:@"app-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getSystemVersion] forHTTPHeaderField:@"device-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:@"iphone" forHTTPHeaderField:@"os"];
    // 统一补充语言与 token 头，避免 code=2 登录失效
    NSArray<NSString *> *preferredLanguages3 = [NSLocale preferredLanguages];
    NSString *localeLanguage3 = @"en-us";
    if ([preferredLanguages3.firstObject containsString:@"zh-Hans"]) {
        localeLanguage3 = @"zh-cn";
    }
    [[NetWorkManager shareManager].requestSerializer setValue:localeLanguage3 forHTTPHeaderField:@"think-lang"];
    MOUserModel *user3 = [MOUserModel unarchiveUserModel];
    if (user3 != nil) {
        [[NetWorkManager shareManager].requestSerializer setValue:user3.token forHTTPHeaderField:@"token"];
    }  else {
        [[NetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    }
    
    NSURLSessionDataTask *task = [[NetWorkManager shareManager] POST:url.exchangeNull parameters:rsaDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *response = [NSDictionary exchangeNull:responseObject];
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"1"]) {
                success(response[@"data"]);
            } else if ([[NSString stringWithFormat:@"%@",response[@"code"]]isEqualToString:@"2"]) {
                [self handleLogOut];
                loginFail();
            } else {
				NSString *msg = response[@"msg"];
                DLog(@"uploadAudioFileWithFileName - %@", response[@"msg"]);
				NSError *error = [NSError errorWithDomain:@"msg" code:0 userInfo:@{NSLocalizedDescriptionKey:msg?:@""}];
				failure(error);
            }
        } else {
			NSError *error = [NSError errorWithDomain:@"msg" code:0 userInfo:@{NSLocalizedDescriptionKey:@"返回数据格式错误"}];
            failure(error);
        }
        DLog(@"response - %@",response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    return task;
}

//
- (void)downloadFileWithUrl:(NSString *)url savePath:(NSString *)savePath downloadProgress:(FileDownloadProgress)progress downloadCompletion:(CompletionState)completion {
    NSURLSessionDownloadTask *task = [NetWorkManager downloadFileWithUrl:url savaPath:savePath sownloadProgress:progress downloadCompletion:completion];
    [task resume];
}

- (NSURLSessionDataTask *)PostWithUrl:(NSString *)url paraDict:(NSDictionary *)dict success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    NSDictionary *rsaDict = [self configRSAParameter:dict];
    [[NetWorkManager shareManager].requestSerializer setValue:@"1" forHTTPHeaderField:@"system-id"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getAppVersion] forHTTPHeaderField:@"app-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:[AppToken getSystemVersion] forHTTPHeaderField:@"device-version"];
    [[NetWorkManager shareManager].requestSerializer setValue:@"iphone" forHTTPHeaderField:@"os"];
    NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
    
    NSString *localeLanguage = @"en-us";
    if ([preferredLanguages.firstObject containsString:@"zh-Hans"]) {
        localeLanguage = @"zh-cn";
    }
    DLog("url:%@ paraDict:%@",url,dict);
    [[NetWorkManager shareManager].requestSerializer setValue:localeLanguage forHTTPHeaderField:@"think-lang"];

    MOUserModel *user = [MOUserModel unarchiveUserModel];
    if (user != nil) {
        [[NetWorkManager shareManager].requestSerializer setValue:user.token forHTTPHeaderField:@"token"];
    }  else {
        [[NetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    }
    
    NSURLSessionDataTask *task = [NetWorkManager requestWithType:HttpRequestTypePost withUrlString:url.exchangeNull withParaments:rsaDict withSuccessBlock:^(NSDictionary *object) {
        
        DLog("url:%@ res:%@",url,object);
        
        if ([[NSString stringWithFormat:@"%@",object[@"code"]]isEqualToString:@"1"]) {
            success(object);
        } else if ([[NSString stringWithFormat:@"%@",object[@"code"]]isEqualToString:@"2"]) {
            [self handleLogOut];
            loginFail();
        } else {
            msg(object[@"msg"]);
        }
    } withFailureBlock:^(NSError *error) {
        DLog(@"%@",error);
        failure(error);
    } progress:^(float progress) {
    }];
    return task;
}


#pragma mark - customMethod


NSData* WriteWavFileHeader(long totalAudioLen, long totalDataLen, long longSampleRate,int channels, long byteRate)
{
    Byte  header[44];
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);  //file-size (equals file-size - 8)
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';  // Mark it as type "WAVE"
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // Mark the format section 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;   // 4 bytes: size of 'fmt ' chunk, Length of format data.  Always 16
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;  // format = 1 ,Wave type PCM
    header[21] = 0;
    header[22] = (Byte) channels;  // channels
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (1 * 16 / 8); // block align
    header[33] = 0;
    header[34] = 16; // bits per sample
    header[35] = 0;
    header[36] = 'd'; //"data" marker
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);  //data-size (equals file-size - 44).
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    return [[NSData alloc] initWithBytes:header length:44];;
}

- (void)handleLogOut {
    [MOUserModel removeUserModel];
    [MOAppDelegate.transition popToRootViewControllerAnimated:YES];
}

// 参数加密后转化
- (NSDictionary *)configRSAParameter:(NSDictionary *)para {
    NSDictionary * rsaParameter = nil;

    // 不传参事用e30=
    NSString *base64Str = @"e30=";
    
    if (para != nil && para.allKeys.count > 0) {
        NSString *jsonParmeters = [self dictToJsonStr:para];
        NSData *data = [jsonParmeters dataUsingEncoding:NSUTF8StringEncoding];
        base64Str = [data base64EncodedString];
    }

    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];

    NSString * befRSA = [NSString stringWithFormat:@"data=%@&timestamp=%@",base64Str,timeString];
    HBRSAHandler * handler = [HBRSAHandler new];
    NSString *keyString = PRIVATE_KEY_STRING;

    [handler importKeyWithType:KeyTypePrivate andkeyString:keyString];
        
    NSString *sign = [handler signString:befRSA];
    rsaParameter = @{@"data":base64Str,
                     @"sign":sign,
                     @"timestamp":timeString};

    return rsaParameter;
}

#pragma mark - 字典转josn
- (NSString *)dictToJsonStr:(NSDictionary *)dict{
    NSString *jsonString = nil;
    if([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(error) {
            DLog(@"Error:%@",error);
        }
    }
    return jsonString;
}



@end

