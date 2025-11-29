import SwiftUI
import Foundation



// 请确保你的 MyProjectItem 至少有 `id: Int`、`name: String`、`statusText: String` 等字段
// struct MyProjectItem { let id: Int; let name: String; let statusText: String }

struct ProjectTabItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let xOffset: CGFloat
}

struct TaskNavigationData: Hashable {
    let taskId: Int
    let userTaskId: Int
}

struct FollowProjectNavigationData: Hashable {
    let showFollowProject: Bool = true
}

struct MyProjectController: View {
    let initialSelectedTab: Int
      @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: Int
    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var errorMessage: String?
    @State private var myProjectList: [MyProjectItem] = []
    @State private var currentPage: Int = 1
    @State private var limit: Int = 20
    @State private var hasMoreData: Bool = true
    @State private var navigationPath = NavigationPath()
    @State private var navigationToTaskDetail = false
    @State private var selectedTaskNavigationData: TaskNavigationData? = nil
    
    // 数据缓存：每个 tab 的数据、加载状态、页码等
    @State private var cachedData: [Int: [MyProjectItem]] = [:]  // 每个 tab 的数据缓存
    @State private var categoryPages: [Int: Int] = [:]  // 每个 tab 的当前页码
    @State private var categoryHasMoreData: [Int: Bool] = [:]  // 每个 tab 是否还有更多数据
    @State private var categoryIsLoadingMore: [Int: Bool] = [:]  // 每个 tab 是否正在加载更多
    @State private var hasLoadedTab: Set<Int> = []  // 记录哪些 tab 已经加载过数据
    
    // 初始化方法
    init(initialSelectedTab: Int) {
        self.initialSelectedTab = initialSelectedTab
        self._selectedTab = State(initialValue: initialSelectedTab)
        print("MyProjectController 初始化，initialSelectedTab: \(initialSelectedTab)")
    }

    // 把 tabs 做成显式常量，避免每次类型推断开销
    private let tabs: [ProjectTabItem] = [
        ProjectTabItem(id: 0, title: "全部项目", xOffset: 0),
        ProjectTabItem(id: 1, title: "进行中", xOffset: 0),
        ProjectTabItem(id: 2, title: "待审核", xOffset: 0),
        ProjectTabItem(id: 3, title: "待修正", xOffset: 0),
        ProjectTabItem(id: 4, title: "初审通过", xOffset: 0),
        ProjectTabItem(id: 5, title: "已完成", xOffset: 0)
    ]

    var body: some View {
        // NavigationStack(path: $navigationPath) {
            ZStack {
                Color(hex: "#F7F8FA").ignoresSafeArea()

                VStack(spacing: 0) {
                    // 自定义标题栏
                    customNavigationBar()
                    
                    VStack(spacing: 5) {
                        tabBar()         // 把顶部选项卡拆成小函数
                           

                        // 使用视图缓存，所有 tab 的视图同时存在，只切换显示
                        ZStack {
                            ForEach(tabs, id: \.id) { tab in
                                tabContentView(tab.id)
                                    .opacity(selectedTab == tab.id ? 1 : 0)
                                    .disabled(selectedTab != tab.id)
                                    .allowsHitTesting(selectedTab == tab.id)
                            }
                        }
                                    
                    }
                    Spacer()
                }

                 NavigationLink(
                     destination: TaskDetailController(
                         taskId: selectedTaskNavigationData?.taskId ?? 0,
                         userTaskId: selectedTaskNavigationData?.userTaskId ?? 0
                     ),
                     isActive: $navigationToTaskDetail
                 ) {
                     EmptyView()
                 }
            }
           .navigationBarHidden(true)         
            .navigationBarBackButtonHidden(true)       
            // .navigationDestination(for: TaskNavigationData.self) { navigationData in
            //     TaskDetailController(taskId: navigationData.taskId, userTaskId: navigationData.userTaskId)
            // }
            .navigationDestination(for: FollowProjectNavigationData.self) { _ in
                followProjectController()
            }
        // }
        .onAppear {
            print("MyProjectController onAppear，selectedTab: \(selectedTab)")
            selectedTab = initialSelectedTab
            
            // 检查是否有缓存数据
            if let cached = cachedData[initialSelectedTab], !cached.isEmpty {
                // 有缓存，直接显示
                myProjectList = cached
                currentPage = categoryPages[initialSelectedTab] ?? 1
                hasMoreData = categoryHasMoreData[initialSelectedTab] ?? true
            } else {
                // 没有缓存，才请求接口
                fetchMyProject(reset: true)
            }
            
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
        }
    }
    
    // MARK: - 自定义导航栏
    @ViewBuilder
    private func customNavigationBar() -> some View {
        ZStack {
            Text("我的项目")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                
                Spacer()
                
                NavigationLink(destination: followProjectController()) {
                    HStack { 
                        Text("关注项目")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color(hex: "#9A1E2E").opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex:"#F7F8FA"))
    }

    // private func handleFollowProjectTap() {
    //     navigationPath.append(FollowProjectNavigationData())
    // }

    // MARK: - 顶部选项卡（拆分函数，减轻主 body 复杂度）
    @ViewBuilder
    private func tabBar() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.id) { tab in
                    tabItemView(tab)
                }
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder
    private func tabItemView(_ item: ProjectTabItem) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                if selectedTab != item.id {
                    // 立即切换 tab，不等待网络请求
                    selectedTab = item.id
                    
                    // 如果有缓存数据，立即显示
                    if let cached = cachedData[item.id], !cached.isEmpty {
                        myProjectList = cached
                        // 恢复该 tab 的页码和 hasMoreData 状态
                        currentPage = categoryPages[item.id] ?? 1
                        hasMoreData = categoryHasMoreData[item.id] ?? true
                    } else {
                        // 没有缓存数据，显示空数组，等待加载
                        myProjectList = []
                    }
                    
                    // 如果该 tab 从未加载过数据，才请求接口
                    if !hasLoadedTab.contains(item.id) {
                        currentPage = 1
                        categoryPages[item.id] = 1
                        fetchMyProject(reset: true)
                    }
                    // 如果已有缓存数据，不请求接口，直接使用缓存
                }
            }) {
                Text(item.title)
                    .font(selectedTab == item.id ? .headline : .subheadline)
                    .fontWeight(selectedTab == item.id ? .bold : .regular)
                    .foregroundColor(selectedTab == item.id ? .black : .gray)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 12)
                    // .padding(.vertical, 8)
            }

           if selectedTab == item.id {
                Image("Rectangle 149")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)
                    .offset(y: -10)
                    .offset(x: item.xOffset)
            } else {
                Color.clear
                    .frame(height: 10)
                    .offset(y: -10)
                    .offset(x: item.xOffset)
            }
        }
    }

    // MARK: - Tab 内容视图（为每个 tab 创建独立的视图，保持状态）
    @ViewBuilder
    private func tabContentView(_ tabId: Int) -> some View {
        let tabData = getTabData(tabId)
        let tabIsLoading = isLoading && selectedTab == tabId && !hasLoadedTab.contains(tabId)
        let tabHasMore = categoryHasMoreData[tabId] ?? true
        let tabIsLoadingMore = categoryIsLoadingMore[tabId] ?? false
        
        if tabIsLoading {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    ProgressView("加载中...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if tabData.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Image("icon_data_empty")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    Text("暂时没有项目")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#000000"))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id("tab_empty_\(tabId)")
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(tabData, id: \.id) { item in
                        Button(action: {
                            handleProjectItemTap(item: item)
                        }) {
                            projectItemView(myProjectItem: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // 用 id 比较最后一项，避免对整个对象做 ==（可能没有 Equatable）
                            if let lastId = tabData.last?.id, item.id == lastId {
                                loadMoreIfNeeded(for: tabId)
                            }
                        }
                    }

                    // 底部提示（使用 tab 特定的状态）
                    if tabIsLoadingMore {
                        ProgressView("加载中...")
                            .padding()
                    } else if !tabHasMore {
                        Text("没有更多数据了")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal)
            }
            .refreshable {
                await refreshTabData(tabId: tabId)
            }
            .id("tab_content_\(tabId)") // 使用 id 保持视图状态
        }
    }
    
    // MARK: - 获取指定 tab 的数据（从缓存中获取）
    private func getTabData(_ tabId: Int) -> [MyProjectItem] {
        return cachedData[tabId] ?? []
    }

   

    // 显示一个 projectItemView 数据的视图。
    @MainActor
    @ViewBuilder
    private func projectItemView(myProjectItem: MyProjectItem) -> some View {
        HStack(alignment:.center){
            // 使用封面图片或默认图标
            if let coverImage = myProjectItem.cover_image, !coverImage.isEmpty {
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
                Text(myProjectItem.title ?? "未知标题")
                    .font(.system(size: 16,weight:.semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(myProjectItem.simple_descri ?? "暂无描述")
                    .font(.system(size: 14))
                    .foregroundColor(.black).opacity(0.58)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack{
                    Text("PoID：\(myProjectItem.task_no ?? "未知")")
                        .font(.system(size: 14))
                        .foregroundColor(.black).opacity(0.58)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                Text("\(myProjectItem.currency_unit ?? "￥")\(String(format: "%.2f", myProjectItem.price ?? 0.0))")
                .font(.system(size: 16,weight:.semibold))
                .foregroundColor(Color(hex:"#9A1E2E"))
                .padding(.trailing,-5)
                
                if let unit = myProjectItem.unit, !unit.isEmpty {
                    Text("/\(unit)")
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

    // MARK: - 分页逻辑
    private func loadMoreIfNeeded(for tabId: Int? = nil) {
        let targetTab = tabId ?? selectedTab
        let tabHasMore = categoryHasMoreData[targetTab] ?? true
        let tabIsLoadingMore = categoryIsLoadingMore[targetTab] ?? false
        
        guard tabHasMore && !isLoading && !tabIsLoadingMore else { return }
        
        categoryIsLoadingMore[targetTab] = true
        if let savedPage = categoryPages[targetTab] {
            currentPage = savedPage
        }
        fetchMyProject(reset: false)
    }
    
    // MARK: - 刷新指定 tab 的数据
    @MainActor
    private func refreshTabData(tabId: Int) async {
        // 只刷新当前 tab 的数据
        currentPage = 1
        categoryPages[tabId] = 1
        selectedTab = tabId
        fetchMyProject(reset: true)
    }
    
    private func handleProjectItemTap(item: MyProjectItem) {
        print("🔥 项目点击事件触发 - ID: \(item.id), TaskID: \(item.task_id ?? 0)")
        print("🚀 使用 SwiftUI 导航跳转到任务详情")
        navigationToTaskDetail = true
        // 使用 SwiftUI 导航，传递 taskId 和 userTaskId
        let navigationData = TaskNavigationData(
            taskId: item.task_id ?? 0,
            userTaskId: item.id
        )
        selectedTaskNavigationData = navigationData
        // navigationPath.append(navigationData)
        
        
    }

    private func fetchMyProject(reset: Bool) {
        let targetTab = selectedTab
        
        if reset {
            currentPage = 1
            categoryPages[targetTab] = 1
            hasMoreData = true
            categoryHasMoreData[targetTab] = true
        } else {
            categoryIsLoadingMore[targetTab] = true
        }

        isLoading = true
        errorMessage = nil

        let requestBody: [String: Any] = [
            "page": currentPage,
            "limit": limit,
            "task_status": targetTab
        ]

        NetworkManager.shared.post(APIConstants.Profile.getMyProject, businessParameters: requestBody) { (result: Result<MyProjectResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false
                isLoadingMore = false
                categoryIsLoadingMore[targetTab] = false

                switch result {
                case .success(let response):
                    if response.code == 1 {
                        let newItems = response.data
                        var tabData: [MyProjectItem]
                        
                        if reset {
                            // 刷新时替换数据
                            tabData = newItems
                            cachedData[targetTab] = tabData
                            hasLoadedTab.insert(targetTab)
                        } else {
                            // 加载更多时追加数据
                            let existingData = cachedData[targetTab] ?? []
                            tabData = existingData + newItems
                            cachedData[targetTab] = tabData
                        }
                        
                        // 更新当前显示的数据（如果当前选中的 tab 就是请求的 tab）
                        if targetTab == selectedTab {
                            myProjectList = tabData
                        }
                        
                        // 判断是否还有更多数据
                        let hasMore = newItems.count >= limit
                        categoryHasMoreData[targetTab] = hasMore
                        hasMoreData = hasMore
                        
                        if hasMore {
                            let nextPage = currentPage + 1
                            currentPage = nextPage
                            categoryPages[targetTab] = nextPage
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
}
