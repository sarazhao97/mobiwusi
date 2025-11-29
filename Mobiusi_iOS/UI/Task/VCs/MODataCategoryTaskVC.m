//
//  MODataCategoryTaskVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MODataCategoryTaskVC.h"
#import "MODataCategoryTaskwCell.h"
#import "MOTextFillTaskTopicVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MOVideoFillTaskTopicVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MORecordingVC.h"
#import "MOPlainTextFillTaskTopicVC.h"
#import "MOTaskDetailVC.h"

@interface MODataCategoryTaskVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)BOOL isManualLoading;
@property(nonatomic,strong)MOHomeTaskSegmentVM *viewModel;
@end

@implementation MODataCategoryTaskVC

- (instancetype)initWithViewModel:(MOHomeTaskSegmentVM *)viewModel
{
	self = [super init];
	if (self) {
		self.viewModel = viewModel;
	}
	return self;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationController.interactivePopGestureRecognizer.enabled = YES;
	self.navigationController.interactivePopGestureRecognizer.delegate = nil;
	DLog(@"%s %@",__func__,self.navigationController);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.showsVerticalScrollIndicator = NO;
	[self.tableView registerClass:[MODataCategoryTaskwCell class] forCellReuseIdentifier:@"MODataCategoryTaskwCell"];
	[self.view addSubview:self.tableView];
	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.top.equalTo(self.view.mas_top).offset(10);
		make.bottom.equalTo(self.view.mas_bottom);
	}];
	
	
	WEAKSELF
	self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
		
		weakSelf.viewModel.page = 1;
		[weakSelf loadListData];
	}];
	
	self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
		weakSelf.tableView.mj_header.hidden = YES;
		weakSelf.viewModel.page += 1;
		[weakSelf loadListData];
	}];
	self.tableView.mj_footer.automaticallyHidden = YES;
	
	if (self.isManualLoading) {
		[self.tableView.mj_header beginRefreshing];
	}
	
}

-(void)manualLoadingIfLoad {
	
	if (self.isViewLoaded) {
		[self.tableView.mj_header beginRefreshing];
	} else {
		self.isManualLoading = YES;
	}
	
}


-(void)requestData{
	
	WEAKSELF
	[self.viewModel getHomeTaskListWithCate:self.viewModel.cate keyword:@"" follow:0 lat:0 lng:0 data_cate:self.viewModel.data_cate page:self.viewModel.page limit:50 success:^(NSArray *array) {
		
		if (array.count < 50) {
			[weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
		}
		
		if (weakSelf.viewModel.page != 1) {
			if (array.count == 50) {
				[weakSelf.tableView.mj_footer endRefreshing];
			}
		} else {
			
			[weakSelf.tableView.mj_header endRefreshing];
		}
		[weakSelf.viewModel.dataList addObjectsFromArray:array];
		[weakSelf.tableView reloadData];
		
		weakSelf.tableView.mj_header.hidden = NO;
		
	} failure:^(NSError *error) {
		[weakSelf.tableView.mj_header endRefreshing];
		[weakSelf.tableView.mj_footer endRefreshing];
		[weakSelf.tableView reloadData];
		weakSelf.tableView.mj_header.hidden = NO;
	} msg:^(NSString *string) {
		[weakSelf.tableView.mj_header endRefreshing];
		[weakSelf.tableView.mj_footer endRefreshing];
		weakSelf.tableView.mj_header.hidden = NO;
		[MBProgressHUD showMessag:string toView:MOAppDelegate.window];
	} loginFail:^{
		[weakSelf.tableView.mj_header endRefreshing];
		[weakSelf.tableView.mj_footer endRefreshing];
		weakSelf.tableView.mj_header.hidden = NO;
		
	} ];
}
- (void)loadListData {
	if ([MOLocationManager shared].latitude == 0) {
		WEAKSELF
		[MOLocationManager shared].onLocationUpdate = ^(double latitude, double longitude,BOOL success) {
			[weakSelf requestData];
		};
		[[MOLocationManager shared] startUpdatingLocation];
		return;
	}
	
	[self requestData];
    
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.viewModel.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 110;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MODataCategoryTaskwCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MODataCategoryTaskwCell"];
    
    [cell hiddenAllGradientLayer];
    [cell configCellWithModel:self.viewModel.dataList[indexPath.item]];
    if (indexPath.row == 0) {
        [cell showLevel1GradientLayer];
    }
    if (indexPath.row == 1) {
        [cell showLevel2GradientLayer];
    }
    
    if (indexPath.row == 2) {
        [cell showLevel3GradientLayer];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOTaskListModel *model = self.viewModel.dataList[indexPath.item];
    MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:model.task_id userTaskId:model.user_task_id];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}



#pragma mark - JXCategoryListContentViewDelegate

 - (UIView *)listView {
     return self.view;
 }



#pragma mark - setter && getter



-(UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
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


@end
