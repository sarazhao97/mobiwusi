//
//  MBProgressHUD+Add.h
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Add)
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showGetGold:(NSString *)string toView:(UIView *)view;
+ (void)showNotGetGold:(NSString *)string toView:(UIView *)view;

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view afterDelay:(NSTimeInterval)delay;

+ (MBProgressHUD *)showCycleLoadingMessag:(NSString *)message toView:(UIView *)view;
+ (BOOL)CycleLoadingSuccess:(NSString *)text ForView:(UIView *)view animated:(BOOL)animated;

@end
