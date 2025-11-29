//
//  MBSwiftUITabBarWrapper.h
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSwiftUITabBarWrapper : NSObject

/// 创建SwiftUI版本的TabBar控制器
+ (UIViewController *)createTabBarViewController;

/// 创建AI栏目的SwiftUI控制器
+ (UIViewController *)createAIViewController;

@end

NS_ASSUME_NONNULL_END
