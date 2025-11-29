

#import "MOTabBar.h"


@interface MOTabBar()
@property (nonatomic, strong) NSMutableArray *tabBarButtons;
@end

@implementation MOTabBar
{
    UIEdgeInsets _oldSafeAreaInsets;
}
- (NSMutableArray *)tabBarButtons
{
    if (_tabBarButtons == nil) {
        _tabBarButtons = [NSMutableArray array];
    }
    return _tabBarButtons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        _oldSafeAreaInsets = UIEdgeInsetsZero;

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _oldSafeAreaInsets = UIEdgeInsetsZero;
}

- (void)setSelectedButton:(MOTabBarButton *)selectedButton{
    _selectedButton = selectedButton;
    _selectedButton.selected = YES;
}

- (void)addTabBarButtonWithItem:(UITabBarItem *)item
{
    // 1.创建按钮
    MOTabBarButton *button = [[MOTabBarButton alloc] init];
    [self addSubview:button];
    // 添加按钮到数组中
    [self.tabBarButtons addObject:button];
    
    // 2.设置数据
    button.item = item;
    
    // 3.监听按钮点击
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    // 4.默认选中第0个按钮
    if (self.tabBarButtons.count == 0) {
        [self buttonClick:button];
    }
    
    self.layer.shadowColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.05].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 1;
}

- (void)addRedPointWithTabBarButton:(int)index{
    MOTabBarButton *button = self.tabBarButtons[index];
    [button addSubview:button.redPoint];
}

- (void)removeRedPointWithTabBarButton:(int)index{
    MOTabBarButton *button = self.tabBarButtons[index];
    [button.redPoint removeFromSuperview];
}

/**
 *  监听按钮点击
 */
- (void)buttonClick:(MOTabBarButton *)button
{
    
    // 1.通知代理
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectedButtonFrom:to:)]) {
        [self.delegate tabBar:self didSelectedButtonFrom:self.selectedButton.tag to:button.tag];
    }
    
    // 2.设置按钮的状态
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 调整加号按钮的位置
    CGFloat h = 49;
    CGFloat w = self.frame.size.width;
//    self.plusButton.center = CGPointMake(w * 0.5, h * 0.5);
    
    // 按钮的frame数据
    CGFloat buttonH = h;
    CGFloat buttonW = w / self.subviews.count;
    CGFloat buttonY = 0;
    
    for (int index = 0; index<self.tabBarButtons.count; index++) {
        // 1.取出按钮
        MOTabBarButton *button = self.tabBarButtons[index];
        
        // 2.设置按钮的frame
        CGFloat buttonX = index * buttonW;
//        if (index > 0) {
//            buttonX += buttonW;
//        }
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        // 3.绑定tag
        button.tag = index;
    }
}
- (MOTabBarButton*)getCustomTabBarButton:(int)index
{
    if (index<self.tabBarButtons.count) {
//        DLog(@"self.tabBarButtons:%lu",(unsigned long)self.tabBarButtons.count);
        MOTabBarButton *button = self.tabBarButtons[index];
        return button;
    }else
    {
        return nil;
    }
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(_oldSafeAreaInsets, self.safeAreaInsets)) {
        [self invalidateIntrinsicContentSize];
        
        if (self.superview) {
            [self.superview setNeedsLayout];
            [self.superview layoutSubviews];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    
    if (@available(iOS 11.0, *)) {
        float bottomInset = self.safeAreaInsets.bottom;
        if (bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90)) {
            size.height += bottomInset;
        }
    }
    
    return size;
}

- (void)setFrame:(CGRect)frame {
    if (self.superview) {
        if (frame.origin.y + frame.size.height != self.superview.frame.size.height) {
            frame.origin.y = self.superview.frame.size.height - frame.size.height;
        }
    }
    [super setFrame:frame];
}

@end
