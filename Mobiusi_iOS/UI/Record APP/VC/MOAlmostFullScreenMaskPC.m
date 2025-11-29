//
//  MOAlmostFullScreenMaskPC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/5.
//

#import "MOAlmostFullScreenMaskPC.h"

@interface MOAlmostFullScreenMaskPC ()
@end

@implementation MOAlmostFullScreenMaskPC

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [BlackColor colorWithAlphaComponent:0.5];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect finalFrameForVC = [transitionContext finalFrameForViewController:toViewController];
    finalFrameForVC = CGRectMake(finalFrameForVC.origin.x, STATUS_BAR_Height_CODE, finalFrameForVC.size.width, finalFrameForVC.size.height - STATUS_BAR_HEIGHT);
    CGRect initialFrameForVC = CGRectMake(finalFrameForVC.origin.x,
                                          [UIScreen mainScreen].bounds.size.height,
                                          finalFrameForVC.size.width,
                                          finalFrameForVC.size.height);
    
    if (self.presenting) {
        // 设置圆角
        [toViewController.view cornerRadius:QYCornerRadiusTop radius:20.0];
        
        toViewController.view.frame = initialFrameForVC;
        [containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.frame = finalFrameForVC;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
        
        // 添加下滑手势
        [self.interactiveTransition wireToViewController:toViewController];
        
        
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frame = initialFrameForVC;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end


@implementation MOAlmostFullScreenInteractivePC

- (void)wireToViewController:(UIViewController *)viewController {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [viewController.view addGestureRecognizer:panGesture];
    self.currentVC = viewController;
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view];
    CGFloat progress = fabs(translation.y) / view.bounds.size.height;
    progress = MIN(1.0, MAX(0.0, progress));
    DLog("%f",progress);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.interactionInProgress = YES;
            [self.currentVC dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interactionInProgress = NO;
            if (progress > 0.5) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

@end

@implementation MOAlmostFullScreenMasDelegate
-(instancetype)init {
    self = [super init];
    if (self) {
        self.animator = [[MOAlmostFullScreenMaskPC alloc] init];
        self.interactiveTransition = [MOAlmostFullScreenInteractivePC new];
    }
    
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    self.animator.presenting = YES;
//    self.animator.interactiveTransition = self.interactiveTransition;
    return self.animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    MOAlmostFullScreenMaskPC *animator = [[MOAlmostFullScreenMaskPC alloc] init];
    self.animator.presenting = NO;
    return self.animator;
}

//- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
//    
//    return self.interactiveTransition.interactionInProgress ? self.interactiveTransition : nil;
//}
@end



