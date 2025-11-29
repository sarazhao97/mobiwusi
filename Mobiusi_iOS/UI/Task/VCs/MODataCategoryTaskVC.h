//
//  MODataCategoryTaskVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MOBaseViewController.h"
#import "JXCategoryListContainerView.h"
#import "MOHomeTaskSegmentVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface MODataCategoryTaskVC : MOBaseViewController<JXCategoryListContentViewDelegate>

- (instancetype)initWithViewModel:(MOHomeTaskSegmentVM *)viewModel;
-(void)manualLoadingIfLoad;


@end

NS_ASSUME_NONNULL_END
