//
//  MOTabBarViewController.m
//  ItcastWeibo
//
//  Created by apple on 14-5-5.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MOTabBarViewController.h"
#import "MONavigationController.h"

@interface MOTabBarViewController () <MOTabBarDelegate,UINavigationControllerDelegate>
@end

@implementation MOTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化tabbar
    [self setupTabbar];
    // 初始化所有的子控制器
    [self setupAllChildViewControllers];
    //是否显示红点
//    [self.customTabBar addRedPointWithTabBarButton:3];

    self.selectedIndex = 0;
    MOTabBarButton *button = [self.customTabBar getCustomTabBarButton:0];
    button.selected = YES;
    self.customTabBar.selectedButton = button;

}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillLayoutSubviews {
    for (UIView *view in self.tabBar.subviews) {
        if (![view isKindOfClass:[MOTabBar class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 删除系统自动生成的UITabBarButton
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    
    MOTabBarButton* button = [self.customTabBar getCustomTabBarButton:(int)selectedIndex];
    // 2.设置按钮的状态
    self.customTabBar.selectedButton.selected = NO;
    self.customTabBar.selectedButton = button;
}

/**
 *  初始化tabbar
 */
- (void)setupTabbar
{
    MOTabBar *customTabBar = [[MOTabBar alloc] init];
    customTabBar.frame = CGRectMake(0, 0, self.tabBar.bounds.size.width, TABBAR_HEIGHT);
    customTabBar.delegate = self;
    [self.tabBar addSubview:customTabBar];
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.customTabBar = customTabBar;
    
    //去掉tabBar的线
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
}

/**
 *  监听tabbar按钮的改变
 *  @param from   原来选中的位置
 *  @param to     最新选中的位置
 */
- (void)tabBar:(MOTabBar *)tabBar didSelectedButtonFrom:(int)from to:(int)to
{
    self.selectedIndex = to;
}



/**
 *  初始化所有的子控制器
 */
- (void)setupAllChildViewControllers
{
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MTHomeVC *homeVC = [storyBoard instantiateViewControllerWithIdentifier:@"MTHomeVC"];
//    [self setupChildViewController:homeVC title:@"首页" imageName:@"icon_tab_home_n" selectedImageName:@"icon_tab_home_s" andNeedHideBar:YES];
//
//    MTCameraTransVC *cameraVC = [storyBoard instantiateViewControllerWithIdentifier:@"MTCameraTransVC"];
//    [self setupChildViewController:cameraVC title:@"拍照" imageName:@"icon_tab_carema_n" selectedImageName:@"icon_tab_carema_n" andNeedHideBar:YES];
//    
//    MTVoiceTransVC *voiceVC = [storyBoard instantiateViewControllerWithIdentifier:@"MTVoiceTransVC"];
//    [self setupChildViewController:voiceVC title:@"对话翻译" imageName:@"icon_tab_voice_n" selectedImageName:@"icon_tab_voice_s" andNeedHideBar:YES];
//
//    MTFavVC *favVC = [storyBoard instantiateViewControllerWithIdentifier:@"MTFavVC"];
//    [self setupChildViewController:favVC title:@"收藏" imageName:@"icon_tab_fav_n" selectedImageName:@"icon_tab_fav_s" andNeedHideBar:YES];
    
}
                                                                           
/**
 *  初始化一个子控制器
 *
 *  @param childVc           需要初始化的子控制器
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中的图标
 *  @param needHide 导航条push的时候是否需要隐藏Tabbar
 */
- (void)setupChildViewController:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName andNeedHideBar:(BOOL)needHide
{
    // 1.设置控制器的属性
    
    childVc.title = title;
    
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    childVc.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 2.包装一个导航控制器
    MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:childVc];
//    nav.needHideBar = needHide;
    
//    if ([childVc isKindOfClass:[MTNewsMainController class]]) {
//        UINavigationBar *navBar = nav.navigationBar;
//        [navBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//        //线条颜色
//        [navBar setShadowImage:[UIImage imageWithColor:FYLINE_COLOR_E]];
//    }

    [self addChildViewController:nav];
    
    // 3.添加tabbar内部的按钮
    [self.customTabBar addTabBarButtonWithItem:childVc.tabBarItem];
}

- (void)HideTabarView:(BOOL)isHideen animated:(BOOL)animated{
    self.isDown = isHideen;
    if (isHideen) {
        if (animated) {
            [UIView animateWithDuration:0.35 animations:^{
                CGRect tabFrame = self.tabBar.frame;
                tabFrame.origin.y = SCREEN_HEIGHT;
                self.tabBar.frame = tabFrame;
            } completion:^(BOOL finished) { }];
        } else {
            CGRect tabFrame = self.tabBar.frame;
            tabFrame.origin.y = SCREEN_HEIGHT;
            self.tabBar.frame = tabFrame;
        }
    } else {
        if (animated) {
            
            [UIView animateWithDuration:0.35 animations:^{
                CGRect tabFrame = self.tabBar.frame;
                tabFrame.origin.y = SCREEN_HEIGHT - TABBAR_HEIGHT;
                self.tabBar.frame = tabFrame;
            } completion:^(BOOL finished) { }];
            
        } else {
            CGRect tabFrame = self.tabBar.frame;
            tabFrame.origin.y = SCREEN_HEIGHT - TABBAR_HEIGHT;
            self.tabBar.frame = tabFrame;
        }
    }
}

- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                window = temp;
                break;
            }
        }
    }
    //取当前展示的控制器
    result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    //如果为UITabBarController：取选中控制器
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    //如果为UINavigationController：取可视控制器
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result visibleViewController];
    }
    return result;
}

@end
