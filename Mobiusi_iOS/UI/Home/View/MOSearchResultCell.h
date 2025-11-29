//
//  MOSearchResultCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOTableViewCell.h"
#import "MOSearchResultModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOSearchResultCell : MOTableViewCell
@property(nonatomic,copy)void(^didAddBtnClick)(void);

-(void)configCellWithData:(nullable MOSearchResultCateModel *)data keyword:(nullable NSString *)keyword;
@end

NS_ASSUME_NONNULL_END
