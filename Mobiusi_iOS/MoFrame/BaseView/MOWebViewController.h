//
//  MOWebViewController.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/12.
//

#import "MOBaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOWebViewController : MOBaseViewController<WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (nonatomic, copy) NSString *url;

@property (weak, nonatomic) IBOutlet UILabel *webTitleLabel;

@property (nonatomic, copy) NSString *webTitle;

@property (nonatomic,copy) void(^closeHandle)(MOWebViewController *webVC);

+(instancetype)createWebViewFromStoryBoard;
+(instancetype)createWebViewFromStoryBoardWithTitle:(NSString *)title url:(NSString *)url;
+(UINavigationController *)createWebViewAlertStyleWithTitle:(NSString *)title url:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
