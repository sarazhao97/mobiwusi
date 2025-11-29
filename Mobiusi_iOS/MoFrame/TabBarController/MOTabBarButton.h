

#import <UIKit/UIKit.h>

@interface MOTabBarButton : UIButton
@property (nonatomic, strong) UITabBarItem *item;
@property (nonatomic, strong) UIImageView *redPoint;

- (id)initWithNormalColor:(UIColor *)normal andSelectedColor:(UIColor *)selected;

@end
