//
//  MOLoginVM.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOLoginVM : MOViewModel

///  获取验证码
/// - Parameters:
///   - mobile: 手机号
///   - sms_event: 事件类型
///   - country_code: 国家代号
///   - channel_type: 验证码类型 0或不传：短信验证码 1：语音验证码
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

///  登录接口
/// - Parameters:
///   - mobile:  电话号码
///   - code:    验证码
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
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

@end

NS_ASSUME_NONNULL_END
