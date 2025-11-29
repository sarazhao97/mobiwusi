//
//  MOHomeTaskSegmentVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/29.
//

#import "MOHomeTaskSegmentVC.h"
#import "MOHomeTaskCell.h"
#import "MORecordingVC.h"
#import "MOTaskDetailVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOHomeTaskSegmentVC ()

@end

@implementation MOHomeTaskSegmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MOHomeTaskCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"MOHomeTaskCell"];
	[self.tableView registerClass:[MONewHomeTaskCell class] forCellReuseIdentifier:@"MONewHomeTaskCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
    WEAKSELF
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.edges.equalTo(self.view);
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.tableView.mj_footer resetNoMoreData];
        weakSelf.viewModel.page = 1;
        [weakSelf loadListData];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        weakSelf.viewModel.page += 1;
        [weakSelf loadListData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    self.viewModel.page = 1;
    self.viewModel.limit = 20;
    [self loadListData];
}



-(void)requestData{
	
	[self.viewModel getHomeTaskListWithCate:self.viewModel.cate keyword:@"" follow:0 lat:[MOLocationManager shared].latitude lng:[MOLocationManager shared].longitude data_cate:0 page:self.viewModel.page limit:self.viewModel.limit success:^(NSArray *array) {
		if (self.viewModel.page != 1) {
			if (array.count > 0) {
				[self.tableView.mj_footer endRefreshing];
			} else {
				[self.tableView.mj_footer endRefreshingWithNoMoreData];
			}
		} else {
			[self.tableView.mj_header endRefreshing];
		}
		[self.viewModel.dataList addObjectsFromArray:array];
		[self.tableView reloadData];
		
		if (self.viewModel.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	} failure:^(NSError *error) {
		[self.tableView.mj_header endRefreshing];
		[self.tableView.mj_footer endRefreshing];
		[self.tableView reloadData];
		if (self.viewModel.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	} msg:^(NSString *string) {
		[self.tableView.mj_header endRefreshing];
		[self.tableView.mj_footer endRefreshing];
		if (self.viewModel.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
		[MBProgressHUD showMessag:string toView:MOAppDelegate.window];
	} loginFail:^{
		[self.tableView.mj_header endRefreshing];
		
		if (self.viewModel.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	} ];
}

- (void)loadListData {
	
	if ([MOLocationManager shared].latitude == 0) {
		WEAKSELF
		[MOLocationManager shared].onLocationUpdate = ^(double latitude, double longitude,BOOL success) {
			DLog("获取到定位=====")
			[weakSelf requestData];
		};
		[[MOLocationManager shared] startUpdatingLocation];
		return;
	}
	
	[self requestData];
	
    
}

- (UITableView *)addTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1000) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
    return tableView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MONewHomeTaskCell * cell = (MOHomeTaskCell *)[tableView dequeueReusableCellWithIdentifier:@"MONewHomeTaskCell"];
	[cell configHomeCellWithModel:self.viewModel.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MOTaskListModel *model = self.viewModel.dataList[indexPath.item];
    MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:model.task_id userTaskId:model.user_task_id];
	vc.didChangedRecevingTaskStatuts = ^(BOOL isGiveUp) {
		if (isGiveUp) {
			model.remaining_places ++;
			[tableView reloadData];
			return;
		}
		
		model.remaining_places --;
		[tableView reloadData];
	};
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}



- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    DLog(@"%s %f   %f",__func__,velocity.x,velocity.y);
    if ( velocity.y > 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 377) animated:YES];
    }
    
    if (velocity.y < 0 && scrollView.contentOffset.y <= 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
}


#pragma mark - JXCategoryListContentViewDelegate

 - (UIView *)listView {
     return self.view;
 }

#pragma mark - setter & getter

- (MOHomeTaskSegmentVM *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [MOHomeTaskSegmentVM new];
    }
    return _viewModel;
}

@end
