//
//  MOTransition.h
//  MT
//
//  Created by x11 on 2023/8/16.
//  Copyright © 2023年 db. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOTransition : NSObject

+ (MOTransition *)sharedMOTransition;

//进入登录界面
- (void)enterLoginUI;

// 进入主界面逻辑
- (void)enterMainUI;
-(NSInteger)navigationVCViewControllersCount;
-(NSArray<UIViewController *> *)navigationChildViewControllers;
-(void)insertVC:(UIViewController *)viewController index:(NSInteger)index;

// 代码中尽量改用以下方式去push/pop/present界面
- (UINavigationController *)navigationViewController;

- (UIViewController *)topViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)presentViewControllerWithAlertStyle:(UIViewController *)vc  animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

@end
