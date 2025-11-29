
#import "MOTabBar.h"

#import <UIKit/UIKit.h>

@interface MOTabBarViewController : UITabBarController

/**
 *  自定义的tabbar
 */
@property (nonatomic, weak) MOTabBar *customTabBar;
@property (nonatomic) NSInteger loadCount;
@property (nonatomic,assign) BOOL isDown;

/**
 *  显示或隐藏TabBar
 *
 *  @param isHideen 是否隐藏
 *  @param animated 是否需要动画
 */
- (void)HideTabarView:(BOOL)isHideen  animated:(BOOL)animated;

@end
