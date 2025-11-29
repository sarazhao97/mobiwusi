

#import "MOTabBarButton.h"
#import <UIKit/UIKit.h>

@class MOTabBar;

@protocol MOTabBarDelegate <NSObject>

@optional
- (void)tabBar:(MOTabBar *)tabBar didSelectedButtonFrom:(int)from to:(int)to;

- (void)toPurVC;

- (void)toCameraVC;

@end

@interface MOTabBar : UIView
//通用bar
- (void)addTabBarButtonWithItem:(UITabBarItem *)item;

- (MOTabBarButton*)getCustomTabBarButton:(int)index;

- (void)addRedPointWithTabBarButton:(int)index;
- (void)removeRedPointWithTabBarButton:(int)index;

@property (nonatomic, weak) id<MOTabBarDelegate> delegate;
@property (nonatomic, weak) MOTabBarButton *selectedButton;

@end
