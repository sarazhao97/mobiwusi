//
//  LogOffAccount.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/27.
//

import SwiftUI
import Foundation


struct LogOffAccountView:View {
    @Environment(\.dismiss) var dismiss
    @State private var mobile: String? = ""
    @State private var showLogOffModal = false
    @State private var errorMessage = ""
    @State private var loading = false

     // 执行退出登录的方法
    private func performLogOff() {
        loading = true
        errorMessage = ""
        
         NetworkManager.shared.post(APIConstants.Login.logOff, 
                                 businessParameters: [:]) { (result: Result<CancelUserResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                         // // 清除用户数据
                        NetworkManager.shared.clearUserData()
                        
                        // // 发送登录通知，触发跳转到登录页面
                        NotificationCenter.default.post(name: .loginRequired, object: nil)
                        
                        // print("用户确认退出登录，已清除用户数据并发送通知")
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
                loading = false
            }
        }

    }
    var body: some View {
        ZStack{
            Color(hex: "#F7F8FA").ignoresSafeArea()
            VStack(alignment:.center,spacing:50){
                Spacer()
                Text("当前账号")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#333333"))
                    .padding(.top,-100)
                Text(mobile.map { $0.count == 11 ? String($0.prefix(3)) + "******" + String($0.suffix(2)) : $0 } ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(Color.black)
                     .padding(.top,-70)
                VStack(alignment:.center,spacing:15){
                    Text("温馨提示")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#333333"))
                    Text("请确认你的账号中是否存在未完成的项目，待领取待提现的收益等，操作完成后可注销账号。")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black)
                        .lineSpacing(15)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal,20)
                Spacer()
                HStack{
                    Text("注销账号")
                     .font(.system(size: 18))
                     .foregroundColor(Color(hex:"#FF0006"))
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal,20)
                .onTapGesture {
                    // 处理注销账号点击事件
                    showLogOffModal = true
                }
                
            }

             if showLogOffModal {
                       CustomLogOffAlert(
                           showAlert: $showLogOffModal,
                           onConfirm: {
                               performLogOff()
                           }
                       )
                   }
            if loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex:"#ffffff")))
                    .padding(30)
                    .frame(width:120,height:120)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
            }
        }
        .onAppear{
           mobile = UserManager.shared.getMobile()
           print("当前账号：\(mobile ?? "N/A")")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 处理返回按钮点击事件
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
             ToolbarItem(placement: .principal) {
                    Text("注销账号").font(.system(size: 24)).foregroundColor(.black)
                }
        }
    }
}

// 自定义注销对话框
struct CustomLogOffAlert: View {
    @Binding var showAlert: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showAlert = false
                }
            
            // 对话框内容
            VStack(spacing: 20) {
                // 标题
                Text("确认注销账号？")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // 内容文本
                Text("提交账户注销申请60天内，你仍可登录该账户（登录成功将终止注销流程，但你可重新申请注销）；若超过60天未登录，你的账户将被注销且不可恢复，请谨慎操作。")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(12)
                
                // 按钮区域
                HStack(spacing: 15) {
                    // 取消按钮
                    Button(action: {
                        showAlert = false
                    }) {
                        Text("再想想")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex:"#EDEEF4"))
                            .cornerRadius(10)
                           
                    }
                    
                    // 确定按钮
                    Button(action: {
                        showAlert = false
                        onConfirm()
                    }) {
                        Text("确认注销")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}
