//
//  MBTestViewController.m
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//  测试TabBar是否正常显示的控制器
//

#import "MBTestViewController.h"
#import "Mobiusi_iOS-Swift.h"

@interface MBTestViewController ()

@end

@implementation MBTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加测试标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"TabBar测试页面";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    
    // 添加测试按钮
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [testButton setTitle:@"测试TabBar" forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testTabBar) forControlEvents:UIControlEventTouchUpInside];
    testButton.backgroundColor = [UIColor systemBlueColor];
    [testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    testButton.layer.cornerRadius = 8;
    testButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:testButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-50],
        
        [testButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [testButton.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:30],
        [testButton.widthAnchor constraintEqualToConstant:200],
        [testButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)testTabBar {
    // 创建并显示TabBar控制器
    UITabBarController *tabBarController = [MBMainTabBarWrapper createMainTabBarController];
    
    // 模态显示
    [self presentViewController:tabBarController animated:YES completion:^{
        NSLog(@"TabBar控制器已显示");
    }];
}

@end
