//
//  MOMessageListTableViewCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOTableViewCell.h"
#import "MOMessageListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOMessageListTableViewCell : MOTableViewCell
@property(nonatomic,strong)UIImageView *inconImageView;
@property(nonatomic,strong)UILabel *msgTitleLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)MOView *lineView;
@property(nonatomic,strong)UILabel *msgTextLabel;
@property(nonatomic,strong)MOView *myContent;

-(void)configWithModel:(MOMessageListItemModel *)model;
@end

NS_ASSUME_NONNULL_END
