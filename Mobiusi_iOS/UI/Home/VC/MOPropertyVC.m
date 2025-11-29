//
//  MOPropertyVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/4.
//

#import "MOPropertyVC.h"
#import "MOPropertyIncomeListCell.h"
#import "MOUserBalanceCenterModel.h"
#import "MOUserBalanceDetailsModel.h"
#import "MOUserAssetDatePickerVC.h"
#import "MOApplyCashVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOPropertyVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalAssetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayIncomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accumulatedIncomeLabel;
@property(nonatomic,assign)NSInteger page;

@property (weak, nonatomic) IBOutlet UILabel *monthIncomeExpenditureInforLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentMonthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandImageView;

@property (weak, nonatomic) IBOutlet MOButton *withdrawalBtn;


@property(nonatomic,strong)MOUserBalanceDetailsModel *userBalanceDetailsModel;
@property(nonatomic,strong)MOUserBalanceCenterModel *userBalanceCenterModel;

@property(nonatomic,copy)NSString *balanceDetailsMonth;

// 新增：空态容器视图
@property(nonatomic,strong)UIView *emptyContainerView;
@end

@implementation MOPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.backgroundColor = ClearColor;
    self.currentMonthLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    if (@available(iOS 11.0, *)){
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    self.tableView.tableFooterView = ({
        UIView *footView = [UIView new];
        footView;
    });
    [self.tableView registerNib:[UINib nibWithNibName:@"MOPropertyIncomeListCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"MOPropertyIncomeListCell"];
    self.bgImageView.backgroundColor = WhiteColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // 新增：配置空态视图（默认隐藏）
    [self setupEmptyView];
    self.tableView.backgroundView.hidden = YES;

    WEAKSELF
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf getUserBalanceDetails];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        weakSelf.tableView.mj_header.hidden = YES;
        weakSelf.page += 1;
        [weakSelf getUserBalanceDetails];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    [self.tableView.mj_header beginRefreshing];
    
    [self.bgImageView cornerRadius:QYCornerRadiusAll radius:20];
    
    [self.withdrawalBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    //修复不居中的BUG
    self.withdrawalBtn.imageAlignment = MOButtonImageAlignmentBottom + 1;
    self.withdrawalBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
    [self.withdrawalBtn setTitle:NSLocalizedString(@"   申请提现   ", nil) titleColor:Color9A1E2E bgColor:[Color9A1E2E colorWithAlphaComponent:0.1] font:MOPingFangSCBoldFont(14)];
    [self.withdrawalBtn cornerRadius:QYCornerRadiusAll radius:8];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    self.currentMonthLabel.userInteractionEnabled = YES;
    [self.currentMonthLabel addGestureRecognizer:tapGesture];
    
    self.expandImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture1.numberOfTapsRequired = 1;
    tapGesture1.numberOfTouchesRequired = 1;
    [self.expandImageView addGestureRecognizer:tapGesture1];

    self.totalAssetsLabel.text = @"0.00";
    self.yesterdayIncomeLabel.text = @"0.00";
    self.accumulatedIncomeLabel.text = @"0.00";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM";
    self.balanceDetailsMonth = [dateFormatter stringFromDate:[NSDate date]];
    dateFormatter.dateFormat = NSLocalizedString(@"yyyy年MM月", nil);
    self.currentMonthLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.monthIncomeExpenditureInforLabel.text = @"";
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(ApplyForWithdrawalSucess) name:@"ApplyForWithdrawalSucess" object:nil];

}

-(void)ApplyForWithdrawalSucess {
    
    [MOAppDelegate.transition popToViewController:self animated:YES];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadRequest];
}

-(void)loadRequest {
    
    [[MONetDataServer sharedMONetDataServer] getUserBalanceCenterSuccess:^(NSDictionary *dic) {
        
        MOUserBalanceCenterModel *model = [MOUserBalanceCenterModel yy_modelWithDictionary:dic];
        self.totalAssetsLabel.text = model.account_balance;
        self.yesterdayIncomeLabel.text = model.yesterday_income;
        self.accumulatedIncomeLabel.text = model.income_val;
        self.userBalanceCenterModel = model;
        
    } failure:^(NSError *error) {
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self showErrorMessage:string];
    } loginFail:^{
        
    }];
}

// 新增：空态视图搭建与居中约束
- (void)setupEmptyView {
    UIView *container = [[UIView alloc] initWithFrame:self.tableView.bounds];
    container.backgroundColor = [UIColor clearColor];
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 12.0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_data_empty"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat width = 140.0;
        CGFloat ratio = imageView.image.size.height / MAX(imageView.image.size.width, 1);
        [NSLayoutConstraint activateConstraints:@[
            [imageView.widthAnchor constraintEqualToConstant:width],
            [imageView.heightAnchor constraintEqualToConstant:width * ratio]
        ]];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"暂无资产明细";
    label.textColor = [UIColor colorWithHexString:@"#000000"];
    //字体加粗
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textAlignment = NSTextAlignmentCenter;

    [container addSubview:stack];
    [stack addArrangedSubview:imageView];
    [stack addArrangedSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:container.centerYAnchor constant:-40]
    ]];

    self.emptyContainerView = container;
    self.tableView.backgroundView = container;
}

-(void)getUserBalanceDetails {
    
    [[MONetDataServer sharedMONetDataServer] getUserBalanceDetailsWithMonth:self.balanceDetailsMonth page:0 limit:50 type:0 get_type:0 success:^(NSDictionary *dic) {
        MOUserBalanceDetailsModel *model = [MOUserBalanceDetailsModel yy_modelWithDictionary:dic];
        if (self.page != 1) {
            [self.userBalanceDetailsModel.list addObjectsFromArray:model.list];
        }else{
            self.userBalanceDetailsModel = model;
        }
        if (model.list.count < 50) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView.mj_header endRefreshing];
        self.monthIncomeExpenditureInforLabel.text = [NSString stringWithFormat:NSLocalizedString(@"收益%@ 提现%@", nil),model.count_data.income_val,model.count_data.withdrawal_val];
        [self.tableView reloadData];
        
        // 新增：数据为空时显示空态视图
        BOOL isEmpty = (self.userBalanceDetailsModel.list.count == 0);
        self.tableView.backgroundView.hidden = !isEmpty;
        
    } failure:^(NSError *error) {
        [self showErrorMessage:error.localizedFailureReason];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    } msg:^(NSString *string) {
        [self showErrorMessage:string];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    } loginFail:^{
        
    }];
}

-(void)handleTap:(UITapGestureRecognizer *)tap {
    
    MOUserAssetDatePickerVC *vc = [MOUserAssetDatePickerVC new];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    WEAKSELF
    vc.didConfirmButtonClick = ^(NSString * _Nonnull simpleDateStr, NSString * _Nonnull chinaDateStr, NSDate * _Nonnull date) {
        
        weakSelf.currentMonthLabel.text = chinaDateStr;
        weakSelf.balanceDetailsMonth = simpleDateStr;
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    [self presentViewController:vc animated:YES completion:^{
        
        [vc showAnimate];
    }];
    
    
}

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (void)backButtonTapped {
    [self goBack];
}

- (IBAction)applyCashClick:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MOApplyCashVC *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOApplyCashVC"];
//    targetVC.account_balance = self.userBalanceCenterModel.account_balance;
    MOWithdrawViewController *targetVC = [MOWithdrawViewController new];
    targetVC.account_balance = self.userBalanceCenterModel.account_balance;
    
    // 使用当前视图控制器的导航控制器来推送
    if (self.navigationController) {
        [self.navigationController pushViewController:targetVC animated:YES];
    } else {
        // 如果没有导航控制器，使用模态展示
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:targetVC];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userBalanceDetailsModel.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MOPropertyIncomeListCell * cell = (MOPropertyIncomeListCell *)[tableView dequeueReusableCellWithIdentifier:@"MOPropertyIncomeListCell"];
    if (cell == nil) {
        cell = [[MOPropertyIncomeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MOPropertyIncomeListCell"];
    }
    MOUserBalanceListItemModel *model = self.userBalanceDetailsModel.list[indexPath.row];
    [cell configCellWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end
