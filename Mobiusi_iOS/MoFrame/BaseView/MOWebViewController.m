//
//  MOWebViewController.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/12.
//

#import "MOWebViewController.h"

@interface MOWebViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end



@implementation MOWebViewController

+(instancetype)createWebViewFromStoryBoard {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MOWebViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
    MOWebViewController *webviewController = (MOWebViewController *)targetVC;
    return targetVC;
}

+(instancetype)createWebViewFromStoryBoardWithTitle:(NSString *)title url:(NSString *)url {
	MOWebViewController *vc =  [MOWebViewController createWebViewFromStoryBoard];
	vc.webTitle = title;
	vc.url = url;
	return  vc;
}

+(UINavigationController *)createWebViewAlertStyleWithTitle:(NSString *)title url:(NSString *)url {
	MOWebViewController *vc =  [MOWebViewController createWebViewFromStoryBoard];
	vc.webTitle = title;
	vc.url = url;
	MONavigationController *navVC = [[MONavigationController alloc] initWithRootViewController:vc];
	navVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
	navVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	return  navVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    [self clearWebViewCache];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webTitleLabel.text = self.webTitle;
    [self setWebView];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}


- (void)setWebView {
   
//    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
//    
//    // WKWebView的配置
//    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//    configuration.userContentController = userContentController;
//    
//    self.webView.configuration = configuration;
    self.webView.scrollView.bounces = NO;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
#if DEBUG
    if (@available(iOS 16.4, *)) {
        self.webView.inspectable = YES;
    }
#endif
    

    [self.view insertSubview:self.webView belowSubview:self.progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    
}

#pragma mark - actions

- (IBAction)backAction:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        if (self.closeHandle) {
            self.closeHandle(self);
			return;
        }
//        for (UIViewController *vc in EAAppDelegate.transition.navigationViewController.viewControllers) {
//            if ([vc isKindOfClass:[EAScanViewController class]]) {
//                // 返回首页
//                [EAAppDelegate.transition popToRootViewControllerAnimated:YES];
//                return;
//            }
//        }
        // 如果两个页面都没有，返回上级
        [MOAppDelegate.transition popViewControllerAnimated:YES];
        
    }
}

- (void)clearWebViewCache {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
        
    } else {
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                   NSUserDomainMask, YES)[0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    }
}


#pragma mark - WKScriptMessageHandler

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.progressView.hidden = NO;

        [self.progressView setProgress:newprogress animated:YES];
//        DLog(@"self.progressView.progress - %f",self.progressView.progress);
        if (self.progressView.progress == 1.f) {
            [self performSelector:@selector(hideLine) withObject:nil afterDelay:0.5f];
        }
    }
}

- (void)hideLine {
//    DLog(@"self.progressView.progress - %f",self.progressView.progress);
    self.progressView.hidden = YES;
    self.progressView.progress = 0.f;
}

// 取消监听
- (void)dealloc {
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];

    } @catch (NSException *exception) {
        DLog(@"exception - %@",[exception description]);
    } @finally {
        
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView != self.webView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url1 = navigationAction.request.URL;
    DLog(@"url1 - %@", url1);
    if ([url1.scheme isEqualToString:@"tel"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 跳转appstore
    if ([url1.absoluteString containsString:@"itunes.apple.com"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 跳转支付宝
    if ([url1.absoluteString hasPrefix:@"alipays://"] || [url1.absoluteString hasPrefix:@"alipay://"] || [url1.absoluteString hasPrefix:@"alipayqr://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 跳转微信
    if ([url1.absoluteString hasPrefix:@"weixin://"] || [url1.absoluteString hasPrefix:@"wechat://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 跳转淘宝
    if ([url1.absoluteString hasPrefix:@"tbopen://"] || [url1.absoluteString hasPrefix:@"taobao://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 唯品会
    if ([url1.absoluteString hasPrefix:@"vipshop://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 拼多多
    if ([url1.absoluteString hasPrefix:@"pinduoduo://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    //抖音 snssdk1128:// 头条 snssdk141://
    if ([url1.absoluteString hasPrefix:@"snssdk1128://"] || [url1.absoluteString hasPrefix:@"snssdk141://"])
    {
        if ([app canOpenURL:url1])
        {
            [app openURL:url1 options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    DLog(@"message - %@", message);
    completionHandler();
    
}


@end
