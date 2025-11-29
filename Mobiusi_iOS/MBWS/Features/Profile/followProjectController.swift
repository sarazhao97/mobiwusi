//
//  followProjectController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/23.
//

//
//  followProjectController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/23.
//


import SwiftUI
import Foundation
import UIKit

struct FollowProjectTaskNavigationData: Hashable {
    let taskId: Int
    let userTaskId: Int
}


struct followProjectController: View {
  
    @Environment(\.dismiss) var dismiss
    @State private var navigationPath = NavigationPath()
    @State private var taskList: [TaskItem] = []
    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1
    @State private var pageSize: Int = 20
    @State private var errorMessage: String?
    @State private var showLoadingComplete: Bool = false
    @State private var navigateToDetail: Bool = false
    @State private var selectedFollowProjectTaskItem: FollowProjectTaskNavigationData?
    
    // MARK: - 计算属性
    private var taskListView: some View {
        VStack {

            if taskList.isEmpty {
                HStack{
                    Spacer()
                    VStack(spacing:10){
                        Image("icon_data_empty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        Text("暂时没有项目")
                            .font(.system(size: 18,weight:.bold))
                            .foregroundColor(Color(hex: "#000000"))
                    }
                    Spacer()
                }
            } else {
            // 任务列表
            ScrollView{    
            LazyVStack(spacing: 15) {
                ForEach(taskList) { taskItem in
                   Button(action:{
                        // selectedTaskItem = taskItem
                        // navigateToDetail = true
                        handleProjectItemTap(item: taskItem)
                   }){
                      taskItemRow(taskItem: taskItem)
                   }
                     .buttonStyle(PlainButtonStyle())
                 
                  
                }
                
                // 底部加载状态
                bottomLoadingView
            }
           
            Spacer()
            }
            .refreshable {
                fetchTaskList()
            }
             .onAppear {
                // 当列表出现时，如果数据为空且有更多数据，触发加载
                if taskList.isEmpty && hasMoreData {
                    fetchTaskList()
                }
            }
        }
        }
        .padding(.horizontal, 10)
    }

      private func handleProjectItemTap(item: TaskItem) {
       
         navigateToDetail = true
         // 使用 SwiftUI 导航，传递 taskId 和 userTaskId
        let navigationData = FollowProjectTaskNavigationData(
            taskId: item.id,
            userTaskId: item.user_task_id ?? 0
        )
        selectedFollowProjectTaskItem = navigationData
        // navigationPath.append(navigationData)
        
        
    }
    
    private var bottomLoadingView: some View {
        Group {
            if isLoadingMore {
                SceneTabContentViews.loadingView()
                    .padding(.vertical, 20)
            } else if showLoadingComplete {
                SceneTabContentViews.loadingCompleteView()
                    .padding(.vertical, 20)
            } else if !hasMoreData && !taskList.isEmpty {
                SceneTabContentViews.noMoreDataView()
                    .padding(.vertical, 20)
            } else if hasMoreData && !taskList.isEmpty {
                // 添加一个透明的触发器视图，用于检测滚动到底部
                Color.clear
                    .frame(height: 50)
                    .onAppear {
                        loadMoreTasks()
                    }
            }
        }
    }

   
    
    var body: some View {
        ZStack {
            // 全屏背景色
            Color(hex: "#f7f8fa")
                .ignoresSafeArea()
            
            // 主要内容
            taskListView

             NavigationLink(
                     destination: TaskDetailController(
                         taskId: selectedFollowProjectTaskItem?.taskId ?? 0,
                         userTaskId: selectedFollowProjectTaskItem?.userTaskId ?? 0
                     ),
                     isActive: $navigateToDetail
                 ) {
                     EmptyView()
                 }
        }
       .navigationBarTitleDisplayMode(.inline)
       .navigationBarBackButtonHidden(true)
       .navigationBarTitle("关注项目")
       
        // .navigationDestination(isPresented: $navigateToDetail) {
        //     if let taskItem = selectedTaskItem {
        //         TaskDetailController(taskId: taskItem.id ?? 0, userTaskId: taskItem.user_task_id)
        //     } else {
        //         EmptyView()
        //     }
        // }
       .onAppear {
           // 确保在视图出现时隐藏返回按钮
           if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController {
               if let navController = rootViewController as? UINavigationController {
                   navController.topViewController?.navigationItem.hidesBackButton = true
               } else if let tabController = rootViewController as? UITabBarController,
                         let navController = tabController.selectedViewController as? UINavigationController {
                   navController.topViewController?.navigationItem.hidesBackButton = true
               }
           }

           fetchTaskList()
       }
       .toolbar{
           ToolbarItem(placement: .navigationBarLeading) {
               Button(action: {
                   dismiss()
               }) {
                   HStack(spacing: 4) {
                       Image(systemName: "chevron.left")
                           .foregroundColor(.black)
                           .font(.system(size: 18, weight: .medium))
                   }
               }
           }
       }  
      
    }
    
    // MARK: - 私有方法
    private func taskItemRow(taskItem: TaskItem) -> some View {
        TaskItemRow(taskItem: taskItem)
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .id("\(taskItem.id)")
    }
    
   
    
    private func navigateToTaskDetail(taskId: Int, userTaskId: Int) {
        let vc = UIHostingController(
            rootView: TaskDetailController(taskId: taskId, userTaskId: userTaskId)
                .toolbar(.hidden, for: .navigationBar)
        )
        vc.hidesBottomBarWhenPushed = true
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    private func loadMoreTasks() {
        // 防止重复加载
        guard !isLoadingMore && hasMoreData else { 
            print("🚫 跳过加载更多: isLoadingMore=\(isLoadingMore), hasMoreData=\(hasMoreData)")
            return 
        }
        print("📱 开始加载更多数据，当前页: \(currentPage)")
        fetchTaskList(isRefresh: false)
    }
    
    private func fetchTaskList(isRefresh: Bool = true) {
        print("🔄 fetchTaskList called: isRefresh=\(isRefresh), currentPage=\(currentPage), hasMoreData=\(hasMoreData)")
        
        // 防止重复请求
        if isRefresh && isLoading {
            print("🚫 跳过刷新请求: 正在加载中")
            return
        }
        if !isRefresh && (isLoadingMore || !hasMoreData) {
            print("🚫 跳过加载更多请求: isLoadingMore=\(isLoadingMore), hasMoreData=\(hasMoreData)")
            return
        }
        
        if isRefresh {
            isLoading = true
            currentPage = 1
            hasMoreData = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil
      
        
        var parameters: [String: Any] = [
            "page": isRefresh ? 1 : currentPage,
            "limit": pageSize,
            "cate": 0, // cate始终为0
            "follow":1
        ]
        
        NetworkManager.shared.post(APIConstants.Scene.getTaskList, 
                                   businessParameters: parameters) { (result: Result<TaskListResponse, APIError>) in
            DispatchQueue.main.async {
                if isRefresh {
                    self.isLoading = false
                } else {
                    self.isLoadingMore = false
                }
                
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        let newTasks = response.data ?? []
                        
                        if isRefresh {
                            // 刷新时替换所有数据
                            self.taskList = newTasks
                        } else {
                            // 分页加载时，只添加新数据，避免影响已有数据
                            let existingIds = Set(self.taskList.map { $0.id })
                            let uniqueNewTasks = newTasks.filter { !existingIds.contains($0.id) }
                            self.taskList.append(contentsOf: uniqueNewTasks)
                            
                            // 非刷新操作时显示加载完成提示
                            if !uniqueNewTasks.isEmpty {
                                self.showLoadingComplete = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.showLoadingComplete = false
                                }
                            }
                        }
                        
                        // 检查是否还有更多数据
                        if newTasks.count < self.pageSize {
                            self.hasMoreData = false
                            print("📄 没有更多数据了，总共加载了 \(self.taskList.count) 条数据")
                        } else {
                            self.currentPage += 1
                            print("📄 加载了 \(newTasks.count) 条数据，下一页: \(self.currentPage)")
                        }
                        
                    } else {
                        self.errorMessage = response.msg 
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
