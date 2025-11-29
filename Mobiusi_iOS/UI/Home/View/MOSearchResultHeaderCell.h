//
//  MOSearchResultHeaderCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOSearchResultHeaderCell : MOTableViewCell
@property(nonatomic,strong)UIImageView *iconImageView;
@property(nonatomic,strong)UILabel *categoryLabel;
@property(nonatomic,strong)MOButton *moreBtn;
@property(nonatomic,copy)void(^didClickMoreBtn)(void);
@end

NS_ASSUME_NONNULL_END
