//
//  MOMyTagSectionHeaderView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/10/5.
//

#import <UIKit/UIKit.h>
#import "MOMyTagTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMyTagSectionHeaderView : UICollectionReusableView

- (void)configWithModel:(MOMyTagTypeModel *)model;

@end

NS_ASSUME_NONNULL_END
