//
//  ProjectCenterViewController.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/8/26.
//

import SwiftUI
import Foundation




struct ProjectCenterViewController: View {
    let task_count: Int
    let yesterday_count: Int
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var currentPage: Int = 1
    @State private var pageSize: Int = 10
    
 
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var showLoadingComplete: Bool = false
    
    @Environment(\.dismiss) var dismiss   // 获取返回方法
    @State private var taskList: [TaskItem] = []
    
    var body: some View {
         return    GeometryReader { geometry in
                ZStack{
                    // 全屏背景色
                    Color(hex: "#f7f8fa")
                        .ignoresSafeArea()
                    // 顶部背景图片
                    VStack {
                        Image("bg_mission_center")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                      .ignoresSafeArea()
                    // 顶部图标
                    VStack {
                        HStack(alignment:.center){
                            Button(action: {
                                // 返回上一页
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .padding(.leading,20)
                                    .padding(.trailing,6)
                                    .frame(width:20,height:20)
                            }
                            Image("icon_mission_center")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:120)
                            
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    HStack(alignment:.center,spacing:50){
                        VStack(alignment:.center,spacing:10){
                            Text("任务总量")
                                .font(.system(size: 12))
                                .foregroundColor(.white).opacity(0.58)
                            Text("\(task_count)")
                                .font(.system(size: 20,weight:.semibold))
                                .foregroundColor(.white)
                            
                        }
                        VStack(alignment:.center,spacing:10){
                            Text("昨日新增")
                                .font(.system(size: 12))
                                .foregroundColor(.white).opacity(0.58)
                            Text("+\(yesterday_count)")
                                .font(.system(size: 20,weight:.semibold))
                                .foregroundColor(.white)
                            
                        }
                        
                    }
                    .padding(.top, 40) // 距离顶部安全区域的距离
                    .padding(.leading,30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    // 白色卡片区域
                    VStack{
                        // 任务列表
                        ScrollView(showsIndicators:false){                     
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
                                    SceneTabContentViews.loadingView()
                                        .onAppear {
                                            // 当loading视图出现时不触发加载，避免重复
                                        }
                                } else if showLoadingComplete {
                                    SceneTabContentViews.loadingCompleteView()
                                } else if !hasMoreData && !taskList.isEmpty {
                                    SceneTabContentViews.noMoreDataView()
                                } else if hasMoreData && !taskList.isEmpty {
                                    // 添加一个透明的触发器视图
                                    Color.clear
                                        .frame(height: 1)
                                        .onAppear {
                                            loadMoreTasksIfNeeded()
                                        }
                                }
                            }
                             .onAppear {
                            // 当列表出现时，如果数据为空且有更多数据，触发加载
                            if taskList.isEmpty && hasMoreData {
                                loadMoreTasksIfNeeded()
                            }
                        }
                        }
                       
                        
                        
                        
                    }
                        .padding(.vertical,5)
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height - 136)  //全屏高度
                        .background(Color(hex:"#F3F4F6"))
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                        .offset(y: 40)

                    
                    
                    
                }
                 .ignoresSafeArea(edges:.bottom)
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)   // 隐藏系统默认返回按钮
                .onAppear {
                    fetchTaskList()
                }
         }
            
           
            
        
        
      
        
    }

      func loadMoreTasksIfNeeded() {
        if hasMoreData && !isLoadingMore && !isLoading {
            fetchTaskList(isRefresh: false)
        }
    }
      func fetchTaskList(isRefresh: Bool = true) {
            // 防止重复请求
            if isRefresh && isLoading {
                return
            }
            if !isRefresh && (isLoadingMore || !hasMoreData) {
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
                "cate": 0 // cate始终为0
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
                            } else {
                                self.currentPage += 1
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
       
    

    
    





