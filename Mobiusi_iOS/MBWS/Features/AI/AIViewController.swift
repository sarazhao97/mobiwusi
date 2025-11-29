//
//  AIView.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/8/26.
//

//
//  ProfileViewController.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/8/26.
//
import SwiftUI

struct AIView: View {
    @State private var navigateToFoodSafer: Bool = false
    @State private var navigateToNotification: Bool = false
    
    
    
    var body: some View {
        NavigationStack {
            ZStack{
            // 全屏背景色
            Color(hex: "#f7f8fa")
                .ignoresSafeArea(.all)
            
            // 右上角铃铛图标 - 固定在顶部导航条位置
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        navigateToNotification = true
                    }) {
                        Image("fi_bell")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 0) // 移除顶部间距，让铃铛图标贴近顶部
                  
                   
                }
                .frame(height: 40) // 设置固定高度，模拟导航条高度
                .padding(.horizontal,15)
                Spacer()
            }
            
            // 主要内容
            VStack{
                ZStack{
                    Image("icon_ai_mo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth:.infinity,maxHeight: 300)
                        .padding(.horizontal,5)
                    
                    VStack{
                        Text("你好，我是小Mo~")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.black)
                            .frame(maxWidth:.infinity,alignment:.center)
                            .padding(.leading,50)
                            .padding(.top,20)
                            .minimumScaleFactor(0.7)
                            .allowsTightening(true)
                        HStack{
                            Text("我是一个多才多艺的万能选手！能分析、能翻译、能拍照、还能测八字，什么都难不倒我～每一次变身，都藏着惊喜，等你来解锁体验！")
                                .lineSpacing(6)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#626262"))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,22)
                        .frame(maxWidth:.infinity,alignment:.leading)
                        .background(Color.white)
                        .cornerRadius(18)
                        .padding(20)
                    }
                    .frame(maxWidth:.infinity,maxHeight:300,alignment:.center)
                    .padding(.horizontal,20)
                    .padding(.top,20)
                }
                VStack{
                      HStack{
                        Button(action: {
                                       let summarizeSampleVC = MOSummarizeSampleVC()
                            
                            // 设置返回按钮的回调
                            summarizeSampleVC.setBackButtonAction {
                                summarizeSampleVC.dismiss(animated: true)
                            }
                            
                            let navController = UINavigationController(rootViewController: summarizeSampleVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.modalTransitionStyle = .coverVertical
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootVC = window.rootViewController {
                                var topVC = rootVC
                                while let presentedVC = topVC.presentedViewController {
                                    topVC = presentedVC
                                }
                                topVC.present(navController, animated: true)
                            }
                        }) {
                            VStack(alignment:.leading,spacing:10){
                                Image("icon_ai_information_analyst")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:50,height:50)
                                Text("资讯分析师")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.black)
                                   Text("秒解信息迷雾，洞见趋势先机")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex:"#626262"))
                            }
                            .padding(.horizontal,20)
                            .padding(.vertical,10)
                            .frame(maxWidth:.infinity,maxHeight:140)
                            .background(Color(hex:"#ffffff"))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Button(action:{
                            let translateVC = MOTranslateTextOnImageVC()
                            let navController = UINavigationController(rootViewController: translateVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.modalTransitionStyle = .coverVertical
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootVC = window.rootViewController {
                                var topVC = rootVC
                                while let presentedVC = topVC.presentedViewController {
                                    topVC = presentedVC
                                }
                                topVC.present(navController, animated: true)
                            }
                        }){
                        VStack(alignment:.leading,spacing:10){
                            Image("icon_ai_overseas_translator")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:50,height:50)
                            Text("出国翻译官")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.black)
                           Text("跨语言无障碍，行走世界随身译")
                                .font(.system(size: 12))
                              .multilineTextAlignment(.leading)
                               .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex:"#626262"))
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .frame(maxWidth:.infinity,maxHeight:140)
                         .background(Color(hex:"#ffffff"))
                        .cornerRadius(10)
                      }
                    }
                    .padding(.horizontal,10)
                    .frame(maxWidth:.infinity)
                  
                    
                    HStack{
                        Button(action: {
                            let aiCameraVC = MOAICameraVC()
                            let navController = UINavigationController(rootViewController: aiCameraVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.modalTransitionStyle = .coverVertical
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootVC = window.rootViewController {
                                var topVC = rootVC
                                while let presentedVC = topVC.presentedViewController {
                                    topVC = presentedVC
                                }
                                topVC.present(navController, animated: true)
                            }
                        }) {
                            VStack(alignment:.leading,spacing:10){
                                Image("icon_ai_versatile_photographer")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:50,height:50)
                                Text("多变摄影师")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.black)
                                Text("一镜揽万象，风格随心切换")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex:"#626262"))
                            }
                            .padding(.horizontal,20)
                            .padding(.vertical,10)
                            .frame(maxWidth:.infinity,maxHeight:140)
                            .background(Color(hex:"#ffffff"))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        VStack(alignment:.leading,spacing:10){
                            Image("icon_ai_food_safety")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:50,height:50)
                            Text("食品安全员")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.black)
                            Text("舌尖防线守护者，每一口都安心")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex:"#626262"))
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .frame(maxWidth:.infinity,maxHeight:140)
                         .background(Color(hex:"#ffffff"))
                        .cornerRadius(10)
                        .onTapGesture {
                            Task { @MainActor in
                                let navController = UINavigationController(rootViewController: MOFoodSafetyVC())
                                navController.modalPresentationStyle = .fullScreen
                                navController.modalTransitionStyle = .coverVertical
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    var topVC = rootVC
                                    while let presentedVC = topVC.presentedViewController {
                                        topVC = presentedVC
                                    }
                                    topVC.present(navController, animated: true)
                                }
                            }
                        }
                    }
                    .padding(.horizontal,10)
                    .frame(maxWidth:.infinity)
                }
                .offset(y:-20)
                
                Spacer()
            }
            .padding(.horizontal,5)
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            NavigationLink(destination: FoodSaferControllerWrapper(), isActive: $navigateToFoodSafer) {
                EmptyView()
            }
            NavigationLink(destination:NotificationController(), isActive: $navigateToNotification) {
                    EmptyView()
                }
        }
        }
    }
}

// 将 UIKit 的 FoodSaferController 封装为 SwiftUI 视图，供 NavigationLink 使用
struct FoodSaferControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MOFoodSafetyVC {
        MOFoodSafetyVC()
    }
    func updateUIViewController(_ uiViewController: MOFoodSafetyVC, context: Context) {}
}
