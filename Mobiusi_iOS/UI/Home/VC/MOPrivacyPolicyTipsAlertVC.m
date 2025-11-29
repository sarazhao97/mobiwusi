//
//  MOPrivacyPolicyTipsAlertVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/12.
//

#import "MOPrivacyPolicyTipsAlertVC.h"
#import "MOWebViewController.h"

@interface MOPrivacyPolicyTipsAlertVC ()
@property(nonatomic,weak)UIView *launchScreenBgView;
@property(nonatomic,strong)MOView *maskView;
@property(nonatomic,strong)MOView *alertView;
@property(nonatomic,strong)UILabel *alertTitleLabel;
@property(nonatomic,strong)YYLabel *alertTextLabel;
@property(nonatomic,strong)MOButton *alertAgreeBtn;
@property(nonatomic,strong)MOButton *alertDisagreeBtn;
@end

@implementation MOPrivacyPolicyTipsAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupConstraints];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

-(void)setupUI{
    [self.view addSubview: self.launchScreenBgView];
    
    [self.view addSubview: self.maskView];
    
    [self.view addSubview: self.alertView];
    
    [self.alertView addSubview: self.alertTitleLabel];
    
    [self.alertView addSubview: self.alertTextLabel];
    [self.alertDisagreeBtn addTarget:self action:@selector(alertDisagreeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview: self.alertDisagreeBtn];
    [self.alertAgreeBtn addTarget:self action:@selector(alertAgreeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview: self.alertAgreeBtn];
}


-(void)setupConstraints {
    
    //启动图背景
    [self.launchScreenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
        
    }];
    
    //黑色半透明图背景
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
        
    }];
    
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.centerY.equalTo(self.view.mas_centerY);
        
    }];
    
    
    [self.alertTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.alertView.mas_centerX);
        make.left.greaterThanOrEqualTo(self.alertView.mas_left).offset(10);
        make.right.lessThanOrEqualTo(self.alertView.mas_right).offset(-10);
        make.top.equalTo(self.alertView.mas_top).offset(20);
        
    }];
    
    self.alertTextLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 20*2 - 20*2;
    [self.alertTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.alertView.mas_left).offset(20);
        make.right.equalTo(self.alertView.mas_right).offset(-20);
        make.top.equalTo(self.alertTitleLabel.mas_bottom).offset(20);
        
    }];
    
    
    [self.alertDisagreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.alertView.mas_left).offset(20);
        make.top.equalTo(self.alertTextLabel.mas_bottom).offset(20);
        make.height.equalTo(@(55));
        make.bottom.equalTo(self.alertView.mas_bottom).offset(-20);
    }];
    
    [self.alertAgreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.alertDisagreeBtn.mas_right).offset(10);
        make.right.equalTo(self.alertView.mas_right).offset(-20);
        make.centerY.equalTo(self.alertDisagreeBtn.mas_centerY);
        make.width.equalTo(self.alertDisagreeBtn.mas_width);
        make.height.equalTo(@(55));
        
    }];
    
}


-(void)alertDisagreeBtnClick {
    
    if (self.resultCallBack) {
        self.resultCallBack(NO,self);
    }
}

-(void)alertAgreeBtnClick {
    
    if (self.resultCallBack) {
        self.resultCallBack(YES,self);
    }
}

#pragma mark - setter && getter
-(UIView *)launchScreenBgView {
    
    if (!_launchScreenBgView) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LaunchScreen-zh-en" bundle:nil];
        UIViewController *launchScreenVC = [storyBoard instantiateViewControllerWithIdentifier:@"LaunchScreen"];
        [self addChildViewController:launchScreenVC];
        _launchScreenBgView = launchScreenVC.view;
    }
    return _launchScreenBgView;
}

-(MOView *)maskView {
    
    if (!_maskView) {
        _maskView = [MOView new];
        _maskView.backgroundColor = [BlackColor colorWithAlphaComponent:0.2];
    }
    return _maskView;
}

-(MOView *)alertView {
    
    if (!_alertView) {
        _alertView = [MOView new];
        _alertView.backgroundColor = WhiteColor;
        [_alertView cornerRadius:QYCornerRadiusAll radius:20];
    }
    return _alertView;
}

-(UILabel *)alertTitleLabel {
    
    if (!_alertTitleLabel) {
        _alertTitleLabel = [UILabel labelWithText:NSLocalizedString(@"用户服务协议与隐私政策提示", nil) textColor:BlackColor font:MOPingFangSCBoldFont(20)];
        _alertTitleLabel.numberOfLines = 0;
        _alertTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _alertTitleLabel;
}


-(YYLabel *)alertTextLabel {
    
    if (!_alertTextLabel) {
        _alertTextLabel = [YYLabel new];
        _alertTextLabel.numberOfLines = 0;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 10;
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"请在使用前查阅", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:Color626262,NSParagraphStyleAttributeName:paragraphStyle}];
        
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"《用户协议》", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:MainSelectColor,NSParagraphStyleAttributeName:paragraphStyle}];
        [str2 yy_setTextHighlightRange:NSMakeRange(0, str2.string.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOWebViewController pushServiceAgreementWebVC];
        }];
        [str1 appendAttributedString:str2];
        
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"和", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:Color626262,NSParagraphStyleAttributeName:paragraphStyle}];
        [str1 appendAttributedString:str3];
        NSMutableAttributedString *str4 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"《隐私政策》", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:MainSelectColor,NSParagraphStyleAttributeName:paragraphStyle}];
        [str4 yy_setTextHighlightRange:NSMakeRange(0, str4.string.length) color:MainSelectColor backgroundColor:ClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            [MOWebViewController pushPrivacyAgreementWebVC];
        }];
        [str1 appendAttributedString:str4];
        
        NSMutableAttributedString *str5 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"并充分了解以下信息/权限申请情况：当您需要上传图片、拍摄功能时，我们会申请获取您的摄像头，读取存储的权限。当您在更新版本时，我们会申请获取您的存储以及软件安装的权限。", nil) attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:Color626262,NSParagraphStyleAttributeName:paragraphStyle}];
        [str1 appendAttributedString:str5];
        _alertTextLabel.attributedText = str1;
    }
    return _alertTextLabel;
    
}

-(MOButton *)alertDisagreeBtn {
    
    if (!_alertDisagreeBtn) {
        _alertDisagreeBtn = [MOButton new];
        [_alertDisagreeBtn setTitle:NSLocalizedString(@"不同意并退出", nil) titleColor:MainSelectColor bgColor:ColorEDEEF5 font:MOPingFangSCFont(15)];
        [_alertDisagreeBtn cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _alertDisagreeBtn;
}

-(MOButton *)alertAgreeBtn{
    
    if (!_alertAgreeBtn) {
        _alertAgreeBtn = [MOButton new];
        [_alertAgreeBtn setTitle:NSLocalizedString(@"同意并继续", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCFont(15)];
        [_alertAgreeBtn cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _alertAgreeBtn;
}

@end
