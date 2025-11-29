//
//  Untitled.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/9/23.
//

import SwiftUI

struct TranslationDetailView: View {
     let url: String // 添加参数
     @Environment(\.dismiss) private var dismiss // 添加 dismiss 环境变量
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色
                Color(red: 0.094, green: 0.157, blue: 0.227)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 图片区域
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height - 250)
                    .clipped()

                    // 底部操作区域
                    HStack {
                        VStack(alignment: .center){
                            Image("保存到相册_(1) 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("保存")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        .offset(x:-100)                     
                        
                        VStack(alignment: .center){
                            Image("share_1")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 24, height: 24)
                            Text("分享")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                            .offset(x:20)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .background(Color(red: 0.094, green: 0.157, blue: 0.227))
                    .padding(.horizontal, 20) // 添加左右边距
                }
                
             
                VStack{
                     // 关闭按钮 - 使用绝对定位
                Button(action: {
                    dismiss()
                }) {
                    Image("Group_133")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                .position(x: geometry.size.width - 50, y: 90) // 往下移动30px (60 + 30 = 90)
                
                // 翻译图标 - 使用绝对定位
                NavigationLink(destination: AboardTranslation()) {
                    Image("Group_137")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                .position(x: geometry.size.width - 50, y: 150) // 往下移动30px (60 + 30 = 90)
                   
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
              
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all)
        .toolbar(.hidden, for: .navigationBar)
        
    }
}

