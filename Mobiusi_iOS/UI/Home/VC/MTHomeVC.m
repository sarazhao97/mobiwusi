//
//  MTHomeVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/20.
//

#import "MTHomeVC.h"
#import "MTHomeBalanceView.h"
#import "MOHomeCatView.h"
#import "MOHomeLabelView.h"
#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorImageView.h"
#import "JXCategoryListContainerView.h"
#import "MOHomeTaskSegmentVC.h"
#import "MOHomeVM.h"
#import "UIButton+WebCache.h"
#import "MOHomeSearchBarView.h"
#import "MOSearchVC.h"
#import "MOHomeProfitReminderVC.h"
#import "MOBaseDataVC.h"
#import "MOTextDataVC.h"
#import "MOAudioDataVC.h"
#import "MOPictureDataVC.h"
#import "MOVideoDataVC.h"
#import "MOTextFillTaskTopicVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MOVideoFillTaskTopicVC.h"
#import "MOMyAllDataVC.h"
#import "Mobiusi_iOS-Swift.h"

static const CGFloat segmentHeight = 50;

@interface MTHomeVC ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MTHomeBalanceView *balanceView;
@property (nonatomic, strong) MOHomeCatView *dataCatView;
@property (nonatomic, strong) MOHomeCatView *newAbilityView;
@property (nonatomic, strong) MOHomeLabelView *labelView;
@property (nonatomic, strong) JXCategoryTitleView *taskCatView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) MOHomeSearchBarView *searchBarView;
@property(nonatomic,strong)MOView *collectionProjectContentView;
@property(nonatomic,strong)MOView *processingDataContentView;
@property(nonatomic,weak)MOAudioProcessListVC *processingDataVC;
@property (nonatomic, strong) MOHomeVM *viewModel;
@property (nonatomic, assign) bool mainScrollEnable;
@property (nonatomic, strong) NSMutableArray<MOHomeTaskSegmentVC *> *vcs;
@end

@implementation MTHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    self.mainScrollView.delegate = self;
    self.mainScrollEnable = YES;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.delaysContentTouches = YES;
    self.topViewHeight.constant = STATUS_BAR_HEIGHT+15+44;
    self.userButton.layer.borderWidth = 1.f;
    self.userButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    [self.mainScrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainScrollView.mas_left);
        make.right.equalTo(self.mainScrollView.mas_right);
        make.top.equalTo(self.mainScrollView.mas_top);
        make.width.equalTo(self.mainScrollView);
        make.bottom.equalTo(self.mainScrollView.mas_bottom);
    }];
    
    [self.contentView addSubview:self.balanceView];
    [self.balanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(92);
    }];
    
    [self.contentView addSubview:self.searchBarView];
    WEAKSELF
    self.searchBarView.didSearch = ^{
        
        [weakSelf.view endEditing:YES];
        MOSearchVC *vc = [MOSearchVC new];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.balanceView.mas_bottom).mas_offset(0);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(55);
    }];
    
    [self.contentView addSubview:self.dataCatView];
    [self.dataCatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarView.mas_bottom).mas_offset(10);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(100); // 85*row+15
    }];
	
	
	[self.contentView addSubview:self.newAbilityView];
	[self.newAbilityView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.dataCatView.mas_bottom).mas_offset(10);
		make.left.right.equalTo(self.contentView);
		make.height.mas_equalTo(100); // 85*row+15
	}];
    
    
    
    [self setupCollectionProjectUI];
    
    [self checkIncomeTip];
}

-(void)setupCollectionProjectUI{
    
    
    [self.contentView addSubview:self.collectionProjectContentView];
    [self.collectionProjectContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.newAbilityView.mas_bottom).offset(10);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [self.collectionProjectContentView addSubview:self.taskCatView];
    self.taskCatView.backgroundColor = ColorEDEEF5;
    [self.taskCatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionProjectContentView);
        make.left.equalTo(self.collectionProjectContentView);
        make.right.equalTo(self.collectionProjectContentView);
        make.height.mas_equalTo(segmentHeight);
    }];
    
    
    self.taskCatView.titles = @[NSLocalizedString(@"热门", nil), NSLocalizedString(@"音频", nil), NSLocalizedString(@"图片", nil), NSLocalizedString(@"文本", nil), NSLocalizedString(@"视频", nil)];
    self.taskCatView.titleColor = [UIColor colorWithHexString:@"333333" alpha:0.5];
    self.taskCatView.titleSelectedColor = [UIColor colorWithHexString:@"333333"];
    self.taskCatView.titleFont = [UIFont systemFontOfSize:13];
    self.taskCatView.titleSelectedFont = [UIFont boldSystemFontOfSize:17];
    self.taskCatView.titleColorGradientEnabled = YES;
    self.taskCatView.averageCellSpacingEnabled = NO;
    self.taskCatView.cellSpacing = 38.0;
    
    JXCategoryIndicatorImageView *indicatorView = [[JXCategoryIndicatorImageView alloc] init];
    indicatorView.indicatorImageView.image = [UIImage imageNamedNoCache:@"icon_segment_s"];
    indicatorView.verticalMargin = 8;
    indicatorView.indicatorImageViewSize = CGSizeMake(40, 15);
    self.taskCatView.indicators = @[indicatorView];
    
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.listCellBackgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
    
    self.taskCatView.listContainer = self.listContainerView;
    
    [self.collectionProjectContentView addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.taskCatView.mas_bottom);
        make.left.equalTo(self.collectionProjectContentView.mas_left);
        make.right.equalTo(self.collectionProjectContentView.mas_right);
        make.height.equalTo(@(SCREEN_HEIGHT - 79 - 50 ));
        make.bottom.equalTo(self.collectionProjectContentView.mas_bottom);
    }];
}




-(void)checkIncomeTip {
    WEAKSELF
    [MOHomeVM getincomeTipWithSuccess:^(id obj) {
        
        MOIncomeTipModel *model  = obj;
        if (model.income_count > 0) {
            MOHomeProfitReminderVC *alertVC = [[MOHomeProfitReminderVC alloc] initWithRevenueAmount:model.income_val];
            alertVC.didClickViewDetail = ^{
                [weakSelf balanceViewTap];
            };
            [MOAppDelegate.transition presentViewControllerWithAlertStyle:alertVC animated:NO completion:^{
    
            }];
        }
        
    } failure:NULL msg:NULL loginFail:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.viewModel getUserInfoSuccess:^(NSDictionary *dic) {
        MOUserModel *user = [MOUserModel unarchiveUserModel];
        // 头像
        [self.userButton sd_setImageWithURL:[NSURL URLWithString:user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamedNoCache:@"icon_user_avatar"]];
        // 金额
        [self.balanceView reloadUserBalanceWithUser:user];
        // 标签
        [self.labelView reloadLabelCountWithUser:user];

    } failure:^(NSError *error) {
        
    } msg:^(NSString *string) {
        
    } loginFail:^{
        
    }];
}

#pragma mark - methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    DLog(@"%s %f   %f",__func__,velocity.x,velocity.y);
    DLog(@"%s ++%f   +++%f",__func__,targetContentOffset->x,targetContentOffset->y);
    if(velocity.y > 0){
        scrollView.scrollEnabled = NO;
        *targetContentOffset = CGPointMake(0, 377);
        scrollView.scrollEnabled = YES;
    }
    if(velocity.y < 0){
        scrollView.scrollEnabled = NO;
        *targetContentOffset = CGPointMake(0, 0);
        scrollView.scrollEnabled = YES;
    }
    
    if ((*targetContentOffset).y > 262) {
//        scrollView.scrollEnabled = NO;
        *targetContentOffset = CGPointMake(0, 377);
//        scrollView.scrollEnabled = YES;
    }
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return 5;
}

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    MOHomeTaskSegmentVC *vc = [MOHomeTaskSegmentVC new];
    vc.viewModel.cate = index;
    vc.canRefresh = YES;
    vc.scrollView = self.mainScrollView;
    
    vc.superScrollBlock = ^(BOOL canScroll) {
    };
    [self.vcs addObject:vc];
    return vc;
}

#pragma mark - actions

- (IBAction)userButtonClick:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOPersonCenterVC"];
    MOPersonCenterSFVC *targetVC = [MOPersonCenterSFVC new];
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

- (void)balanceViewTap {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOPropertyVC"];
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

- (void)labelViewTap {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOMyTagVC"];
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

#pragma mark - setter && getter

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (MTHomeBalanceView *)balanceView {
    if (_balanceView == nil) {
        _balanceView = [[[NSBundle mainBundle]loadNibNamed:@"MTHomeBalanceView" owner:self options:nil] lastObject];
        [_balanceView commonInit];
        WEAKSELF
        _balanceView.balanceViewClick = ^{
            [weakSelf balanceViewTap];
        };
        
        _balanceView.dataViewClick = ^{
			MOMyAllDataVC *vc = [[MOMyAllDataVC alloc] initWithCate:0 userTaskId:0 user_paste_board:NO];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
        };
        
        _balanceView.taskViewClick = ^{
            DLog(@"点击我的任务");
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOMyTaskVC"];
            [MOAppDelegate.transition pushViewController:targetVC animated:YES];
        };
    }
    return _balanceView;
}

- (MOHomeCatView *)dataCatView {
    if (_dataCatView == nil) {
        _dataCatView = [[[NSBundle mainBundle]loadNibNamed:@"MOHomeCatView" owner:nil options:nil] lastObject];
        [_dataCatView commonInit];
        _dataCatView.clickHandle = ^(NSInteger index) {
            switch (index) {
                case 101:
                    {
                        
                        MOAudioDataVC *vc = [MOAudioDataVC new];
                        [MOAppDelegate.transition pushViewController:vc animated:YES];
                    }
                    break;
                case 102:
                    {
                        MOPictureDataVC *vc = [MOPictureDataVC new];
                        [MOAppDelegate.transition pushViewController:vc animated:YES];
                    }
                    break;
                case 103:
                    {
                        MOTextDataVC *vc = [MOTextDataVC new];
                        [MOAppDelegate.transition pushViewController:vc animated:YES];
                    }
                    break;
                case 104:
                    {
                        
                        MOVideoDataVC *vc = [MOVideoDataVC new];
                        [MOAppDelegate.transition pushViewController:vc animated:YES];
                    }
                    break;
                case 105:
                    {
                        MODataPartnerVC *vc = [MODataPartnerVC new];
                        [MOAppDelegate.transition pushViewController:vc animated:YES];
                    }
                    break;
                default:
                    break;
            }
        };
    }
    return _dataCatView;
}

-(MOHomeCatView *)newAbilityView {
	
	if (_newAbilityView == nil) {
		_newAbilityView = [[[NSBundle mainBundle]loadNibNamed:@"MOHomeCatView" owner:nil options:nil] lastObject];
		[_newAbilityView newAbilityCommonInit];
		_newAbilityView.clickHandle = ^(NSInteger index) {
			switch (index) {
				case 101:{
					MOSummarizeSampleVC *vc = [MOSummarizeSampleVC new];
					[MOAppDelegate.transition pushViewController:vc animated:YES];
					}
					break;
				case 102:{
					MOTranslateTextOnImageVC *vc = [MOTranslateTextOnImageVC new];
					MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
					nav.modalPresentationStyle = UIModalPresentationFullScreen;
					nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
					[self presentModalViewController:nav animated:YES];
					break;
				}
				case 103:{
					MOAICameraVC *vc = [MOAICameraVC new];
					MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
					nav.modalPresentationStyle = UIModalPresentationFullScreen;
					nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
					[self presentModalViewController:nav animated:YES];
					break;
				}
					
				case 104:{
//					MOFoodSafetyVC *vc = [MOFoodSafetyVC new];
//					MONavigationController *nav = [[MONavigationController alloc] initWithRootViewController:vc];
//					nav.modalPresentationStyle = UIModalPresentationFullScreen;
//					nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//					[self presentModalViewController:nav animated:YES];
					UIViewController *vc =  [MOSwiftUIWrapperBuilder createWithCameraView];
					[MOAppDelegate.transition pushViewController:vc animated:YES];
					break;
				}
					
				default:
					break;
			}
		};
	}
	
	return _newAbilityView;
}

- (MOHomeLabelView *)labelView {
    if (_labelView == nil) {
        _labelView = [[[NSBundle mainBundle]loadNibNamed:@"MOHomeLabelView" owner:nil options:nil] lastObject];
        _labelView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelViewTap)];
        [_labelView addGestureRecognizer:tap];
    }
    return _labelView;
}

- (JXCategoryTitleView *)taskCatView {
    if (_taskCatView == nil) {
        _taskCatView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.6, segmentHeight)];
        _taskCatView.delegate = self;
    }
    return _taskCatView;
}

-(MOHomeSearchBarView *)searchBarView {
    
    if (!_searchBarView) {
        _searchBarView = [[MOHomeSearchBarView alloc] initWithFrame:CGRectMake(0, 0, 45, segmentHeight)];
    }
    return  _searchBarView;
}

-(MOView *)collectionProjectContentView {
    if (!_collectionProjectContentView) {
        _collectionProjectContentView = [MOView new];
    }
    return  _collectionProjectContentView;
}

-(MOView *)processingDataContentView {
    
    if (!_processingDataContentView) {
        _processingDataContentView = [MOView new];
    }
    return  _processingDataContentView;
}

    
- (MOHomeVM *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [MOHomeVM new];
    }
    return _viewModel;
}

- (NSMutableArray<MOHomeTaskSegmentVC *> *)vcs {
    if (_vcs == nil) {
        _vcs = [NSMutableArray new];
    }
    return _vcs;
}
@end
