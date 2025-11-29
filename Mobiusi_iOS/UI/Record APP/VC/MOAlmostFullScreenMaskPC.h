//
//  MOAlmostFullScreenMaskPC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/5.
//

#import <UIKit/UIKit.h>
@class MOAlmostFullScreenInteractivePC;
NS_ASSUME_NONNULL_BEGIN
//非交互式的动画
@interface MOAlmostFullScreenMaskPC : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) MOAlmostFullScreenInteractivePC *interactiveTransition;
@end

@interface MOAlmostFullScreenInteractivePC : UIPercentDrivenInteractiveTransition
@property (nonatomic, assign) BOOL interactionInProgress;
@property(nonatomic,weak)UIViewController *currentVC;
- (void)wireToViewController:(UIViewController *)viewController;
@end

//过渡代理
@interface MOAlmostFullScreenMasDelegate : NSObject<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) MOAlmostFullScreenInteractivePC *interactiveTransition;
@property (nonatomic, strong) MOAlmostFullScreenMaskPC *animator;

@end
NS_ASSUME_NONNULL_END
