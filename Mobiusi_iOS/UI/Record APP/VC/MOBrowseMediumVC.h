//
//  MOBrowseMediumVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOBaseViewController.h"
#import "MOBrowseMediumItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOBrowseMediumVC : MOBaseViewController
@property(nonatomic,copy)void(^didLongPressImage)(NSInteger index);
- (instancetype)initWithDataList:(NSArray<MOBrowseMediumItemModel *> *)dataList selectedIndex:(NSInteger)selectedIndex;

@end

NS_ASSUME_NONNULL_END
