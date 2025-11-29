//
//  Translation.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/9/25.
//

import SwiftUI

struct AboardTranslation: View {
    var body: some View {
        VStack{
           ZStack{
         // 全屏背景色
                Color(hex: "#f7f8fa")
                    .ignoresSafeArea()
            
                VStack(spacing:5){
                    VStack{
                        HStack{
                            HStack{
                                Rectangle()
                                .fill(Color(hex: "#9A1E2E"))
                                .frame(width: 4, height: 16)
                                .cornerRadius(2)
                                Text("原文")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#000000"))
                            }
                            Spacer()
                            HStack(alignment:.center){
                                Image("复制_1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                Text("复制")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#9A1E2E"))
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal,5)
                            .background(Color(hex:"#F5E8EA"))
                            .cornerRadius(10)
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(.horizontal, 10)



        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
       
    }
}

