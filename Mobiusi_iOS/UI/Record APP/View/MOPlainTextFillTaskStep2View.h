//
//  MOPlainTextFillTaskStep2View.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOPlainTextFillTaskStep2View : MOView<UITextFieldDelegate>
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOButton *exampleBtn;
@property(nonatomic,strong)UITextField *titleInput;
@property(nonatomic,strong)UILabel *titleLengthCountLabel;
@property(nonatomic,strong)UITextView *textInput;
@property(nonatomic,copy)void(^didExampleBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
