//
//  MOBaseDataVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOBaseViewController.h"
#import "MODataTopCardView.h"
#import "MONavBarView.h"
#import "MOHomeVM.h"
#import "MOCateOptionModel.h"
#import "JXCategoryTitleView.h"
#import "MODataCategoryTaskVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOBaseDataVC : MOBaseViewController<JXCategoryListContainerViewDelegate>
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong,readonly)MODataTopCardView *topLeftCard;
@property(nonatomic,strong,readonly)MODataTopCardView *topRightCard;
@property(nonatomic,strong)MOHomeVM *viewModel;
@property (nonatomic, strong,readonly) JXCategoryTitleView *categoryTitlesView;
@property(nonatomic,strong)MOCateOptionModel *cateOptionModel;
-(void)addUI;
-(void)setUpUI;
-(void)realodCategoryList;
-(void)addTaskBtnClick;
@end

NS_ASSUME_NONNULL_END
