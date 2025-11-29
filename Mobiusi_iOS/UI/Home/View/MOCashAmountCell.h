//
//  MOCashAmountCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import <UIKit/UIKit.h>
#import "MOCateOptionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOCashAmountCell : UICollectionViewCell
@property(nonatomic,strong)MOView *bgView;
@property(nonatomic,strong)UILabel *amountLabel;
-(void)configNormalSateCellWithModel:(MOCateOptionItem *)model;
-(void)configSelectedSateCellWithModel:(MOCateOptionItem *)model;
@end

NS_ASSUME_NONNULL_END
