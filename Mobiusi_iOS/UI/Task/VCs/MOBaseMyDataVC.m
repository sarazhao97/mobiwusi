//
//  MOBaseMyDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/27.
//

#import "MOBaseMyDataVC.h"
#import "Mobiusi_iOS-Swift.h"
#import <UITableView+FDKeyedHeightCache.h>
#import <UITableView+FDIndexPathHeightCache.h>
@interface MOBaseMyDataVC ()
@property(nonatomic,assign)BOOL isPresented;
@end

@implementation MOBaseMyDataVC


+ (MONavigationController *)creatPresentationCustomStyleWithNavigationRootVCWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId{
    
    MOBaseMyDataVC *vc = [[[self class] alloc] initPresentationCustomStyleWithCate:cate userTaskId:userTaskId];
    MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.transitioningDelegate = vc.myTransitionDelegate;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return nav;
}
- (instancetype)initPresentationCustomStyleWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId {
    
	self = [self initWithCate:cate userTaskId:userTaskId user_paste_board:NO];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.myTransitionDelegate;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.isPresented = YES;
    }
    return self;
}

- (instancetype)initWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId user_paste_board:(BOOL)user_paste_board
{
    self = [super init];
    if (self) {
        self.cate = cate;
        self.userTaskId = userTaskId;
		self.user_paste_board = user_paste_board;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    [self.view addSubview:self.navBar];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    if (self.isPresented) {
        [self.navBar customStatusBarheight:21];
        WEAKSELF
        self.navBar.gobackDidClick = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        };
    }
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    self.tableView.backgroundColor = ClearColor;
    
    
    [self.view addSubview:self.tableView];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, Bottom_SafeHeight, 0)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    
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

-(void)goSummarizeVCWithModel:(MOUserTaskDataModel*)model{
    
    if (model.summarize_status == 2) {
		
		NSString* previewImageUrl = nil;
		if (model.cate == 2) {
			previewImageUrl = model.result.firstObject.path;
		}
		
		if (model.cate == 4) {
			previewImageUrl = model.result.firstObject.preview_url;
		}
		
        MOSummarizeVC *vc = [[MOSummarizeVC alloc] initWithCate:model.cate resultId:model.model_id previewImageUrl:previewImageUrl];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    }
}

-(void)loadRequest {
    
	[[MONetDataServer sharedMONetDataServer] getUserDataWithCate_id:self.cate user_task_id:self.userTaskId user_paste_board:self.user_paste_board page:self.page limit:self.limit success:^(NSArray *array) {
        
        NSMutableArray<MOUserTaskDataModel *> *newArr = [NSArray yy_modelArrayWithClass:[MOUserTaskDataModel class] json:array].mutableCopy;
        if (self.page == 1) {
            [self.tableView.fd_keyedHeightCache invalidateAllHeightCache];
            [self.tableView.fd_indexPathHeightCache invalidateAllHeightCache];
            [self.dataList removeAllObjects];
        }
        
        if (newArr.count > 0 && newArr.count < 50) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        if (self.page != 1) {
            if (newArr.count == 50) {
                [self.tableView.mj_footer endRefreshing];
            }
        } else {
            
            [self.tableView.mj_header endRefreshing];
        }
        
        [self.dataList addObjectsFromArray:newArr];
        [self.tableView reloadData];
        self.tableView.mj_header.hidden = NO;
        
    } failure:^(NSError *error) {
        [self showMessage:error.localizedDescription];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } msg:^(NSString *string) {
        [self showMessage:string];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } loginFail:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self hidenActivityIndicator];
		});
    }];
    
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    return nil;
    
}



#pragma mark - setter && getter
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        _navBar.titleLabel.text = NSLocalizedString(@"我的文本",nil);
    }
    
    return _navBar;
}

-(UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
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

-(NSMutableArray *)dataList {
    
    if (!_dataList) {
        _dataList = @[].mutableCopy;
    }
    return _dataList;
}


-(MOAlmostFullScreenMasDelegate *)myTransitionDelegate {
    
    if (!_myTransitionDelegate) {
        _myTransitionDelegate = [MOAlmostFullScreenMasDelegate new];
    }
    return _myTransitionDelegate;
}

@end
