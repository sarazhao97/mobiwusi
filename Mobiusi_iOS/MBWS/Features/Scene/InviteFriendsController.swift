

import SwiftUI
import Foundation

// 用于跟踪滚动位置的 PreferenceKey
struct ShareScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SharePathItem: Identifiable {
    var id = UUID()
    var icon: String?
    var title: String?
}
struct InviteFriendsController:View {
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage = ""
    @State private var sharePaths : [SharePathItem] = [
        SharePathItem(icon: "icon_share_save", title: "保存图片"),
        SharePathItem(icon: "icon_share_wx", title: "微信好友"),
        SharePathItem(icon: "icon_share_circle", title: "朋友圈"),
        // SharePathItem(icon: "icon_share_qq", title: "QQ好友"),
        // SharePathItem(icon: "icon_share_zone", title: "QQ空间"),
    ]
    // 横向滚动的示例数据（可替换为你的实际数据）
    @State private var shareimgs: [ShareStyleItem] = []
    @State private var currentIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollTimer: Timer?
    private let previewWidth: CGFloat = 10 // 左右预览宽度
    var body: some View {
         ZStack{
            // 全屏背景色
            Color(hex: "#f7f8fa")
                .ignoresSafeArea()
            VStack{
                // 分页图片区域
                GeometryReader { proxy in
                    if shareimgs.isEmpty {
                        Text("暂无可分享样式")
                            .frame(width: proxy.size.width)
                            .foregroundColor(Color(hex: "#999999"))
                            .frame(height: 560)
                    } else {
                        let itemWidth = proxy.size.width - previewWidth * 2 // 每张图片的宽度（屏幕宽度减去左右预览）
                        ScrollViewReader { scrollProxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(shareimgs.indices, id: \.self) { idx in
                                        shareStyleItemView(item: shareimgs[idx], idx: idx)
                                            .frame(width: itemWidth)
                                            .id(idx)
                                    }
                                }
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(key: ShareScrollOffsetPreferenceKey.self, 
                                                      value: geometry.frame(in: .named("scroll")).minX)
                                    }
                                )
                            }
                            .coordinateSpace(name: "scroll")
                            .onPreferenceChange(ShareScrollOffsetPreferenceKey.self) { value in
                                scrollOffset = value
                                // 检测滚动是否停止
                                checkScrollEnded(itemWidth: itemWidth, scrollProxy: scrollProxy)
                            }
                            .onChange(of: shareimgs) { newItems in
                                if newItems.isEmpty { return }
                                // 确保索引有效
                                if currentIndex >= newItems.count {
                                    currentIndex = max(0, newItems.count - 1)
                                }
                                // 滚动到当前索引
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollToIndex(currentIndex, itemWidth: itemWidth, scrollProxy: scrollProxy)
                                }
                            }
                            .onChange(of: currentIndex) { newIndex in
                                // 当索引改变时，自动对齐到该索引
                                scrollToIndex(newIndex, itemWidth: itemWidth, scrollProxy: scrollProxy)
                            }
                        }
                    }
                }
                .frame(height: 560)

                Spacer()
                 // 底部操作栏
                BottomActionBarView()
            }

         }
         .navigationBarBackButtonHidden(true)
         .navigationBarTitle("邀请好友", displayMode: .inline)
         .toolbar{
             ToolbarItem(placement: .navigationBarLeading) {
                 Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#000000"))
                    }
             }
         }
         .onAppear{
            fetchShareimgs()
         }
    }

    // 辅助：生成分享样式项视图
    @ViewBuilder
    private func shareStyleItemView(item: ShareStyleItem, idx: Int) -> some View {
        VStack(spacing:0){
            AsyncImage(url: URL(string: item.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height:400)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height:400)
                    .clipped()
            }
            HStack(alignment:.center){
                AsyncImage(url: URL(string: item.avatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width:50,height:50)
                        .cornerRadius(8)
                        .clipped()
                } placeholder: {
                     Rectangle()
                    .fill(Color.clear)
                    .frame(width:50,height:50)
                    .clipped()
                }
                Text(item.nick_name ?? "")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#000000"))
                    Spacer()
                AsyncImage(url: URL(string: item.qrcode_url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width:90,height:90)
                        .clipped()
                } placeholder: {
                      Rectangle()
                    .fill(Color.clear)
                    .frame(width:90,height:90)
                    .clipped()
                }
            }
            .padding(.horizontal,10)
            .padding(.vertical,18)
            .background(Color.white)
        }
    }
    
   @ViewBuilder
    private func BottomActionBarView() -> some View {
        HStack(spacing: 0){
            ForEach(Array(sharePaths.enumerated()), id: \.offset) { idx, item in
                VStack(spacing:6){
                    Image(item.icon ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width:40,height:40)
                        .cornerRadius(8)
                        .clipped()
                    Text(item.title ?? "")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#000000"))
                }
                .frame(maxWidth: .infinity)
            }
        }
         .padding(.vertical,20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        //忽略底部安全区域
        .ignoresSafeArea(edges: .bottom)
    }
    
    // 检测滚动是否停止，如果停止则自动对齐
    private func checkScrollEnded(itemWidth: CGFloat, scrollProxy: ScrollViewProxy) {
        // 取消之前的定时器
        scrollTimer?.invalidate()
        
        let currentScrollOffset = scrollOffset
        let currentLastOffset = lastScrollOffset
        let currentIdx = currentIndex
        
        // 如果滚动位置没有变化，说明滚动已停止
        if abs(currentScrollOffset - currentLastOffset) < 0.1 {
            // 计算应该对齐的索引
            let targetIndex = calculateTargetIndex(offset: currentScrollOffset, itemWidth: itemWidth)
            if targetIndex != currentIdx {
                DispatchQueue.main.async {
                    currentIndex = targetIndex
                    scrollToIndex(targetIndex, itemWidth: itemWidth, scrollProxy: scrollProxy)
                }
            }
        } else {
            // 设置定时器，0.2秒后检查滚动是否停止
            let capturedItemWidth = itemWidth
            let capturedScrollProxy = scrollProxy
            
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                Task { @MainActor in
                    // 重新获取最新的 scrollOffset
                    let latestOffset = scrollOffset
                    let targetIndex = calculateTargetIndex(offset: latestOffset, itemWidth: capturedItemWidth)
                    if targetIndex != currentIndex {
                        currentIndex = targetIndex
                        scrollToIndex(targetIndex, itemWidth: capturedItemWidth, scrollProxy: capturedScrollProxy)
                    }
                }
            }
        }
        
        lastScrollOffset = scrollOffset
    }
    
    // 计算目标索引
    private func calculateTargetIndex(offset: CGFloat, itemWidth: CGFloat) -> Int {
        guard !shareimgs.isEmpty else { return 0 }
        // 计算当前偏移量对应的索引（考虑预览宽度）
        // offset 是 HStack 的 minX，我们需要计算哪个图片应该居中
        let adjustedOffset = -offset + previewWidth
        let index = Int(round(adjustedOffset / itemWidth))
        return max(0, min(index, shareimgs.count - 1))
    }
    
    // 滚动到指定索引
    private func scrollToIndex(_ index: Int, itemWidth: CGFloat, scrollProxy: ScrollViewProxy) {
        guard index >= 0 && index < shareimgs.count else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            scrollProxy.scrollTo(index, anchor: .leading)
        }
    }

    func fetchShareimgs(){
        errorMessage = ""
        NetworkManager.shared.post(APIConstants.Scene.shareImage, 
                                 businessParameters: [:]) { (result: Result<ShareStylesResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{    
                        shareimgs = response.data ?? []
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
            }
        }
    }
}
