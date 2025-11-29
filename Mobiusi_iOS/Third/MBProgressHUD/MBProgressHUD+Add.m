//
//  MBProgressHUD+Add.m
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+Add.h"

@implementation MBProgressHUD (Add)

// 安全获取用于展示 HUD 的视图/窗口（兼容多场景）
static inline UIView *MBHUDSafeView(UIView *view) {
    if (view) { return view; }
    UIWindow *targetWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) { continue; }
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *win in ws.windows) {
                    if (win.isKeyWindow) { targetWindow = win; break; }
                }
                if (!targetWindow) { targetWindow = ws.windows.firstObject; }
                break;
            }
        }
    }
    if (!targetWindow) {
        targetWindow = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    }
    return targetWindow ?: nil;
}

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return; }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:safeView animated:YES];
    if (text.isExist) {
        hud.labelText = text;
    }
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return; }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:safeView animated:YES];
    if (text.isExist) {
        hud.labelText = text;
    }
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view afterDelay:1.2];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

+ (void)showGetGold:(NSString *)string toView:(UIView *)view
{
    [self show:string icon:@"mbp_hud_dou.png" view:view afterDelay:1.2];
}

+ (void)showNotGetGold:(NSString *)string toView:(UIView *)view
{
    [self show:string icon:@"mbp_hud_no_pass.png" view:view afterDelay:1.2];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view {
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return nil; }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:safeView animated:YES];
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:0.7];
    return hud;
}

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return nil; }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:safeView animated:YES];
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:delay];
    return hud;
}

+ (MBProgressHUD *)showCycleLoadingMessag:(NSString *)message toView:(UIView *)view {
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return nil; }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:safeView animated:YES];
    if (message.isExist) {
        hud.labelText = message;
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.userInteractionEnabled = YES;
    return hud;
}

+ (BOOL)CycleLoadingSuccess:(NSString *)text ForView:(UIView *)view animated:(BOOL)animated {
    UIView *safeView = MBHUDSafeView(view);
    if (!safeView) { NSLog(@"[MBProgressHUD+Add] No valid view/window to show HUD."); return NO; }
    MBProgressHUD *hud = [self HUDForView:safeView];
    if (hud != nil) {
        hud.labelText = text;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", @"success.png"]]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:0.7];
        return YES;
    }
    return NO;
}

@end
