//
//  MOHomeVM.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOViewModel.h"
#import "MoIncomeTipModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeVM : MOViewModel

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



/// 首页收入提醒
/// - Parameters:
///   - success: 请求成功回调
///   - failure: 请求失败回调
///   - msg: 返回错误信息回调
///   - loginFail: 登录异常回调
+(void)getincomeTipWithSuccess:(nonnull MOObjectBlock)success failure:(nullable MOErrorBlock)failure msg:(nullable MOStringBlock)msg loginFail:(nullable MOBlock)loginFail;

@end

NS_ASSUME_NONNULL_END
