//
//  MOHomeTaskSegmentVC.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/29.
//

#import "MOTableViewController.h"
#import "JXCategoryListContainerView.h"
#import "MOHomeTaskSegmentVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeTaskSegmentVC : MOTableViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, strong) MOHomeTaskSegmentVM *viewModel;

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) BOOL canRefresh;

@property (nonatomic, copy) MOBoolBlock superScrollBlock;
@property (nonatomic, weak) UIScrollView *scrollView;
@end

NS_ASSUME_NONNULL_END
