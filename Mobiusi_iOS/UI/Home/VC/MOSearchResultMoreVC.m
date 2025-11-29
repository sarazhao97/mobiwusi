//
//  MOSearchResultMoreVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOSearchResultMoreVC.h"
#import "MOSearchResultCell.h"
#import "MONavBarView.h"
#import "MOSearchResultCell.h"
#import "MOSearchResultHeaderCell.h"
#import "MOSearchResultModel.h"
#import "MOTaskListModel.h"
#import "MOTextFillTaskTopicVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MOVideoFillTaskTopicVC.h"
#import "MORecordingVC.h"
#import "MOTaskDetailVC.h"

@interface MOSearchResultMoreVC ()
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSString *searchKeyWord;
@property(nonatomic,strong)NSMutableArray <MOSearchResultCateModel *> *datalist;
@end

@implementation MOSearchResultMoreVC

- (instancetype)initWithDataList:(NSArray *)daraList
{
    self = [super init];
    if (self) {
        [self.datalist addObjectsFromArray:daraList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navBar];
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    
    NSDictionary *titile = @{@(1):NSLocalizedString(@"音频数据", nil),@(2):NSLocalizedString(@"图片数据",nil),@(3):NSLocalizedString(@"文本数据",nil),@(4):NSLocalizedString(@"视频数据",nil)};
    MOSearchResultCateModel *model = self.datalist.firstObject;
    self.navBar.titleLabel.text = titile[@(model.cate)];
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    self.tableView.backgroundColor = ClearColor;
    [self.tableView registerClass:[MOSearchResultCell class] forCellReuseIdentifier:@"MOSearchResultCell"];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    

    [self.tableView reloadData];
}



-(void)checkFillTaskWithModel:(MOSearchResultCateModel *)itemModel {
    
    NSDictionary *jsonDict = [itemModel yy_modelToJSONObject];
    MOTaskListModel *model = [MOTaskListModel yy_modelWithDictionary:jsonDict];
    MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:model.task_id userTaskId:model.user_task_id];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datalist.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 42.0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MOView *vi = [MOView new];
    vi.backgroundColor = ClearColor;
    return vi;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOSearchResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSearchResultCell"];
    MOSearchResultCateModel *model =  self.datalist[indexPath.row];
    [cell configCellWithData:model keyword:self.searchKeyWord];
    WEAKSELF
    cell.didAddBtnClick = ^{
        [weakSelf checkFillTaskWithModel:model];
    };
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

-(NSMutableArray<MOSearchResultSetcionModel *> *)datalist {
    
    if (!_datalist) {
        _datalist = @[].mutableCopy;
    }
    return _datalist;
}


@end
