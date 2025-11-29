//
//  MOHomeSearchBarView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOHomeSearchBarView : MOView
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UIImageView *leftIconImageView;
@property(nonatomic,strong)UITextField *searchTF;
@property(nonatomic,strong)MOButton *searchBtn;
@property(nonatomic,copy)void (^didSearch)(void);
@end

NS_ASSUME_NONNULL_END
