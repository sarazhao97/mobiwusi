//
//  SceneView.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/8/26.
//
import SwiftUI
import Foundation



struct TabItem {
    let id: Int
    let title: String
    let icon: String?
    let xOffset: CGFloat
}

struct SceneTypeItem: Decodable {
    let id: Int
    let name: String
    let parent_id: Int
    let icon: String?
    let isParent: Bool
    let children: [SceneTypeChild]?
    let state: String
    let open: Bool
}

struct SceneTypeChild: Decodable {
    let id: Int
    let name: String
    let parent_id: Int
    let icon: String?
    let icon_url: String?
}

// 使用 ResponseModels.swift 中已定义的 TaskItem
// 不需要重复定义 Taskset，直接使用 TaskItem

// 显示一个 TaskItem 数据的视图。
@MainActor
struct TaskItemRow: View {
    var taskItem: TaskItem
    var body: some View {
        HStack(alignment:.center){
            // 使用封面图片或默认图标
            if let coverImage = taskItem.cover_image, !coverImage.isEmpty {
                CachedAsyncImage(url: URL(string: coverImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                   Image("占位图")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                }
                .cornerRadius(10)
                .frame(width: 80, height: 80)
            } else {
                Image("占位图")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .frame(width: 80, height: 80)
            }
            VStack(alignment:.leading,spacing:10){
                Text(taskItem.title)
                    .font(.system(size: 16,weight:.semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(taskItem.simple_descri)
                    .font(.system(size: 14))
                    .foregroundColor(.black).opacity(0.58)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack{
                    Text("PoID：\(taskItem.task_no)")
                        .font(.system(size: 14))
                        .foregroundColor(.black).opacity(0.58)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                Text("\(taskItem.currency_unit)\(String(format: "%.2f", taskItem.price))")
                .font(.system(size: 16,weight:.semibold))
                .foregroundColor(Color(hex:"#9A1E2E"))
                .padding(.trailing,-5)
                
                if !taskItem.unit.isEmpty {
                    Text("/\(taskItem.unit)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex:"#9A1E2E"))
                }
            }
            .padding(.top,40)
           
           
        }
       
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
         .background(Color.white)
           .cornerRadius(8)
       
       
    }
}

struct SceneView: View {
    @State private var keyword = "" //关键词
    @State private var selectedTab: Int = 0
    @State private var moduleHeight: CGFloat = 120
    @State private var showPanel: Bool = false // 控制面板显示状态
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var sceneTypes: [SceneTypeItem] = []
    @State private var task_count: Int = 0
    @State private var yesterday_count: Int = 0
    @State private var taskList: [TaskItem] = []
    @State private var hasLoadedData: Bool = false // 标记数据是否已加载
    @State private var showNotification = false
    
    // 分页相关状态
    @State private var currentPage: Int = 1
    @State private var pageSize: Int = 10
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var showLoadingComplete: Bool = false
    @State private var navigationToInviteFriends: Bool = false
    @State private var navigateToAllIndustry: Bool = false

    @State private var navigateToNotification: Bool = false

    private var tabItems: [TabItem] {
        var items: [TabItem] = []
        
        // 添加固定的"热门场景"项目
        items.append(TabItem(id: 0, title: "热门场景", icon: "Fire_(火热)", xOffset: -10))
        
        // 添加从 sceneTypes 获取的数据
        for (index, sceneType) in sceneTypes.enumerated() {
            let tabItem = TabItem(
                id: sceneType.id,
                title: sceneType.name,
                icon: sceneType.icon?.isEmpty == false ? sceneType.icon : nil,
                xOffset: -2
            )
            items.append(tabItem)
        }
        
        return items
    }
    
    // 拆分出单独的选项卡视图组件
    @ViewBuilder
    private func tabItemView(_ item: TabItem) -> some View {
        if item.id == 0 {
            firstTabView(item)
        } else {
            regularTabView(item)
        }
    }
    
    // 第一个选项卡视图（包含图标）
    @ViewBuilder
    private func firstTabView(_ item: TabItem) -> some View {
        HStack(alignment: .center,spacing: 4) {
            if let iconName = item.icon {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .padding(.bottom,8)
                    .padding(.leading,5)
            }
            tabButtonWithIndicator(item)
                .padding(.trailing, 5)
        }
    }
    
    // 普通选项卡视图
    @ViewBuilder
    private func regularTabView(_ item: TabItem) -> some View {
        tabButtonWithIndicator(item)
    }
    
    // 选项卡按钮和指示器组合视图
    @ViewBuilder
    private func tabButtonWithIndicator(_ item: TabItem) -> some View {
        VStack(spacing: 0) {
            tabButton(item)
            tabIndicator(item)
        }
    }
    
    // 选项卡按钮
    @ViewBuilder
    private func tabButton(_ item: TabItem) -> some View {
        Button(item.title) {
            selectedTab = item.id
        }
        .font(selectedTab == item.id ? .headline : .subheadline)
        .fontWeight(selectedTab == item.id ? .bold : .regular)
        .foregroundColor(selectedTab == item.id ? .black : .gray)
        .lineLimit(nil)
        .frame(maxWidth: .infinity)
    }
    
    // 选项卡指示器
    @ViewBuilder
    private func tabIndicator(_ item: TabItem) -> some View {
        if selectedTab == item.id {
            Image("Rectangle 149")
                .resizable()
                .scaledToFit()
                .frame(height: 10)
                .offset(y: -5)
                .offset(x: item.xOffset)
        } else {
            Color.clear
                .frame(height: 10)
                .offset(y: -5)
                .offset(x: item.xOffset)
        }
    }
    
    // 根据选中的选项卡显示对应的内容视图
    @ViewBuilder
    private func tabContentView() -> some View {
        if selectedTab == 0 {
            // 第一个标签页：热门场景
            SceneTabContentViews.hotScenesContent(
                taskList: taskList,
                isLoadingMore: isLoadingMore,
                hasMoreData: hasMoreData,
                showLoadingComplete: showLoadingComplete,
                onLoadMore: loadMoreTasksIfNeeded,
                onRefresh: {
                    fetchTaskList()
                },
                task_count: task_count,
                yesterday_count: yesterday_count,
                navigationToInviteFriends: $navigationToInviteFriends
            )
        } else {
            // 其他标签页：根据选中的标签页ID找到对应的SceneTypeItem
            if let selectedSceneType = sceneTypes.first(where: { $0.id == selectedTab }) {
                SceneTabContentViews.commonContent(
                    sceneType: selectedSceneType,
                    taskList: taskList,
                    isLoadingMore: isLoadingMore,
                    hasMoreData: hasMoreData,
                    showLoadingComplete: showLoadingComplete,
                    onLoadMore: loadMoreTasksIfNeeded,
                    onRefresh: {
                        fetchTaskList()
                    },
                    navigateToAllIndustry: $navigateToAllIndustry
                )
            } else {
                // 如果找不到对应的场景类型，显示默认内容
                SceneTabContentViews.hotScenesContent(
                    taskList: taskList,
                    isLoadingMore: isLoadingMore,
                    hasMoreData: hasMoreData,
                    showLoadingComplete: showLoadingComplete,
                    onLoadMore: loadMoreTasksIfNeeded,
                    onRefresh: {
                        fetchTaskList()
                    },
                    task_count: task_count,
                    yesterday_count: yesterday_count,
                    navigationToInviteFriends: $navigationToInviteFriends
                )
            }
        }
    }
    
    // Loading动画组件
    @ViewBuilder
    private func loadingView() -> some View {
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
    private func loadingCompleteView() -> some View {
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
    private func noMoreDataView() -> some View {
        Text("没有更多数据了")
            .font(.system(size: 14))
            .foregroundColor(Color(hex: "#999999"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }


    private func fetchSceneTypes() {
       isLoading = true
        errorMessage = nil
        
         NetworkManager.shared.post(APIConstants.Scene.getSceneTypes, 
                                   businessParameters: [:]) { (result: Result<SceneTypesResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false         
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        sceneTypes = response.data?.scene_data ?? []
                        task_count = response.data?.task_count ?? 0
                        yesterday_count = response.data?.yesterday_count ?? 0
                        
                        // 场景类型加载完成后，立即获取任务列表
                        fetchTaskList()
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchTaskList(isRefresh: Bool = true) {
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
        
        // 根据选中的tab设置scene_id参数
        let sceneIdValue: Int?
        if selectedTab == 0 {
            // 热门场景，不传scene_id参数（获取全部）
            sceneIdValue = nil
        } else {
            // 其他场景，使用对应的场景ID
            sceneIdValue = selectedTab
        }
        
        var parameters: [String: Any] = [
            "page": isRefresh ? 1 : currentPage,
            "limit": pageSize,
            "cate": 0 // cate始终为0
        ]
        
        // 如果有场景ID，添加到参数中
        if let sceneId = sceneIdValue {
            parameters["scene_id"] = sceneId
        }
        // 如果已成功获取位置信息，追加经纬度参数
        let lat = MOLocationManager.shared.latitude
        let lng = MOLocationManager.shared.longitude
        if lat != 0 && lng != 0 {
            parameters["lat"] = lat
            parameters["lng"] = lng
        }
        
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
    
    private func loadMoreTasksIfNeeded() {
        if hasMoreData && !isLoadingMore && !isLoading {
            fetchTaskList(isRefresh: false)
        }
    }
    


    var body: some View {
        // NavigationView {
            ZStack{
             // 全屏背景色
                Color(hex: "#f7f8fa")
                    .ignoresSafeArea()
            VStack{
                HStack(alignment:.center){
                 Button(action:{
                    Task { @MainActor in
                            let vc = UIHostingController(
                                rootView: SearchViewController()
                                    .toolbar(.hidden, for: .navigationBar)
                                    
                            )
                            vc.hidesBottomBarWhenPushed = true
                            MOAppDelegate().transition.push(vc, animated: true)
                        }
                 }){
                     HStack{
                    Image(systemName: "magnifyingglass")
                      .foregroundColor(.black)
                      Spacer()
                    Text("输入关键字/项目ID搜索")
                     .font(.system(size: 14))
                     .foregroundColor(Color(hex:"#9B9B9B"))
                      Spacer()
                }    
                    .padding(.vertical,10)
                    .padding(.horizontal,10)
                    .frame(maxWidth:.infinity, maxHeight: 40)
                    .background(Color.white)
                     .cornerRadius(30)
                    
                 }
                  .contentShape(Rectangle())  
                
             Button(action: {
                        navigateToNotification = true
                    }) {
                        Image("icon_notification")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 0) // 移除顶部间距，让铃铛图标贴近顶部
                  
                   
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal,10)
              
               
               GeometryReader { geometry in 
                   ZStack(alignment: .trailing) {
                       // 选项卡可以滚动显示
                       if showPanel {
                           // 当面板展开时显示文本
                           HStack(alignment:.center) {
                               Text("场景选择")
                                   .font(.system(size: 16, weight: .medium))
                                   .foregroundColor(.black)
                               Spacer()
                           }
                           .padding(.horizontal, 10)
                           .frame(height: 40)
                           .zIndex(1000.5)
                       } else {
                           // 当面板收起时显示选项卡
                           ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(tabItems, id: \.id) { item in
                                            tabItemView(item)
                                                .frame(width: item.id == 0 ? geometry.size.width * 0.28 : geometry.size.width * 0.15)
                                                .id(item.id) // 为每个选项添加ID用于滚动定位
                                        }
                                    }
                                    .padding(.leading, 5)
                                    .padding(.trailing, geometry.size.width * 0.1)
                                }
                                .onAppear {
                                    // 初始滚动到选中的选项
                                    proxy.scrollTo(selectedTab, anchor: .center)
                                }
                                .onChange(of: selectedTab) { newValue in
                                    // 当选项改变时自动滚动到新选项
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(newValue, anchor: .center)
                                    }
                                }
                            }
                       }                      
                       // 半透明箭头组件，覆盖在最右侧选项卡上
                       HStack{
                            Spacer()
                            Button{
                                 showPanel.toggle()
                            } label: {
                                Image((!showPanel ? "Arrow___Caret_Down_MD" : "Arrow___Caret_UP_MD"))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                 .padding(.top,-10)
                                 .padding(.trailing,10)
                            }                        
                       }
                       .frame(width: geometry.size.width * 0.16, height: 40)
                       .background(
                           LinearGradient(
                               gradient: Gradient(colors: [Color(hex:"#F7F8FA").opacity(1), Color(hex:"#F7F8FA").opacity(0)]),
                               startPoint: .trailing,
                               endPoint: .leading
                           )
                       )
                       .zIndex(1001) // 确保箭头显示在面板上方
                   }
               }
               .frame(height: 40)
        


               
               // 显示对应选项卡的内容
               tabContentView()
               
                // Spacer()
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .padding(.horizontal,5)
            // .padding(.top,40)
            .onAppear{
                if !hasLoadedData {
                    fetchSceneTypes()
                    hasLoadedData = true
                }
                // 首次进入或坐标尚未获取时，启动定位更新以拿到经纬度
                if MOLocationManager.shared.latitude == 0 || MOLocationManager.shared.longitude == 0 {
                    MOLocationManager.shared.startUpdatingLocation()
                }
            }
            .onChange(of: selectedTab) { newValue in
                // 当tab切换时，重新获取对应场景的任务列表
                fetchTaskList()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TaskAbandonedSuccess"))) { _ in
                // 收到放弃任务成功的通知，刷新任务列表
                fetchTaskList()
            }

            NavigationLink(destination: InviteController(), isActive: $navigationToInviteFriends) {
                EmptyView()
            }
             if let selectedSceneType = sceneTypes.first(where: { $0.id == selectedTab }){
                NavigationLink(destination: AllIndustries(children: selectedSceneType.children ?? []), isActive: $navigateToAllIndustry) {
                EmptyView()
            }
             }

             NavigationLink(destination:NotificationController(), isActive: $navigateToNotification) {
                    EmptyView()
                }
            
            
        }
        .navigationBarHidden(true)
        .toolbar(.hidden)
        .overlay(
            // 滑出面板 - 使用overlay确保不影响其他元素布局
            VStack {
                if showPanel {
                    ZStack(alignment: .top) {
                        // 遮罩层
                        Color.black.opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 150) // 从选项卡下方开始，避免覆盖箭头
                            .edgesIgnoringSafeArea(.bottom)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showPanel.toggle()
                                }
                            }
                        
                        // 面板内容 - 放在遮罩层之后确保正确层级
                        VStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5),
                                        spacing: 10
                                    ) {
                                        ForEach(tabItems, id: \.id) { item in
                                            Button(action: {
                                                selectedTab = item.id
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showPanel = false
                                                }
                                                // 自动滚动到选中的选项
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        proxy.scrollTo(item.id, anchor: .center)
                                                    }
                                                }
                                            }) {
                                                Text(item.title)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(selectedTab == item.id ? Color.white : Color(hex:"#626262"))
                                                    .frame(minWidth: 60, maxWidth: .infinity, minHeight: 30, maxHeight: 30)
                                                    .background(selectedTab == item.id ? Color(hex:"#9A1E2E") : Color.white)
                                                    .cornerRadius(5)
                                            }
                                            .id(item.id) // 为每个选项添加ID用于滚动定位
                                        }
                                    }
                                    .padding(.vertical,20)
                                }
                                .frame(maxHeight: 100) // 限制ScrollView高度
                            }
                              
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .background(Color(hex: "#f7f8fa"))
                         .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 0))
                        .padding(.top, 88) // 确保面板从选项卡下方开始，与遮罩层对齐
                        .zIndex(1000) // 确保面板在最高层级
               


              
                }
                }
               
            }
            .padding(.top, 0), // 调整面板位置，使其出现在搜索栏和选项卡下方
            alignment: .top
        )
}
}


#Preview {
    SceneView()
}
