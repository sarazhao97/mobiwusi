//
//  MainTabView.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/1/25.
//

import SwiftUI
import UIKit

// View扩展，支持指定角的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// 磨砂玻璃效果视图
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddContentSheet = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 首页
                HomeViewController()
                    .tabItem {
                        Text("首页")
                        .font(.system(size: 18))
                    }
                    .tag(0)
                
                // 
                SceneView()
                    .tabItem {
                        Image(systemName: "")
                        Text("场景")
                        .font(.system(size: 18))
                    }
                    .tag(1)
                
                // 加号按钮 - 空白页面
                Color.clear
                    .tabItem {
                        Image("icon_publish")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                    }
                    .tag(2)
                
                // 场景
                AIView()
                    .tabItem {
                        Image(systemName: "")
                        Text("AI")
                        .font(.system(size: 18))
                    }
                    .tag(3)
                
                // 我的
                MineViewController()
                    .tabItem {
                        Image(systemName: "")
                        Text("我的")
                        .font(.system(size: 18))
                    }
                    .tag(4)
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 2 {
                    // 点击加号时显示弹出层
                    showAddContentSheet = true
                    // 重置选中状态到首页
                    selectedTab = 0
                }
            }
            
            // 弹出层遮罩
            if showAddContentSheet {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .dark))
                    Color.black.opacity(0.1)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    showAddContentSheet = false
                }
                
                // 底部弹出层
                VStack {
                    Spacer()
                    VStack(spacing: 30) {
                        // 弹出层内容
                        VStack {
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
                                     VStack(spacing:5){
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
                               }
                               HStack(spacing:10){
                                    VStack(spacing:5){
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
                                     VStack(spacing:5){
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
                               }

                               HStack(alignment:.center){
                                Button{
                                    showAddContentSheet = false
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
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: showAddContentSheet)
            }
        }
        
         .accentColor(Color(red: 154/255, green: 30/255, blue: 46/255)) // 设置选中颜色
        .onAppear {
            // 自定义TabBar外观
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            // 去掉顶部边框线（阴影线）
            appearance.shadowImage = nil
            appearance.shadowColor = .clear
            
            // 设置未选中状态的颜色和位置
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 18)
            ]
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            
            // 设置选中状态的颜色和位置
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 18)
            ]
            appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            
            // 设置TabBar高度和内容居中
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().itemPositioning = .fill
            UITabBar.appearance().itemSpacing = 0
        }
    }
}





struct AddContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 154/255, green: 30/255, blue: 46/255))
                    .padding()
                
                Text("添加内容")
                    .font(.largeTitle)
                    .padding()
                
                Text("点击这里添加新的内容")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("添加")
        }
    }
}

