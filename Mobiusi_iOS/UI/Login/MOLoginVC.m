//
//  MOLoginVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/20.
//

#import "MOLoginVC.h"
#import "MOLoginVM.h"
#import "MOWebViewController.h"
#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorImageView.h"
#import "JXCategoryListContainerView.h"
#import "MORegisterVC.h"
#import "MOForgotPasswordVC.h"
#import <WechatOpenSDK/WXApi.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import <AFServiceSDK/AFServiceSDK.h>
#import "MOAliPayLoginAuthModel.h"



#import "MOLoginBottomView.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOLoginVC ()<JXCategoryViewDelegate,ASAuthorizationControllerDelegate,WXApiDelegate,ASAuthorizationControllerPresentationContextProviding>

@property (weak, nonatomic) IBOutlet UITextField *phoneTf;

@property (weak, nonatomic) IBOutlet UITextField *codeTf;

@property (weak, nonatomic) IBOutlet UIButton *verifyCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *agreementBtn;

@property (nonatomic, strong) YYLabel *agreementLabel;

@property (weak, nonatomic) IBOutlet UILabel *cdLabel;

@property (nonatomic, strong) MOLoginVM *viewModel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int cd;

@property (weak, nonatomic) IBOutlet UIView *segmentBgView;

@property (weak, nonatomic) IBOutlet UIView *codeView;

@property (weak, nonatomic) IBOutlet UIView *pswView;
@property (weak, nonatomic) IBOutlet UITextField *pswTf;
@property (weak, nonatomic) IBOutlet UIButton *eyeButton;


@property (nonatomic, strong) JXCategoryTitleView *taskCatView;
//  1手机验证码 2手机密码 默认为1
@property (nonatomic, assign) NSInteger verifyType;

@property (nonatomic, strong) YYLabel *goReginsterVCLabel;
@property (nonatomic, strong) MOButton *forgotPwdBtn;
@property (nonatomic, strong) YYLabel *voiceVerifyCodeLabel;

@property(nonatomic,strong)UILabel *bottomLoginTitleLabel;
@property(nonatomic,strong)MOLoginBottomView *bottomLoginView;
@property (nonatomic, assign) NSInteger countryCode;
@property (nonatomic, assign) BOOL showVoiceVerifyCodeDialog; // 控制语音验证码对话框显示
@property (nonatomic, strong) UIView *voiceVerifyCodeDialogView; // 语音验证码对话框视图

@property (weak, nonatomic) IBOutlet MOCountryCodeView *countryCodeView;

@end

@implementation MOLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.countryCode = 86;
    self.countryCodeView.codeLable.text = StringWithFormat(@"+%ld",self.countryCode);
    WEAKSELF
    self.countryCodeView.didClick = ^{
        MOAllCountryCodeVC *vc = [MOAllCountryCodeVC new];
        vc.didSelected = ^(NSInteger, NSInteger countryCode) {
            weakSelf.countryCode = countryCode;
            weakSelf.countryCodeView.codeLable.text = StringWithFormat(@"+%ld",countryCode);
        };
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    
    
    CGSize size = [Util calculateLabelSizeWithText:@"我已阅读并同意《用户协议》及《隐私协议》" andMarginSize:CGSizeMake(SCREEN_WIDTH-42-20, CGFLOAT_MAX) andTextFont:[UIFont systemFontOfSize:12]];
    
    [self.view addSubview:self.agreementLabel];
    self.agreementLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 20*2 - 22;
    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.agreementBtn.mas_right).mas_offset(5);
//        make.right.equalTo(self.view).mas_offset(20);
        make.centerY.equalTo(self.agreementBtn);
//        make.width.mas_equalTo(size.width+10);
        make.height.mas_equalTo(size.height);
    }];
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tap.cancelsTouchesInView = NO;  // 让事件继续传递给子视图
    [self.view addGestureRecognizer:tap];
    
    [self.segmentBgView addSubview:self.taskCatView];
    [self.taskCatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.segmentBgView);
        make.height.mas_equalTo(40);
//        make.width.mas_equalTo(220);
    }];
    
    self.taskCatView.titles = @[NSLocalizedString(@"密码登录", nil), NSLocalizedString(@"验证码登录", nil)];
    self.taskCatView.titleColor = [UIColor colorWithHexString:@"333333" alpha:0.5];
    self.taskCatView.titleSelectedColor = [UIColor colorWithHexString:@"333333"];
    self.taskCatView.titleFont = [UIFont systemFontOfSize:13];
    self.taskCatView.titleSelectedFont = [UIFont boldSystemFontOfSize:17];
    self.taskCatView.titleColorGradientEnabled = YES;
    self.taskCatView.contentEdgeInsetLeft = 15;
    self.taskCatView.contentEdgeInsetRight = 30;
    self.taskCatView.cellSpacing = 53.0;
    self.taskCatView.averageCellSpacingEnabled = NO;

    JXCategoryIndicatorImageView *indicatorView = [[JXCategoryIndicatorImageView alloc] init];
    indicatorView.indicatorImageView.image = [UIImage imageNamedNoCache:@"icon_segment_s"];
    indicatorView.verticalMargin = 8;
    indicatorView.indicatorImageViewSize = CGSizeMake(40, 15);
    self.taskCatView.indicators = @[indicatorView];
    self.verifyType = 1;
    
    [self.view addSubview:self.goReginsterVCLabel];
    [self.goReginsterVCLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left).offset(19);
        make.top.equalTo(self.loginBtn.mas_bottom).offset(27);
    }];
    
    [self.view addSubview:self.forgotPwdBtn];
    [self.forgotPwdBtn addTarget:self action:@selector(forgotPwdBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.view.mas_right).offset(-19);
        make.centerY.equalTo(self.goReginsterVCLabel.mas_centerY);
    }];
    
    [self.view addSubview:self.voiceVerifyCodeLabel];
    [self.voiceVerifyCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-19);
        make.top.equalTo(self.loginBtn.mas_bottom).offset(27);
    }];
    // 默认隐藏，只在验证码登录时显示
    self.voiceVerifyCodeLabel.hidden = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxLoginResponseCallBack:) name:WXLoginCallBack object:nil];
    
    
    
    
    
    [self.view addSubview:self.bottomLoginView];
    self.bottomLoginView.loginBtnClick = ^(MOLoginType loginType) {
        
        if (weakSelf.agreementBtn.selected == NO) {
            [MBProgressHUD showMessag:NSLocalizedString(@"请先阅读并同意《用户协议》及《隐私协议》", nil) toView:MOAppDelegate.window];
            return;
        }
        if (loginType == LoginTypeWX) {
            [weakSelf wxLogin];
        }
        if (loginType == LoginTypeAliPay) {
            [weakSelf alipayLogin];
        }
        if (loginType == LoginTypeAppleId) {
            [weakSelf appleIdlogin];
        }
    };
    [self.bottomLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.width.equalTo(@(50));
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(Bottom_SafeHeight>0?-Bottom_SafeHeight:-20);
    }];
    
    [self.view addSubview:self.bottomLoginTitleLabel];
    
    [self.bottomLoginTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.bottomLoginView.mas_top).offset(-10);
    }];
    
    // 初始化对话框状态
    self.showVoiceVerifyCodeDialog = NO;
    
    // 创建对话框视图
    [self setupVoiceVerifyCodeDialog];
    
}

- (void)setupVoiceVerifyCodeDialog {
    // 创建遮罩层
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    maskView.alpha = 0;
    maskView.tag = 1001;
    
    // 创建对话框容器
    UIView *dialogView = [[UIView alloc] init];
    dialogView.backgroundColor = [UIColor whiteColor];
    dialogView.layer.cornerRadius = 12;
    dialogView.clipsToBounds = YES;
    dialogView.tag = 1002;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"获取语音验证码";
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 内容文本
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"我们将以语音电话的形式告知您验证码，请留意接听来电呦";
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor colorWithHexString:@"959998"];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 0;
    
    // 取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"9B1D2E"] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor colorWithHexString:@"EDEEF3"];
    cancelBtn.layer.cornerRadius = 12;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(dismissVoiceVerifyCodeDialog) forControlEvents:UIControlEventTouchUpInside];
    
    // 立即获取按钮
    UIButton *confirmBtn = [[UIButton alloc] init];
    [confirmBtn setTitle:@"立即获取" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.backgroundColor = [UIColor colorWithHexString:@"9B1D2E"];
    confirmBtn.layer.cornerRadius = 12;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmBtn addTarget:self action:@selector(confirmVoiceVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加到视图
    [self.view addSubview:maskView];
    [self.view addSubview:dialogView];
    [dialogView addSubview:titleLabel];
    [dialogView addSubview:contentLabel];
    [dialogView addSubview:cancelBtn];
    [dialogView addSubview:confirmBtn];
    
    // 设置约束
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [dialogView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.mas_equalTo(300);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dialogView).offset(24);
        make.left.right.equalTo(dialogView).inset(20);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(16);
        make.left.right.equalTo(dialogView).inset(20);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom).offset(24);
        make.left.equalTo(dialogView).offset(20);
        make.right.equalTo(dialogView.mas_centerX).offset(-6);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(dialogView).offset(-20);
    }];
    
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom).offset(24);
        make.left.equalTo(dialogView.mas_centerX).offset(6);
        make.right.equalTo(dialogView).offset(-20);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(dialogView).offset(-20);
    }];
    
    // 保存引用
    self.voiceVerifyCodeDialogView = dialogView;
    
    // 默认隐藏
    maskView.hidden = YES;
    dialogView.hidden = YES;
    
    // 添加点击遮罩关闭的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVoiceVerifyCodeDialog)];
    [maskView addGestureRecognizer:tapGesture];
}

- (void)checkBeforeShowVoiceVerifyCodeDialog {
    // 1. 先验证是否已勾选同意用户协议和隐私协议
    if (self.agreementBtn.selected == NO) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先阅读并同意《用户协议》及《隐私协议》", nil) toView:MOAppDelegate.window];
        return;
    }
    
    // 2. 再验证是否填写手机号
    if (!self.phoneTf.text.isExist) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请输入手机号", nil) toView:MOAppDelegate.window];
        return;
    }
    
    // 3. 验证通过后，显示确认对话框
    [self showVoiceVerifyCodeDialog];
}

- (void)showVoiceVerifyCodeDialog {
    UIView *maskView = [self.view viewWithTag:1001];
    UIView *dialogView = [self.view viewWithTag:1002];
    
    maskView.hidden = NO;
    dialogView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 1.0;
        dialogView.alpha = 1.0;
        dialogView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissVoiceVerifyCodeDialog {
    UIView *maskView = [self.view viewWithTag:1001];
    UIView *dialogView = [self.view viewWithTag:1002];
    
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 0;
        dialogView.alpha = 0;
        dialogView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        maskView.hidden = YES;
        dialogView.hidden = YES;
    }];
}

- (void)confirmVoiceVerifyCode {
    [self dismissVoiceVerifyCodeDialog];
    // 调用接口获取语音验证码
    [self requestVoiceVerifyCode];
}

-(void)wxLogin {
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"ios";
    MOAppDelegate.wxApiDelegate = self;
    [WXApi sendAuthReq:req viewController:self delegate:nil completion:^(BOOL success) {
        
    }];
}
-(void)wxLoginResponseCallBack:(SendAuthResp *)resp {
    
    if (resp.errCode == 0) {
        
        [self showActivityIndicator];
        [[MONetDataServer sharedMONetDataServer] weChatLoginWithCode:resp.code success:^(NSDictionary *dic) {
            [self hidenActivityIndicator];
            MOUserModel *userInfo = [MOUserModel yy_modelWithJSON:dic];
            if (userInfo.mobile.length) {
                [userInfo archivedUserModel];
                [self gotoHomeVC];
            } else {
                [self goBindPhoneNumberVC:userInfo loginType:LoginTypeWX];
            }
            
        } failure:^(NSError *error) {
            [self hidenActivityIndicator];
            [self showErrorMessage:error.debugDescription];
        } msg:^(NSString *string) {
            [self hidenActivityIndicator];
            [self showErrorMessage:string];
        }];
    }
}

-(void)appleIdlogin {
    
    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    
    ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;
    [authorizationController performRequests];
}

-(void)alipayLogin {
    
    NSString *state =  [NSString stringWithFormat:@"%ld",(unsigned long)[NSDate date].timeIntervalSince1970];
    NSString *url = StringWithFormat(@"https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=2021005132612403&scope=auth_user&state=%@",state);
    NSDictionary *params = @{kAFServiceOptionBizParams: @{@"url": url},
                             kAFServiceOptionCallbackScheme: @"alipayAthud",
                             kAFServiceOptionNotUseLanding:@(YES)
                             };
    WEAKSELF
    [AFServiceCenter callService:AFServiceAuth withParams:params andCompletion:^(AFAuthServiceResponse *response) {
        if (response.responseCode == AFAuthResSuccess){
            DLog(@"授权结果:%@", response.result);
            NSString *auth_code = response.result[@"auth_code"];
            [weakSelf showActivityIndicator];
            [[MONetDataServer sharedMONetDataServer] alipayLoginWithCode:auth_code success:^(NSDictionary *dic) {
                [weakSelf hidenActivityIndicator];
                MOUserModel *userInfo = [MOUserModel yy_modelWithJSON:dic];
                if (userInfo.mobile.length) {
                    [userInfo archivedUserModel];
                    [self gotoHomeVC];
                } else {
                    [self goBindPhoneNumberVC:userInfo loginType:LoginTypeAliPay];
                }
                
            } failure:^(NSError *error) {
                [weakSelf hidenActivityIndicator];
                [weakSelf showErrorMessage:error.debugDescription];
            } msg:^(NSString *string) {
                [weakSelf hidenActivityIndicator];
                [weakSelf showErrorMessage:string];
            }];
            
        }
    }];
}

-(void)goBindPhoneNumberVC:(MOUserModel *)dataModel loginType:(MOLoginType)loginType{
    MOBindCellPhoneNumberVC *vc = [MOBindCellPhoneNumberVC new];
    vc.wXModel = dataModel;
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}

-(void)gotoHomeVC {
    // 登录成功后的页面跳转逻辑
    // 1）如果登录页是以模态方式显示在TabBar之上，直接dismiss即可回到首页
    // 2）如果登录页是应用的根视图（未登录启动应用），切换根控制器到主TabBar
    [MOAppDelegate uMPushSetAlias];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = MOAppDelegate.window.rootViewController;
        UITabBarController *tabBarController = [MBMainTabBarWrapper createMainTabBarController];
        void (^applyRoot)(void) = ^{
            MOAppDelegate.homeVC = tabBarController;
            MOAppDelegate.window.rootViewController = tabBarController;
            // 明确选中首页（SwiftUI HomeViewController）
            tabBarController.selectedIndex = 0;
            [MOAppDelegate.window makeKeyAndVisible];
        };
        if (rootVC.presentedViewController != nil) {
            [rootVC dismissViewControllerAnimated:NO completion:^{
                applyRoot();
            }];
        } else if (self.presentingViewController != nil) {
            [self dismissViewControllerAnimated:NO completion:^{
                applyRoot();
            }];
        } else {
            applyRoot();
        }
    });
}



- (void)endEditing {
    [self.view endEditing:YES];
}

- (IBAction)verifyCodeClick:(id)sender {
    
    [self.phoneTf resignFirstResponder];
    
    if (self.agreementBtn.selected == NO) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先阅读并同意《用户协议》及《隐私协议》", nil) toView:MOAppDelegate.window];
        return;
    }
    
    if (!self.phoneTf.text.isExist) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请输入手机号", nil) toView:MOAppDelegate.window];
        return;
    }
    
//    if (self.phoneTf.text.length != 11) {
//        [MBProgressHUD showMessag:NSLocalizedString(@"请输入合法的手机号！", nil) toView:MOAppDelegate.window];
//        return;
//    }
    
    MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
    [self.viewModel getVerifyCodeWithMobile:self.phoneTf.text sms_event:3 country_code:self.countryCode channel_type:0 success:^(NSDictionary *dic) {
        [hud hide:YES];
        [MBProgressHUD showMessag:NSLocalizedString(@"已发送", nil) toView:MOAppDelegate.window];
        [self addtimer];
    } failure:^(NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showError:error.localizedDescription toView:MOAppDelegate.window];
    } msg:^(NSString *string) {
        [hud hide:YES];
        [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
    } loginFail:^{
        [hud hide:YES];

    }];
}

- (IBAction)eyeClick:(id)sender {
    self.eyeButton.selected = !self.eyeButton.selected;
    if (self.eyeButton.selected == YES) {
        self.pswTf.secureTextEntry = NO;
    } else {
        self.pswTf.secureTextEntry = YES;
    }
}

- (void)addtimer {
    self.cd = 0;
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication]endBackgroundTask:UIBackgroundTaskInvalid];
    }];
    
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction {
    int timecount = 60-self.cd;
    if (timecount == 0) {
        self.verifyCodeBtn.enabled = YES;
        self.verifyCodeBtn.hidden = NO;
        self.cdLabel.hidden = YES;
        if (self.timer.isValid) {
            [self.timer invalidate];
        }
    } else {
        self.verifyCodeBtn.enabled = NO;
        self.verifyCodeBtn.hidden = YES;
        self.cdLabel.hidden = NO;
        self.cdLabel.text = [NSString stringWithFormat:@"%d s", timecount];
    }
    self.cd ++;
}

- (void)forgotPwdBtnClick {
    MOForgotPasswordVC *vc = [MOForgotPasswordVC new];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}

- (void)requestVoiceVerifyCode {
    [self.phoneTf resignFirstResponder];
    
    // 注意：协议和手机号验证已在显示对话框前完成，这里直接调用接口
    MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
    // 语音验证码：channel_type = 3
    [self.viewModel getVerifyCodeWithMobile:self.phoneTf.text sms_event:3 country_code:self.countryCode channel_type:3 success:^(NSDictionary *dic) {
        [hud hide:YES];
        [MBProgressHUD showMessag:NSLocalizedString(@"语音验证码已发送", nil) toView:MOAppDelegate.window];
        [self addtimer];
    } failure:^(NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showError:error.localizedDescription toView:MOAppDelegate.window];
    } msg:^(NSString *string) {
        [hud hide:YES];
        [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
    } loginFail:^{
        [hud hide:YES];
    }];
}

#pragma mark 微信登录
- (void)onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {
            SendAuthResp *resp2 = (SendAuthResp *)resp;
            [self wxLoginResponseCallBack:resp2];
        }
    }
}
#pragma mark 苹果登录

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *appleIDCredential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        
        NSString *identityToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
        // 这里可以将用户信息发送到服务器进行验证和处理
        [self showActivityIndicator];
        [[MONetDataServer sharedMONetDataServer] appleLoginWithCode:identityToken success:^(NSDictionary *dic) {
            [self hidenActivityIndicator];
            DLog(@"%@",dic);
            MOUserModel *userModel = [MOUserModel yy_modelWithJSON:dic];
            if (userModel.mobile.length) {
                [userModel archivedUserModel];
                [self gotoHomeVC];
            } else {
                [self goBindPhoneNumberVC:userModel loginType:LoginTypeAppleId];
            }
        } failure:^(NSError *error) {
            [self hidenActivityIndicator];
            [self showErrorMessage:error.debugDescription];
        } msg:^(NSString *string) {
            [self hidenActivityIndicator];
            [self showErrorMessage:string];
        }];

    }
}

#pragma mark - JXCategoryListContainerViewDelegate

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.verifyType = index + 1;
//    if (self.verifyType == 1) {
//        self.verifyCodeBtn.hidden = YES;
//        self.phoneTf.placeholder = @"请输入账号";
//        self.codeTf.placeholder = @"请输入密码";
//        self.codeTf.secureTextEntry = YES;
//        self.cdLabel.hidden = YES;
//
//    } else {
//        self.verifyCodeBtn.hidden = NO;
//        self.phoneTf.placeholder = @"请输入手机号";
//        self.codeTf.placeholder = @"请输入验证码";
//        self.codeTf.secureTextEntry = NO;
//    }
    
    if (self.verifyType == 1) {
        // 密码登录：显示"没有账号，去注册"和"忘记密码"，隐藏语音验证码提示
        self.codeView.hidden = YES;
        self.pswView.hidden = NO;
        self.goReginsterVCLabel.hidden = NO;
        self.forgotPwdBtn.hidden = NO;
        self.voiceVerifyCodeLabel.hidden = YES;
    } else {
        // 验证码登录：隐藏"没有账号，去注册"和"忘记密码"，显示语音验证码提示
        self.codeView.hidden = NO;
        self.pswView.hidden = YES;
        self.goReginsterVCLabel.hidden = YES;
        self.forgotPwdBtn.hidden = YES;
        self.voiceVerifyCodeLabel.hidden = NO;
    }
}

- (IBAction)loginClick:(id)sender {
    
    [self.phoneTf resignFirstResponder];
    [self.codeTf resignFirstResponder];
    [self.pswTf resignFirstResponder];
    
    if (self.agreementBtn.selected == NO) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先阅读并同意《用户协议》及《隐私协议》", nil) toView:MOAppDelegate.window];
        return;
    }
    
    if (!self.phoneTf.text.isExist) {
        if (self.verifyType == 1) {
            [MBProgressHUD showMessag:NSLocalizedString(@"请输入手机号!", nil) toView:MOAppDelegate.window];
        } else {
            [MBProgressHUD showMessag:NSLocalizedString(@"请输入手机号!", nil) toView:MOAppDelegate.window];
        }
        return;
    }

    
    if (self.verifyType == 1) {
        if (!self.pswTf.text.isExist) {
            [MBProgressHUD showMessag:NSLocalizedString(@"请输入密码", nil) toView:MOAppDelegate.window];
            return;
        }
    } else {
        if (!self.codeTf.text.isExist) {
            [MBProgressHUD showMessag:NSLocalizedString(@"请输入验证码", nil) toView:MOAppDelegate.window];
            return;
        }
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
    NSInteger checkType = 1;
    NSString *phone = @"";
    NSString *code = @"";
    NSString *account = @"";
    NSString *password = @"";

    if (self.verifyType == 1) {
        checkType = 2;
        // 账密
        account = self.phoneTf.text;
        password = self.pswTf.text;
    } else {
        checkType = 1;
        // 验证码
        phone = self.phoneTf.text;
        code = self.codeTf.text;
    }
    
    [self.viewModel loginWithMobile:phone country_code:self.countryCode code:code account:account password:password checkType:checkType name:nil avatar:nil sex:-1 unionid:nil openid:nil sub:nil email:nil alipay_openid:nil success:^(NSDictionary *dic) {
        
        [hud hide:YES];
        [MBProgressHUD showSuccess:NSLocalizedString(@"登录成功", nil) toView:MOAppDelegate.window];
        
        // 验证 token 是否成功保存
        if ([MOUserModel isTokenValid]) {
            NSLog(@"✅ Token 保存成功: %@", [MOUserModel getCurrentUserToken]);
        } else {
            NSLog(@"❌ Token 保存失败");
        }
        
        // 重置验证码/密码
        self.verifyCodeBtn.enabled = YES;
        self.verifyCodeBtn.hidden = NO;
        self.cdLabel.hidden = YES;
        self.pswTf.text = @"";
        
        if (self.timer.isValid) {
            [self.timer invalidate];
        }
        self.codeTf.text = @"";
        [self gotoHomeVC];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showError:error.localizedDescription toView:MOAppDelegate.window];
    } msg:^(NSString *string) {
        [hud hide:YES];
        [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
    } loginFail:^{
        [hud hide:YES];
    }];
    
}

- (IBAction)agreementClick:(id)sender {
    self.agreementBtn.selected = !self.agreementBtn.selected;
}

#pragma mark - setter && getter
- (MOLoginVM *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [MOLoginVM new];
    }
    return _viewModel;
}

- (YYLabel *)agreementLabel {
    if (_agreementLabel == nil) {
        _agreementLabel = [YYLabel new];
        _agreementLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [NSMutableAttributedString createWithString:NSLocalizedString(@"我已阅读并同意", nil) font:MOPingFangSCFont(12) textColor:BlackColor];
        NSMutableAttributedString *attributedString1 = [NSMutableAttributedString createWithString:NSLocalizedString(@"《用户协议》", nil) font:MOPingFangSCFont(12) textColor:MainSelectColor];
        [attributedString1 yy_setTextHighlightRange:NSMakeRange(0, NSLocalizedString(@"《用户协议》", nil).length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOWebViewController pushServiceAgreementWebVC];
        }];
        NSMutableAttributedString *attributedString2 = [NSMutableAttributedString createWithString:NSLocalizedString(@"及", nil) font:MOPingFangSCFont(12) textColor:BlackColor];
        
        NSMutableAttributedString *attributedString3 = [NSMutableAttributedString createWithString:NSLocalizedString(@"《隐私协议》", nil) font:MOPingFangSCFont(12) textColor:MainSelectColor];
        [attributedString3 yy_setTextHighlightRange:NSMakeRange(0, NSLocalizedString(@"《隐私协议》", nil).length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOWebViewController pushPrivacyAgreementWebVC];
            
        }];
        
        [attributedString appendAttributedString:attributedString1];
        [attributedString appendAttributedString:attributedString2];
        [attributedString appendAttributedString:attributedString3];
        
        _agreementLabel.attributedText = attributedString;
    }
    return _agreementLabel;
}

- (JXCategoryTitleView *)taskCatView {
    if (_taskCatView == nil) {
        _taskCatView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.6, 40)];
        _taskCatView.delegate = self;
    }
    return _taskCatView;
}

-(YYLabel *)goReginsterVCLabel {
    
    if (!_goReginsterVCLabel) {
        
        _goReginsterVCLabel = [YYLabel new];
        _goReginsterVCLabel.numberOfLines = 0;

        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"没有账号，", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:Color626262}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"去注册", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:MainSelectColor}];

        [str2 yy_setTextHighlightRange:NSMakeRange(0, str2.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            MORegisterVC *vc = [MORegisterVC new];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
            
        }];
        [str1 appendAttributedString:str2];
        _goReginsterVCLabel.attributedText = str1;
    }
    return _goReginsterVCLabel;
}

-(MOButton *)forgotPwdBtn {
    if (!_forgotPwdBtn) {
        _forgotPwdBtn = [MOButton new];
        [_forgotPwdBtn setTitle:NSLocalizedString(@"忘记密码", nil) titleColor:MainSelectColor bgColor:ClearColor font:MOPingFangSCMediumFont(12)];
        [_forgotPwdBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _forgotPwdBtn;
}

-(YYLabel *)voiceVerifyCodeLabel {
    if (!_voiceVerifyCodeLabel) {
        _voiceVerifyCodeLabel = [YYLabel new];
        _voiceVerifyCodeLabel.numberOfLines = 0;
        _voiceVerifyCodeLabel.textAlignment = NSTextAlignmentRight;
        
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"收不到验证码？试试", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:Color626262}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"语音验证码", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:MainSelectColor}];
        
        [str2 yy_setTextHighlightRange:NSMakeRange(0, str2.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            // 先验证协议和手机号，再显示确认对话框
            [self checkBeforeShowVoiceVerifyCodeDialog];
        }];
        [str1 appendAttributedString:str2];
        _voiceVerifyCodeLabel.attributedText = str1;
    }
    return _voiceVerifyCodeLabel;
}

-(UILabel *)bottomLoginTitleLabel {
    
    if (!_bottomLoginTitleLabel) {
        _bottomLoginTitleLabel = [UILabel labelWithText:@"其他登录方式" textColor:Color9B9B9B font:MOPingFangSCMediumFont(13)];
    }
    return _bottomLoginTitleLabel;
}


-(MOLoginBottomView *)bottomLoginView  {
    
    if (!_bottomLoginView) {
        _bottomLoginView = [MOLoginBottomView new];
    }
    return _bottomLoginView;
}

@end
