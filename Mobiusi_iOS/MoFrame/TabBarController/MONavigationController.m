
#import "MONavigationController.h"

@interface MONavigationController ()

//@property (nonatomic) BOOL tabBarIsShow;

@end

@implementation MONavigationController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navDelegate = self.interactivePopGestureRecognizer.delegate;
    self.interactivePopGestureRecognizer.delegate = nil;
    self.delegate = self;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return self.topViewController.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
	return self.topViewController.shouldAutorotate;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (self.needHideBar) {
//        if (self.viewControllers.count > 0) {
//            viewController.hidesBottomBarWhenPushed = YES;
//        }
//    } else {
//        if (self.viewControllers.count > 0) {
//            viewController.hidesBottomBarWhenPushed = NO;
//        }
//    }
    
    // push的时候隐藏tabbar
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end
