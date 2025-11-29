//
//  MOHomeCatView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/21.
//

#import "MOHomeCatView.h"
#import "MOHomeCatCell.h"

@interface MOHomeCatView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation MOHomeCatView

- (void)awakeFromNib {
	[super awakeFromNib];
	// Initialization code
}

- (void)commonInit {
	
	// 添加 UICollectionView 代理和数据源
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.dataSource = @[
		@{@"icon":@"icon_data_partner", @"text":NSLocalizedString(@"数据合伙人", nil), @"index":@(105)},
		@{@"icon":@"icon_data_audio", @"text":NSLocalizedString(@"音频数据", nil), @"index":@(101)},
		@{@"icon":@"icon_data_picture", @"text":NSLocalizedString(@"图片数据", nil), @"index":@(102)},
		@{@"icon":@"icon_data_text", @"text":NSLocalizedString(@"文本数据", nil), @"index":@(103)},
		@{@"icon":@"icon_data_video", @"text":NSLocalizedString(@"视频数据", nil), @"index":@(104)}
	];
	// 设置 layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	CGFloat width = (SCREEN_WIDTH-20)/5;
	layout.itemSize = CGSizeMake(width, 85); // 设置每个 item 的大小
	layout.minimumLineSpacing = 0; // 行间距
	layout.minimumInteritemSpacing = 0; // 列间距
	layout.sectionInset = UIEdgeInsetsMake(0, 0, 15, 0);
	layout.scrollDirection = UICollectionViewScrollDirectionVertical; // 设置滚动方向
	self.collectionView.collectionViewLayout = layout;
	
	// 注册 UICollectionViewCell
	[self.collectionView registerNib:[UINib nibWithNibName:@"MOHomeCatCell" bundle:nil] forCellWithReuseIdentifier:@"MOHomeCatCell"];
	
	[self.collectionView reloadData];
}

- (void)newAbilityCommonInit {
	
	// 添加 UICollectionView 代理和数据源
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.dataSource = @[
		@{@"icon":@"icon_mobiwusi_summarize_b", @"text":NSLocalizedString(@"资讯分析师", nil), @"index":@(101)},
		@{@"icon":@"icon_translate_ability", @"text":NSLocalizedString(@"出国翻译官", nil), @"index":@(102)},
		@{@"icon":@"Icon_ai_camera", @"text":NSLocalizedString(@"多变摄影师", nil), @"index":@(103)},
//		@{@"icon":@"icon_video_secure", @"text":NSLocalizedString(@"食品安全", nil), @"index":@(104)}
	];
	// 设置 layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	CGFloat width = (SCREEN_WIDTH-20)/5;
	layout.itemSize = CGSizeMake(width, 85); // 设置每个 item 的大小
	layout.minimumLineSpacing = 0; // 行间距
	layout.minimumInteritemSpacing = 0; // 列间距
	layout.sectionInset = UIEdgeInsetsMake(0, 0, 15, 0);
	layout.scrollDirection = UICollectionViewScrollDirectionVertical; // 设置滚动方向
	self.collectionView.collectionViewLayout = layout;
	
	// 注册 UICollectionViewCell
	[self.collectionView registerNib:[UINib nibWithNibName:@"MOHomeCatCell" bundle:nil] forCellWithReuseIdentifier:@"MOHomeCatCell"];
	
	[self.collectionView reloadData];
	
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count; // 返回要显示的单元格数量
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CGSize size = collectionView.bounds.size;
	
	CGFloat width = (size.width - 20) / 5;
	CGFloat height = size.height;
	return  CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MOHomeCatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOHomeCatCell" forIndexPath:indexPath];
    // 配置 cell 的外观，例如背景色
    cell.backgroundColor = [UIColor whiteColor];
    [cell configWithDict:self.dataSource[indexPath.row]];
    return cell;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"Selected item at index: %ld", (long)indexPath.item);
    NSDictionary *dic = self.dataSource[indexPath.item];
    NSInteger index = [dic[@"index"] integerValue];
    if (self.clickHandle) {
        self.clickHandle(index);
    }
}

@end


