//
//  MOMessageListVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOMessageListVC.h"
#import "MONavBarView.h"
#import "MOMessageListModel.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "MOMessageListTableViewCell.h"
#import "MOTaskDetailVC.h"

@interface MOMessageListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) NSInteger dataId;
@property (nonatomic, assign) NSInteger userTaskResultId;
@property (nonatomic, assign) NSInteger dataCate;

@property(nonatomic,strong)MONavBarView *navBar;

@property(nonatomic,strong)NSMutableArray<MOMessageListItemModel *> *dataList;
@property(nonatomic,strong)MOButton *closeBtn;
@end

@implementation MOMessageListVC


- (instancetype)initPresentationCustomStyleWithDataId:(NSInteger)dataId
											 dataCate:(NSInteger)data_cate
									 userTaskResultId:(NSInteger)userTaskResultId {
    
    self = [self initWithDataId:dataId dataCate:data_cate  userTaskResultId:userTaskResultId];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.myTransitionDelegate;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.isPresented = YES;
        [self showCloseBtn];
        [self hiddenBackBtn];
    }
    return self;
}
- (instancetype)initWithDataId:(NSInteger)dataId dataCate:(NSInteger)data_cate userTaskResultId:(NSInteger)userTaskResultId
{
    self = [super init];
    if (self) {
        self.dataId = dataId;
		self.userTaskResultId = userTaskResultId;
		self.dataCate = data_cate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    WEAKSELF
    
    self.navBar.titleLabel.text = NSLocalizedString(@"消息", nil);
    [self.view addSubview:self.navBar];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    if (self.isPresented) {
        [self.navBar customStatusBarheight:21];
        self.navBar.gobackDidClick = ^{
            
            [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        };
    }
    
    
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MOMessageListTableViewCell class] forCellReuseIdentifier:@"MOMessageListTableViewCell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, Bottom_SafeHeight, 0)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
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



-(void)showCloseBtn {
    if (!self.closeBtn.superview) {
        [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(20));
            make.height.equalTo(@(20));
        }];
        [self.navBar.rightItemsView addArrangedSubview:self.closeBtn];;
    }
}

-(void)hiddenBackBtn {
    
    self.navBar.backBtn.hidden = YES;
}

-(void)closeBtnClick {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)loadRequest {
	[[MONetDataServer sharedMONetDataServer] getMessageListWithData_id:self.dataId dataCate:self.dataCate userTaskResultId:self.userTaskResultId page:self.page limit:self.limit success:^(NSDictionary *dic) {
        MOMessageListModel *model = [MOMessageListModel yy_modelWithJSON:dic];
        if (self.page != 1) {
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.dataList removeAllObjects];
            [[self.tableView fd_keyedHeightCache] invalidateAllHeightCache];
            [self.tableView.mj_header endRefreshing];
        }
        if (model.list.count < 50) {

            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.dataList addObjectsFromArray:model.list];
        [self.tableView  reloadData];
        
    } failure:^(NSError *error) {
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self showErrorMessage:string];
    } loginFail:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self hidenActivityIndicator];
		});
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    MOView *vi = [MOView new];
    vi.backgroundColor = ClearColor;
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 1.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MOView *vi = [MOView new];
    vi.backgroundColor = ClearColor;
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOMessageListItemModel *model = self.dataList[indexPath.section];

    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMessageListTableViewCell" cacheByKey:key configuration:^(MOMessageListTableViewCell * cell) {
        [cell configWithModel:model];
    }];
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MOMessageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOMessageListTableViewCell"];
    MOMessageListItemModel *model = self.dataList[indexPath.section];
    [cell configWithModel:model];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOMessageListItemModel *model = self.dataList[indexPath.section];
    if (model.type_id == 2) {
        MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:model.task_id userTaskId:model.relate_id];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    }
    
}


#pragma mark - setter && getter
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        _navBar.titleLabel.text = NSLocalizedString(@"消息", nil);
    }
    
    return _navBar;
}

-(NSMutableArray<MOMessageListItemModel *> *)dataList {
    
    if (!_dataList) {
        _dataList = @[].mutableCopy;
    }
    return _dataList;
}

-(UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleInsetGrouped];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = ClearColor;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    return _tableView;
}

-(MOAlmostFullScreenMasDelegate *)myTransitionDelegate {
    
    if (!_myTransitionDelegate) {
        _myTransitionDelegate = [MOAlmostFullScreenMasDelegate new];
    }
    return _myTransitionDelegate;
}

-(MOButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [MOButton new];
        [_closeBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
        [_closeBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_close.png"]];
    }
    return _closeBtn;
}

@end
