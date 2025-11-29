//
//  MOBaseDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOBaseDataVC.h"

#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorImageView.h"
#import "JXCategoryListContainerView.h"
#import "MODataCategoryTaskVC.h"


@interface MOBaseDataVC ()
@property(nonatomic,strong)MOButton *addTaskBtn;
@property(nonatomic,strong)MOView *topView;
@property (nonatomic, strong) JXCategoryListContainerView *pageContainerView;
@end



@implementation MOBaseDataVC
@synthesize topLeftCard = _topLeftCard;
@synthesize topRightCard = _topRightCard;
@synthesize categoryTitlesView = _categoryTitlesView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.topRightCard.hidden = YES;
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    [self.addTaskBtn addTarget:self action:@selector(addTaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar.rightItemsView addArrangedSubview:self.addTaskBtn];
    [self.view addSubview:self.navBar];
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    DLog(@"%s %@",__func__,self.navigationController);
}

-(void)addUI {
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom).offset(3);
    }];
    
    
    [self.topView addSubview:self.topLeftCard];
    
    CGFloat itemCardWidth = (SCREEN_WIDTH - 2*11 - 2)/2.0;
    [self.topLeftCard.bottomBtn setTitles:NSLocalizedString(@"去管理 →", nil)];
    [self.topLeftCard mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.topView.mas_left).offset(11);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.bottom.equalTo(self.topView.mas_bottom).offset(-19);
        make.width.equalTo(@(itemCardWidth));
    }];
    
    
    [self.topView addSubview:self.topRightCard];
    self.topRightCard.bgImageView.image = [UIImage imageNamedNoCache:@"icon_data_bg_right.png"];
    self.topRightCard.titleLabel.textColor = BlackColor;
    self.topRightCard.subTitleLabel.text = NSLocalizedString(@"我能做什么", nil);
    self.topRightCard.subTitleLabel.textColor = ColorAFAFAF;
    [self.topRightCard.bottomBtn setTitles:NSLocalizedString(@"去加工 →", nil)];
    self.topRightCard.largeImageView.image = [UIImage imageNamedNoCache:@"icon_data_processAgin.png"];
    [self.topRightCard mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.topView.mas_centerY);
        make.width.equalTo(@(itemCardWidth));
        make.right.equalTo(self.topView.mas_right).offset(-11);
    }];
    
    self.categoryTitlesView.averageCellSpacingEnabled = NO;
    self.categoryTitlesView.titleColor = Color9B9B9B;
    self.categoryTitlesView.titleSelectedColor = BlackColor;
    self.categoryTitlesView.titleFont = MOPingFangSCMediumFont(13);
    self.categoryTitlesView.titleSelectedFont = MOPingFangSCBoldFont(15);
    self.categoryTitlesView.titleColorGradientEnabled = YES;
     
    JXCategoryIndicatorImageView *indicatorView = [[JXCategoryIndicatorImageView alloc] init];
    indicatorView.indicatorImageView.image = [UIImage imageNamedNoCache:@"icon_segment_s"];
    indicatorView.verticalMargin = 10;
    indicatorView.indicatorImageViewSize = CGSizeMake(52, 11);
    self.categoryTitlesView.indicators = @[indicatorView];
    
    self.pageContainerView.listCellBackgroundColor = ClearColor;

    self.categoryTitlesView.listContainer = self.pageContainerView;
    
    
    [self.view addSubview:self.categoryTitlesView];
    [self.categoryTitlesView  mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.equalTo(@(42));
    }];
    
    [self.view addSubview:self.pageContainerView];
    
    
    
    [self.pageContainerView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    self.pageContainerView.scrollView.directionalLockEnabled = YES;
    [self.pageContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryTitlesView.mas_bottom).mas_offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];
}

-(void)realodCategoryList {
    [self.pageContainerView reloadData];
}

-(void)addTaskBtnClick {
    
}
- (void)setUpUI{
    
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryTitlesView.titles.count;
}



//// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
//- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
//    
//    MODataCategoryTaskVC *vc = [MODataCategoryTaskVC new];
//    [vc manualLoadingIfLoad];
//    return vc;
//}



#pragma mark - setter && getter
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
    }
    
    return _navBar;
}

-(MOButton *)addTaskBtn {
    
    if (!_addTaskBtn) {
        _addTaskBtn = [MOButton new];
        [_addTaskBtn setImage:[UIImage imageNamedNoCache:@"icon_searchResult_add"]];
		[_addTaskBtn setEnlargeEdgeWithTop:5 left:5 bottom:5 right:5];
        [_addTaskBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    }
    return  _addTaskBtn;
}

-(MOView *)topView {
    
    if (!_topView) {
        _topView = [MOView new];
    }
    
    return _topView;
}


-(MODataTopCardView *)topLeftCard {
    
    if (!_topLeftCard) {
        _topLeftCard = [MODataTopCardView new];
    }
    
    return _topLeftCard;
}

-(MODataTopCardView *)topRightCard {
    
    if (!_topRightCard) {
        _topRightCard = [MODataTopCardView new];
    }
    
    return _topRightCard;
}

-(JXCategoryTitleView *)categoryTitlesView {
    
    if (!_categoryTitlesView) {
        _categoryTitlesView = [JXCategoryTitleView new];
    }
    
    return _categoryTitlesView;
}


-(JXCategoryListContainerView *)pageContainerView {
    
    if (!_pageContainerView) {
        _pageContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    
    return _pageContainerView;
}

@end
