//
//  MBSwiftUITabBarWrapper.swift
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//

import SwiftUI
import UIKit

// MARK: - SwiftUI TabBar Wrapper for Objective-C
@objc(MBSwiftUITabBarWrapper)
public class MBSwiftUITabBarWrapper: NSObject {
    
    @MainActor
    @objc public static func createTabBarViewController() -> UIViewController {
        let hostingController = UIHostingController(rootView: MBSimpleTabBarView())
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
    
    @MainActor
    @objc public static func createAIViewController() -> UIViewController {
        let hostingController = UIHostingController(rootView: MBSimpleAIView())
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}

// MARK: - Simple TabBar View
struct MBSimpleTabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    MBSimpleHomeView()
                case 1:
                    MBSimpleSceneView()
                case 2:
                    MBSimpleAIView()
                case 3:
                    MBSimpleProfileView()
                default:
                    MBSimpleHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                // 首页
                MBSimpleTabBarButton(
                    index: 0,
                    selectedTab: $selectedTab,
                    title: tabTitles[0],
                    iconName: tabIcons[0]
                )
                
                // 场景
                MBSimpleTabBarButton(
                    index: 1,
                    selectedTab: $selectedTab,
                    title: tabTitles[1],
                    iconName: tabIcons[1]
                )
                
                // 中间的红色加号按钮
                MBCenterPublishButton()
                
                // AI
                MBSimpleTabBarButton(
                    index: 2,
                    selectedTab: $selectedTab,
                    title: tabTitles[2],
                    iconName: tabIcons[2]
                )
                
                // 我的
                MBSimpleTabBarButton(
                    index: 3,
                    selectedTab: $selectedTab,
                    title: tabTitles[3],
                    iconName: tabIcons[3]
                )
            }
            .frame(height: 83) // 49 + 34 (safe area)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private let tabTitles = ["首页", "场景", "AI", "我的"]
    private let tabIcons = ["house", "square.grid.2x2", "brain.head.profile", "person"]
}

// MARK: - Simple Tab Bar Button
struct MBSimpleTabBarButton: View {
    let index: Int
    @Binding var selectedTab: Int
    let title: String
    let iconName: String
    
    var isSelected: Bool {
        selectedTab == index
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 49)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Center Publish Button
struct MBCenterPublishButton: View {
    var body: some View {
        Button(action: {
            // 处理发布按钮点击事件
            print("发布按钮被点击")
        }) {
            ZStack {
                // 红色圆角矩形背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
                    .frame(width: 50, height: 50)
                
                // 白色加号图标
                Image("icon_publish")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .frame(height: 49)
    }
}

// MARK: - Simple Views
struct MBSimpleHomeView: View {
    var body: some View {
        VStack {
            Text("首页")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("这里是首页内容")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

struct MBSimpleSceneView: View {
    var body: some View {
        VStack {
            Text("场景")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("这里是场景内容")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

struct MBSimpleAIView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("AI智能助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("让AI为您提供专业服务")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Button("食品安全检测") {
                    print("食品安全检测被点击")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("资讯分析师") {
                    print("资讯分析员被点击")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button("海外翻译") {
                    print("海外翻译被点击")
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

struct MBSimpleTaskView: View {
    var body: some View {
        VStack {
            Text("任务")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("这里是任务内容")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

struct MBSimpleProfileView: View {
    var body: some View {
        VStack {
            Text("我的")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("这里是个人中心内容")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}
