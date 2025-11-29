//
//  AllIndustries.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/13.
//

import SwiftUI
import Foundation
import UIKit
import SafariServices
import WebKit


struct AllIndustries: View {
    @Environment(\.dismiss) private var dismiss
    var children: [SceneTypeChild]
    
    // MARK: - 图标显示辅助函数（本地实现）
    @MainActor
    @ViewBuilder
    private static func iconView(for child: SceneTypeChild) -> some View {
        if let iconUrl = child.icon_url, !iconUrl.isEmpty {
            if let url = URL(string: iconUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                } placeholder: {
                    Image("占位图")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
            } else {
                Image("占位图")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                     .frame(width: 60, height: 60)
            }
        } else {
            Image("占位图")
                .resizable()
                .aspectRatio(contentMode: .fit)
                 .frame(width: 60, height: 60)
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
                .font(.system(size: 16))
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
    
    // MARK: - 处理子分类点击事件（本地实现）
    private static func handleChildItemTap(child: SceneTypeChild) {
        print("点击了子分类：\(child.name)")
        Task { @MainActor in
            let vc = UIHostingController(
                rootView: subcategoryTaskList(sceneId: child.id, title: child.name)
                    .toolbar(.hidden, for: .navigationBar)
            )
            vc.hidesBottomBarWhenPushed = true
            vc.navigationItem.title = child.name
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            MOAppDelegate().transition.push(vc, animated: true)
        }
    }
    
    var body: some View {
        ZStack {
            // 全屏背景色
            Color(hex: "#ffffff")
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 10) {
                if children.isEmpty {
                    Text("暂无行业")
                } else {
                ScrollView(showsIndicators: false){
                    ForEach(0..<((children.count + 4) / 5), id: \.self) { rowIndex in
                        HStack {
                            ForEach(0..<5, id: \.self) { colIndex in
                                let itemIndex = rowIndex * 5 + colIndex
                                if itemIndex < children.count {
                                    let child = children[itemIndex]
                                    Self.childItemView(for: child)
                                } else {
                                    // 空白占位
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                 }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("全部行业")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 处理返回按钮点击事件
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

