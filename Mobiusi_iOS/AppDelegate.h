//
//  AppDelegate.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/13.
//

#import <UIKit/UIKit.h>
#import "MOTransition.h"
#import <WechatOpenSDK/WXApi.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property(nonatomic,weak)UIViewController *homeVC;
@property (nonatomic, strong) MOTransition *transition;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic,weak)id<WXApiDelegate> wxApiDelegate;
-(void)uMPushSetAlias;
@end

