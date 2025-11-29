//
//  MOHomeCatView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/21.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeCatView : MOView

@property (nonatomic, copy) MOIndexBlock clickHandle;

- (void)commonInit;
- (void)newAbilityCommonInit;
    
@end

NS_ASSUME_NONNULL_END
