//
//  MOSearchResultVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOSearchResultVC.h"
#import "MOSearchNavBarView.h"
#import "MOSearchResultCell.h"
#import "MOSearchResultHeaderCell.h"
#import "MOSearchResultModel.h"
#import "MOTaskListModel.h"
#import "MOTextFillTaskTopicVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MOVideoFillTaskTopicVC.h"
#import "MORecordingVC.h"
#import "MOSearchResultMoreVC.h"
#import "MOTaskDetailVC.h"
@interface MOSearchResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MOSearchNavBarView *navBar;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSString *searchKeyWord;
@property(nonatomic,strong)NSMutableArray <MOSearchResultSetcionModel *> *setcionDataList;
@property(nonatomic,strong)MOSearchResultModel *dataModel;
@end

@implementation MOSearchResultVC


- (instancetype)initWithSearchKeyWord:(NSString *)searchKeyWord
{
    self = [super init];
    if (self) {
        self.searchKeyWord = searchKeyWord;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.navBar];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    
    self.navBar.didSearch = ^(NSString * _Nonnull keyWord,UITextField *textFiled) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SearchKeyWordNew object:keyWord];
        DLog(@"%@",keyWord);
    };
    self.navBar.didDeleteAllSearchTFText = ^(UITextField * _Nonnull textFiled) {
        [MOAppDelegate.transition popViewControllerAnimated:NO];
    };
    self.navBar.searchTF.text = self.searchKeyWord;
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(44));
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    self.tableView.backgroundColor = ClearColor;
    [self.tableView registerClass:[MOSearchResultCell class] forCellReuseIdentifier:@"MOSearchResultCell"];
    [self.tableView registerClass:[MOTableViewCell class] forCellReuseIdentifier:@"MOSearchResultFooter"];
    [self.tableView registerClass:[MOSearchResultHeaderCell class] forCellReuseIdentifier:@"MOSearchResultHeaderCell"];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self loadRequest];
}

-(void)loadRequest{
    
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] getMultiSearchWithKeyword:self.searchKeyWord limit:0 success:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        MOSearchResultModel *model = [MOSearchResultModel yy_modelWithJSON:dic];
        self.dataModel = model;
        [self processData];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self hidenActivityIndicator];
        
    } msg:^(NSString *string) {
        [self hidenActivityIndicator];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
}

-(void)processData {
    
    if (self.dataModel.audio_list.count) {
        MOSearchResultSetcionModel *model = [MOSearchResultSetcionModel new];
        model.title = NSLocalizedString(@"音频数据", nil);
        model.cate = 1;
        model.setcionDataList = @[].mutableCopy;
        [model.setcionDataList addObjectsFromArray:self.dataModel.audio_list];
        [self.setcionDataList addObject:model];
    }
    
    if (self.dataModel.image_list.count) {
        MOSearchResultSetcionModel *model = [MOSearchResultSetcionModel new];
        model.title = NSLocalizedString(@"图片数据", nil);
        model.cate = 2;
        model.setcionDataList = @[].mutableCopy;
        [model.setcionDataList addObjectsFromArray:self.dataModel.image_list];
        [self.setcionDataList addObject:model];
    }
    
    if (self.dataModel.text_list.count) {
        MOSearchResultSetcionModel *model = [MOSearchResultSetcionModel new];
        model.title = NSLocalizedString(@"文本数据", nil);
        model.cate = 3;
        model.setcionDataList = @[].mutableCopy;
        [model.setcionDataList addObjectsFromArray:self.dataModel.text_list];
        [self.setcionDataList addObject:model];
    }
    
    
    if (self.dataModel.video_list.count) {
        MOSearchResultSetcionModel *model = [MOSearchResultSetcionModel new];
        model.title = NSLocalizedString(@"视频数据", nil);
        model.cate = 4;
        model.setcionDataList = @[].mutableCopy;
        [model.setcionDataList addObjectsFromArray:self.dataModel.video_list];
        [self.setcionDataList addObject:model];
    }
    
    
}

-(void)checkFillTaskWithModel:(MOSearchResultCateModel *)itemModel {
    
    NSDictionary *jsonDict = [itemModel yy_modelToJSONObject];
    MOTaskListModel *model = [MOTaskListModel yy_modelWithDictionary:jsonDict];
    MOTaskDetailVC *vc = [[MOTaskDetailVC alloc] initWithTaskId:model.task_id userTaskId:model.user_task_id];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.setcionDataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.setcionDataList[section].setcionDataList.count + 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 40;
    }
    
    if (indexPath.row > self.setcionDataList[indexPath.section].setcionDataList.count) {
        return 17;
    }
    return 42.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 20;
    }
    
    return 10.0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MOView *vi = [MOView new];
    vi.backgroundColor = ClearColor;
    return vi;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        MOSearchResultHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSearchResultHeaderCell"];
        NSDictionary *icons = @{@(1):@"icon_data_audio_small.png",@(2):@"icon_data_picture_small.png",@(3):@"icon_data_text_small.png",@(4):@"icon_data_video_small.png"};
        MOSearchResultSetcionModel *model = self.setcionDataList[indexPath.section];
        cell.categoryLabel.text = model.title;
        cell.iconImageView.image = [UIImage imageNamedNoCache:icons[@(model.cate)]];
        cell.moreBtn.hidden = self.setcionDataList[indexPath.section].setcionDataList.count < 4;
        WEAKSELF
        cell.didClickMoreBtn = ^{
            MOSearchResultSetcionModel *model =  weakSelf.setcionDataList[indexPath.section];
            MOSearchResultMoreVC *vc = [[MOSearchResultMoreVC alloc] initWithDataList:model.setcionDataList];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
        };
        return  cell;
        
        
        
    } else if (indexPath.row > self.setcionDataList[indexPath.section].setcionDataList.count){
        MOTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSearchResultFooter"];
        return  cell;
    }else  {
        MOSearchResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSearchResultCell"];
        MOSearchResultCateModel *model =  self.setcionDataList[indexPath.section].setcionDataList[indexPath.row - 1];
        [cell configCellWithData:model keyword:self.searchKeyWord];
        WEAKSELF
        cell.didAddBtnClick = ^{
            [weakSelf checkFillTaskWithModel:model];
        };
        return  cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return;
    }
    if (indexPath.row > self.setcionDataList[indexPath.section].setcionDataList.count){
        
        return;
    }
    MOSearchResultCateModel *model =  self.setcionDataList[indexPath.section].setcionDataList[indexPath.row - 1];
    [self checkFillTaskWithModel:model];
}

#pragma mark - setter && getter
-(MOSearchNavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MOSearchNavBarView new];
        
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

-(NSMutableArray<MOSearchResultSetcionModel *> *)setcionDataList {
    
    if (!_setcionDataList) {
        _setcionDataList = @[].mutableCopy;
    }
    return _setcionDataList;
}

@end
