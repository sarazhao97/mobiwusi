//
//  TranslationResultController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/28.
//

import SwiftUI
import Foundation


struct TranslationResultController:View {
    let translationDetail: ImageTranslationDetailData
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    
    var body: some View {
            ZStack{
                  Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
                
                // Toast组件
                if showToast {
                    VStack {
                        Spacer()
                        
                        Text("已复制到粘贴板")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                            )
                            .transition(.opacity.combined(with: .scale))
                        
                        Spacer()
                    }
                    .zIndex(1000)
                }

                VStack(spacing:10){
                    ScrollView(showsIndicators: false){
                    VStack(spacing:10){
                        HStack{
                            HStack(spacing:10){
                                //竖条,圆角
                                Rectangle()
                                    .fill(Color(hex: "#9A1E2E"))
                                    .frame(width: 4, height: 20)
                                    .cornerRadius(2)
                                Text("原文")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Button(action: {
                                copyToClipboard(translationDetail.original_text)
                            }) {
                                HStack(spacing:10){
                                    Image("复制_1 1")
                                       .resizable()
                                       .frame(width: 20, height: 20)
                                    Text("复制")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex:"#9A1E2E"))
                                }
                                .padding(.horizontal,8)
                                .padding(.vertical,4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex:"#F5E8EA"))
                                )
                            }
                        }

                        HStack{
                            Text(translationDetail.original_text)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    .padding(12)
                    .frame(maxWidth:.infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                      VStack(spacing:10){
                        HStack{
                            HStack(spacing:10){
                                //竖条,圆角
                                Rectangle()
                                    .fill(Color(hex: "#ffffff"))
                                    .frame(width: 4, height: 20)
                                    .cornerRadius(2)
                                Text("译文")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button(action: {
                                copyToClipboard(translationDetail.translate_text)
                            }) {
                                HStack(spacing:10){
                                    Image("复制_1(1) 1")
                                       .resizable()
                                       .frame(width: 20, height: 20)
                                    Text("复制")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex:"#ffffff"))
                                }
                                .padding(.horizontal,8)
                                .padding(.vertical,4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex:"#ffffff"))
                                        .opacity(0.2)
                                )
                            }
                        }
                          HStack{
                            Text(translationDetail.translate_text)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                         .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    .padding(12)
                    .frame(maxWidth:.infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex:"#9A1E2E"))
                    )
                }
                    Spacer()
                    
                }
                .padding(.horizontal,16)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("出国翻译官")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                       
                }
            }
    
    }
    
    // 复制方法
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
}
