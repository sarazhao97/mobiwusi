//
//  MOSearchVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOSearchVC.h"
#import "MOSearchNavBarView.h"
#import "MOHotSearchDataCell.h"
#import "MOHotSearchHeader.h"
#import "MOSearchHistoryHeader.h"
#import "MOSearchResultVC.h"
#import "MOUserTaskDataModel.h"
#import "MOHotSearchListItemModel.h"

@interface MOSearchVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MOSearchNavBarView *navBar;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray<NSString *> *searchHistoryList;
@property(nonatomic,strong)NSMutableArray<MOHotSearchListItemModel *> *hostSearchDataList;
@end

@implementation MOSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WEAKSELF
    [[NSNotificationCenter defaultCenter] addObserverForName:SearchKeyWordNew object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        NSString *keyword = notification.object;
        [weakSelf.searchHistoryList insertObject:keyword atIndex:0];
        [weakSelf updateLocalSearchHistoryList];
        [weakSelf configTableHeader];
    }];
    
    [self.view addSubview:self.navBar];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    
    self.navBar.didSearch = ^(NSString * _Nonnull keyWord,UITextField *textFiled) {
        textFiled.text = @"";
        if (keyWord) {
            MOSearchResultVC *vc = [[MOSearchResultVC alloc] initWithSearchKeyWord:keyWord];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
            [weakSelf.searchHistoryList insertObject:keyWord atIndex:0];
            [weakSelf updateLocalSearchHistoryList];
            [weakSelf configTableHeader];
        }
    };
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(44));
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    
    
    
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    [self.tableView registerClass:[MOHotSearchDataCell class] forCellReuseIdentifier:@"MOHotSearchDataCell"];
    [self.tableView registerClass:[MOHotSearchHeader class] forCellReuseIdentifier:@"MOHotSearchHeader"];
    [self.tableView registerClass:[MOTableViewCell class] forCellReuseIdentifier:@"MOHotSearchFooter"];
    self.tableView.backgroundColor = ClearColor;
    [self.view addSubview:self.tableView];
    
    [self configTableHeader];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self loadRequest];
}

-(void)loadRequest {
    
    [[MONetDataServer sharedMONetDataServer] getHotSearchListWithCate_id:0 page:1 limit:9 success:^(NSArray *array) {
        
        NSArray *newArray = [NSArray yy_modelArrayWithClass:[MOHotSearchListItemModel class] json:array];
        [self.hostSearchDataList addObjectsFromArray:newArray];
        [self.tableView reloadData];
        DLog(@"%@",array);
        
    } failure:^(NSError *error) {
        
    } msg:^(NSString *string) {
        
    } loginFail:^{
        
    }];
}

-(void)updateLocalSearchHistoryList {
    
    if (self.searchHistoryList.count > 50) {
        self.searchHistoryList = [self.searchHistoryList subarrayWithRange:NSMakeRange(0, 50)].mutableCopy;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.searchHistoryList forKey:SearchHistoryList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)configTableHeader {
    
    NSArray *list =   [[NSUserDefaults standardUserDefaults] objectForKey:SearchHistoryList];
    self.searchHistoryList = list?list.mutableCopy:@[].mutableCopy;
    if (list.count > 0) {
        MOSearchHistoryHeader *tableHeader = [MOSearchHistoryHeader new];
        tableHeader.didSelectHistorySearch = ^(NSString * _Nonnull text) {
            MOSearchResultVC *vc = [[MOSearchResultVC alloc] initWithSearchKeyWord:text];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
        };
        WEAKSELF
        tableHeader.didClearHistorySearch = ^{
            [weakSelf.searchHistoryList removeAllObjects];
            [weakSelf updateLocalSearchHistoryList];
            weakSelf.tableView.tableHeaderView = nil;
            [weakSelf.tableView reloadData];
        };
        CGSize szie = [tableHeader systemLayoutSizeFittingSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
        self.tableView.tableHeaderView = tableHeader;
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, szie.height);
    }
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.hostSearchDataList.count > 0) {
        
        return self.hostSearchDataList.count + 2;
    }
    return self.hostSearchDataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 52.0;
    }
    if (indexPath.row == self.hostSearchDataList.count + 1) {
        return 10;
    }
    return 46.0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        MOHotSearchHeader *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOHotSearchHeader"];
        
        return cell;
        
    } else if (indexPath.row > self.hostSearchDataList.count){
        
        MOTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOHotSearchFooter"];
        cell.backgroundColor = WhiteColor;
        return cell;
        
    }else  {
        MOHotSearchDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOHotSearchDataCell"];
        NSArray<UIColor *> *indexLabelBgColors = @[ColorEC0000,ColorEC6200,ColorECC800];
        cell.indexLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        UIColor *bg = ColorAFAFAF;
        if (indexPath.row - 1 < 3) {
            bg = indexLabelBgColors[indexPath.row - 1];
        }
        cell.indexLabel.backgroundColor = bg;
        MOHotSearchListItemModel *model = self.hostSearchDataList[indexPath.row - 1];
        cell.searchTextLabel.text = model.title;
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        return;
    }
    if (indexPath.row > self.hostSearchDataList.count){
        return;
    }
    MOHotSearchListItemModel *model = self.hostSearchDataList[indexPath.row - 1];
    MOSearchResultVC *vc = [[MOSearchResultVC alloc] initWithSearchKeyWord:model.title];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
    [[MONetDataServer sharedMONetDataServer] hostSearchAddClickWithTask_id:model.model_id success:^(id obj) {
        
    } failure:^(NSError *error) {
        
    } msg:^(NSString *string) {
        
    } loginFail:^{
        
    }];
    
    
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


-(NSMutableArray<NSString *> *)searchHistoryList {
    if (!_searchHistoryList) {
        _searchHistoryList = @[].mutableCopy;
    }
    return _searchHistoryList;
}

-(NSMutableArray<MOUserTaskDataModel *> *)hostSearchDataList {
    
    if (!_hostSearchDataList) {
        _hostSearchDataList = @[].mutableCopy;
    }
    return _hostSearchDataList;
}
@end
