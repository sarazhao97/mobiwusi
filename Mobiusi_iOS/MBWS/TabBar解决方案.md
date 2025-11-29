# TabBar不显示问题解决方案

## 问题分析

SwiftUI TabBar不显示可能的原因：
1. iOS版本兼容性问题
2. SwiftUI TabView在某些情况下可能不显示
3. 集成方式不正确
4. 视图层次结构问题

## 解决方案

### 方案1：使用测试版本（推荐先试这个）

```objc
// 在AppDelegate.m中
#import "Mobiusi_iOS-Swift.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 使用测试版本
    UIViewController *testVC = [MBSwiftUITabBarWrapper createTestTabBarViewController];
    self.window.rootViewController = testVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}
```

### 方案2：使用自定义TabBar（最稳定）

```objc
// 如果测试版本正常，使用自定义TabBar
UIViewController *customVC = [MBSwiftUITabBarWrapper createCustomTabBarViewController];
self.window.rootViewController = customVC;
```

### 方案3：使用原生SwiftUI TabView

```objc
// 使用原生TabView版本
UIViewController *nativeVC = [MBSwiftUITabBarWrapper createTabBarViewController];
self.window.rootViewController = nativeVC;
```

## 调试步骤

### 1. 检查控制台输出
运行后应该看到：
```
MBTestTabBarView appeared - TabBar should be visible
```

### 2. 检查设备兼容性
- 确保在真机上测试（模拟器可能有兼容性问题）
- 确保iOS版本 >= 13.0

### 3. 检查Xcode设置
- 确保项目支持SwiftUI
- 确保所有Swift文件都添加到编译目标中
- 检查Build Settings中的Swift版本

### 4. 使用Xcode调试工具
- 使用View Hierarchy Debugger查看视图层次
- 设置断点检查viewDidLoad是否被调用

## 可用的TabBar实现

1. **MBTestTabBarView** - 最简化的测试版本
2. **MBCustomTabBarView** - 自定义实现，最稳定
3. **MBTabBarView** - 原生SwiftUI TabView
4. **MBCustomTabBarView** - 包装器中的自定义版本

## 推荐使用顺序

1. 先试 `createTestTabBarViewController`
2. 如果正常，再试 `createCustomTabBarViewController`
3. 最后试 `createTabBarViewController`

## 常见问题

### Q: TabBar完全不显示
A: 使用测试版本，检查控制台输出

### Q: TabBar显示但点击无响应
A: 检查按钮的action是否正确设置

### Q: 只有部分Tab显示
A: 检查tabItem配置和tag值

### Q: 在模拟器上不显示
A: 在真机上测试，模拟器可能有兼容性问题

## 代码示例

完整的AppDelegate集成示例：

```objc
#import "AppDelegate.h"
#import "Mobiusi_iOS-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 选择一种实现方式
    UIViewController *rootVC = [MBSwiftUITabBarWrapper createTestTabBarViewController];
    // UIViewController *rootVC = [MBSwiftUITabBarWrapper createCustomTabBarViewController];
    // UIViewController *rootVC = [MBSwiftUITabBarWrapper createTabBarViewController];
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    NSLog(@"Root view controller set: %@", rootVC);
    
    return YES;
}

@end
```
