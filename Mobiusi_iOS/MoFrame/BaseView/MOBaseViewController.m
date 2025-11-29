//
//  MOBaseViewController.m
//  LW_Translate
//
//  Created by x11 on 2023/9/16.
//

#import "MOBaseViewController.h"
#import "MRActivityIndicatorView.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "MOWebViewController.h"

@interface MOBaseViewController ()

@property (nonatomic, strong) UIBarButtonItem *barBackItem;
@property (nonatomic, strong) MRActivityIndicatorView * activityIndicatorView;   //地点转圈指示器

@end

@implementation MOBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 检查navigationController是否为MONavigationController类型
    if ([self.navigationController isKindOfClass:[MONavigationController class]]) {
        MONavigationController *nav = (MONavigationController *)self.navigationController;
        nav.interactivePopGestureRecognizer.enabled = NO;
        nav.interactivePopGestureRecognizer.delegate = nav.navDelegate;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
    self.navigationController.navigationBar.translucent = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    if (@available(iOS 13.0, *)) {
        // 避免导航栏滚动时变色
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.shadowColor = nil;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
    self.fd_prefersNavigationBarHidden = YES;
    
    // 改换titile样式
    self.navigationItem.titleView = self.titleLabel;
    // 改换backButton样式
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = self.barBackItem;
    }
    //
    //    [self.view addSubview:self.topBgImageView];
    //    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.top.right.equalTo(self.view);
    //        make.height.mas_equalTo(SCREEN_WIDTH*0.456);
    //    }];
    
    
    //    self.navigationItem.leftBarButtonItem = self.barBackItem;
    
    //    [self.view addSubview:self.titleLabel];
    //    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.view);
    //        make.height.mas_equalTo(44);
    //        make.top.equalTo(self.view).mas_offset(STATUS_BAR_HEIGHT);
    //    }];
    
}

// 设置右边的按钮
- (void)setRightItemBtn:(UIButton *)rightItemBtn {
    _rightItemBtn = rightItemBtn;
    
    [self.view addSubview:rightItemBtn];
    [rightItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-16);
        make.centerY.equalTo(self.titleLabel);
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)goBack {
    [MOAppDelegate.transition popViewControllerAnimated:YES];
}

- (void)putKeyboardAway {
    [self.view endEditing:YES];
}


- (void)showActivityIndicator {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD show];
    
}

- (void)showAllowUserInteractionsActivityIndicator {
	
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
	[SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
	[SVProgressHUD show];
	
}


-(void)showMessage:(NSString *)msg {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD dismissWithDelay:1.5];
    [SVProgressHUD showInfoWithStatus:msg];
}
-(void)showErrorMessage:(nullable NSString *)msg {
    
	[self showErrorMessage:msg image:nil];
}

-(void)showErrorMessage:(nullable NSString *)msg image:(nullable UIImage *)image{
	
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
	[SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
	[SVProgressHUD dismissWithDelay:1.5];
	[SVProgressHUD setErrorImage:image];
	[SVProgressHUD setImageViewSize:CGSizeMake(image.size.width, image.size.height)];
	[SVProgressHUD setShouldTintImages:NO];
	[SVProgressHUD showErrorWithStatus:msg];
}


-(void)showProgressWithMessage:(NSString *)msg {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD dismissWithDelay:1.5];
    [SVProgressHUD showWithStatus:msg];
}


- (void)hidenActivityIndicator {
    //    [self.activityIndicatorView stopAnimating];
    //    [self.activityIndicatorView removeFromSuperview];
    [SVProgressHUD dismiss];
    
}

/** 修改当前UIViewController的状态栏颜色 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent; // 白色状态栏
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

+(void)pushServiceAgreementWebVC {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
    MOWebViewController *webviewController = (MOWebViewController *)targetVC;
    webviewController.webTitle = NSLocalizedString(@"用户协议", nil);
    webviewController.webTitleLabel.text = NSLocalizedString(@"用户协议", nil);
    webviewController.url = service_agreements;
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

+(void)pushPrivacyAgreementWebVC {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
    MOWebViewController *webviewController = (MOWebViewController *)targetVC;
    webviewController.webTitle = NSLocalizedString(@"隐私政策", nil);
    webviewController.webTitleLabel.text = NSLocalizedString(@"隐私政策", nil);
    webviewController.url = privacy_agreements;
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

+(void)pushPointsRuleWebVC {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
    MOWebViewController *webviewController = (MOWebViewController *)targetVC;
    webviewController.webTitle = NSLocalizedString(@"积分规则", nil);
    webviewController.webTitleLabel.text = NSLocalizedString(@"积分规则", nil);
    webviewController.url = points_rule;
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

+(void)pushWebVCWithUrl:(NSString *)url title:(NSString *)title {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
    MOWebViewController *webviewController = (MOWebViewController *)targetVC;
    webviewController.webTitle = title;
    webviewController.webTitleLabel.text = title;
    webviewController.url = url;
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

-(BOOL)shouldAutorotate {
	
	return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
	
	return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}


#pragma mark - getter setter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#01070D"];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIBarButtonItem *)barBackItem {
    if (_barBackItem == nil) {
        UIImage *image = [[UIImage imageNamedNoCache:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _barBackItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
    return _barBackItem;
}

- (MRActivityIndicatorView *)activityIndicatorView {
    //定位旋转
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[MRActivityIndicatorView alloc]init];
        _activityIndicatorView.frame = CGRectMake(0, 0, 22, 22);
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
        _activityIndicatorView.lineWidth = 2.0f;
        _activityIndicatorView.tintColor = [UIColor colorWithHexString:@"#3BBEFE"];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (void)dealloc {
    DLog(@"%@ ----> dealloc", [self class]);
}

@end
