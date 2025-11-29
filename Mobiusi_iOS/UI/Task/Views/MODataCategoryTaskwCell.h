//
//  MODataCategoryTaskwCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import <UIKit/UIKit.h>
#import "MOView.h"
#import "MOTaskListModel.h"
#import "MOTableViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface MODataCategoryTaskwCell : MOTableViewCell
@property(nonatomic,strong)MOView *cardView;
@property(nonatomic,strong)MOView *bgContentView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;
@property(nonatomic,strong)UILabel *tagLabel;
@property(nonatomic,strong)UILabel *priceLabel;

-(void)showLevel1GradientLayer;
-(void)showLevel2GradientLayer;
-(void)showLevel3GradientLayer;
-(void)hiddenAllGradientLayer;

-(void)configCellWithModel:(MOTaskListModel *)model;
@end

NS_ASSUME_NONNULL_END
