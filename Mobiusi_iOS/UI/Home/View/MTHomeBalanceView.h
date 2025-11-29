//
//  MTHomeBalanceView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/21.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTHomeBalanceView : MOView

@property (nonatomic, copy) MOBlock balanceViewClick;
@property (nonatomic, copy) MOBlock dataViewClick;
@property (nonatomic, copy) MOBlock taskViewClick;

- (void)commonInit;

- (void)reloadUserBalanceWithUser:(MOUserModel *)user;

@end

NS_ASSUME_NONNULL_END
