//
//  MOTransition.m
//  MT
//
//  Created by x11 on 2023/8/16.
//  Copyright © 2023年 db. All rights reserved.
//

#import "MOTransition.h"
#import "MONavigationController.h"
#import "Mobiusi_iOS-Swift.h"

@implementation MOTransition

SINGLETON_GCD(MOTransition)

- (void)enterLoginUI {
    
}

- (void)enterMainUI {
    UITabBarController *tabBarController = [MBMainTabBarWrapper createMainTabBarController];
    MOAppDelegate.window.rootViewController = tabBarController;
}

-(NSInteger)navigationVCViewControllersCount{
	UINavigationController *navVC =  [self navigationViewController];
	return  navVC.viewControllers.count;
}

-(NSArray<UIViewController *> *)navigationChildViewControllers {
	UINavigationController *navVC =  [self navigationViewController];
	return  navVC.viewControllers;
}

-(void)insertVC:(UIViewController *)viewController index:(NSInteger)index {
	UINavigationController *navVC =  [self navigationViewController];
	NSMutableArray *vcs = [navVC.viewControllers mutableCopy];
	[vcs insertObject:viewController atIndex:index];
	navVC.viewControllers = vcs;
	
}

// 获取当前活动的navigationcontroller
- (UINavigationController *)navigationViewController {
    
    UIViewController *rootViewController = MOAppDelegate.window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectVc = [((UITabBarController *)rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (UIViewController *)topViewController {
    UINavigationController *nav = [self navigationViewController];
    return nav.visibleViewController;
}

// 获取当前可呈现的顶层视图控制器（沿着 presentedViewController 链）
- (UIViewController *)currentPresentingViewController {
    UIViewController *vc = MOAppDelegate.window.rootViewController;
    if (!vc) { return nil; }
    
    // 沿着模态链查找最顶层
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    // 如果是 TabBar，选择当前选中的
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        UIViewController *selected = tab.selectedViewController ?: vc;
        vc = selected;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
    }
    
    // 如果是导航，返回可见的控制器
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)vc).visibleViewController;
    }
    return vc;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([viewController isKindOfClass:NSClassFromString(@"MTHomeVC")]) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).homeVC = viewController;
    }
    @autoreleasepool {
        
        [[self navigationViewController] pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [[self navigationViewController] popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [[self navigationViewController] popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [[self navigationViewController] popToViewController:viewController animated:animated];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *top = [self currentPresentingViewController] ?: MOAppDelegate.window.rootViewController;
    if (!top.view.window) {
        // 若顶层不在窗口层级，回退到根
        top = MOAppDelegate.window.rootViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        [top presentViewController:vc animated:animated completion:completion];
    } else if (vc.navigationController == nil) {
        MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [top presentViewController:nav animated:animated completion:completion];
    } else {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)presentViewControllerWithAlertStyle:(UIViewController *)vc  animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *top = [self currentPresentingViewController] ?: MOAppDelegate.window.rootViewController;
    if (!top.view.window) {
        top = MOAppDelegate.window.rootViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [top presentViewController:vc animated:animated completion:completion];
    } else if (vc.navigationController == nil) {
        MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [top presentViewController:nav animated:animated completion:completion];
    } else {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion {
    if (vc.navigationController != self.navigationViewController) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    } else {
        [vc.navigationController popViewControllerAnimated:YES];
    }
}

@end
