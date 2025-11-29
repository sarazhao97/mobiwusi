//
//  MOWithdrawalRecordCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOTableViewCell.h"
#import "MOWithdrawalRecordModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOWithdrawalRecordCell : MOTableViewCell
@property(nonatomic,strong)UILabel *amountLabel;
@property(nonatomic,strong)UILabel *stateLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)MOView *rightContentView;
@property(nonatomic,strong)MOView *bottomLine;

-(void)configCellWithModel:(MOWithdrawalRecordItemModel *)model;
@end

NS_ASSUME_NONNULL_END
