//
//  MOMyTagVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/25.
//

#import "MOMyTagVC.h"
#import "JXCategoryTitleView.h"
#import "JXCategoryIndicatorImageView.h"
#import "JXCategoryListContainerView.h"
#import "MOMyTagCell.h"
#import "MOMyTagSectionHeaderView.h"
#import "MOMyTagVM.h"
#import "MOTagCollectionViewFlowLayout.h"

@interface MOMyTagVC ()<JXCategoryViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) JXCategoryTitleView *taskCatView;

@property (weak, nonatomic) IBOutlet UIView *segBgView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSDictionary *tagsData;

@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, strong) MOMyTagVM *viewModel;

@property (nonatomic, assign) NSInteger selectCateIndex;

@end

@implementation MOMyTagVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.segBgView addSubview:self.taskCatView];
    [self.taskCatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.segBgView);
        make.width.mas_equalTo(160);
    }];
    
    self.taskCatView.titles = @[NSLocalizedString(@"已拥有", nil), NSLocalizedString(@"未拥有", nil)];
    self.taskCatView.titleColor = [UIColor colorWithHexString:@"333333" alpha:0.5];
    self.taskCatView.titleSelectedColor = [UIColor colorWithHexString:@"333333"];
    self.taskCatView.titleFont = [UIFont systemFontOfSize:13];
    self.taskCatView.titleSelectedFont = [UIFont boldSystemFontOfSize:17];
    self.taskCatView.titleColorGradientEnabled = YES;
    
    self.selectCateIndex = 0;
    JXCategoryIndicatorImageView *indicatorView = [[JXCategoryIndicatorImageView alloc] init];
    indicatorView.indicatorImageView.image = [UIImage imageNamedNoCache:@"icon_segment_s"];
    indicatorView.verticalMargin = 8;
    indicatorView.indicatorImageViewSize = CGSizeMake(40, 15);
    self.taskCatView.indicators = @[indicatorView];
    
//    [self.viewModel getUserTagWithCate:1 success:^(NSArray *array) {
//        [self.collectionView reloadData];
//    } failure:^(NSError *error) {
//        
//    } msg:^(NSString *string) {
//        
//    } loginFail:^{
//        
//    }];
    
    [self.viewModel getWithoutUserTagWithCate:2 success:^(NSArray *array) { 
        [self.collectionView reloadData];

    } failure:^(NSError *error) { } msg:^(NSString *string) {
        
    } loginFail:^{
        
    }];
    
    MOTagCollectionViewFlowLayout *layout = [[MOTagCollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 10;
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
//    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MOMyTagCell" bundle:NSBundle.mainBundle] forCellWithReuseIdentifier:@"MOMyTagCell"];
    [self.collectionView registerClass:[MOMyTagSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MOMyTagSectionHeaderView"];
    
}

#pragma mark - JXCategoryListContainerViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.selectCateIndex = index;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    if (self.selectCateIndex == 0) {
//        return self.viewModel.dataList.count;
//    } else {
        return self.viewModel.noDataList.count;
//    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    if (self.selectCateIndex == 0) {
//        MOMyTagTypeModel *typeModel = self.viewModel.dataList[section];
//        return [typeModel.tags count];
//    } else {
        MOMyTagTypeModel *typeModel = self.viewModel.noDataList[section];
        return [typeModel.tags count];
//    }
    
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MOMyTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOMyTagCell" forIndexPath:indexPath];
    
//    if (self.selectCateIndex == 0) {
//        MOMyTagTypeModel *typeModel = self.viewModel.dataList[indexPath.section];
//        MOMyTagModel *tag = typeModel.tags[indexPath.item];
//        [cell configWithModel:tag];
//    } else {
        MOMyTagTypeModel *typeModel = self.viewModel.noDataList[indexPath.section];
        MOMyTagModel *tag = typeModel.tags[indexPath.item];
        [cell configWithModel:tag];
//    }
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        MOMyTagSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MOMyTagSectionHeaderView" forIndexPath:indexPath];
        
//        if (self.selectCateIndex == 0) {
//            MOMyTagTypeModel *typeModel = self.viewModel.dataList[indexPath.section];
//            [headerView configWithModel:typeModel];
//        } else {
            MOMyTagTypeModel *typeModel = self.viewModel.noDataList[indexPath.section];
            [headerView configWithModel:typeModel];
//        }
        
        return headerView;
    }
    return nil;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.selectCateIndex == 0) {
//        MOMyTagTypeModel *typeModel = self.viewModel.dataList[indexPath.section];
//        MOMyTagModel *tag = typeModel.tags[indexPath.item];
//        CGSize textSize = [tag.name sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
//        return CGSizeMake(textSize.width + 40, 27);
//    } else {
    MOMyTagTypeModel *typeModel = self.viewModel.noDataList[indexPath.section];
    MOMyTagModel *tag = typeModel.tags[indexPath.item];
    
    // 动态计算文本宽度
    CGSize textSize = [tag.name sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
    CGFloat calculatedWidth = textSize.width + 40;

    CGFloat maxWidth = SCREEN_WIDTH-32; // 设置最大宽度为SCREEN_WIDTH-32，避免item过宽
       
    CGFloat width = MIN(calculatedWidth, maxWidth);
    // 返回动态宽度 + 间距（保证每个 item 的宽度不变，且间距固定）
    return CGSizeMake(width, 27);  // 如果你想每个 item 有固定的额外间距，可以调整 +40 的值
//    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 16, 0, 16);
}

- (JXCategoryTitleView *)taskCatView {
    if (_taskCatView == nil) {
        _taskCatView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        _taskCatView.delegate = self;
    }
    return _taskCatView;
}

- (MOMyTagVM *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [MOMyTagVM new];
    }
    return _viewModel;
}
    
@end
