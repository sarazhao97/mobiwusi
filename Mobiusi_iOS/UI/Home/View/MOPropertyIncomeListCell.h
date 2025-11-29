//
//  MOPropertyIncomeListCell.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/4.
//

#import "MOTableViewCell.h"
#import "MOUserBalanceDetailsModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOPropertyIncomeListCell : MOTableViewCell

-(void)configCellWithModel:(MOUserBalanceListItemModel *)model;
@end

NS_ASSUME_NONNULL_END
