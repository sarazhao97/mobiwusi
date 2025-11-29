//
//  MOPropertyIncomeListCell.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/4.
//

#import "MOPropertyIncomeListCell.h"

@interface MOPropertyIncomeListCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation MOPropertyIncomeListCell


-(void)configCellWithModel:(MOUserBalanceListItemModel *)model {
    
    self.nameLabel.text = model.category_name?:@"";
    self.timeLabel.text = model.date_name;
    self.numberLabel.text = model.val;
}

@end
