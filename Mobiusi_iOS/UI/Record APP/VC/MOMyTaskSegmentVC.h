//
//  MOMyTaskSegmentVC.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/13.
//

#import "MOTableViewController.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMyTaskSegmentVC : MOTableViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, assign) NSInteger status;

@end

NS_ASSUME_NONNULL_END
