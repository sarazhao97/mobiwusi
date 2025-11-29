//
//  MOPrevNextButtonSetView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/14.
//

#import "MOView.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOPrevNextButtonSetView : MOView
@property(nonatomic,strong)MOButton *prevBtn;
@property(nonatomic,strong)MOButton *nextBtn;
@property(nonatomic,strong)MOButton *saveBtn;
@property(nonatomic,copy)void(^didPrevBtnClick)(void);
@property(nonatomic,copy)void(^didNextBtnClick)(void);
@property(nonatomic,copy)void(^didsaveBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
