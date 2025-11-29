//
//  LoginConfirmView.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/24.
//

import SwiftUI
import Foundation


struct LoginConfirmView:View {
    @Environment(\.dismiss) var dismiss
    let id: String
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack(alignment:.topLeading){
             Color(hex: "#F7F8FA").ignoresSafeArea()
             VStack(spacing: 20){
                customNavigationBar()
                
                // 展示或后续处理扫描到的 URL
                VStack( spacing: 0) {
                   Image("icon_scan_login")
                      .resizable()
                      .scaledToFit()
                      .frame(width: UIScreen.main.bounds.width * 0.8)
                      .padding(.top,50)
                    Text("Mobiwusi电脑端登录确认")
                       .font(.system(size: 25))
                       .foregroundColor(.black)
                       .padding(.top,-50)
                    
                   
                        Button(action: {
                             guard !id.isEmpty else {
                                errorMessage = "无法解析二维码ID"
                                print("确认登录失败：ID为空")
                                return
                            }
                            confirmLogin(id: id)
                        }) {
                            Text("确认登录")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FF6B6B"), Color(hex: "#E62941")]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(12)
                        
                    }
                    .padding(.top,60)
                    Button(action:{
                        dismiss()
                    }){
                        Text("取消")
                          .font(.system(size: 20))
                          .foregroundColor(Color(hex:"#626262"))
                          .padding(.vertical, 15)
                          .padding(.horizontal, 24)
                        
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                 .cornerRadius(12)
                .padding(.horizontal)
               
               

                // TODO: 在此根据 URL 执行登录确认逻辑（比如发起请求或跳转）
             }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        // .onAppear {
        //     scanId = extractQueryValue(from: url, key: "id") ?? ""
        // }
        
    }

    //自定义导航栏
    private func customNavigationBar() -> some View {
        HStack {
            Button(action: {
                // 处理返回按钮点击事件
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("登录确认")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
    }


    func confirmLogin(id:String){
         errorMessage = ""
         let requestBody: [String: Any] = [
                "id": id,
            ]
        
         NetworkManager.shared.post(APIConstants.Login.confirmLogin, 
                                 businessParameters: requestBody) { (result: Result<ConfirmLoginResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        MBProgressHUD.showMessag("扫码成功", to: nil, afterDelay: 3.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            dismiss()
                        }
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage ?? "", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
            }
        }
    }
}

