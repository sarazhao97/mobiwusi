//
//  EditPwdController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/27.
//

import SwiftUI
import Foundation


struct EditPwdController:View {
    @Environment(\.dismiss) var dismiss
    let mobile: String
    @State private var verifyCode: String = ""
    @State private var isSendingCode: Bool = false
    @State private var countdown: Int = 60
    @State private var timer: Timer? = nil
    @State private var errorMessage: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isShowPassword: Bool = false
    @State private var isShowConfirmPassword: Bool = false

    var body: some View {
       ZStack{
           // 全屏背景色
           Color(hex: "#f7f8fa")
               .ignoresSafeArea()
               VStack{
                ZStack(alignment:.topLeading){
               Image("bg_login")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                VStack(spacing:20){
                    HStack{
                        Text("修改密码")
                        .font(.system(size: 36))
                        .foregroundColor(.black)
                       .padding(.horizontal,20)
                       .padding(.vertical,20)
                        Spacer()
                    }
                    HStack{
                         Text("为了您的账户安全，需要验证您的手机号：\(maskMobile(mobile))")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal,20)
                         Spacer()
                        }
                    
                    // 验证码输入框 + 右侧内嵌按钮
                    TextField("请输入验证码", text: $verifyCode)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.vertical,20)
                        .padding(.horizontal,20)
                        // .padding(.trailing, 110) // 为右侧按钮预留空间
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#EDEEF5"))
                        .cornerRadius(10)
                        .padding(.horizontal,20)
                        .overlay(alignment: .trailing) {
                            Button(action: {
                                sendVerifyCode()
                            }) {
                                Text(isSendingCode ? "\(countdown)s后重试" : "获取验证码")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex:"#9A1E2E"))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                  
                            }
                            .disabled(isSendingCode)
                            .padding(.trailing, 30)
                        }

                        Group {
                            if isShowPassword {
                                TextField("请输入登录密码", text: $password)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("请输入登录密码", text: $password)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.vertical,20)
                        .padding(.horizontal,20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#EDEEF5"))
                        .cornerRadius(10)
                        .padding(.horizontal,20)
                        .overlay(alignment: .trailing) {
                            Button(action: {
                               isShowPassword.toggle()
                            }) {
                                Image(isShowPassword ? "浏览_(2) 1" : "隐藏_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                  
                            }
                            .padding(.trailing, 40)
                        }
                        HStack{
                            Text("密码必须包含大小写字母和数字，长度6-16位")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex:"#AFAFAF"))
                            .padding(.horizontal,20)
                            Spacer()
                        }
                      

                         Group {
                            if isShowConfirmPassword {
                                TextField("请再次输入登录密码", text: $confirmPassword)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("请再次输入登录密码", text: $confirmPassword)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.vertical,20)
                        .padding(.horizontal,20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#EDEEF5"))
                        .cornerRadius(10)
                        .padding(.horizontal,20)
                        .overlay(alignment: .trailing) {
                            Button(action: {
                               isShowConfirmPassword.toggle()
                            }) {
                                Image(isShowConfirmPassword ? "浏览_(2) 1" : "隐藏_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                  
                            }
                            .padding(.trailing, 40)
                        }

                            HStack{
                              Button(action: {
                                  updatePassword()
                              }) {
                                  Text("立即修改")
                                      .font(.system(size: 18))
                                      .foregroundColor(.white)
                                      
                              }
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex:"#9A1E2E"))
                            .cornerRadius(10)
                            .padding(.top,10)
                            .padding(.horizontal, 20)
                            
                           
                    
                        Spacer()
                    }
                     
                      
                }
              
                Spacer()
               }
       
             
       }
       .navigationBarBackButtonHidden(true)
       .navigationBarTitleDisplayMode(.large)
       .toolbar {
           ToolbarItem(placement: .navigationBarLeading) {
               Button(action: {
                   dismiss()
               }) {
                   Image(systemName: "chevron.left")
                       .font(.system(size: 20))
                       .foregroundColor(.black)
               }
           }
       }
       .onDisappear {
           timer?.invalidate()
       }
       
    }

    // 更新密码
    private func updatePassword() {
        guard password == confirmPassword else {
            errorMessage = "两次输入密码不一致"
             MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
            return
        }
        guard password.count >= 6 && password.count <= 16 else {
              errorMessage = "密码长度必须在6-16位之间"
               MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
            return
        }

           let requestBody: [String: Any] = [
                "mobile": mobile,
                "password": password,
                "code": verifyCode,
                "second_password": confirmPassword
            ]
        // TODO: 在这里触发真实的密码更新请求
        NetworkManager.shared.post(APIConstants.Login.forget, 
                               businessParameters: requestBody) { (result: Result<ForgetResponse, APIError>) in
            switch result {
            case .success(let response):
                let code = response.code
                let msg = response.msg
                Task { @MainActor in
                    if code == 1 {
                        print("密码更新成功")
                        MBProgressHUD.showMessag("密码更新成功", to: nil, afterDelay: 3.0)
                        dismiss()
                    } else {
                        errorMessage = msg
                    }
                }
            case .failure(let error):
                let message = error.localizedDescription
                Task { @MainActor in
                    errorMessage = message
                }
            }
        }
    }

    
    // 手机号脱敏：保留前三位和后两位，中间使用6个*
    private func maskMobile(_ mobile: String) -> String {
        let digits = mobile.filter { $0.isNumber }
        guard digits.count >= 5 else { return mobile }
        let prefix = String(digits.prefix(3))
        let suffix = String(digits.suffix(2))
        return prefix + "******" + suffix
    }
    
    // 发送验证码并启动倒计时
    private func sendVerifyCode() {

        let requestBody:[String:Any] = [
            "mobile":mobile,
            "sms_event":5,
        ]
        // TODO: 在这里触发真实的验证码发送请求
          NetworkManager.shared.post(APIConstants.Login.getCode, 
                                 businessParameters: requestBody) { (result: Result<CodeResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code.isEqual(to: 1) {
                       print("验证码发送成功")
                        MBProgressHUD.showMessag("验证码已发送，请注意查收", to: nil, afterDelay: 3.0)
                        startCountdown()
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
            }
        }
       
    }
    
    @MainActor private func startCountdown() {
        isSendingCode = true
        countdown = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    isSendingCode = false
                    timer?.invalidate()
                }
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
}
