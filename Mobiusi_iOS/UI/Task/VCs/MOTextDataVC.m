//
//  MOTextDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MOTextDataVC.h"
#import "MOMyTextDataVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOTextDataVC ()

@end

@implementation MOTextDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.titleLabel.text = NSLocalizedString(@"文本数据",nil);
    
    self.viewModel = [MOHomeVM new];
    
    [self showActivityIndicator];
    WEAKSELF
    [self.viewModel getCateOptionSuccess:^(NSDictionary *dic) {
        
        weakSelf.cateOptionModel = [MOCateOptionModel yy_modelWithJSON:dic];
        
        [weakSelf hidenActivityIndicator];
        [weakSelf addUI];
        [weakSelf setUpUI];
    } failure:^(NSError *error) {
        [weakSelf hidenActivityIndicator];
    } msg:^(NSString *string) {
        [weakSelf hidenActivityIndicator];
    } loginFail:^{
        [weakSelf hidenActivityIndicator];
    }];
    
    
}

-(void)addTaskBtnClick {
    MOUploadTextFileVC *vc = [MOUploadTextFileVC createAlertStyle];
    [self presentViewController:vc animated:YES completion:NULL];
}


-(void)setUpUI {
    
    self.topLeftCard.bgImageView.image = [UIImage imageNamedNoCache:@"icon_data_text_bg_left.png"];
    self.topLeftCard.titleLabel.text = NSLocalizedString(@"我的文本",nil);
    self.topLeftCard.subTitleLabel.text = NSLocalizedString(@"文本数据都在这里",nil);
    self.topLeftCard.largeImageView.image = [UIImage imageNamedNoCache:@"icon_data_text.png"];
    self.topLeftCard.didBottomBtnClick = ^{
        
        MOMyTextDataVC *vc = [[MOMyTextDataVC alloc] initWithCate:3 userTaskId:0 user_paste_board:NO];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    
    self.topRightCard.titleLabel.text = @"加工文本";
    
    
    NSMutableArray <NSString *>* datacateNames = @[].mutableCopy;
    [datacateNames addObject:NSLocalizedString(@"全部", nil)];
    for (MOCateOptionItem *item  in self.cateOptionModel.text_cate) {
        [datacateNames addObject:item.name];
    }
    self.categoryTitlesView.titles = datacateNames;
    [self realodCategoryList];
}


#pragma mark - JXCategoryListContainerViewDelegate

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    
    MOHomeTaskSegmentVM *viewmodel = [MOHomeTaskSegmentVM new];
    viewmodel.cate = 3;
    if ([self.categoryTitlesView.titles[index] isEqualToString:NSLocalizedString(@"全部", nil)]) {
        viewmodel.data_cate = 0;
    } else {
        MOCateOptionItem *item = self.cateOptionModel.text_cate[index - 1];
        viewmodel.data_cate = [item.value integerValue];
    }
    MODataCategoryTaskVC *vc = [[MODataCategoryTaskVC alloc] initWithViewModel:viewmodel];
    [vc manualLoadingIfLoad];
    return vc;
}
@end
