//
//  MBSimpleTabBarController.swift
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//  简化版本的TabBar控制器，避免并发问题
//

import UIKit
import SwiftUI

// MARK: - 简化版TabBar控制器
@objc(MBSimpleTabBarController)
public class MBSimpleTabBarController: UITabBarController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 创建新的 SwiftUI 首页控制器
        let homeVC = UIHostingController(rootView: HomeViewController())
        let homeNav = MONavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "首页", image: UIImage(systemName: "house.fill"), tag: 0)
        
        // 创建AI栏目控制器
        let aiVC = MBAIViewController()
        let aiNav = MONavigationController(rootViewController: aiVC)
        aiNav.tabBarItem = UITabBarItem(title: "AI", image: UIImage(systemName: "brain.head.profile"), tag: 1)
        
        // 创建任务控制器（占位符）
        let taskVC = UIViewController()
        taskVC.view.backgroundColor = .systemBackground
        taskVC.title = "任务"
        let taskNav = MONavigationController(rootViewController: taskVC)
        taskNav.tabBarItem = UITabBarItem(title: "任务", image: UIImage(systemName: "list.bullet"), tag: 2)
        
        // 创建个人中心控制器（占位符）
        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.title = "我的"
        let profileNav = MONavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "我的", image: UIImage(systemName: "person.fill"), tag: 3)
        
        // 设置视图控制器
        self.viewControllers = [homeNav, aiNav, taskNav, profileNav]
        
        // 设置TabBar样式
        self.tabBar.tintColor = .systemBlue
        self.tabBar.backgroundColor = .systemBackground
        
        // 默认选中首页
        self.selectedIndex = 0
    }
    
}

// MARK: - 简化版包装器
@objc(MBSimpleTabBarWrapper)
public class MBSimpleTabBarWrapper: NSObject {
    
    @objc public static func createSimpleTabBarController() -> UITabBarController {
        return MBSimpleTabBarController()
    }
}
