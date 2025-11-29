//
//  MOBaseViewController.h
//  LW_Translate
//
//  Created by x11 on 2023/9/16.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOBaseViewController : UIViewController

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) UIImageView *topBgImageView;   //地点转圈指示器

- (void)goBack;

//loading
- (void)showActivityIndicator;
- (void)showAllowUserInteractionsActivityIndicator;
- (void)hidenActivityIndicator;
-(void)showMessage:(NSString *)msg;
-(void)showErrorMessage:(nullable NSString *)msg;
-(void)showErrorMessage:(nullable NSString *)msg image:(nullable UIImage *)image;
-(void)showProgressWithMessage:(NSString *)msg;

- (void)putKeyboardAway;

+(void)pushServiceAgreementWebVC;
+(void)pushPrivacyAgreementWebVC;
+(void)pushPointsRuleWebVC;
+(void)pushWebVCWithUrl:(NSString *)url title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
