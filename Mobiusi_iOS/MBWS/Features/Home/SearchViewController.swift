//
//  SearchViewController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/24.
//

import SwiftUI
import Foundation

// MARK: - 数字容器样式修饰器
struct NumberContainerModifier: ViewModifier {
    let number: Int
    
    func body(content: Content) -> some View {
        let digitCount = String(number).count
        
        if digitCount > 2 {
            // 超过两位数字：使用 padding
            content
                .padding(2)
        } else {
            // 两位及以下：使用固定宽高
            content
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - 灵活布局视图
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
            FlexibleViewLayout(
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        
    }
}

struct FlexibleViewLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = []
        var currentRow: [Data.Element] = []
        
        for item in data {
            let itemString = String(describing: item)
            let estimatedWidth = estimateTextWidth(itemString)
            
            // 如果当前行已经有内容，检查是否可以添加新项目
            if !currentRow.isEmpty {
                let currentRowWidth = currentRow.map { estimateTextWidth(String(describing: $0)) }.reduce(0, +)
                let spacingWidth = CGFloat(currentRow.count) * 8 // 间距宽度
                
                // 如果添加新项目会超出屏幕宽度，则换行
                if currentRowWidth + spacingWidth + estimatedWidth > UIScreen.main.bounds.width - 40 { // 减去左右padding
                    rows.append(currentRow)
                    currentRow = [item]
                } else {
                    currentRow.append(item)
                }
            } else {
                // 如果当前行为空，直接添加
                currentRow.append(item)
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func estimateTextWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14)
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return size.width + 16 // 加上左右padding (8 + 8)
    }
}


struct SearchViewController:View {
    @Environment(\.dismiss) private var dismiss
    @State private var keyword = ""
    @State private var hotTaskList: [HotTaskItem] = []
    @State private var errorMessage: String?
    @State private var currentPage: Int = 1
    @State private var limit: Int = 10
    @State private var cate: Int = 0
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var historySearchList: [String] = []
    var body: some View {
        ZStack{
             Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing:20){
                searchBarView
                
                if !historySearchList.isEmpty {
                    historySearchView()
                } 

                hotTaskListView
            }
              .padding(.horizontal,10)
        }
        .onAppear{
            getHotTaskList(isRefresh: true)
        }
      
        .navigationBarHidden(true)
       .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - 搜索栏视图
    private var searchBarView: some View {
        HStack{
            //返回按钮
            Button(action:{dismiss()}){
                 Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.black)
                .padding(.leading, 20)
                .padding(.trailing,10)
            
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dismiss()
            }
           
           HStack{
           TextField("输入关键字/项目ID搜索", text: $keyword)
            .font(.system(size: 14))
           .foregroundColor(.black)
           Button(action:{
              Task { @MainActor in
                            let vc = UIHostingController(
                                rootView: SearchResultController(initialKeyword: keyword)
                            )
                            vc.hidesBottomBarWhenPushed = true
                            MOAppDelegate().transition.push(vc, animated: true)
                    }

                    //historySearchList去重
                    if !historySearchList.contains(keyword) {
                        historySearchList.append(keyword)
                    }
           }){
            HStack(alignment:.center){
               Text("搜索")
               .font(.system(size: 14))
               .foregroundColor(.white)
               
           }
           .padding(.vertical, 8)
           .padding(.horizontal, 8)
           .background(Color(hex:"#9A1E2E"))
           .cornerRadius(10)
           }
           
           }
           .padding(.vertical,10)
           .padding(.horizontal,10)
           .frame(maxWidth:.infinity, maxHeight: 40)
           .background(Color.white)
            .cornerRadius(10)
           
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 热门任务列表视图
    private var hotTaskListView: some View {
        VStack(alignment:.leading,spacing:10){
                HStack{
                    Image("Fire_(火热) 1") 
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    Text("热门数据")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                  
                }
                  ScrollView(showsIndicators: false){
                        LazyVStack(spacing: 15) {
                            ForEach(Array(hotTaskList.enumerated()), id: \.element.id){ index, item in
                               //热门数据item
                               hotTaskItemView(item: item, index: index)
                               .id(item.id)
                               .onTapGesture {
                                 Task { @MainActor in
                                           let vc = UIHostingController(
                                               rootView: SearchResultController(initialKeyword: item.title)
                                           )
                                           vc.hidesBottomBarWhenPushed = true
                                           MOAppDelegate().transition.push(vc, animated: true)
                                   }

                                //historySearchList去重
                                if !historySearchList.contains(item.title) {
                                    historySearchList.append(item.title)
                                }
                                }
                            }
                            
                            // 底部加载状态
                            bottomLoadingView
                        }
                    }
                    .refreshable{
                        getHotTaskList(isRefresh: true)
                    }
            
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // MARK: - 底部加载视图
    private var bottomLoadingView: some View {
        VStack {
            if isLoadingMore {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("加载中...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
            } else if !hasMoreData && !hotTaskList.isEmpty {
                Text("没有更多数据了")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
            }
            
            // 触发加载更多数据的透明视图
            if hasMoreData && !isLoadingMore {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        loadMoreData()
                    }
            }
        }
    }
    
    // MARK: - 加载更多数据
    private func loadMoreData() {
        guard hasMoreData && !isLoadingMore else { return }
        getHotTaskList(isRefresh: false)
    }

   private func getHotTaskList(isRefresh: Bool = false) {
        if isRefresh {
            currentPage = 1
            hotTaskList = []
            hasMoreData = true
        }
        
        errorMessage = nil
        isLoadingMore = true
        
         let requestBody: [String: Any] = [
                "page": currentPage,
                "limit": limit,
                "cate": cate
            ]
        
         NetworkManager.shared.post(APIConstants.Index.hotSearchList, 
                                 businessParameters: requestBody) { (result: Result<HotTaskListResponse, APIError>) in
            DispatchQueue.main.async {         
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        if isRefresh {
                            hotTaskList = response.data
                        } else {
                            hotTaskList.append(contentsOf: response.data)
                        }
                        
                        // 检查是否还有更多数据
                        if response.data.count < limit {
                            hasMoreData = false
                        } else {
                            currentPage += 1
                        }
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                isLoadingMore = false
            }
        }
    }

    //MARK: - 热门数据item
    private func hotTaskItemView(item: HotTaskItem, index: Int) -> some View {
        HStack{
            let number = index + 1
                Text("\(number)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .modifier(NumberContainerModifier(number: number))
                     .background(number == 1 ? Color(hex: "#EC0000") : number == 2 ? Color(hex: "#EC6200") : number == 3 ? Color(hex: "#ECC800") : Color(hex:"#AFAFAF"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(item.title)
                .font(.system(size: 16))
                .foregroundColor(.black)
                Spacer()
        }
        .padding(.vertical,10)
    }

    //MARK： - 历史搜索
    private func historySearchView() -> some View {
        VStack{
            HStack{
                Text("历史搜索")
                .font(.system(size: 16))
                .foregroundColor(Color(hex:"#AFAFAF"))
                Spacer()
                Button(action: {
                    clearHistorySearch()
                }) {
                   Image("icon_del")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                }
            }
            .padding(.horizontal,18)
            .padding(.bottom,-10)
                 LazyVStack(alignment: .leading, spacing: 10) {
                    FlexibleView(data: historySearchList, spacing: 10, alignment: .leading) { item in
                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .cornerRadius(10)
                             .onTapGesture {
                                 Task { @MainActor in
                                           let vc = UIHostingController(
                                               rootView: SearchResultController(initialKeyword: item)
                                           )
                                           vc.hidesBottomBarWhenPushed = true
                                           MOAppDelegate().transition.push(vc, animated: true)
                                   }
                                }
                    }
                }
                .padding(.horizontal,20)
                .padding(.vertical,10)
               
           
            
        }
    }

    //MARK： - 清空历史搜索
    private func clearHistorySearch() {
        historySearchList = []
    }

}
