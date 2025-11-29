//
//  MORegisterVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/11.
//

#import "MORegisterVC.h"
#import "MONavBarView.h"
#import "UIButton+CountDown.h"
#import "MOWebViewController.h"
#import "NSString+MobiusiTool.h"
#import "Mobiusi_iOS-Swift.h"
@interface MORegisterVC ()<UITextFieldDelegate>
@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)UILabel *bgTitleLabel;
@property (nonatomic, strong) UIScrollView *moScrollView;
@property (nonatomic, strong) MOView *moContentView;

@property (nonatomic, strong) UITextField *phoneEmailTextField;
@property (nonatomic, strong) MOCountryCodeView *countryCodeView;
@property (nonatomic, strong) MOView *phoneEmailContentView;
@property (nonatomic, strong) UITextField *verifyCodeTextField;
@property (nonatomic, strong) MOView *verifyCodeContentView;
@property (nonatomic, strong) MOButton *getVerifyCodeBtn;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) MOButton *passwordViewBtn;
@property (nonatomic, strong) UILabel *passwordRuleLabel;
@property (nonatomic, strong) MOView *passwordContentView;
@property (nonatomic, strong) UITextField *confirmPasswordTextField;
@property (nonatomic, strong) MOView *confirmPasswordContentView;
@property (nonatomic, strong) MOButton *confirmPasswordViewBtn;
@property (nonatomic, strong) MOButton *agreementBtn;
@property (nonatomic, strong) YYLabel *agreementLabel;
@property (nonatomic, strong) MOButton *registerBtn;
@property (nonatomic, strong) YYLabel *goLoginVCLabel;
@property (nonatomic, assign) NSInteger countryCode;
@end

@implementation MORegisterVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.countryCode = 86;
    [self setupUI];
    [self setupConstraints];
}

- (void)setupUI {
    
    self.view.backgroundColor = WhiteColor;
    [self.view addSubview:self.bgImageView];
    //导航
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    self.navBar.gobackDidClick = ^{
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    [self.view addSubview:self.navBar];
    // 滚动视图
    [self.view addSubview:self.moScrollView];
    [self.moScrollView addSubview:self.moContentView];
    
    [self.moContentView addSubview:self.bgTitleLabel];
    
    // 手机号/邮箱输入框
    [self.moContentView addSubview:self.phoneEmailContentView];
    WEAKSELF
    self.countryCodeView.didClick = ^{
        MOAllCountryCodeVC *vc = [MOAllCountryCodeVC new];
        vc.didSelected = ^(NSInteger, NSInteger countryCode) {
            weakSelf.countryCode = countryCode;
            weakSelf.countryCodeView.codeLable.text = StringWithFormat(@"+%ld",countryCode);
        };
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    [self.phoneEmailContentView addSubview:self.countryCodeView];
    
    self.phoneEmailTextField.delegate = self;
    [self.phoneEmailContentView addSubview:self.phoneEmailTextField];
    
    // 验证码相关
    [self.moContentView addSubview:self.verifyCodeContentView];
    self.verifyCodeTextField.delegate = self;
    [self.verifyCodeContentView addSubview:self.verifyCodeTextField];
    [self.getVerifyCodeBtn addTarget:self action:@selector(getVerifyCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.verifyCodeContentView addSubview:self.getVerifyCodeBtn];
    
    // 密码输入框
    [self.moContentView addSubview:self.passwordContentView];
    self.passwordTextField.delegate = self;
    [self.passwordContentView addSubview:self.passwordTextField];
    [self.passwordViewBtn addTarget:self action:@selector(passwordViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordContentView addSubview:self.passwordViewBtn];
    
    //密码规则
    [self.moContentView addSubview:self.passwordRuleLabel];
    
    // 确认密码输入框
    [self.moContentView addSubview:self.confirmPasswordContentView];
    self.confirmPasswordTextField.delegate = self;
    [self.confirmPasswordContentView addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordViewBtn addTarget:self action:@selector(confirmPasswordViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmPasswordContentView addSubview:self.confirmPasswordViewBtn];
    
    // 协议勾选
    [self.moContentView addSubview:self.agreementBtn];
    [self.agreementBtn addTarget:self action:@selector(agreementBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.moContentView addSubview:self.agreementLabel];
    
    // 注册按钮
    [self.registerBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.moContentView addSubview:self.registerBtn];
    
    [self.moContentView addSubview:self.goLoginVCLabel];
}

- (void)setupConstraints {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    // 导航
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    
    
    // 滚动视图约束
    [self.moScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.moContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.moScrollView);
        make.width.equalTo(self.moScrollView);
    }];
    
    //大标题
    [self.bgTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moContentView.mas_left).offset(23);
        make.right.equalTo(self.moContentView.mas_right);
        make.top.equalTo(self.moContentView.mas_top).offset(34);
    }];
    
    
    // 输入框通用间距
    CGFloat padding = 20;
    CGFloat textFieldHeight = 55;
    CGFloat leftMarginTF = 17;
    
    // 手机号
    [self.phoneEmailContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgTitleLabel.mas_bottom).offset(32);
        make.left.equalTo(self.moContentView.mas_left).offset(padding);
        make.right.equalTo(self.moContentView.mas_right).offset(-padding);
        make.height.equalTo(@(textFieldHeight));
    }];
    [self.countryCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneEmailContentView.mas_top);
        make.left.equalTo(self.phoneEmailContentView.mas_left).offset(leftMarginTF);
        make.bottom.equalTo(self.phoneEmailContentView.mas_bottom);
    }];
    [self.countryCodeView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.countryCodeView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.phoneEmailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneEmailContentView.mas_top);
        make.left.equalTo(self.countryCodeView.mas_right).offset(leftMarginTF);
        make.right.equalTo(self.phoneEmailContentView.mas_right).offset(-leftMarginTF);
        make.bottom.equalTo(self.phoneEmailContentView.mas_bottom);
    }];
    [self.phoneEmailTextField setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
    
    // 验证码输入框
    
    [self.verifyCodeContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneEmailContentView.mas_bottom).offset(padding);
        make.left.equalTo(self.moContentView.mas_left).offset(padding);
        make.right.equalTo(self.moContentView.mas_right).offset(-padding); // 预留按钮空间
        make.height.equalTo(@(textFieldHeight));
    }];
    [self.verifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyCodeContentView.mas_top);
        make.left.equalTo(self.verifyCodeContentView.mas_left).offset(leftMarginTF);
        make.bottom.equalTo(self.verifyCodeContentView.mas_bottom);
        
    }];
    
    // 获取验证码按钮
    [self.getVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyCodeContentView);
        make.left.equalTo(self.verifyCodeTextField.mas_right).offset(leftMarginTF);
        make.right.equalTo(self.verifyCodeContentView.mas_right).offset(-leftMarginTF);
        make.bottom.equalTo(self.verifyCodeContentView.mas_bottom);
    }];
    [self.getVerifyCodeBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.getVerifyCodeBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    // 密码输入框
    [self.passwordContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyCodeContentView.mas_bottom).offset(padding);
        make.left.right.equalTo(self.verifyCodeContentView);
        make.height.equalTo(@(textFieldHeight));
    }];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordContentView.mas_top);
        make.left.equalTo(self.passwordContentView.mas_left).offset(leftMarginTF);
        make.right.equalTo(self.passwordContentView.mas_right).offset(-leftMarginTF - 24);
        make.bottom.equalTo(self.passwordContentView.mas_bottom);
    }];
    [self.passwordViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.passwordContentView.mas_centerY);
        make.right.equalTo(self.passwordContentView.mas_right).offset(-leftMarginTF);
        make.width.height.equalTo(@(24));
    }];
    
    //密码规则
    [self.passwordRuleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordContentView.mas_bottom).offset(10);
        make.left.equalTo(self.passwordContentView);
    }];
    
    // 确认密码输入框
    [self.confirmPasswordContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordRuleLabel.mas_bottom).offset(padding);
        make.left.right.equalTo(self.passwordContentView);
        make.height.equalTo(@(textFieldHeight));
    }];
    [self.confirmPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmPasswordContentView.mas_top);
        make.left.equalTo(self.confirmPasswordContentView.mas_left).offset(leftMarginTF);
        make.right.equalTo(self.confirmPasswordContentView.mas_right).offset(-leftMarginTF - 24);
        make.bottom.equalTo(self.confirmPasswordContentView.mas_bottom);
    }];
    [self.confirmPasswordViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPasswordContentView.mas_centerY);
        make.right.equalTo(self.confirmPasswordContentView.mas_right).offset(-leftMarginTF);
        make.width.height.equalTo(@(24));
    }];
    
    // 协议勾选
    [self.agreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmPasswordContentView.mas_bottom).offset(16);
        make.left.equalTo(self.moContentView.mas_left).offset(padding);
        make.size.equalTo(@(18));
    }];
    
    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.agreementBtn.mas_top);;
        make.left.equalTo(self.agreementBtn.mas_right).offset(10);
    }];
    
    // 注册按钮
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.agreementBtn.mas_bottom).offset(27);
        make.left.equalTo(self.moContentView.mas_left).offset(padding);
        make.right.equalTo(self.moContentView.mas_right).offset(-padding);
        make.height.equalTo(@(55));
    }];
    
    [self.goLoginVCLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerBtn.mas_bottom).offset(27);
        make.left.equalTo(self.moContentView.mas_left).offset(padding);
        make.right.equalTo(self.moContentView.mas_right).offset(-padding);
        make.bottom.equalTo(self.moContentView.mas_bottom).offset(-padding);
    }];
}

-(void)getVerifyCodeBtnClick {
    
//    if (self.phoneEmailTextField.text.length != 11) {
//        [self showMessage:NSLocalizedString(@"请输入合法的手机号！", nil)];
//        return;
//    }
    
    [self.getVerifyCodeBtn startCountDownWithTitle:^NSString * _Nonnull(UIButton * _Nonnull btn, NSInteger count) {
        if (count > 60) {
            btn.enabled = YES;
            [btn stopCountDown];
            return NSLocalizedString(@"获取验证码", nil);
        } else {
            btn.enabled = NO;
            return [NSString stringWithFormat:@"%lds",60 -(long)count];
        }
    }];
    
    [[MONetDataServer sharedMONetDataServer] getVerifyCodeWithMobile:self.phoneEmailTextField.text sms_event:4 country_code:self.countryCode channel_type:0 success:^(NSDictionary *dic) {
        
        [self showMessage:NSLocalizedString(@"已发送", nil)];
    } failure:^(NSError *error) {
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self showErrorMessage:string];
    } loginFail:^{
        
    }];
    
}

-(void)passwordViewBtnClick {
    
    self.passwordViewBtn.selected = !self.passwordViewBtn.selected;
    self.passwordTextField.secureTextEntry = self.passwordViewBtn.selected;
}

-(void)confirmPasswordViewBtnClick {
    
    self.confirmPasswordViewBtn.selected = !self.confirmPasswordViewBtn.selected;
    self.confirmPasswordTextField.secureTextEntry = self.confirmPasswordViewBtn.selected;
}

-(void)agreementBtnClick {
    
    self.agreementBtn.selected = !self.agreementBtn.selected;
}

-(void)registerBtnClick {
    
    if (!self.phoneEmailTextField.text.length) {
        [self showMessage:NSLocalizedString(@"请输入手机号", nil)];
        return;
    }
    
//    if (self.phoneEmailTextField.text.length != 11) {
//        [self showMessage:NSLocalizedString(@"请输入合法的手机号！", nil)];
//        return;
//    }
    
    if (!self.verifyCodeTextField.text.length) {
        [self showMessage:NSLocalizedString(@"请输入验证码", nil)];
        return;
    }
    if (!self.passwordTextField.text.length) {
        [self showMessage:NSLocalizedString(@"请输入登录密码", nil)];
        return;
    }
    if (![self.passwordTextField.text isRegisterPwd]) {
        [self showMessage:NSLocalizedString(@"密码必须6-16 位，必须包含大小写字母、数字、特殊字符", nil)];
        return;
    }
    if (!self.confirmPasswordTextField.text.length) {
        [self showMessage:NSLocalizedString(@"请输入再次输入登录密码", nil)];
        return;
    }
    
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        [self showMessage:NSLocalizedString(@"两次输入的密码不一致", nil)];
        return;
    }
    
    if (!self.agreementBtn.selected) {
        [self showMessage:NSLocalizedString(@"请阅读并同意《用户协议》和《隐私协议》", nil)];
    }
    
    
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] registWithMobile:self.phoneEmailTextField.text code:self.verifyCodeTextField.text password:self.passwordTextField.text second_password:self.confirmPasswordTextField.text success:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        MOUserModel *user = [MOUserModel yy_modelWithJSON:dic];
        [user archivedUserModel];
        [self showMessage:NSLocalizedString(@"注册成功!", nil)];
        [MOAppDelegate uMPushSetAlias];
        // 注册成功后跳转到新的 SwiftUI 首页
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
        
    } failure:^(NSError *error) {
        [self hidenActivityIndicator];
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self hidenActivityIndicator];
        [self showErrorMessage:string];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
    
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

#pragma mark - 懒加载
-(UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.image = [UIImage imageNamedNoCache:@"bg_home_top.png"];
    }
    return _bgImageView;
}
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        _navBar.titleLabel.text = @"";
    }
    
    return _navBar;
}

-(UILabel *)bgTitleLabel {
    
    if (!_bgTitleLabel) {
        _bgTitleLabel = [UILabel labelWithText:NSLocalizedString(@"注册账号", nil) textColor:BlackColor font:MOPingFangSCHeavyFont(25)];
    }
    
    return _bgTitleLabel;
}

- (UIScrollView *)moScrollView {
    if (!_moScrollView) {
        _moScrollView = [[UIScrollView alloc] init];
        _moScrollView.showsVerticalScrollIndicator = NO;
    }
    return _moScrollView;
}

- (MOView *)moContentView {
    if (!_moContentView) {
        _moContentView = [[MOView alloc] init];
    }
    return _moContentView;
}

- (UITextField *)phoneEmailTextField {
    if (!_phoneEmailTextField) {
        _phoneEmailTextField = [[UITextField alloc] init];
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入手机号", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(17),NSForegroundColorAttributeName:ColorAFAFAF}];
        _phoneEmailTextField.attributedPlaceholder = str1;
        _phoneEmailTextField.backgroundColor = ClearColor;
        _phoneEmailTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneEmailTextField;
}

-(MOView *)phoneEmailContentView {
    
    if (!_phoneEmailContentView) {
        _phoneEmailContentView = [MOView new];
        [_phoneEmailContentView cornerRadius:QYCornerRadiusAll radius:10];
        _phoneEmailContentView.backgroundColor = ColorEDEEF4;
    }
    return _phoneEmailContentView;
}

- (UITextField *)verifyCodeTextField {
    if (!_verifyCodeTextField) {
        _verifyCodeTextField = [[UITextField alloc] init];
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入验证码", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(17),NSForegroundColorAttributeName:ColorAFAFAF}];
        _verifyCodeTextField.attributedPlaceholder = str1;
        _verifyCodeTextField.backgroundColor = ClearColor;
        _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _verifyCodeTextField;
}

-(MOView *)verifyCodeContentView {
    
    if (!_verifyCodeContentView) {
        _verifyCodeContentView = [MOView new];
        [_verifyCodeContentView cornerRadius:QYCornerRadiusAll radius:10];
        _verifyCodeContentView.backgroundColor = ColorEDEEF4;
    }
    return _verifyCodeContentView;
}

- (MOButton *)getVerifyCodeBtn {
    if (!_getVerifyCodeBtn) {
        _getVerifyCodeBtn = [MOButton new];
        [_getVerifyCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil) titleColor:Color9A1E2E bgColor:ClearColor font:MOPingFangSCMediumFont(12)];
        [_getVerifyCodeBtn fixAlignmentBUG];
        [_getVerifyCodeBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _getVerifyCodeBtn;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入登录密码", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(17),NSForegroundColorAttributeName:ColorAFAFAF}];
        _passwordTextField.attributedPlaceholder = str1;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.backgroundColor = ClearColor;
    }
    return _passwordTextField;
}

-(MOButton *)passwordViewBtn {
    if (!_passwordViewBtn) {
        _passwordViewBtn = [MOButton new];
        [_passwordViewBtn setImage:[UIImage imageNamedNoCache:@"icon_register_pwd_view.png"]];
        [_passwordViewBtn setImage:[UIImage imageNamedNoCache:@"icon_register_pwd_hidden.png"] forState:UIControlStateSelected];
        _passwordViewBtn.selected = YES;
        [_passwordViewBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _passwordViewBtn;
}

-(MOView *)passwordContentView {
    if (!_passwordContentView) {
        _passwordContentView = [MOView new];
        [_passwordContentView cornerRadius:QYCornerRadiusAll radius:10];
        _passwordContentView.backgroundColor = ColorEDEEF4;
    }
    return _passwordContentView;
}

-(UILabel *)passwordRuleLabel {
    
    if (!_passwordRuleLabel) {
        _passwordRuleLabel = [UILabel labelWithText:NSLocalizedString(@"密码必须包含大小写字母、数字、特殊字符，6-16位", nil) textColor:ColorAFAFAF font:MOPingFangSCFont(12)];
    }
    return _passwordRuleLabel;
}

- (UITextField *)confirmPasswordTextField {
    if (!_confirmPasswordTextField) {
        _confirmPasswordTextField = [[UITextField alloc] init];
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请再次输入登录密码", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(17),NSForegroundColorAttributeName:ColorAFAFAF}];
        _confirmPasswordTextField.attributedPlaceholder = str1;
        _confirmPasswordTextField.secureTextEntry = YES;
        _confirmPasswordTextField.backgroundColor = ClearColor;
    }
    return _confirmPasswordTextField;
}

-(MOButton *)confirmPasswordViewBtn {
    if (!_confirmPasswordViewBtn) {
        _confirmPasswordViewBtn = [MOButton new];
        [_confirmPasswordViewBtn setImage:[UIImage imageNamedNoCache:@"icon_register_pwd_view.png"]];
        [_confirmPasswordViewBtn setImage:[UIImage imageNamedNoCache:@"icon_register_pwd_hidden.png"] forState:UIControlStateSelected];
        [_confirmPasswordViewBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
        _confirmPasswordViewBtn.selected = YES;
    }
    return _confirmPasswordViewBtn;
}

-(MOView *)confirmPasswordContentView {
    
    if (!_confirmPasswordContentView) {
        _confirmPasswordContentView = [MOView new];
        [_confirmPasswordContentView cornerRadius:QYCornerRadiusAll radius:10];
        _confirmPasswordContentView.backgroundColor = ColorEDEEF4;
    }
    return _confirmPasswordContentView;
}

- (MOButton *)agreementBtn {
    if (!_agreementBtn) {
        _agreementBtn = [MOButton new];
        
        [_agreementBtn setImage:[UIImage imageNamedNoCache:@"icon_login_unselect.png"]];
        [_agreementBtn setImage:[UIImage imageNamedNoCache:@"icon_login_select.png"] forState:UIControlStateSelected];
        [_agreementBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _agreementBtn;
}

-(YYLabel *)agreementLabel {
    if (!_agreementLabel) {
        _agreementLabel = [YYLabel new];
        _agreementLabel.numberOfLines = 0;
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"我已阅读并同意", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:Color626262}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"《用户协议》", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:MainSelectColor}];

        [str2 yy_setTextHighlightRange:NSMakeRange(0, str2.string.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [MOWebViewController pushServiceAgreementWebVC];
            
        }];
        [str1 appendAttributedString:str2];
        
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"及", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:Color626262}];
        [str1 appendAttributedString:str3];
        
        
        NSMutableAttributedString *str4 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"《隐私协议》", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:MainSelectColor}];

        [str4 yy_setTextHighlightRange:NSMakeRange(0, str4.string.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOWebViewController pushPrivacyAgreementWebVC];
        }];
        [str1 appendAttributedString:str4];
        _agreementLabel.attributedText = str1;
    }
    return _agreementLabel;
}


- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [MOButton new];
        [_registerBtn setTitle:NSLocalizedString(@"立即注册", nil) titleColor:WhiteColor bgColor:Color9A1E2E font:MOPingFangSCHeavyFont(17)];
        [_registerBtn cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _registerBtn;
}

-(YYLabel *)goLoginVCLabel {
    if (!_goLoginVCLabel) {
        _goLoginVCLabel = [YYLabel new];
        _goLoginVCLabel.numberOfLines = 0;

        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"已有账号，", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:Color626262}];
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"去登录", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(12),NSForegroundColorAttributeName:MainSelectColor}];

        [str2 yy_setTextHighlightRange:NSMakeRange(0, str2.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOAppDelegate.transition popViewControllerAnimated:YES];
            
        }];
        [str1 appendAttributedString:str2];
        _goLoginVCLabel.attributedText = str1;
    }
    return _goLoginVCLabel;
}

-(MOCountryCodeView *)countryCodeView {
    
    if (!_countryCodeView) {
        _countryCodeView = [MOCountryCodeView new];
        _countryCodeView.codeLable.text = StringWithFormat(@"+%ld",self.countryCode);
    }
    return _countryCodeView;
}

@end
