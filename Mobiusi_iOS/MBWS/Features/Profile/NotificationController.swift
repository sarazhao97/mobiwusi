import SwiftUI
import Foundation
import UIKit



struct NotificationRow:View{
    var message: MessageItem
   
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
           HStack{
            HStack{
                Image("email")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hex:"#9A1E2E"))
                Text(message.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#000000"))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
            Text(message.formattedTime)
                .font(.system(size: 14))
                .foregroundColor(Color(hex:"#626262"))
           }

           Rectangle()
            .fill(Color(hex:"#F7F8FA"))
            .frame(height: 1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
           HStack{
            Text(message.content)
                .font(.system(size: 16))
                .lineSpacing(6)
                .foregroundColor(Color(hex:"#626262"))
           }
           .padding(.top,10)
        }
        .padding(20)
        .frame(maxWidth:.infinity)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal,10)
        // .padding(.top,-20)

    }

   
}


struct NotificationController: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [MessageItem] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var currentPage = 1
    @State private var limit = 10
    @State private var total = 0
    @State private var hasMoreData: Bool = true

    var body: some View {
        ZStack {
            Color(hex: "#F7F8FA")
                .ignoresSafeArea(.container, edges: .bottom)
            VStack{
             // 自定义标题栏
            customNavigationBar()
            if notifications.isEmpty{
                VStack(alignment:.center,spacing:30){
                    Image("icon_data_empty")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    Text("暂时没有消息")
                        .font(.system(size: 16,weight:.bold))
                        .foregroundColor(Color(hex:"#000000"))
                }
                .padding(.top,80)
            }else{
            ScrollView(showsIndicators: false){
                LazyVStack(spacing: 10) {
                    ForEach(notifications) { message in
                        NotificationRow(message: message)
                            .id(message.id)
                    }
                    
                    // 加载更多指示器
                    if isLoadingMore {
                        ProgressView("加载中...")
                            .padding(.vertical, 20)
                    }
                    
                    // 没有更多数据提示
                    if !hasMoreData && !notifications.isEmpty {
                        Text("没有更多数据了")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                    }
                    
                    // 触发加载更多的占位视图
                    if hasMoreData && !notifications.isEmpty {
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                loadMoreIfNeeded()
                            }
                    }
                }
                
            }
            
            }
            Spacer()
         }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

     // MARK: - 自定义导航栏
    @ViewBuilder
    private func customNavigationBar() -> some View {
            ZStack {
                // 绝对居中的标题
                Text("消息通知")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // 左侧返回按钮覆盖在上层，不影响居中标题
                HStack {
                    Button(action: {
                        // 优先尝试 SwiftUI 的 dismiss
                        dismiss()
                        // 兜底：使用 UIKit 关闭当前视图（适用于 AI 页面等没有 NavigationController 的情况）
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                               var top = window.rootViewController {
                                while let presented = top.presentedViewController {
                                    top = presented
                                }
                                // 如果是 NavigationController，尝试 pop
                                if let navController = top as? UINavigationController {
                                    if navController.viewControllers.count > 1 {
                                        navController.popViewController(animated: true)
                                    } else {
                                        navController.dismiss(animated: true)
                                    }
                                } else if let navController = top.navigationController {
                                    if navController.viewControllers.count > 1 {
                                        navController.popViewController(animated: true)
                                    } else {
                                        navController.dismiss(animated: true)
                                    }
                                } else if top.presentingViewController != nil {
                                    top.dismiss(animated: true)
                                }
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex:"#F7F8FA"))
            .frame(maxWidth: .infinity)
        
       
    }
    
    // MARK: - 加载更多判断
    private func loadMoreIfNeeded() {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        print("📩 触发下一页加载")
        getNotification(isRefresh: false)
    }
    
    // MARK: - 请求逻辑
    private func getNotification(isRefresh: Bool = true) {
        if isRefresh {
            isLoading = true
            currentPage = 1
            hasMoreData = true
        } else {
            isLoadingMore = true
        }

        let pageToRequest = isRefresh ? 1 : currentPage
        let requestBody: [String: Any] = ["page": pageToRequest, "limit": limit]
        print("请求第 \(pageToRequest) 页数据")

        NetworkManager.shared.post(APIConstants.Profile.getNotification,
                                   businessParameters: requestBody) { (result: Result<MessageListResponse, APIError>) in
            DispatchQueue.main.async {
                if isRefresh { isLoading = false } else { isLoadingMore = false }
                
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        let newMessages = response.data?.list ?? []
                        
                        if isRefresh {
                            notifications = newMessages
                        } else {
                            // 去重后追加
                            let existingIDs = Set(notifications.map { $0.id })
                            notifications.append(contentsOf: newMessages.filter { !existingIDs.contains($0.id) })
                        }
                        
                        total = response.data?.total ?? 0
                        
                        // 判断是否还有更多页
                        if newMessages.count < limit {
                            hasMoreData = false
                            print("✅ 没有更多数据")
                        } else {
                            currentPage += 1
                            print("➡️ 准备加载第 \(currentPage) 页")
                        }
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - TabBar 控制方法
    private func hideTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = findTabBarController(in: window.rootViewController) {
                tabBarController.tabBar.isHidden = true
            }
        }
    }
    
    private func showTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = findTabBarController(in: window.rootViewController) {
                tabBarController.tabBar.isHidden = false
            }
        }
    }
    
    private func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        if let navController = viewController as? UINavigationController {
            return findTabBarController(in: navController.viewControllers.last)
        }
        
        if let presentedVC = viewController.presentedViewController {
            return findTabBarController(in: presentedVC)
        }
        
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        
        return nil
    }
}
