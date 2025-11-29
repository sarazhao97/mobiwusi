

#import "MOTabBarButton.h"
#import "UIColor+Hex.h"
// 图标的比例
#define MOTabBarButtonImageRatio 0.5

// 按钮的默认文字颜色
#define  MOTabBarButtonTitleColor FYTITLE_COLOR_D
// 按钮的选中文字颜色
#define  MOTabBarButtonTitleSelectedColor CPMainColor

//#import "MTBadgeButton.h"

@interface MOTabBarButton()
/**
 *  提醒数字
 */
//@property (nonatomic, weak) MTBadgeButton *badgeButton;
@end

@implementation MOTabBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 图标居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        // 文字颜色
        
        [self setTitleColor:TabNormalColor forState:UIControlStateNormal];
        [self setTitleColor:MainSelectColor forState:UIControlStateSelected];
        
    }
    
    return self;
}

- (id)initWithNormalColor:(UIColor *)normal andSelectedColor:(UIColor *)selected
{
    self = [super init];
    if (self) {
        // 图标居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:9];
        // 文字颜色
        [self setTitleColor:normal forState:UIControlStateNormal];
        [self setTitleColor:selected forState:UIControlStateSelected];
        
    }
    
    return self;
}
- (UIImageView *)redPoint{
    if (_redPoint == nil) {
        _redPoint = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/6 + 10, 10, 10, 10)];
        _redPoint.backgroundColor = [UIColor colorWithHexString:@"#FF1313"];
        _redPoint.layer.cornerRadius = 5;
        _redPoint.layer.masksToBounds = YES;
    }
    return _redPoint;
}

// 重写去掉高亮状态
- (void)setHighlighted:(BOOL)highlighted {
}

// 内部图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * MOTabBarButtonImageRatio;
    return CGRectMake(0, 8, imageW, imageH);
}

// 内部文字的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height * MOTabBarButtonImageRatio + 8;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(0, titleY, titleW, titleH);
}

// 设置item
- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    // KVO 监听属性改变
//    [item addObserver:self forKeyPath:@"badgeValue" options:0 context:nil];
    [item addObserver:self forKeyPath:@"title" options:0 context:nil];
    [item addObserver:self forKeyPath:@"image" options:0 context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:0 context:nil];
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
}

- (void)dealloc
{
//    [self.item removeObserver:self forKeyPath:@"badgeValue"];
    [self.item removeObserver:self forKeyPath:@"title"];
    [self.item removeObserver:self forKeyPath:@"image"];
    [self.item removeObserver:self forKeyPath:@"selectedImage"];
}

/**
 *  监听到某个对象的属性改变了,就会调用
 *
 *  @param keyPath 属性名
 *  @param object  哪个对象的属性被改变
 *  @param change  属性发生的改变
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    //"我的"页面特殊处理一下
//    if ([self.item.title isEqualToString:@""]) {
//        self.item.title = @"我的";
//    }
    
    // 设置文字（注释--只显示图片）
    [self setTitle:self.item.title forState:UIControlStateSelected];
    [self setTitle:self.item.title forState:UIControlStateNormal];
    
    // 设置图片
    [self setImage:self.item.image forState:UIControlStateNormal];
    [self setImage:self.item.selectedImage forState:UIControlStateSelected];
}

@end
