//
//  MODataTopCardView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MODataTopCardView : MOView
@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;
@property(nonatomic,strong)UIImageView *largeImageView;
@property(nonatomic,strong)MOButton *bottomBtn;
@property(nonatomic,copy)void(^didBottomBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
