//
//  MOHomeProfitReminderVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOHomeProfitReminderVC.h"
#import "MOView.h"

@interface MOHomeProfitReminderVC ()
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UIImageView *topHeader;
@property(nonatomic,strong)UILabel *topTitleLabel;
@property(nonatomic,strong)UILabel *topSubTitleLabel;
@property(nonatomic,strong)UIImageView *topGoldCoinIcon;
@property(nonatomic,strong)UIImageView *bottomImageView;
@property(nonatomic,strong)UILabel *bottomTitleLabel;
@property(nonatomic,strong)UILabel *revenueAmountLabel;
@property(nonatomic,strong)UILabel *tipLabel;
@property(nonatomic,strong)MOButton *viewDetailsBtn;
@property(nonatomic,strong)MOButton *leavlBtn;
@property(nonatomic,strong)MOButton *closeBtn;
@property(nonatomic,strong)NSString *revenueAmount;
@end

@implementation MOHomeProfitReminderVC


-(instancetype)initWithRevenueAmount:(NSString *)revenueAmount {
    self = [super init];
    if (self) {
        self.revenueAmount = revenueAmount;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [BlackColor colorWithAlphaComponent:0.6];
    
    
//    NSArray <NSString *> *familyNames = [UIFont familyNames];
//       for (NSString *familyName in familyNames) {
//           NSLog(@"Font Family: %@", familyName);
//           
//           // 获取每个字体家族下的所有字体名称
//           NSArray <NSString *> *fontNames = [UIFont fontNamesForFamilyName:familyName];
//           for (NSString *fontName in fontNames) {
//               NSLog(@"  Font Name: %@", fontName);
//           }
//       }
    
    
    [self.view addSubview:self.contentView];
    if (SCREEN_WIDTH < 414) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.9, 0.9);
        self.contentView.transform = scaleTransform;
    }
    
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
        
    }];
    
    [self.contentView addSubview:self.topHeader];
    [self.topHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.contentView.mas_top);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    
    [self.topHeader addSubview:self.topTitleLabel];
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.topHeader.mas_top).offset(22);
        make.left.equalTo(self.topHeader.mas_left).offset(21);
    }];
    
    
    [self.topHeader addSubview:self.topSubTitleLabel];
    [self.topSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.topTitleLabel.mas_bottom).offset(5);
        make.left.equalTo(self.topHeader.mas_left).offset(21);
    }];
    
    
    [self.topHeader addSubview:self.topGoldCoinIcon];
    [self.topGoldCoinIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.right.equalTo(self.topHeader.mas_right).offset(45);
        make.top.equalTo(self.topHeader.mas_top).offset(-45);
    }];
    
    
    [self.contentView addSubview:self.bottomImageView];
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.topHeader.mas_bottom).offset(-20);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [self.bottomImageView addSubview:self.bottomTitleLabel];
    [self.bottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.bottomImageView.mas_centerX);
        make.top.equalTo(self.bottomImageView.mas_top).offset(46);
    }];
    
    [self.bottomImageView addSubview:self.revenueAmountLabel];
    [self.revenueAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.bottomImageView.mas_centerX);
        make.top.equalTo(self.bottomTitleLabel.mas_bottom).offset(32);
    }];
    
    
    [self.bottomImageView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.bottomImageView.mas_centerX);
        make.top.equalTo(self.revenueAmountLabel.mas_bottom).offset(10);
    }];
    
    [self.bottomImageView addSubview:self.viewDetailsBtn];
    [self.viewDetailsBtn addTarget:self action:@selector(viewDetailClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewDetailsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.bottomImageView.mas_centerX);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(15);
        make.width.equalTo(@80);
        make.height.equalTo(@26);
    }];
    [self.viewDetailsBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    
    [self.bottomImageView addSubview:self.leavlBtn];
    [self.leavlBtn addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    [self.leavlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@(55));
        make.top.equalTo(self.viewDetailsBtn.mas_bottom).offset(44);
        make.left.equalTo(self.bottomImageView.mas_left).offset(20);
        make.right.equalTo(self.bottomImageView.mas_right).offset(-20);
    }];
    
    [self.contentView addSubview:self.closeBtn];
    [self.closeBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.closeBtn addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.bottomImageView.mas_bottom).offset(12);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
    
    
}

-(NSMutableAttributedString *)createRevenueAmountAttributedStringWithRevenueAmount:(NSString *)revenueAmount {
    
    if (![revenueAmount  length]) {
        revenueAmount = @"0.00";
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:revenueAmount attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(40),NSForegroundColorAttributeName: MainSelectColor}];
    NSMutableAttributedString *uitString = [[NSMutableAttributedString alloc] initWithString:@"元" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(20),NSForegroundColorAttributeName: MainSelectColor}];
    [string appendAttributedString:uitString];
    return string;
}

-(void)viewDetailClick{
    
    [self closePage];
    if (self.didClickViewDetail) {
        self.didClickViewDetail();
    }
    
}


-(void)closePage {
    
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:NO completion:NULL];
    } else{
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}
#pragma mark - setter && getter
-(MOView *)contentView {
    
    if (!_contentView) {
        _contentView = [MOView new];
        _contentView.backgroundColor = ClearColor;
    }
    
    return _contentView;
}

-(UIImageView *)topHeader {
    
    if (!_topHeader) {
        _topHeader = [UIImageView new];
        _topHeader.image = [UIImage imageNamedNoCache:@"icon_ProfitReminder_topBg.png"];
    }
    
    return _topHeader;
}

-(UILabel *)topTitleLabel {
    
    if (!_topTitleLabel) {
        _topTitleLabel = [UILabel labelWithText:NSLocalizedString(@"恭喜您！", nil) textColor:WhiteColor font:MOPingFangSCFont(30)];
    }
    
    return _topTitleLabel;
}

-(UILabel *)topSubTitleLabel{
    
    if (!_topSubTitleLabel) {
        _topSubTitleLabel = [UILabel labelWithText:NSLocalizedString(@"您的数据收益已到账！", nil) textColor:WhiteColor font:MOPingFangSCHeavyFont(14)];
    }
    
    return _topSubTitleLabel;
}

-(UIImageView *)topGoldCoinIcon {
    if (!_topGoldCoinIcon) {
        _topGoldCoinIcon = [UIImageView new];
        _topGoldCoinIcon.image = [UIImage imageNamedNoCache:@"icon_ProfitReminder_GoldCoin.png"];
        _topGoldCoinIcon.userInteractionEnabled = YES;
    }
    return _topGoldCoinIcon;
}

-(UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [UIImageView new];
        _bottomImageView.image = [UIImage imageNamedNoCache:@"icon_ProfitReminder_bottomBg.png"];
        _bottomImageView.userInteractionEnabled = YES;
    }
    
    return _bottomImageView;
}

-(UILabel *)bottomTitleLabel{
    
    if (!_bottomTitleLabel) {
        _bottomTitleLabel = [UILabel labelWithText:NSLocalizedString(@"项目新增收益", nil) textColor:BlackColor font:MOPingFangSCBoldFont(18)];
    }
    
    return _bottomTitleLabel;
}

-(UILabel *)revenueAmountLabel{
    
    if (!_revenueAmountLabel) {
        _revenueAmountLabel = [UILabel new];
        _revenueAmountLabel.attributedText = [self createRevenueAmountAttributedStringWithRevenueAmount:self.revenueAmount];
    }
    
    return _revenueAmountLabel;
}

-(UILabel *)tipLabel{
    
    if (!_tipLabel) {
        _tipLabel = [UILabel labelWithText:NSLocalizedString(@"收益已存入资产可提现", nil) textColor:Color9B9B9B font:MOPingFangSCFont(13)];
    }
    
    return _tipLabel;
}

-(MOButton *)viewDetailsBtn {
    if (!_viewDetailsBtn) {
        _viewDetailsBtn = [MOButton new];
        [_viewDetailsBtn setTitle:NSLocalizedString(@"查看详情", nil) titleColor:MainSelectColor bgColor:[MainSelectColor colorWithAlphaComponent:0.15] font:MOPingFangSCFont(12)];
        [_viewDetailsBtn cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _viewDetailsBtn;
}

-(MOButton *)leavlBtn {
    if (!_leavlBtn) {
        _leavlBtn = [MOButton new];
        [_leavlBtn setTitle:NSLocalizedString(@"开心收下", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCHeavyFont(12)];
        [_leavlBtn cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _leavlBtn;
}

-(MOButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [MOButton new];
        [_closeBtn setImage:[UIImage imageNamedNoCache:@"icon_ProfitReminder_close_white.png"]];
    }
    return _closeBtn;
}

@end
