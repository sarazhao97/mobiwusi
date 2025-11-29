//
//  MOWithdrawalRecordVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOWithdrawalRecordVC.h"
#import "MONavBarView.h"
#import "MOWithdrawalRecordModel.h"
#import "MOWithdrawalRecordCell.h"

@interface MOWithdrawalRecordVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger limit;
@property(nonatomic,strong)MOWithdrawalRecordModel *dataModel;
@end

@implementation MOWithdrawalRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navBar];
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    self.navBar.gobackDidClick = ^{
        
        // 使用当前视图控制器的导航控制器来返回
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // 如果没有导航控制器，使用 dismiss
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    self.navBar.titleLabel.text = NSLocalizedString(@"提现记录", nil);
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MOWithdrawalRecordCell class] forCellReuseIdentifier:@"MOWithdrawalRecordCell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, Bottom_SafeHeight, 0)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self setupEmptyView];
    self.tableView.backgroundView.hidden = YES;
    WEAKSELF
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.tableView.mj_footer resetNoMoreData];
        weakSelf.page = 1;
        [weakSelf loadRequest];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        weakSelf.tableView.mj_header.hidden = YES;
        weakSelf.page += 1;
        [weakSelf loadRequest];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    self.page = 1;
    self.limit = 50;
    [self.tableView.mj_header beginRefreshing];
    
}

-(void)loadRequest {
    
    [[MONetDataServer sharedMONetDataServer] userWithdrawaRecordWithPage:self.page limit:self.limit success:^(NSDictionary *dic) {
        MOWithdrawalRecordModel *model = [MOWithdrawalRecordModel yy_modelWithJSON:dic];
        if (self.page != 1) {
            [self.dataModel.list addObjectsFromArray:model.list];
        }else{
            self.dataModel = model;
        }
        
        if (model.list.count < 50) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView.mj_header endRefreshing];
        BOOL isEmpty = (self.dataModel.list.count == 0);
        self.tableView.backgroundView.hidden = !isEmpty;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self showErrorMessage:error.localizedFailureReason];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (self.page == 1) {
            BOOL isEmpty = (self.dataModel.list.count == 0);
            self.tableView.backgroundView.hidden = !isEmpty;
        }
        
    } msg:^(NSString *string) {
        [self showErrorMessage:string];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (self.page == 1) {
            BOOL isEmpty = (self.dataModel.list.count == 0);
            self.tableView.backgroundView.hidden = !isEmpty;
        }
    } loginFail:^{
        
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataModel.list.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MOView *vi = [MOView new];
    vi.backgroundColor = ClearColor;
    return vi;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOWithdrawalRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOWithdrawalRecordCell"];
    MOWithdrawalRecordItemModel *model = self.dataModel.list[indexPath.row];
//    MOWithdrawalRecordItemModel *model = [MOWithdrawalRecordItemModel new];
//    model.status = indexPath.row;
//    model.date_name = @"2025年03月11日10:04:18";
//    model.money = @"50";
    [cell configCellWithModel:model];
    return  cell;
}


#pragma mark - setter && getter
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        
    }
    return  _navBar;
}


-(UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleInsetGrouped];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    return _tableView;
}

- (void)setupEmptyView {
    UIView *bg = [UIView new];
    bg.backgroundColor = ClearColor;
    UIView *content = [UIView new];
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"icon_data_empty"];
    UILabel *label = [UILabel new];
    label.text = NSLocalizedString(@"暂无提现记录", nil);
    label.textColor = [UIColor colorWithHexString:@"#000000"];
    label.font = MOPingFangSCMediumFont(14);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    [bg addSubview:content];
    [content addSubview:imageView];
    [content addSubview:label];

    CGFloat verticalOffset = -40; // 上移 40pt，可按需调整
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.centerY.equalTo(bg).offset(verticalOffset);
        make.left.greaterThanOrEqualTo(bg.mas_left).offset(16);
        make.right.lessThanOrEqualTo(bg.mas_right).offset(-16);
    }];

    CGFloat imageAspect = imageView.image ? (imageView.image.size.height / imageView.image.size.width) : 1.0;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content.mas_top);
        make.centerX.equalTo(content);
        make.width.mas_equalTo(140);
        make.height.equalTo(imageView.mas_width).multipliedBy(imageAspect);
    }];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(12);
        make.left.equalTo(content.mas_left);
        make.right.equalTo(content.mas_right);
        make.bottom.equalTo(content.mas_bottom);
    }];

    self.tableView.backgroundView = bg;
}

@end
