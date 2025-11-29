//
//  MBMainTabBarController.swift
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//

import SwiftUI
import UIKit
import Foundation

// MARK: - 自定义TabBar类，实现5个元素的均匀分布
class MBCustomTabBar: UITabBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 获取TabBar的宽度和高度
        let tabBarWidth = self.frame.width
        let tabBarHeight = self.frame.height
        
        // 计算5个元素的均匀分布位置
        // 每个元素占据的宽度 = tabBarWidth / 5
        let itemWidth = tabBarWidth / 5
        
        // 重新排列4个文字按钮的位置，让它们按照5个元素的均匀分布排列
        // 位置：0, 1, 2(按钮), 3, 4
        // 但TabBar只有4个按钮，所以我们需要跳过位置2
        let positions = [0, 1, 3, 4] // 跳过位置2，因为那里是红色按钮
        
        var itemIndex = 0
        for subview in self.subviews {
            if let item = subview as? UIControl {
                if itemIndex < 4 { // 只处理前4个按钮
                    let position = positions[itemIndex]
                    let x = CGFloat(position) * itemWidth + itemWidth / 2
                    item.center = CGPoint(x: x, y: tabBarHeight / 2)
                    itemIndex += 1
                }
            }
        }
    }
}


// MARK: - 主TabBar控制器 - 集成现有的MTHomeVC
@objc(MBMainTabBarController)
@MainActor
public class MBMainTabBarController: UITabBarController {
    // 通过 selector 方式监听通知，避免在非隔离 deinit 中访问属性
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 替换TabBar为自定义TabBar
        let customTabBar = MBCustomTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
        
        setupTabBar()

        // 监听需要登录的通知（用户信息被清除或登录失效）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onLoginRequired(_:)),
            name: .loginRequired,
            object: nil
        )
    }
    
    
    @MainActor
    private func setupTabBar() {
        // 创建现有的主页控制器
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
     
        // let homeVC = storyboard.instantiateViewController(withIdentifier: "MTHomeVC")
        let homeView = HomeViewController()
        let homeVC = UIHostingController(rootView: homeView)
       
        
        let homeNav = MONavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "首页", image: nil, tag: 0)

        // 创建场景控制器（占位符）
        let sceneView = SceneView()
        let sceneVC = UIHostingController(rootView: sceneView)
      
        let sceneNav = MONavigationController(rootViewController: sceneVC)
        sceneNav.tabBarItem = UITabBarItem(title: "场景", image: nil, tag: 1)
        
        // 创建AI栏目控制器（根据设计图重新设计）
        let aiVC = UIHostingController(rootView: AIView())
        
        // 直接使用UIHostingController作为TabBar的视图控制器，不包装在NavigationController中
        aiVC.tabBarItem = UITabBarItem(title: "AI", image: nil, tag: 2)
        // let aiNav = MONavigationController(rootViewController: aiVC)
        // aiNav.tabBarItem = UITabBarItem(title: "AI", image: nil, tag: 2)
        
        // 确保AI视图控制器忽略安全区域
        if #available(iOS 11.0, *) {
            aiVC.view.insetsLayoutMarginsFromSafeArea = false
        }
        
        // 创建个人中心控制器
        // let profileVC = ProfileViewController()
        let profileRoot = UIHostingController(rootView: MineViewController())
        let profileNav = MONavigationController(rootViewController: profileRoot)

        profileNav.tabBarItem = UITabBarItem(title: "我的", image: nil, tag: 3)
        
        // 设置视图控制器
           self.viewControllers = [homeNav, sceneNav, aiVC, profileNav]

        
        // 设置TabBar样式
        self.tabBar.tintColor = .black  // 选中状态的颜色（黑色）
        self.tabBar.unselectedItemTintColor = .gray  // 未选中状态的颜色（灰色）
        // 统一设置白色背景，兼容 iOS 12/13/15 的外观系统，并明确字体、颜色与位置
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            // 去掉顶部边框线（阴影线）
            appearance.shadowImage = nil
            appearance.shadowColor = .clear
            // 未选中与选中字体、颜色、位置
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19) {
                 appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
            
            }else{
                //  appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = .zero
                  appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            }
           
           
            appearance.stackedLayoutAppearance.selected.iconColor = .black
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
             if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19) {
                 appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
               
            }else{
                appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            }
            // 兼容 iPad/横屏的 inline / compact 样式
            appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
            appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        } else if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            // 去掉顶部边框线（阴影线）
            appearance.shadowImage = nil
            appearance.shadowColor = .clear
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19) {
                 appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
               
            }else{
                appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            }
            appearance.stackedLayoutAppearance.selected.iconColor = .black
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
             if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19) {
                 appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
                
             }else{
                 appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
             }
           
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.barTintColor = .white
            self.tabBar.isTranslucent = false
            self.tabBar.backgroundColor = .white
            // 去掉顶部边框线（阴影线）
            self.tabBar.shadowImage = UIImage()
            self.tabBar.backgroundImage = UIImage()
            // iOS 12- 使用 UIAppearance 设置字体大小与位置
            UITabBarItem.appearance().setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ], for: .selected)
             if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19){
                 UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
               
             }else{
                UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
             }
           
        }
        
        // 设置TabBar项目分布方式为均匀分布
        self.tabBar.itemPositioning = .fill
        self.tabBar.itemSpacing = 0
        
        // 设置字体大小和垂直对齐
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .selected)
        
        // 设置文字垂直位置，使其在导航条中垂直居中
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22)
        
        // 默认选中首页
        self.selectedIndex = 0
        
        // 添加中间的红色加号按钮
        setupCenterPublishButton()
    }

    deinit {
        // 使用 self 直接移除通知监听，避免访问 actor 隔离属性
        NotificationCenter.default.removeObserver(self, name: .loginRequired, object: nil)
    }

    @objc private func onLoginRequired(_ notification: Notification) {
        Task { @MainActor in
            self.presentLoginViewController()
        }
    }

    @MainActor
    private func presentLoginViewController() {
        // 获取最顶层的可呈现视图控制器
        var topVC: UIViewController = self
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // 创建并呈现登录页面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "MOLoginVC") as? UIViewController else {
            return
        }
        loginVC.modalPresentationStyle = .fullScreen
        topVC.present(loginVC, animated: true)
    }
    
    @MainActor
    private func setupCenterPublishButton() {
        // 创建中间的红色加号按钮
        let centerButton = UIButton(type: .custom)
        centerButton.backgroundColor = .clear
        centerButton.setImage(UIImage(named: "icon_publish"), for: .normal)
        centerButton.tintColor = .red
        centerButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        // 计算按钮位置（5个元素的均匀分布）
        let tabBarWidth = self.tabBar.frame.width
        let tabBarHeight = self.tabBar.frame.height
       
        let buttonY = (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 19) ? tabBarHeight / 2 + 10.0 : tabBarHeight / 2
        
        // 计算5个元素的均匀分布位置
        // 元素位置：0, 1, 2(按钮), 3, 4
        // 每个元素占据的宽度 = tabBarWidth / 5
        // 按钮应该在位置2，即 2 * (tabBarWidth / 5) + (tabBarWidth / 5) / 2
        let itemWidth = tabBarWidth / 5
        let buttonX = 2 * itemWidth + itemWidth / 2
        centerButton.center = CGPoint(x: buttonX, y: buttonY)
        
        // 添加点击事件
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        // 将按钮添加到TabBar
        self.tabBar.addSubview(centerButton)
        
        // 确保按钮在最前面
        self.tabBar.bringSubviewToFront(centerButton)
    }
    
    @objc private func centerButtonTapped() {
        print("发布按钮被点击")
        // 弹出上传内容页面
        presentUploadContentView()
    }
    
    private func presentUploadContentView() {
        // 创建上传内容页面
        let uploadView = UploadContentView(
            onDismiss: {
                // 关闭当前呈现的视图控制器
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true)
                }
            },
            onUploadImage: {
                // 关闭当前 sheet 并导航到上传图片页面
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self.navigateToUploadImage()
                    }
                }
            },
            onUploadVideo: {
                // 关闭当前 sheet 并导航到上传视频页面
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self.navigateToUploadVideo()
                    }
                }
            },
            onUploadDocument: {
                // 关闭当前 sheet 并导航到上传文档页面
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self.navigateToUploadDocument()
                    }
                }
            },
            onUploadAudio: {
                // 关闭当前 sheet 并导航到上传音频页面
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self.navigateToUploadAudio()
                    }
                }
            }
        )
        let hostingController = UIHostingController(rootView: uploadView)
        
        // 设置 sheet 样式
        if #available(iOS 15.0, *) {
            hostingController.sheetPresentationController?.detents = [.medium(), .large()]
            hostingController.sheetPresentationController?.prefersGrabberVisible = false
            // 设置圆角半径
            hostingController.sheetPresentationController?.preferredCornerRadius = 20
        }
        
        // 呈现页面
        present(hostingController, animated: true)
    }
    
    private func navigateToUploadImage() {
         Task { @MainActor in
                let vc = UIHostingController(
                    rootView: PictureReleasePanel()
  			    .toolbar(.hidden, for: .navigationBar)
			    .toolbarColorScheme(.dark)
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }
    }
    
    private func navigateToUploadVideo() {
          Task { @MainActor in
                let vc = UIHostingController(
                    rootView: VideoReleasePanel()
  			    .toolbar(.hidden, for: .navigationBar)
			    .toolbarColorScheme(.dark)
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }

    }
    
    private func navigateToUploadDocument() {
        // 创建上传文档页面
        // // 呈现页面
        // present(navController, animated: true)
          Task { @MainActor in
                let vc = UIHostingController(
                    rootView: TextReleasePanel()
  			    .toolbar(.hidden, for: .navigationBar)
			    .toolbarColorScheme(.dark)
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }

    }
    
    private func navigateToUploadAudio() {

        Task { @MainActor in
                let vc = UIHostingController(
                    rootView: UploadAudioController()
  			    .toolbar(.hidden, for: .navigationBar)
			    .toolbarColorScheme(.dark)
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }
    }
}

// MARK: - 上传内容页面
struct UploadContentView: View {
    let onDismiss: () -> Void
    let onUploadImage: () -> Void
    let onUploadVideo: () -> Void
    let onUploadDocument: () -> Void
    let onUploadAudio: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 弹出层内容
            VStack(spacing: 30) {
                HStack {
                    Image("icon_ai_slogan")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 240)
                    Spacer()
                }
                .padding(.top,20)
                .padding(.bottom,60)
                   
                // 操作按钮
                VStack(spacing: 10) {
                   HStack(spacing:10){
                        VStack(spacing:5){
                            Button(action: {
                                onUploadImage()
                            }) {
                                ZStack{
                                    Image("icon_publish_img")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth:.infinity)
                                    HStack{
                                    VStack(alignment:.leading,spacing:10){
                                        Text("上传图片")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.black)
                                       
                                        Text("像素之中，数据觉醒")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex:"#2F2F32"))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal,10)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                         VStack(spacing:5){
                            Button(action: {
                                onUploadVideo()
                            }) {
                                ZStack{
                                    Image("icon_publish_video")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth:.infinity)
                                      HStack{
                                    VStack(alignment:.leading,spacing:10){
                                        Text("上传视频")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.black)
                                       
                                        Text("影像留存，数据增值")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex:"#2F2F32"))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal,10)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                   }
                   HStack(spacing:10){
                        VStack(spacing:5){
                            Button(action: {
                                onUploadDocument()
                            }) {
                                ZStack{
                                    Image("icon_publish_file")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth:.infinity)
                                      HStack{
                                    VStack(alignment:.leading,spacing:10){
                                        Text("上传文档")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.black)
                                       
                                        Text("知识积累，从此开始")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex:"#2F2F32"))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal,10)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                         VStack(spacing:5){
                            Button(action: {
                                onUploadAudio()
                            }) {
                                ZStack{
                                    Image("icon_publish_audio")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth:.infinity)
                                      HStack{
                                    VStack(alignment:.leading,spacing:10){
                                        Text("上传音频")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.black)
                                       
                                        Text("声音存档，价值释放")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex:"#2F2F32"))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal,10)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                   }

                   HStack(alignment:.center){
                    Button{
                        onDismiss()
                    }label: {
                         Image("icon_ai_close")
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 50)
                    }
                       
                   }
                   .padding(.top,20)
                   .padding(.bottom,30)
                   
                }
                .padding(.top,20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
           
        }
        .background(
            ZStack {
                // 底层纯白色不透明背景
                Color(hex:"#F7F8FA")
                
                // 中层背景图
                Image("bg_ai")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        )
        .ignoresSafeArea(.all)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}


// MARK: - SwiftUI包装器
@objc(MBMainTabBarWrapper)
public class MBMainTabBarWrapper: NSObject {
    
    @MainActor
    @objc public static func createMainTabBarController() -> UITabBarController {
        return MBMainTabBarController(nibName: nil, bundle: nil)
    }
}
