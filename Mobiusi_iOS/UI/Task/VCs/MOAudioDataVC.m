//
//  MOAudioDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MOAudioDataVC.h"
#import "MOMyAudioDataVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOAudioDataVC ()

@end

@implementation MOAudioDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.titleLabel.text = NSLocalizedString(@"音频数据", nil);
    
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
		dispatch_async(dispatch_get_main_queue(), ^{
			[self hidenActivityIndicator];
		});
    }];
    
}

-(void)setUpUI {
    
    self.topLeftCard.bgImageView.image = [UIImage imageNamedNoCache:@"icon_data_audio_bg_left.png"];
    self.topLeftCard.titleLabel.text = NSLocalizedString(@"我的音频", nil);
    self.topLeftCard.subTitleLabel.text = NSLocalizedString(@"音频数据都在这里", nil);
    self.topLeftCard.largeImageView.image = [UIImage imageNamedNoCache:@"icon_data_audio.png"];
    self.topLeftCard.didBottomBtnClick = ^{
		MOMyAudioDataVC *vc = [[MOMyAudioDataVC alloc] initWithCate:1 userTaskId:0 user_paste_board:NO];
        [MOAppDelegate.transition pushViewController:vc animated:YES];
    };
    
	self.topRightCard.hidden = NO;
    self.topRightCard.titleLabel.text = NSLocalizedString(@"加工音频", nil);
    self.topRightCard.didBottomBtnClick = ^{
		MOAudioProcessingRecordVC *vc = [MOAudioProcessingRecordVC new];
		[MOAppDelegate.transition pushViewController:vc animated:true];
		
    };
    
    NSMutableArray <NSString *>* datacateNames = @[].mutableCopy;
    [datacateNames addObject:NSLocalizedString(@"全部", nil)];
    for (MOCateOptionItem *item  in self.cateOptionModel.audio_cate) {
        [datacateNames addObject:item.name];
    }
    self.categoryTitlesView.titles = datacateNames;
    
    [self realodCategoryList];
}

-(void)addTaskBtnClick {
    
    MORecordAudioNewVC *vc = [MORecordAudioNewVC createAlertStyle];
    [self presentViewController:vc animated:YES completion:NULL];
    
}


#pragma mark - JXCategoryListContainerViewDelegate

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    
    MOHomeTaskSegmentVM *viewmodel = [MOHomeTaskSegmentVM new];
    viewmodel.cate = 1;
    if ([self.categoryTitlesView.titles[index] isEqualToString:NSLocalizedString(@"全部", nil)]) {
        viewmodel.data_cate = 0;
    } else {
        MOCateOptionItem *item = self.cateOptionModel.audio_cate[index - 1];
        viewmodel.data_cate = [item.value integerValue];
    }
    MODataCategoryTaskVC *vc = [[MODataCategoryTaskVC alloc] initWithViewModel:viewmodel];
    [vc manualLoadingIfLoad];
    return vc;
}

@end
