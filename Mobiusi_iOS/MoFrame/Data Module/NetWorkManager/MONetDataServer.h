//
//  MONetDataServer.h
//  Translate
//
//  Created by 11 on 16/8/22.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "NetWorkManager.h"
#import "UrlHeader.h"
#import "MOBlockDef.h"

@interface MONetDataServer : NSObject

typedef void(^FileDownloadProgress) (CGFloat progress,CGFloat total,CGFloat current);

typedef void(^CompletionState) (BOOL state,NSString * message,NSString * filePath);

+ (MONetDataServer *)sharedMONetDataServer;

- (NSDictionary *)configRSAParameter:(NSDictionary *)para;
- (NSURLSessionDataTask *)PostWithUrl:(NSString *)url paraDict:(NSDictionary *)dict success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

#pragma mark - MOLoginVC 登录页面

///  获取验证码
/// - Parameters:
///   - mobile: 手机号
///   - sms_event  1：wap 登陆    2：pc登陆   3：app 登陆    4：注册    5: 忘记验证码
///   country_code 国家代号
///   - channel_type 验证码类型 0或不传：短信验证码 3：语音验证码
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)getVerifyCodeWithMobile:(NSString *)mobile
                      sms_event:(NSInteger)sms_event
                   country_code:(NSInteger)country_code
                    channel_type:(NSInteger)channel_type
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure
                            msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;


/// 登录接口
/// - Parameters:
///   - mobile: 收据号
///   - country_code: 国家代号
///   - code: 验证码
///   - account: 账号
///   - password: 密码
///   - checkType: 验证类型 1手机验证码 2手机密码 默认为1
///   - name: 昵称
///   - avatar: 头像
///   - sex: 性别  >= 0 起作用
///   - unionid: 微信 unionid
///   - openid: 微信openid
///   - sub: 苹果sub
///   - email: 邮箱
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail:
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
              loginFail:(MOBlock)loginFail;

///  注销用户
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)deleteUserSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


/// 注册账号
/// - Parameters:
///   - mobile: 电话号码
///   - code: 验证码
///   - password: 密码
///   - second_password: 再次输入的密码
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)registWithMobile:(NSString *)mobile
                    code:(NSString *)code
                password:(NSString *)password
         second_password:(NSString *)second_password
                 success:(MODictionaryBlock)success
                 failure:(MOErrorBlock)failure
                     msg:(MOStringBlock)msg
               loginFail:(MOBlock)loginFail;



/// 忘记密码
/// - Parameters:
///   - mobile: 电话号码
///   - code: 验证码
///   - password: 密码
///   - second_password: 再次输入的密码
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)resetPasswordWithMobile:(NSString *)mobile
                           code:(NSString *)code
                       password:(NSString *)password
                   country_code:(NSInteger)country_code
         second_password:(NSString *)second_password
                 success:(MOBoolBlock)success
                 failure:(MOErrorBlock)failure
                     msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;


/// 微信登录
/// - Parameters:
///   - code: 微信登录返回的code
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)weChatLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                        msg:(MOStringBlock)msg;


/// 支付宝登录
/// - Parameters:
///   - code: 微信登录返回的code
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)alipayLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                        msg:(MOStringBlock)msg;


/// 苹果登录
/// - Parameters:
///   - code: 苹果登录返回的标识
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
- (void)appleLoginWithCode:(NSString *)code
                    success:(MODictionaryBlock)success
                    failure:(MOErrorBlock)failure
                       msg:(MOStringBlock)msg;

- (void)getCountryCodeWithSuccess:(MOArrayBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg;

- (void)bindWeChatWithCode:(NSString *)wxAuthCode
                   vercode:(NSString *)vercode
                   Success:(MODictionaryBlock)success
                   failure:(MOErrorBlock)failure
                       msg:(MOStringBlock)msg
                 loginFail:(MOBlock)loginFail;

- (void)bindAliPayWithCode:(NSString *)alipayCode
                   vercode:(NSString *)vercode
                   Success:(MODictionaryBlock)success
                   failure:(MOErrorBlock)failure
                       msg:(MOStringBlock)msg
                 loginFail:(MOBlock)loginFail;

- (void)unbindThirdAccountWithAccountType:(NSInteger)account_type
                                  Success:(MODictionaryBlock)success
                                  failure:(MOErrorBlock)failure
                                      msg:(MOStringBlock)msg
                                loginFail:(MOBlock)loginFail;

- (void)bindAppleWithCode:(NSString *)authId
                  vercode:(NSString *)vercode
                  Success:(MODictionaryBlock)success
                  failure:(MOErrorBlock)failure
                      msg:(MOStringBlock)msg
                loginFail:(MOBlock)loginFail;

#pragma mark - MTHomeVC 首页

///  分类选项
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getCateOptionSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

///  个人资料
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserInfoSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

///  获取标签数据 已拥有
/// - Parameters:
///   - cate: 数据类型 0全部 1已获得 2未获得
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

///  获取标签数据（类型）未拥有  获取标签数据，按照标签分类维度返回数据
/// - Parameters:
///   - cate: 数据类型 0全部 1已获得 2未获得
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getWithoutUserTagWithCate:(NSInteger)cate success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

///  获取标签选项
/// - Parameters:
///   - type: 类型 1身份 2装备 3语言 4节日
///   - sub_type: 子类型 1001-国籍,1002-籍贯省份,1003-籍贯城市,1004-出生年代,1005-性别,1006-民族,1007-常驻城市,1008-星座,1009-身高,1010-体重,1011-宗教信仰,2001-手机,2002-电脑,2003-游戏机,2004-平板,2005-摄影,2006-无人机,2007-汽车,3001-母语,3002-方言,3003-外语,3004-计算机语言
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserTagOptionsWithType:(NSInteger)type sub_type:(NSInteger)sub_type success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

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

/// 任务详情
/// - Parameters:
///   - task_id: 任务ID
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getTaskDetailWithTaskId:(NSInteger)task_id
                   user_task_id:(NSInteger)user_task_id
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;

/// 我的任务
/// - Parameters:
///   - cate_id: 类别 1:音频 2：图片 3:音频 4：视频
///   - task_status:1: 进行中 2：待审核 3：未通过 4：初审通过 5：已完成
///   - page: page
///   - limit: limit
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getMyTaskListWithCate_id:(NSInteger)cate_id task_status:(NSInteger)task_status page:(NSInteger)page limit:(NSInteger)limit success:(MOArrayBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

/// 任务题目
/// - Parameters:
///   - task_id: 任务ID
///   - user_task_id: 用户任务ID
///   - task_status: 任务状态 1:进行中 2：待审核；3：未通过 4：已通过 5：已完成
///   - topic_type: 1: 试做题目 2：正式题目
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserTaskTopicWithTaskId:(NSInteger)task_id user_task_id:(NSInteger)user_task_id task_status:(NSInteger)task_status topic_type:(NSInteger)topic_type success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


/// 首页收入提醒
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getincomeTipWithSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


/// 领取任务
/// - Parameters:
///   - task_id: 任务ID
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)receiveATaskWithTaskid:(NSInteger)task_id lat:(double)lat lng:(double)lng success:(MOIndexBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

- (void)receiveATaskV2WithTaskid:(NSInteger)task_id lat:(double)lat lng:(double)lng success:(MOIndexBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;

/// 完成音频题目
/// - Parameters:
///   - task_id: 任务ID
///   - user_task_id: 用户任务ID
///   - result_id: 题目ID
///   - result: 题目结果
///   - duration: 时长
///   - audio_format: 音频格式
///   - audio_rate: 音频采样率
///   - file_name : 文件名称
///   - size: 音频大小
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
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
                            loginFail:(MOBlock)loginFail;

///  收益中心余额统计
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserBalanceCenterSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


/// 余额明细
/// - Parameters:
///   - month: 月份（例如：2024-08）
///   - page: 请求页
///   - limit: 显示条数
///   - type: 0余额明细
///   - get_type: 0全部 1收入 2支出
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserBalanceDetailsWithMonth:(NSString *)month
                                  page:(NSInteger)page
                                 limit:(NSInteger)limit
                                  type:(NSInteger)type
                              get_type:(NSInteger)get_type
                               success:(MODictionaryBlock)success
                               failure:(MOErrorBlock)failure
                                   msg:(MOStringBlock)msg
                             loginFail:(MOBlock)loginFail;



/// 申请提现
/// - Parameters:
///   - money: 提现金额
///   - bank_user_name: 收款人姓名
///   - bank_name: 银行名称
///   - bank_no: 银行卡号
///   - type: 0余额提现
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)userWithdrawalSaveWithMoney:(NSString *)money
                     bank_user_name:(NSString *)bank_user_name
                          bank_name:(NSString *)bank_name
                            bank_no:(NSString *)bank_no
                               type:(NSInteger)type
                    transferChannel:(NSInteger)transfer_channel
                            success:(MODictionaryBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail;



/// 提现记录
/// - Parameters:
///   - page: 请求页
///   - limit: 显示条数
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)userWithdrawaRecordWithPage:(NSInteger)page
                              limit:(NSInteger)limit
                            success:(MODictionaryBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail;
/// 我的数据
/// - Parameters:
///   - cate_id: 类别 1:音频 2：图片 3:音频 4：视频
///   - page: 分页索引
///   - limit: 每页大小
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getUserDataWithCate_id:(NSInteger)cate_id
				  user_task_id:(NSInteger)user_task_id
			  user_paste_board:(BOOL)user_paste_board
						  page:(NSInteger)page
						 limit:(NSInteger)limit
					   success:(MOArrayBlock)success
					   failure:(MOErrorBlock)failure
						   msg:(MOStringBlock)msg
					 loginFail:(MOBlock)loginFail;



/// 热搜
/// - Parameters:
///   - cate_id: 类别 1:音频 2：图片 3:音频 4：视频
///   - page: 分页索引
///   - limit: 每页大小
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getHotSearchListWithCate_id:(NSInteger)cate_id
                               page:(NSInteger)page
                              limit:(NSInteger)limit
                            success:(MOArrayBlock)success
                            failure:(MOErrorBlock)failure
                                msg:(MOStringBlock)msg
                          loginFail:(MOBlock)loginFail;


/// 搜索结果
/// - Parameters:
///   - keyword: 关键字
///   - limit: 条数限制
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getMultiSearchWithKeyword:(NSString *)keyword
                            limit:(NSInteger)limit
                          success:(MODictionaryBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                        loginFail:(MOBlock)loginFail;


/// 热搜数据点击上报
/// - Parameters:
///   - task_id: 任务ID
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)hostSearchAddClickWithTask_id:(NSInteger )task_id
                              success:(MOObjectBlock)success
                              failure:(MOErrorBlock)failure
                                  msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail;


/// 消息列表
/// - Parameters:
///   - data_id: DID
///   - page: 页码索引
///   - limit: 每页限制
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)getMessageListWithData_id:(NSInteger)data_id
						 dataCate:(NSInteger)dataCate
				 userTaskResultId:(NSInteger)user_task_result_id
							 page:(NSInteger)page
							limit:(NSInteger)limit
						  success:(MODictionaryBlock)success
						  failure:(MOErrorBlock)failure
							  msg:(MOStringBlock)msg
							loginFail:(MOBlock)loginFail;



/// 关注任务
/// - Parameters:
///   - task_id: 任务ID
///   - action: 1 关注  2 取消关注
///   - success: 请求成功回调
///   - failure: 求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)followTaskWithTaskId:(NSInteger)task_id
                      action:(NSInteger)action
                     success:(MOIndexBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail;

- (void)checkVersionWithAppType:(unsigned int)app_type
                          appId:(unsigned int)app_id
                         success:(MODictionaryBlock)success
                         failure:(MOErrorBlock)failure
                             msg:(MOStringBlock)msg
                       loginFail:(MOBlock)loginFail;

- (void)getlevelInfoWithSuccess:(MODictionaryBlock)success
                          failure:(MOErrorBlock)failure
                              msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;

- (void)signInWithDate:(NSString *)date
               Success:(MODictionaryBlock)success
               failure:(MOErrorBlock)failure
                   msg:(MOStringBlock)msg
             loginFail:(MOBlock)loginFail;

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
                   loginFail:(MOBlock)loginFail;

- (void)unlimitedUploadDataWithCateId:(NSInteger)cate_id
                                 idea:(nullable NSString *)idea
                             location:(nullable NSString *)location
                            user_data:(NSString *)user_data
                           content_id:(NSInteger)content_id
                         is_summarize:(BOOL)is_summarize
                              Success:(MOBlock)success
                              failure:(MOErrorBlock)failure
                                  msg:(MOStringBlock)msg
                            loginFail:(MOBlock)loginFail ;

-(void)parsePasteboardContentWithContent:(NSString *)content
                                 success:(MODictionaryBlock)success
                                 failure:(MOErrorBlock)failure
                                     msg:(MOStringBlock)msg
                               loginFail:(MOBlock)loginFail;

-(void)writePasteboardContentWithcontentId:(NSInteger)content_id isSummarize:(BOOL)is_summarize
                                   success:(MOBlock)success
                                   failure:(MOErrorBlock)failure
                                       msg:(MOStringBlock)msg
                                 loginFail:(MOBlock)loginFail;

-(void)getSummaryDetailWithCate:(NSInteger)cate
                       resultId:(NSInteger)result_id
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure
                            msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail;

- (void)annotationWithCateId:(NSInteger)cate_id
						 lat:(double)lat
						 lng:(double)lng
						page:(NSInteger)page
					   limit:(NSInteger)limit
					 success:(MOArrayBlock)success
					 failure:(MOErrorBlock)failure
						 msg:(MOStringBlock)msg
				   loginFail:(MOBlock)loginFail;

- (void)annotationCreateOrderWithCateId:(NSInteger)cate_id
								dataId:(NSInteger)data_id
								 taskId:(NSInteger)task_id
									lat:(double)lat
									lng:(double)lng
								success:(MOIndexBlock)success
								failure:(MOErrorBlock)failure
									msg:(MOStringBlock)msg
							  loginFail:(MOBlock)loginFail;

- (void)annotationDetailWithResultId:(NSInteger)result_id
						  metaDataId:(NSInteger)meta_data_id
							 success:(MODictionaryBlock)success
							 failure:(MOErrorBlock)failure
								 msg:(MOStringBlock)msg
						   loginFail:(MOBlock)loginFail;

- (void)annotationOrderListWithCateId:(NSInteger)cateId
								 page:(NSInteger)page
								limit:(NSInteger)limit
							  success:(MOArrayBlock)success
							  failure:(MOErrorBlock)failure
								  msg:(MOStringBlock)msg
							loginFail:(MOBlock)loginFail;

- (void)cateOptionProcessPropertyWithSuccess:(MOArrayBlock)success
									 failure:(MOErrorBlock)failure
										 msg:(MOStringBlock)msg
								   loginFail:(MOBlock)loginFail;

- (void)annotationSaveWithResultId:(NSInteger)result_id
						metaDataId:(NSInteger)meta_data_id
							status:(NSInteger)status
						 audioData:(NSString *)audio_data
						   success:(MOBlock)success
						   failure:(MOErrorBlock)failure
							   msg:(MOStringBlock)msg
						 loginFail:(MOBlock)loginFail;

- (void)speechToTextWithDataId:(NSInteger)data_id
					 startTime:(NSInteger)start_time
					   endTime:(NSInteger)end_time
					   success:(MOStringBlock)success
					   failure:(MOErrorBlock)failure
						   msg:(MOStringBlock)msg
					 loginFail:(MOBlock)loginFail;


- (void)deleteAudioAnnotationWithId:(NSInteger)segmentId
							success:(MOIndexBlock)success
							failure:(MOErrorBlock)failure
								msg:(MOStringBlock)msg
						  loginFail:(MOBlock)loginFail;

- (void)recycleTaskWithUserTaskId:(NSInteger)userTaskId
									success:(MOIndexBlock)success
									failure:(MOErrorBlock)failure
										msg:(MOStringBlock)msg
								  loginFail:(MOBlock)loginFail;

- (void)summaryExampleWithSuccess:(MODictionaryBlock)success
						  failure:(MOErrorBlock)failure
							  msg:(MOStringBlock)msg
						loginFail:(MOBlock)loginFail;

- (void)transPictureWithPath:(NSString *)path
                     success:(MODictionaryBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail;

- (void)transPictureWithPath:(NSString *)path
               parentPostID:(nullable NSString *)parentPostID
                     success:(MODictionaryBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail;

- (void)analysisFoodWithUrl:(NSString *)url
                     success:(MODictionaryBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail;

- (void)analysisFoodWithUrl:(NSString *)url
               parentPostID:(nullable NSString *)parentPostID
                     success:(MODictionaryBlock)success
                     failure:(MOErrorBlock)failure
                         msg:(MOStringBlock)msg
                   loginFail:(MOBlock)loginFail;

- (void)transPictureListWithPage:(NSInteger)page
						   limit:(NSInteger)limit
						 success:(MODictionaryBlock)success
						 failure:(MOErrorBlock)failure
							 msg:(MOStringBlock)msg
					   loginFail:(MOBlock)loginFail;

- (void)foodSafeHistoryListWithPage:(NSInteger)page
						   limit:(NSInteger)limit
						 success:(MODictionaryBlock)success
						 failure:(MOErrorBlock)failure
							 msg:(MOStringBlock)msg
					   loginFail:(MOBlock)loginFail;


#pragma mark - 个人中心

/// 修改个人信息
/// - Parameters:
///   - name: 昵称
///   - avatar: 头像相对路径
///   - sex: 性别
///   - mobile: 手机号
///   - describe: 个性签名
///   - native_city: 籍贯城市
///   - native_city_code: 籍贯城市编号
///   - native_province: 籍贯省份
///   - native_province_code: 籍贯省份编号
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)modifyUserInfoWithUserName:(NSString *)name avatar:(NSString *)avatar sex:(NSInteger)sex mobile:(NSString *)mobile describe:(NSString *)describe native_city:(NSString *)native_city native_city_code:(NSString *)native_city_code native_province:(NSString *)native_province native_province_code:(NSString *)native_province_code success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


/// 意见反馈
/// - Parameters:
///   - type: 意见反馈类型 见分类选项接口 feedback_type
///   - content: 内容
///   - contact_info: 联系方式
///   - detail_img: 附件图片
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (void)feedbackWithType:(NSInteger)type content:(NSString *)content contact_info:(NSString *)contact_info detail_img:(NSString *)detail_img success:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail;


#pragma mark - global requests

///  上传图片
/// - Parameters:
///   - image: 待上传图片，UIImage类型
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image success:(MODictionaryBlock)success failure:(MOErrorBlock)failure loginFail:(MOBlock)loginFail;

///  上传录音文件
/// - Parameters:
///   - fileName: 录音文件名
///   - filePath: 录音文件存储路径
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (NSURLSessionDataTask *)uploadAudioFileWithFileName:(NSString *)fileName filePath:(NSString *)filePath success:(MODictionaryBlock)success failure:(MOErrorBlock)failure loginFail:(MOBlock)loginFail;


///  上传文本文件
/// - Parameters:
///   - fileName: 文本文件名
///   - fileData: 录音文件二进制流
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
- (NSURLSessionDataTask *)uploadFileWithFileName:(NSString *)fileName
                                        fileData:(NSData *)fileData
                                        mimeType:(NSString *)mimeType
                                         success:(MODictionaryBlock)success
                                         failure:(MOErrorBlock)failure
                                       loginFail:(MOBlock)loginFail;

@end



