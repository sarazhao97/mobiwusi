//
//  MOFillTaskTopicStep1View.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOFillTaskTopicStep1View : MOView
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UILabel *requireLabel;
@property(nonatomic,strong)MOButton *viewRequireBtn;
@property(nonatomic,copy)void(^didViewRequireBtnClick)(void);
-(void)setRequreStringToAttributedString:(NSString *)requreString;
@end

NS_ASSUME_NONNULL_END
