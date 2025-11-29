//
//  MindMapFullSrceen.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/29.
//

import SwiftUI
import Foundation


struct MindMapFullSrceenView: View {
        @Environment(\.dismiss) var dismiss
        
    let imageURL: String
    
    // 默认初始化器，提供示例 URL
    init(imageURL: String = "") {
        self.imageURL = imageURL
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 全屏背景色
                Color(hex: "#f7f8fa")
                    .ignoresSafeArea()

                      // 可缩放的图片
                ZoomableImageView(imageURL: imageURL)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.8) // 限制最大高度为屏幕的80%
                    .padding(.horizontal)
                     //旋转图片
                    .rotationEffect(.degrees(90))
                HStack{
                    Spacer()
                    VStack{
                         Spacer()
                          Button(action:{
                                dismiss()
                            }){
                                Image("icon_vertical_screen")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            }
                            .padding(.trailing,20)
                            .padding(.bottom,20)
                           
                    }
                }
              
            }
            .navigationBarBackButtonHidden(true)
        }
        .ignoresSafeArea() // 忽略安全区域，实现真正的全屏
    }
}
