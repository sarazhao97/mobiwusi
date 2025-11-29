//
//  MOBrowseMediumVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOBrowseMediumVC.h"
#import "MONavBarView.h"
#import "MOBrowseMediumCell.h"
#import "MOBrowseMediumItemModel.h"
#import "NSObject+KVO.h"
@interface MOBrowseMediumVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray<MOBrowseMediumItemModel *> *dataList;
@property(nonatomic,assign)NSInteger selectedIndex;
@end

@implementation MOBrowseMediumVC

- (instancetype)initWithDataList:(NSArray *)dataList selectedIndex:(NSInteger)selectedIndex
{
    self = [super init];
    if (self) {
        [self.dataList addObjectsFromArray:dataList];
        self.selectedIndex = selectedIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = Color333333;
    [self.view addSubview:self.collectionView];
    
    
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_w.png"]];
    self.navBar.backgroundColor = [Color333333 colorWithAlphaComponent:0.3];
    [self.view addSubview:self.navBar];
    WEAKSELF
    self.navBar.gobackDidClick = ^{
        
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    };
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MOBrowseMediumCell class] forCellWithReuseIdentifier:@"MOBrowseMediumCell"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    
    [self.collectionView observeValueForKeyPath:@"contentSize" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        CGSize newSize = [change[@"new"] CGSizeValue];
        CGSize oldSize = [change[@"old"] CGSizeValue];
        if (newSize.width != oldSize.width || newSize.height != oldSize.height) {
            [weakSelf.collectionView setContentOffset:CGPointMake(weakSelf.selectedIndex *SCREEN_WIDTH, 0)];
        }
    }];
    
    
    
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect safeAreaFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    CGFloat safeAreaWidth = safeAreaFrame.size.width;
    CGFloat safeAreaHeight = safeAreaFrame.size.height;
    DLog(@"安全区域宽度：%f，安全区域高度：%f", safeAreaWidth, safeAreaHeight);
    DLog("%s",__func__);
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MOBrowseMediumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOBrowseMediumCell" forIndexPath:indexPath];
    MOBrowseMediumItemModel *model = self.dataList[indexPath.item];
    [cell configCellWithModel:model];
	WEAKSELF
	cell.didLongPressImage = ^{
		if (weakSelf.didLongPressImage) {
			weakSelf.didLongPressImage(indexPath.row);
		}
	};
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MOBrowseMediumItemModel *model = self.dataList[indexPath.item];
    if (model.type == MOBrowseMediumItemTypeVideo) {
        MOBrowseMediumCell *mycell = (MOBrowseMediumCell *)cell;
        [mycell.videoPlayer seekToTime:kCMTimeZero];
        [mycell.videoPlayer play];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MOBrowseMediumItemModel *model = self.dataList[indexPath.item];
    MOBrowseMediumCell *mycell = (MOBrowseMediumCell *)cell;
    mycell.imageViewConentView.zoomScale = 1.0;
    if (model.type == MOBrowseMediumItemTypeVideo) {
        [mycell.videoPlayer pause];
    }
    
    
}


#pragma mark - setter && getter

-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        _navBar.titleLabel.text = @"";
    }
    return _navBar;
}


-(UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowfy = [UICollectionViewFlowLayout new];
        flowfy.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowfy.minimumLineSpacing = 0;
        flowfy.minimumInteritemSpacing = 0;
        flowfy.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowfy];
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = ClearColor;
    }
    return _collectionView;
}

-(NSMutableArray<MOBrowseMediumItemModel *> *)dataList {
    
    if (!_dataList) {
        _dataList= @[].mutableCopy;
    }
    return _dataList;
}

@end
