//
//  MOSearchNavBarView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOSearchNavBarView : MOView
@property(nonatomic,strong)MOButton *backBtn;
@property(nonatomic,strong)MOView *searchContnetView;
@property(nonatomic,strong)UITextField *searchTF;
@property(nonatomic,strong)MOButton *searchBtn;
@property(nonatomic,copy)void(^gobackDidClick)(void);
@property(nonatomic,copy)void(^didSearch)(NSString *keyWord,UITextField *textFiled);
@property(nonatomic,copy)void(^didDeleteAllSearchTFText)(UITextField *textFiled);
@end

NS_ASSUME_NONNULL_END
