//
//  AppDelegate.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/13.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <UMPush/UMessage.h>
#import <UMCommon/UMCommon.h>
#import <UMPush/UMPush.h>
#import "MONotificationCustomDataModel.h"
#import "MOTaskDetailVC.h"
#import "MOPrivacyPolicyTipsAlertVC.h"
#import <AFServiceSDK/AFServiceSDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "Mobiusi_iOS-Swift.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate, QQApiInterfaceDelegate, WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL agree = [defaults boolForKey:@"PrivacyPolicyTipsVer1.0Sate"];
    WEAKSELF
    if (!agree) {
        
        MOPrivacyPolicyTipsAlertVC *privacyPolicyTipVC = [MOPrivacyPolicyTipsAlertVC new];
        MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:privacyPolicyTipVC];
        privacyPolicyTipVC.resultCallBack = ^(BOOL agree,MOPrivacyPolicyTipsAlertVC *vc) {
            [defaults setBool:agree forKey:@"PrivacyPolicyTipsVer1.0Sate"];
            if (agree) {
				[weakSelf appLogicWithOptions:launchOptions];
                
            }else {
                exit(0);
            }
        };
        self.window.rootViewController = nav;
        return YES;
    }
    [self appLogicWithOptions:launchOptions];
	[self applicationWillEnterForeground:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    if (!user) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str =  [UIPasteboard generalPasteboard].string;
//		[str.lowercaseString containsString:@"https:"] || [str.lowercaseString containsString:@"http:"]
        if ([str.lowercaseString containsString:@"https:"] || [str.lowercaseString containsString:@"http:"]) {
            [UIPasteboard generalPasteboard].string = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MOCheckedPasteboardLinkVC *vc= [MOCheckedPasteboardLinkVC createAlertStyleWithLinkStr:str];
                WEAKSELF
                vc.didClickRecognitionBtn = ^{
                };
                DLog("topViewController :%@",MOAppDelegate.transition.topViewController);
                UIViewController *topViewController = MOAppDelegate.transition.topViewController;
                if (![topViewController isKindOfClass:[MOCheckedPasteboardLinkVC class]]) {
                    [MOAppDelegate.transition.topViewController presentViewController:vc animated:YES completion:NULL];
                }
            });
            
        }
    });
    
    
}

-(void)appLogicWithOptions:(NSDictionary *)launchOptions{
	
	[CATransaction begin];
	
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOLoginVC"];
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    
    // 已登陆直接跳转主页
    if (user) {
        // 使用Swift创建的TabBar控制器作为根视图控制器
        UITabBarController *tabBarController = [MBMainTabBarWrapper createMainTabBarController];
        self.homeVC = tabBarController;
        self.window.rootViewController = tabBarController;
    } else {
        // 未登录显示登录页面
        MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = nav;
    }
    [self.window makeKeyAndVisible];
    
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].shouldToolbarUsesTextFieldTintColor = YES;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 20;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    // QQ SDK 隐私同意与版本打印
    BOOL qqAgree = [[NSUserDefaults standardUserDefaults] boolForKey:@"PrivacyPolicyTipsVer1.0Sate"];
    [TencentOAuth setIsUserAgreedAuthorization:qqAgree];
    DLog("QQOpenSDK 版本：%@", [TencentOAuth sdkVersion]);
    // 检测 QQ 资源包是否存在（新/旧命名均支持）
    NSString *qqBundleIOS = [[NSBundle mainBundle] pathForResource:@"TencentOpenApi_IOS_Bundle" ofType:@"bundle"];
    NSString *qqBundleLegacy = [[NSBundle mainBundle] pathForResource:@"TencentOpenApi_Bundle" ofType:@"bundle"];
    DLog("QQOpenSDK 资源包：%@", qqBundleIOS ?: qqBundleLegacy ?: @"未找到（需添加到 Copy Bundle Resources）");
    
    [CATransaction setCompletionBlock:^{
        [self configUPushWithLaunchOptions:launchOptions];
        DLog("WeChatSDK 版本：%@",[WXApi getApiVersion]);
//		[WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
//			NSLog(@"WeChatSDK: %@", log);
//		}];
		[WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
			NSLog(@"WeChatSDK: %@", log);
		}];
		BOOL universalLinkEnable =  [WXApi registerApp:WX_APP_ID universalLink:UNIVERSAL_LINK];
		DLog("universalLinkEnable:%d",universalLinkEnable)
		if (user) {
			[self uMPushSetAlias];
		}
	}];
	
	[CATransaction commit];
    
}



-(void)uMPushSetAlias {
    
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    if (user && self.deviceToken) {
        NSString *userAlias = [NSString stringWithFormat:@"user_%@",user.modelId];
        [UMessage setAlias:userAlias type:@"user" response:^(id  _Nullable responseObject, NSError * _Nullable error) {
            
            DLog(@"%@",responseObject);
        }];
    }
    
}

-(void)configUPushWithLaunchOptions:(NSDictionary *)launchOptions {
    
    [UMConfigure setLogEnabled:YES];
    NSString *channel = @"App Store";
#if DEBUG
    channel = @"test";
#endif
    [UMConfigure initWithAppkey:@"67c7ff06b675b11708d22cc5" channel:@"App Store"];
    
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else
        {
        }
    }];
    [UMessage openDebugMode:NO];
    [UMessage setWebViewClassString:@"UMWebViewController"];
    [UMessage addLaunchMessage];
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {
    // 可按需处理 QQ 的请求
}

- (void)onResp:(QQBaseResp *)resp {
    // 处理 QQ 分享结果回调（result == @"0" 成功）
    NSString *result = [resp.result isKindOfClass:[NSString class]] ? resp.result : nil;
    NSString *msg = [result isEqualToString:@"0"] ? @"分享成功" : [NSString stringWithFormat:@"分享失败(%@)", result ?: @"未知错误"];
    [MBProgressHUD showMessag:msg toView:MOAppDelegate.window];
}

// QQ 在线状态回调（可忽略）
- (void)isOnlineResponse:(NSDictionary *)response {
}

#pragma mark ----远程通知(推送)回调
//[ 系统回调 ] 远程通知注册成功回调，获取DeviceToken成功





- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // 先尝试交给 QQ 处理
    if ([QQApiInterface handleOpenURL:url delegate:self]) {
        return YES;
    }
    // 再交给微信处理
    return [WXApi handleOpenURL:url delegate:(self.wxApiDelegate ?: self)];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.host isEqualToString: @"apmqpdispatch"]) {
        [AFServiceCenter handleResponseURL:url withCompletion:^(AFAuthServiceResponse *response) {
            
        }];
    }
    // 先尝试交给 QQ 处理
    if ([QQApiInterface handleOpenURL:url delegate:self]) {
        return YES;
    }
    // 再交给微信处理
    if ([url.scheme isEqualToString: WX_APP_ID]) {
        BOOL result = [WXApi handleOpenURL:url delegate:(MOAppDelegate.wxApiDelegate ?: MOAppDelegate)];
        return result;
    }
    // 其他业务处理
    MOUserModel *user = [MOUserModel unarchiveUserModel];
    if ([url.scheme isEqualToString: @"mobisuwishare"] && user) {
        [UIPasteboard generalPasteboard].string = nil;
        NSURLComponents *componets = [[NSURLComponents alloc] initWithString:url.absoluteString];
        NSString *dataStr = nil;
        NSInteger type = 0;
        for (NSURLQueryItem *item in componets.queryItems) {
            if ([item.name isEqualToString:@"data"]) {
                dataStr = item.value;
            }
            if ([item.name isEqualToString:@"type"]) {
                type = item.value.integerValue;
            }
        }
        NSData *data = [[NSData alloc] initWithBase64Encoding:dataStr];
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        MOLinkRecognitionVC *govc = [[MOLinkRecognitionVC alloc] initWithLinkStr:text fromPasteboard:NO needToInput:NO];
        [MOAppDelegate.transition pushViewController:govc animated:YES];
    }
    return YES;
}

- (void)openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options completionHandler:(void (^ __nullable NS_SWIFT_UI_ACTOR)(BOOL success))completion {
    // QQ 普通 scheme 回调处理
    if ([QQApiInterface handleOpenURL:url delegate:self]) {
        if (completion) completion(YES);
        return;
    }
    // 微信回调处理
    [WXApi handleOpenURL:url delegate:(self.wxApiDelegate ?: self)];
}





-(BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    // QQ Universal Link 回调处理（如果启用 UL）
    if ([TencentOAuth CanHandleUniversalLink:userActivity.webpageURL]) {
        BOOL handled = [QQApiInterface handleOpenUniversallink:userActivity.webpageURL delegate:self];
        if (handled) { return YES; }
    }
    return [WXApi handleOpenUniversalLink:userActivity delegate:(self.wxApiDelegate ?: self)];
}







//iOS10新增：处理后台点击通知的代理方法





#pragma mark ----远程通知(推送)回调
//[ 系统回调 ] 远程通知注册成功回调，获取DeviceToken成功


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    NSUInteger len = [deviceToken length];
    char *chars = (char *) [deviceToken bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    NSString *token = hexString;
    DLog(@"%s token :%@",__func__,token);
    self.deviceToken = token;
    [self uMPushSetAlias];
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"%s===%@",__func__,error.localizedDescription);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:NO];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
        
        DLog(@"%s userInfo:%@",__func__,userInfo);
        completionHandler(UIBackgroundFetchResultNewData);
    }
}














#pragma mark UNUserNotificationCenterDelegate
//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        DLog(@"%s userInfo:%@",__func__,userInfo);
        NSLog(@"userInfo:%@",userInfo);
        MONotificationUserInfoModel *pushDataModel = [MONotificationUserInfoModel yy_modelWithJSON:userInfo];
        MONotificationCustomDataModel *custom = [MONotificationCustomDataModel yy_modelWithJSON:pushDataModel.custom];
        if (custom.is_dialog) {
            
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:pushDataModel.aps.alert.title message:pushDataModel.aps.alert.body preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVc addAction:action];
            [self.window.rootViewController presentViewController:alertVc animated:NO completion:NULL];
            //当应用处于前台时提示设置，需要哪个可以设置哪一个
            completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
            return;
        }
        //当应用处于前台时提示设置，需要哪个可以设置哪一个
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
        
        return;
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
   
}

//iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    DLog(@"%s userInfo:%@",__func__,userInfo);
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        MONotificationUserInfoModel *pushDataModel = [MONotificationUserInfoModel yy_modelWithJSON:userInfo];
        MONotificationCustomDataModel *custom = [MONotificationCustomDataModel yy_modelWithJSON:pushDataModel.custom];
        if (!custom.is_dialog) {
            if (custom.type_id == 11) {
				UIViewController *tmpVC = nil;
				for (UIViewController *vc in [MOAppDelegate.transition navigationChildViewControllers]) {
					if ([vc isKindOfClass:[MOSummarizeSampleVC class]]) {
						tmpVC = vc;
					}
				}
				if (tmpVC) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SummarizeSampleNeedRefresh" object:nil];
					[MOAppDelegate.transition popToViewController:tmpVC animated:YES];
					return;
				}
				MOSummarizeSampleVC *vc = [MOSummarizeSampleVC new];
                [MOAppDelegate.transition pushViewController:vc animated:YES];
                return;
            }
            MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:custom.task_id userTaskId:custom.relate_id];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
        }
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
    completionHandler();
}



- (MOTransition *)transition {
    if (_transition == nil) {
        _transition = [MOTransition sharedMOTransition];
    }
    return _transition;
}

@end

@implementation AppDelegate (WeChatDelegate)
#pragma mark - WeChat WXApiDelegate
- (void)onReq:(BaseReq *)req {
    if (self.wxApiDelegate && [self.wxApiDelegate respondsToSelector:@selector(onReq:)]) {
        [self.wxApiDelegate onReq:req];
        return;
    }
    // 默认无需处理
}

- (void)onResp:(BaseResp *)resp {
    if (self.wxApiDelegate && [self.wxApiDelegate respondsToSelector:@selector(onResp:)]) {
        [self.wxApiDelegate onResp:resp];
        return;
    }
    NSString *msg = (resp.errCode == WXSuccess) ? @"操作成功" : [NSString stringWithFormat:@"操作失败(%d)", resp.errCode];
    [MBProgressHUD showMessag:msg toView:MOAppDelegate.window];
}
@end
