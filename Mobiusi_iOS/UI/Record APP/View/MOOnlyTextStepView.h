//
//  MOOnlyTextStepView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOOnlyTextStepView : MOView
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOButton *exampleBtn;
@property(nonatomic,strong)UITextView *textInput;
@end

NS_ASSUME_NONNULL_END
