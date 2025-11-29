//
//  MOMyTaskVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/13.
//

#import "MOMyTaskVC.h"
#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorImageView.h"
#import "JXCategoryListContainerView.h"
#import "MOMyTaskSegmentVC.h"
@interface MOMyTaskVC ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *segmentBgView;
@property (nonatomic, strong) JXCategoryTitleView *taskCatView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@end

@implementation MOMyTaskVC


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    DLog(@"%s %@",__func__,self.navigationController);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.segmentBgView addSubview:self.taskCatView];
    [self.taskCatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.segmentBgView);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    self.taskCatView.titles = @[NSLocalizedString(@"进行中", nil), NSLocalizedString(@"待审核", nil), NSLocalizedString(@"待修正", nil), NSLocalizedString(@"初审通过", nil), NSLocalizedString(@"已完成", nil)];
    self.taskCatView.titleColor = [UIColor colorWithHexString:@"333333" alpha:0.5];
    self.taskCatView.titleSelectedColor = [UIColor colorWithHexString:@"333333"];
    self.taskCatView.titleFont = [UIFont systemFontOfSize:13];
    self.taskCatView.titleSelectedFont = [UIFont boldSystemFontOfSize:17];
    self.taskCatView.titleColorGradientEnabled = YES;
    self.taskCatView.contentEdgeInsetLeft = 30;
    self.taskCatView.contentEdgeInsetRight = 30;
    

    JXCategoryIndicatorImageView *indicatorView = [[JXCategoryIndicatorImageView alloc] init];
    indicatorView.indicatorImageView.image = [UIImage imageNamedNoCache:@"icon_segment_s"];
    indicatorView.verticalMargin = 8;
    indicatorView.indicatorImageViewSize = CGSizeMake(40, 15);
    self.taskCatView.indicators = @[indicatorView];
    
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.listCellBackgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];

    self.taskCatView.listContainer = self.listContainerView;
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentBgView.mas_bottom).mas_offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];

}

#pragma mark - methods

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (IBAction)followClick:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOMyFollowListVC"];
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return 5;
}

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    MOMyTaskSegmentVC *vc = [MOMyTaskSegmentVC new];
    vc.status = index+1;
    return vc;
}

#pragma mark - actions


#pragma mark - setter && getter

- (JXCategoryTitleView *)taskCatView {
    if (_taskCatView == nil) {
        _taskCatView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _taskCatView.delegate = self;
    }
    return _taskCatView;
}

@end
