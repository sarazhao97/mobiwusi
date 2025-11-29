//
//  MOPictureDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOPictureDataVC.h"
#import "MOMyPictureDataVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOPictureDataVC ()

@end

@implementation MOPictureDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.titleLabel.text = NSLocalizedString(@"图片数据", nil);
    
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



-(void)setUpUI {
    
    self.topLeftCard.bgImageView.image = [UIImage imageNamedNoCache:@"icon_data_image_bg_left.png"];
    self.topLeftCard.titleLabel.text = NSLocalizedString(@"我的图片", nil);
    self.topLeftCard.subTitleLabel.text = NSLocalizedString(@"图片数据都在这里", nil);
    self.topLeftCard.largeImageView.image = [UIImage imageNamedNoCache:@"icon_data_picture.png"];
    self.topLeftCard.didBottomBtnClick = ^{
        
		MOMyPictureDataVC *vc = [[MOMyPictureDataVC alloc] initWithCate:2 userTaskId:0 user_paste_board:NO];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    
    
    self.topRightCard.titleLabel.text = NSLocalizedString(@"加工图片", nil);
    
    
    NSMutableArray <NSString *>* datacateNames = @[].mutableCopy;
    [datacateNames addObject:NSLocalizedString(@"全部", nil)];
    for (MOCateOptionItem *item  in self.cateOptionModel.image_cate) {
        [datacateNames addObject:item.name];
    }
    self.categoryTitlesView.titles = datacateNames;
    
    [self realodCategoryList];
}

-(void)addTaskBtnClick {
    
    MOUploadPictureVC *vc = [MOUploadPictureVC createAlertStyle];
    [self presentViewController:vc animated:true completion:NULL];
}


#pragma mark - JXCategoryListContainerViewDelegate

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    
    MOHomeTaskSegmentVM *viewmodel = [MOHomeTaskSegmentVM new];
    viewmodel.cate = 2;
    if ([self.categoryTitlesView.titles[index] isEqualToString:NSLocalizedString(@"全部", nil)]) {
        viewmodel.data_cate = 0;
    } else {
        MOCateOptionItem *item = self.cateOptionModel.image_cate[index - 1];
        viewmodel.data_cate = [item.value integerValue];
    }
    MODataCategoryTaskVC *vc = [[MODataCategoryTaskVC alloc] initWithViewModel:viewmodel];
    [vc manualLoadingIfLoad];
    return vc;
}

@end
