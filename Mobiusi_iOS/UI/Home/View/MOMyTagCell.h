//
//  MOMyTagCell.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/12.
//

#import <UIKit/UIKit.h>
#import "MOMyTagTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMyTagCell : UICollectionViewCell

- (void)configWithModel:(MOMyTagModel *)model;

@end

NS_ASSUME_NONNULL_END
