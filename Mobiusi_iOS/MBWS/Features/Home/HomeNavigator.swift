import SwiftUI

/// Home模块的通用导航助手，抽取可复用的点击跳转逻辑
enum HomeNavigator {
    /// 处理媒体项的点击逻辑并进行页面跳转（命令式，旧方法）
    @MainActor
    static func navigate(_ item: IndexItem) {
        // 特殊来源处理
        if item.source == 6 || item.source == 3 {
            if item.cate == 3 {
                // pushHosting(FileReaderTool(item: item))
                HomeViewController().NavigateToPreview(path: item.meta_data?.first?.relative_path ?? "")
            }
            return
        }
        // 常规来源分支
        if item.source != 2 {
            pushHosting(
                FullScreenViewController(data: item)
                    .toolbarColorScheme(.dark)
            )
        } else {
            pushHosting(
                MOFoodSafetyAnalysisDetail(item: item)
                    .toolbarColorScheme(.dark)
            )
        }
    }

    /// 基于 NavigationLink 的声明式导航：提供一个可复用的链接（推荐新方法）
    @MainActor @ViewBuilder
    static func link<L: View>(_ item: IndexItem, @ViewBuilder label: () -> L) -> some View { 
        if item.source == 6 || item.source == 3 {
            if item.cate == 3 {
                Button(action: {
                MyDataController.navigateToPreview(path: item.meta_data?.first?.relative_path ?? "")}){
                    Text("")
                }
            } else {
               HStack{}
            }
        }  else{
              NavigationLink(destination: destinationView(for: item)) {
              label()
        }
        } 
      
    }

    /// 将数据项映射到目标视图（供 NavigationLink 使用）
    @MainActor @ViewBuilder
    static func destinationView(for item: IndexItem) -> some View {
       if item.source != 2 {
            FullScreenViewController(data: item)
                .toolbar(.hidden, for: .tabBar)
                .toolbarColorScheme(.dark)
        } else {
            MOFoodSafetyAnalysisDetail(item: item)
                .toolbar(.hidden, for: .tabBar)
                .toolbarColorScheme(.dark)
        }
    }

    /// 包装UIHostingController推入逻辑（旧方法，命令式，已禁用）
    @MainActor
    private static func pushHosting<V: View>(_ view: V) {
        let vc = UIHostingController(rootView: view)
        vc.hidesBottomBarWhenPushed = true
        MOAppDelegate().transition.push(vc, animated: true)
    }
}