//
//  MONavBarView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MONavBarView : MOView
@property(nonatomic,strong)MOButton *backBtn;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIStackView *rightItemsView;
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,copy)void(^gobackDidClick)(void);
-(void)customStatusBarheight:(CGFloat)newHeight;
@end

NS_ASSUME_NONNULL_END
