//
//  MOMyFollowListVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/13.
//

#import "MOMyFollowListVC.h"
#import "MOHomeTaskCell.h"
#import "MORecordingVC.h"
#import "MOTaskDetailVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOMyFollowListVC ()

@property (nonatomic, strong) NSMutableArray <MOTaskListModel *> *dataList;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger limit;

@end

@implementation MOMyFollowListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
	[self.tableView registerClass:MONewHomeTaskCell.class forCellReuseIdentifier:@"MONewHomeTaskCell"];

    self.page = 1;
    self.limit = 50;
    
    WEAKSELF
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.tableView.mj_footer resetNoMoreData];
        weakSelf.page = 1;
        [weakSelf loadListData];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        weakSelf.page += 1;
        [weakSelf loadListData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    self.page = 1;
    self.limit = 50;
    [self loadListData];
    
}

-(void)requestData{
	
	[[MONetDataServer sharedMONetDataServer] getHomeTaskListWithCate:0 keyword:@"" follow:1 lat:0 lng:0 data_cate:0 page:self.page limit:self.limit success:^(NSArray *array) {
		
		NSMutableArray<MOTaskListModel *> *newArr = [NSMutableArray new];
		for (NSDictionary *dict in array) {
			MOTaskListModel *model = [MOTaskListModel yy_modelWithJSON:dict];
			
			// 暂时注释tags
//            NSMutableArray<MOTaskListTagModel *> *tags = [NSMutableArray new];
//            for (NSDictionary *tag_dict in dict[@"tags"]) {
//                MOTaskListTagModel *tagModel = [MOTaskListTagModel yy_modelWithJSON:tag_dict];
//                [tags addObject:tagModel];
//            }
//            model.tags = tags;

			NSMutableArray<MOTaskDescModel *> *task_describe = [NSMutableArray new];
			for (NSDictionary *task_describe_dict in dict[@"task_describe"]) {
				MOTaskDescModel *task_describe_model = [MOTaskDescModel yy_modelWithJSON:task_describe_dict];
				[task_describe addObject:task_describe_model];
			}
			
			model.task_describe = task_describe;
			[newArr addObject:model];
		}
	   
		if (self.page == 1) {
			[self.dataList removeAllObjects];
		}
		
		if (self.page != 1) {
			if (newArr.count > 0) {
				[self.tableView.mj_footer endRefreshing];
			} else {
				[self.tableView.mj_footer endRefreshingWithNoMoreData];
			}
		} else {
			[self.tableView.mj_header endRefreshing];
		}
		[self.dataList addObjectsFromArray:newArr];
		[self.tableView reloadData];
		
		if (self.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	} failure:^(NSError *error) {
		[self.tableView.mj_header endRefreshing];
		[self.tableView.mj_footer endRefreshing];
		[self.tableView reloadData];
		if (self.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	} msg:^(NSString *string) {
		[self.tableView.mj_header endRefreshing];
		[self.tableView.mj_footer endRefreshing];
		if (self.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
		[MBProgressHUD showMessag:string toView:MOAppDelegate.window];
	} loginFail:^{
		[self.tableView.mj_header endRefreshing];
		[self.tableView.mj_footer endRefreshing];
		if (self.dataList.count > 0) {
//            self.nodataView.hidden = YES;
		} else {
//            self.nodataView.hidden = NO;
		}
	}];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = 1;
    self.limit = 50;
    [self loadListData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    CGFloat baseY = safeAreaInsets.top+44+10;
    self.tableView.frame = CGRectMake(0, baseY, SCREEN_WIDTH, SCREEN_HEIGHT-baseY);
}

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (UITableView *)addTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_HEIGHT) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    return tableView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MONewHomeTaskCell * cell = (MOHomeTaskCell *)[tableView dequeueReusableCellWithIdentifier:@"MONewHomeTaskCell"];
    [cell configHomeCellWithModel:self.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MOTaskListModel *model = self.dataList[indexPath.item];
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

#pragma mark - JXCategoryListContentViewDelegate

 - (UIView *)listView {
     return self.view;
 }

- (NSMutableArray<MOTaskListModel *> *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
