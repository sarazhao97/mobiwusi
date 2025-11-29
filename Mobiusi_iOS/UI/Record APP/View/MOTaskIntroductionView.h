//
//  MOTaskIntroductionView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOTaskIntroductionView : MOView
@property(nonatomic,strong)MOView *markView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *textLabel;
@property(nonatomic,strong)MOButton *exampleBtn;
@property(nonatomic,copy)void(^didExampleBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
