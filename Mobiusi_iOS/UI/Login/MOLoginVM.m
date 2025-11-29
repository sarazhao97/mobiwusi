//
//  MOLoginVM.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOLoginVM.h"

@implementation MOLoginVM

- (void)getVerifyCodeWithMobile:(NSString *)mobile
                      sms_event:(NSInteger)sms_event
                   country_code:(NSInteger)country_code
                    channel_type:(NSInteger)channel_type
                        success:(MODictionaryBlock)success
                        failure:(MOErrorBlock)failure
                            msg:(MOStringBlock)msg
                      loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getVerifyCodeWithMobile:mobile sms_event:sms_event country_code:country_code channel_type:channel_type success:^(NSDictionary *dic) {
        success(dic);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


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
///   
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
    
    
    [[MONetDataServer sharedMONetDataServer] loginWithMobile:mobile country_code:country_code code:code account:account password:password checkType:checkType name:name avatar:avatar sex:sex unionid:unionid openid:openid sub:sub email:email alipay_openid:alipay_openid success:^(NSDictionary *dic) {
        
        MOUserModel *user = [MOUserModel yy_modelWithJSON:dic];
        [user archivedUserModel];
        
        // 调试信息：打印保存的用户信息
        NSLog(@"登录成功，用户信息已保存:");
        NSLog(@"用户ID: %@", user.modelId);
        NSLog(@"用户名: %@", user.name);
        NSLog(@"手机号: %@", user.mobile);
        NSLog(@"Token: %@", user.token);
        NSLog(@"完整数据: %@", dic);
        
        success(dic);
        
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
    
}


@end
