//
//  SceneTabContentViews.swift
//  Mobiwusi
//
//  Created by Assistant on 2024/01/16.
//

import SwiftUI
import Foundation
import UIKit
import SafariServices
import WebKit



// MARK: - 场景选项卡内容视图
struct SceneTabContentViews {
  
    
    // MARK: - 热门场景内容
    @MainActor
    static func hotScenesContent(
        taskList: [TaskItem],
        isLoadingMore: Bool = false,
        hasMoreData: Bool = true,
        showLoadingComplete: Bool = false,
        onLoadMore: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil,
        task_count: Int = 0,
        yesterday_count: Int = 0,
        navigationToInviteFriends: Binding<Bool> = .constant(false)
       
    ) -> some View {
        VStack(spacing: 10) {
         ScrollView(showsIndicators:false){
            // 模块区域
            HStack(alignment:.center, spacing: 10){
                VStack{
                    ZStack(alignment: .topLeading){
                         Image("bg_scene_mission_center")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                          Image("icon_mission_center")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .padding(.top,20)
                            .padding(.leading,10)
                        
                        VStack(spacing:5){
                            HStack{
                                VStack(spacing:4){
                                        Text("项目 总量")
                                        .lineLimit(1)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white).opacity(0.58)
                                        Text("\(task_count)")
                                        .lineLimit(1)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            VStack(spacing:4){
                                Text("昨日新增")
                                 .lineLimit(1)
                                .font(.system(size: 12))
                                .foregroundColor(.white).opacity(0.58)
                                Text("+\(yesterday_count)")
                                 .lineLimit(1)
                                .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.vertical,8)
                                .padding(.horizontal,8)
                                .frame(maxWidth:.infinity)
                                .background(Color.white.opacity(0.18))
                                .cornerRadius(5)
                                .padding(.horizontal,10)
                                .padding(.top,50)

                                  NavigationLink(destination: ProjectCenterViewController(
                                      task_count: task_count,
                                      yesterday_count: yesterday_count
                                     
                                  )) {
                                      HStack{
                                          Text("去看看")
                                          .font(.system(size: 12))
                                          .foregroundColor(Color(hex:"#9A1E2E"))
                                          Image("fi_arrow-right")
                                              .resizable()
                                              .frame(width: 10, height: 10)
                                      }
                                      .padding(.horizontal,8)
                                      .padding(.vertical,3)
                                      .background(Color.white)
                                      .cornerRadius(5)
                                      .frame(maxWidth: .infinity, alignment: .leading)
                                      .padding(.leading,10)
                                      .padding(.top,10)
                                  }
                                
                            }
                    }
                    
                  
                }
                .frame(maxWidth:.infinity)
              
               VStack{
                   
                        Button(action:{
                             navigationToInviteFriends.wrappedValue = true
                        }){
                             ZStack{
                         Image("bg_scene_invite_friends")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                        VStack(alignment:.leading ,spacing:5){
                            Text("邀请好友")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#476BEE"))
                            Text("这里摇人")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex:"#476BEE"))

                        }
                        .padding(.leading,10)
                        .frame(maxWidth:.infinity, alignment: .leading)
                         }
                    }
                        
                        
                          
                   
                    NavigationLink {
                        TutorialWebViewPage(urlString: "https://mobiwusi.com/tutorial",title: "新手教程")
                          
                          
                    } label: {
                      ZStack{
                         Image("bg_scene_new_tutorial")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                         VStack(alignment:.leading ,spacing:5){
                            Text("轻松开局")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#E35F94"))
                            Text("新手教程")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex:"#E35F94"))

                        }
                        .padding(.leading,10)
                        .frame(maxWidth:.infinity, alignment: .leading)
                           
                    }
                    }

                }
                 .frame(maxWidth:.infinity,maxHeight: .infinity)
            }
           .frame(height: 150)
           
           // 任务列表
           LazyVStack(spacing: 15) {
               ForEach(taskList) { taskItem in
                    TaskItemRow(taskItem: taskItem)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .id(taskItem.id)
                        .onTapGesture {
                            if taskItem.user_task_id == nil {
                                SceneTabContentViews.receiveTask(taskId: taskItem.id) { success, newUserTaskId in
                                    guard success, let userTaskId = newUserTaskId else {
                                        return
                                    }
                                    Task { @MainActor in
                                        let vc = UIHostingController(
                                            rootView: TaskDetailController(taskId: taskItem.id, userTaskId: userTaskId)
                                                .toolbar(.hidden, for: .navigationBar)
                                                
                                        )
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                }
                            } else if let existingUserTaskId = taskItem.user_task_id {
                                Task { @MainActor in
                                    let vc = UIHostingController(
                                        rootView: TaskDetailController(taskId: taskItem.id, userTaskId: existingUserTaskId)
                                            .toolbar(.hidden, for: .navigationBar)
                                    )
                                    vc.hidesBottomBarWhenPushed = true
                                    MOAppDelegate().transition.push(vc, animated: true)
                                }
                            }
                        }
               }
               
               // 底部加载状态
                if isLoadingMore {
                    loadingView()
                        .onAppear {
                            // 当loading视图出现时不触发加载，避免重复
                        }
                } else if showLoadingComplete {
                    loadingCompleteView()
                } else if !hasMoreData && !taskList.isEmpty {
                    noMoreDataView()
                } else if hasMoreData && !taskList.isEmpty {
                    // 添加一个透明的触发器视图
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            onLoadMore?()
                        }
                }
           }
           .onAppear {
               // 当列表出现时，如果数据为空且有更多数据，触发加载
               if taskList.isEmpty && hasMoreData {
                   onLoadMore?()
               }
           }
           }
           .refreshable {
               // 下拉刷新
               if let refresh = onRefresh {
                   await Task { @MainActor in
                       refresh()
                   }.value
               }
           }
           .padding(.horizontal, 10)
        }
    }
    
    // MARK: - 通用内容
    @MainActor
    static func commonContent(
        sceneType: SceneTypeItem,
        taskList: [TaskItem],
        isLoadingMore: Bool = false,
        hasMoreData: Bool = true,
        showLoadingComplete: Bool = false,
        onLoadMore: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil,
         navigateToAllIndustry: Binding<Bool> = .constant(false)
    ) -> some View {
        VStack(spacing: 10) {
            ScrollView(showsIndicators: false) {
                // 模块区域
                childrenGridView(children: sceneType.children, navigateToAllIndustry: navigateToAllIndustry)
                
                // 任务列表
                taskListView(
                    taskList: taskList,
                    isLoadingMore: isLoadingMore,
                    hasMoreData: hasMoreData,
                    showLoadingComplete: showLoadingComplete,
                    onLoadMore: onLoadMore
                )
            }
            .refreshable {
                // 下拉刷新
                if let refresh = onRefresh {
                    await Task { @MainActor in
                        refresh()
                    }.value
                }
            }
            .padding(.horizontal, 10)
        }
     }
    
    // MARK: - 子分类网格视图
    @MainActor
    @ViewBuilder
    private static func childrenGridView(children: [SceneTypeChild]?, navigateToAllIndustry: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 10) {
            if let children = children, !children.isEmpty {
                let totalRows = min(2, (children.count + 4) / 5)
                ForEach(0..<totalRows, id: \.self) { rowIndex in
                    childrenGridRow(
                        rowIndex: rowIndex,
                        children: children,
                        navigateToAllIndustry: navigateToAllIndustry
                    )
                }
            } else {
                emptyChildrenView()
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical,10)
        .background(Color(hex: "#ffffff"))
        .cornerRadius(10)
    }
    
    // MARK: - 子分类网格行
    @MainActor
    @ViewBuilder
    private static func childrenGridRow(rowIndex: Int, children: [SceneTypeChild], navigateToAllIndustry: Binding<Bool>) -> some View {
        HStack {
            ForEach(0..<5, id: \.self) { colIndex in
                let itemIndex = rowIndex * 5 + colIndex
                if children.count > 10 && rowIndex == 1 && colIndex == 4 {
                    allIndustryButton(navigateToAllIndustry: navigateToAllIndustry)
                } else if itemIndex < children.count {
                    let child = children[itemIndex]
                    childItemView(for: child)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - 全部行业按钮
    @MainActor
    @ViewBuilder
    private static func allIndustryButton(navigateToAllIndustry: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image("icon_scene_all")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            Text("全部行业")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#626262"))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture{
            navigateToAllIndustry.wrappedValue = true
        }
    }
    
    // MARK: - 空子分类视图
    @MainActor
    @ViewBuilder
    private static func emptyChildrenView() -> some View {
        VStack(spacing: 20) {
            Image("占位图")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - 任务列表视图
    @MainActor
    @ViewBuilder
    private static func taskListView(
        taskList: [TaskItem],
        isLoadingMore: Bool,
        hasMoreData: Bool,
        showLoadingComplete: Bool,
        onLoadMore: (() -> Void)?
    ) -> some View {
        LazyVStack(spacing: 15) {
            ForEach(taskList) { taskItem in
                taskItemRowView(taskItem: taskItem)
            }
            
            // 底部加载状态
            taskListFooter(
                isLoadingMore: isLoadingMore,
                hasMoreData: hasMoreData,
                showLoadingComplete: showLoadingComplete,
                taskList: taskList,
                onLoadMore: onLoadMore
            )
        }
        .onAppear {
            if taskList.isEmpty && hasMoreData {
                onLoadMore?()
            }
        }
    }
    
    // MARK: - 任务项行视图
    @MainActor
    @ViewBuilder
    private static func taskItemRowView(taskItem: TaskItem) -> some View {
        TaskItemRow(taskItem: taskItem)
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .id("\(taskItem.id)")
            .onTapGesture {
                handleTaskItemTap(taskItem: taskItem)
            }
    }
    
    // MARK: - 处理任务项点击
    @MainActor
    private static func handleTaskItemTap(taskItem: TaskItem) {
        if taskItem.user_task_id == nil {
            SceneTabContentViews.receiveTask(taskId: taskItem.id) { success, newUserTaskId in
                guard success, let userTaskId = newUserTaskId else {
                    return
                }
                Task { @MainActor in
                    navigateToTaskDetail(taskId: taskItem.id, userTaskId: userTaskId)
                }
            }
        } else if let existingUserTaskId = taskItem.user_task_id {
            Task { @MainActor in
                navigateToTaskDetail(taskId: taskItem.id, userTaskId: existingUserTaskId)
            }
        }
    }
    
    // MARK: - 导航到任务详情
    @MainActor
    private static func navigateToTaskDetail(taskId: Int, userTaskId: Int) {
        let vc = UIHostingController(
            rootView: TaskDetailController(taskId: taskId, userTaskId: userTaskId)
                .toolbar(.hidden, for: .navigationBar)
        )
        vc.hidesBottomBarWhenPushed = true
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    // MARK: - 任务列表底部视图
    @MainActor
    @ViewBuilder
    private static func taskListFooter(
        isLoadingMore: Bool,
        hasMoreData: Bool,
        showLoadingComplete: Bool,
        taskList: [TaskItem],
        onLoadMore: (() -> Void)?
    ) -> some View {
        if isLoadingMore {
            loadingView()
        } else if showLoadingComplete {
            loadingCompleteView()
        } else if !hasMoreData && !taskList.isEmpty {
            noMoreDataView()
        } else if hasMoreData && !taskList.isEmpty {
            Color.clear
                .frame(height: 1)
                .onAppear {
                    onLoadMore?()
                }
        }
    }


     //MARK：- 领取任务
     static func receiveTask(taskId: Int, completion: @escaping @Sendable (Bool, Int?) -> Void) {
        let requestBody: [String: Any] = [
            "task_id": taskId,
        ]
        NetworkManager.shared.post(APIConstants.Scene.receiveTask,
                                   businessParameters: requestBody) { (result: Result<ReceiveTaskResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("领取任务成功")
                        completion(true, response.data.intValue)
                    } else {
                        print("领取任务失败: \(response.msg)")
                        // 显示消息并自定义停留时间（比如3秒）
                        MBProgressHUD.showMessag("\(response.msg)", to: nil, afterDelay: 3.0)
                        completion(false, nil)
                    }
                case .failure:
                    print("领取任务失败2")
                    completion(false, nil)
                }
            }
        }
    }
    
    // MARK: - Loading组件
    @ViewBuilder
     static func loadingView() -> some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#9A1E2E")))
            
            Text("正在加载")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // 加载完成提示组件
    @ViewBuilder
     static func loadingCompleteView() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#9A1E2E"))
                .font(.system(size: 16))
            
            Text("加载完成")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .transition(.opacity)
    }
    
    // 没有更多数据提示组件
    @ViewBuilder
     static func noMoreDataView() -> some View {
        Text("没有更多数据了")
            .font(.system(size: 14))
            .foregroundColor(Color(hex: "#999999"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }
    
    // MARK: - 图标显示辅助函数
    @MainActor
    @ViewBuilder
    private static func iconView(for child: SceneTypeChild) -> some View {
        if let iconUrl = child.icon_url, !iconUrl.isEmpty {
            if let url = URL(string: iconUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                } placeholder: {
                    Image("占位图")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                         .frame(width: 50, height: 50)
                }
            } else {
                Image("占位图")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
        } else {
            Image("占位图")
                .resizable()
                .aspectRatio(contentMode: .fit)
                 .frame(width: 50, height: 50)
        }
    }
    
    // MARK: - 子分类项目视图辅助函数
    @MainActor
    @ViewBuilder
    private static func childItemView(for child: SceneTypeChild) -> some View {
        VStack(alignment: .center, spacing: 5) {
            // 显示图标
            iconView(for: child)
            
            // 显示名称
            Text(child.name)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#626262"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .id("\(child.id)-\(child.icon_url ?? "")")
        .onTapGesture {
            handleChildItemTap(child: child)
        }
    }
    
    // MARK: - 处理子分类点击事件
    private static func handleChildItemTap(child: SceneTypeChild) {
        // 处理点击事件，例如导航到子分类详情页
        print("点击了子分类：\(child.name)")
        Task { @MainActor in
            let vc = UIHostingController(
                rootView: subcategoryTaskList(sceneId: child.id,title:child.name)
                    .toolbar(.hidden, for: .navigationBar)
            )
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.title = child.name
            // 完全隐藏导航栏，避免返回按钮闪现
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            MOAppDelegate().transition.push(vc, animated: true)
        }
    }
}

// MARK: - 全屏 SwiftUI 网页页面（WKWebView 包装）
struct TutorialWebViewPage: View {
    let urlString: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        WebView(url: URL(string: urlString)!)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#000000"))
                    }
                }
            }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}
