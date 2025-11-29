//
//  MOMyTaskSegmentVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/13.
//

#import "MOMyTaskSegmentVC.h"
#import "MOHomeTaskCell.h"
#import "MORecordingVC.h"
#import "MOTaskDetailVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOMyTaskSegmentVC ()

@property (nonatomic, strong) NSMutableArray <MOTaskListModel *> *dataList;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger limit;

@end

@implementation MOMyTaskSegmentVC


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    DLog(@"%s %@",__func__,self.navigationController);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"MOHomeTaskCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"MOHomeTaskCell"];
	[self.tableView registerClass:MOMyTaskcell.class forCellReuseIdentifier:@"MOMyTaskcell"];
	

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

- (void)loadListData {
    [[MONetDataServer sharedMONetDataServer] getMyTaskListWithCate_id:0 task_status:self.status page:self.page limit:self.limit success:^(NSArray *array) {
        
        NSMutableArray<MOMyTaskListModel *> *newArr = [NSMutableArray new];
        for (NSDictionary *dict in array) {
            MOMyTaskListModel *model = [MOMyTaskListModel yy_modelWithJSON:dict];
            
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = 1;
    self.limit = 50;
    [self loadListData];
    
}

- (UITableView *)addTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_HEIGHT-50) style:UITableViewStyleGrouped];
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
	MOMyTaskcell * cell = (MOMyTaskcell *)[tableView dequeueReusableCellWithIdentifier:@"MOMyTaskcell"];
    [cell configMyTaskCellWithModel:self.dataList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MOTaskListModel *taskListModel = self.dataList[indexPath.row];
    MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:taskListModel.task_id userTaskId:taskListModel.user_task_id];
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
