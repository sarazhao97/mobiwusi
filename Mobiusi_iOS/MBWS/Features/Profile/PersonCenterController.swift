//
//  personCenterController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/24.
//

import SwiftUI
import Foundation
import PhotosUI
import Photos
import AVFoundation
import AVKit
import CryptoKit

// MARK: - 自定义进度条
struct customProgressBar: View {
    let progress: Double  // 进度值 0.0 - 1.0
    let filledColor: Color  // 已填充颜色
    let unfilledColor: Color  // 未填充颜色
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景条
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#D03230").opacity(0.1))
                    .frame(width: geometry.size.width,height:10)
                    .cornerRadius(5)
                
                // 已填充部分
                if progress > 0 {
                    let filledWidth = geometry.size.width * max(0, min(1, progress))
                        HStack(spacing: 0) {
                            // 进度条
                            RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#9A1E2E"))
                                    .frame(width: filledWidth, height: 10)
                                     .cornerRadius(5)
                                    
                        }
                        
                   
                }
            }
        }
        .frame(height: 10)
    }
}

struct PersonCenterController:View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileData: UserProfileData?
    @State private var showEditAvatar = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var errorMessage: String?
    @State private var isUploading: Bool = false
    @State private var presignedDatas: [PresignedUrlItem] = []
    @State private var showEditNickname: Bool = false
    @State private var nickname: String = ""
    
    
    // 处理头像点击事件
    private func handleAvatarTap() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // 已有权限，直接打开相册
            showPhotoPicker = true
        case .denied, .restricted:
            // 已拒绝权限，显示提示面板
            showEditAvatar = true
        case .notDetermined:
            // 未请求过权限，显示提示面板
            showEditAvatar = true
        @unknown default:
            break
        }
    }
    
    // 请求相册访问权限并打开相册
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // 已有权限，打开相册
            DispatchQueue.main.async {
                showEditAvatar = false
                showPhotoPicker = true
            }
        case .denied, .restricted:
            // 已拒绝权限，跳转到设置
            showEditAvatar = false
            openAppSettings()
        case .notDetermined:
            // 未请求过权限，请求权限
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    showEditAvatar = false
                    if newStatus == .authorized || newStatus == .limited {
                        showPhotoPicker = true
                    }
                    // 如果用户拒绝，面板已关闭，不执行任何操作
                }
            }
        @unknown default:
            break
        }
    }
    
    // 跳转到系统设置中的应用权限管理页面
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                DispatchQueue.main.async {
                    if success {
                        print("成功跳转到系统设置")
                    } else {
                        print("跳转到系统设置失败")
                    }
                }
            }
        }
    }
    
    // 计算文件 SHA256 哈希值
    private func sha256Hex2(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    // 上传头像获取预签名URL
    private func uploadAvatarToServer(image: UIImage?) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ 无法获取图片数据")
            return
        }
        
        // 计算文件哈希值
        let fileHash = sha256Hex2(of: imageData)
        
        // 构建文件信息字典
        let imageItem: [String: Any] = [
            "file_name": "avatar_\(UUID().uuidString).jpg",
            "file_size": imageData.count,
            "file_hash": fileHash
        ]
        
        let filesArray = [imageItem]
        
        // 将文件信息转换为 JSON 并 Base64 编码
        guard let jsonData = try? JSONSerialization.data(withJSONObject: filesArray, options: []),
              let base64String = jsonData.base64EncodedString() as String? else {
            print("❌ 无法将文件信息转换为 Base64")
            return
        }

        let requestBody: [String: Any] = [
            "files": base64String
        ]
             NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl, 
                                 businessParameters: requestBody) { (result: Result<GetPresignedUrlsResponse, APIError>) in
            DispatchQueue.main.async {
               
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        //预签名url返回数据
                        presignedDatas = response.data
                        print("✅ 图片预签名url返回数据: \(response.data)")
                        // updateAvatarToServer(path: response.data[0].path)
                           // 上传图片到预签名URL
                        performAvatarUpload(presignedItems: response.data, imageData: imageData)
                        
                    } else {
                        errorMessage = response.msg
                        print("❌ 获取预签名URL失败: \(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("❌ 获取预签名URL异常: \(error.localizedDescription)")
                }
            }
        }
        
      
    }

    private func performAvatarUpload(presignedItems: [PresignedUrlItem], imageData: Data) {
        // 上传图片到预签名URL
        for item in presignedItems {
            putUpload(data: imageData, to: item.upload_url) { success, status, error in
                if success {
                    print("✅ 图片上传成功: \(item)")
                    updateAvatarToServer(path: item.path)
                } else {
                    self.errorMessage = error?.localizedDescription
                    MBProgressHUD.showMessag("\(error?.localizedDescription ?? "上传失败")", to: nil, afterDelay: 3.0)
                }
            }
        }
    }

 

    private func putUpload(data: Data, to url: String, completion: @escaping (Bool, Int, Error?) -> Void) {
        guard let uploadURL = URL(string: url) else {
            print("❌ 上传URL无效: \(url)")
            completion(false, -1, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "上传URL无效"]))
            return
        }
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        // 注意：不设置 Content-Type 头，因为预签名 URL 已经包含了签名
        // 添加额外的头会导致签名验证失败（403错误）
        
        print("📤 开始上传文件到: \(url)")
        print("📦 文件大小: \(data.count) 字节")
        
        // 使用 uploadTask 而不是 dataTask
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 上传失败: \(error.localizedDescription)")
                    completion(false, -1, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ 上传失败: 无效的响应")
                    completion(false, -1, NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应"]))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                print("📊 上传响应状态码: \(statusCode)")
                
                if (200...299).contains(statusCode) {
                    print("✅ 文件上传成功")
                    completion(true, statusCode, nil)
                } else {
                    let errorMsg = "上传失败，HTTP状态码: \(statusCode)"
                    print("❌ \(errorMsg)")
                    completion(false, statusCode, NSError(domain: "UploadFailed", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                }
            }
        }
        task.resume()
    }

    //修改头像
    private func updateAvatarToServer(path: String) {
        isUploading = true
         let requestBody: [String: Any] = [
                "avatar": path,
            ]
            NetworkManager.shared.post(APIConstants.Profile.editUserInfo, 
                            businessParameters: requestBody) { (result: Result<UpdateUserInfoResponse, APIError>) in
            DispatchQueue.main.async {
                isUploading = false         
                switch result {
                case .success(let response):
                    if response.code == 1{
                       MBProgressHUD.showMessag("个人信息修改成功", to: nil, afterDelay: 3.0)
                       fetchMyData()
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(response.msg)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
            }
        }
        
    }
    
    //修改昵称
    private func updateNicknameToServer() {
        guard !nickname.isEmpty else {
            MBProgressHUD.showMessag("昵称不能为空", to: nil, afterDelay: 2.0)
            return
        }
        
        isUploading = true
        let requestBody: [String: Any] = [
            "name": nickname,
        ]
        
        NetworkManager.shared.post(APIConstants.Profile.editUserInfo, 
                        businessParameters: requestBody) { (result: Result<UpdateUserInfoResponse, APIError>) in
            DispatchQueue.main.async {
                isUploading = false         
                switch result {
                case .success(let response):
                    if response.code == 1{
                       MBProgressHUD.showMessag("个人信息修改成功", to: nil, afterDelay: 3.0)
                       fetchMyData()
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(response.msg)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

      private func fetchMyData() {    
        errorMessage = nil
       
        NetworkManager.shared.post(APIConstants.Profile.getMyData, businessParameters: [:]) { (result: Result<UserProfileResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        profileData = response.data
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
  

   
    @ViewBuilder
    func EditAvatarView() -> some View {
              ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showEditAvatar = false
                }
            // 居中的提示面板
            VStack(spacing: 20) {
                // 标题
                Text("温馨提示")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                // 内容
                Text("为了选择本地图片或者拍照进行上传，我们需要您提供摄像头拍照和读取相册存储的权限")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#626262"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineSpacing(5)
                
                // 按钮区域
                HStack(spacing: 15) {
                    // 左边按钮：拒绝
                    Button(action: {
                        showEditAvatar = false
                    }) {
                        Text("拒绝")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(hex: "#F5F5F5"))
                            .cornerRadius(8)
                    }
                    
                    // 右边按钮：同意
                    Button(action: {
                        requestPhotoLibraryPermission()
                    }) {
                        Text("同意")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
              }
             
        
    }

    @ViewBuilder
    func EditNicknameView(nickname: Binding<String>) -> some View {
    
          ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showEditNickname = false
                }
             // 居中的提示面板
            VStack(spacing: 20) {
                   // 标题
                Text("修改昵称")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)
                TextField("请输入昵称", text: nickname)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                
                HStack(spacing: 15) {
                    // 取消按钮
                    Button(action: {
                        showEditNickname = false
                    }) {
                        Text("取消")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(hex: "#F5F5F5"))
                            .cornerRadius(8)
                    }
                    
                    // 确定按钮
                    Button(action: {
                        updateNicknameToServer()
                        showEditNickname = false
                    }) {
                        Text("确定")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
             .frame(width: UIScreen.main.bounds.width - 60)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
              }
          }
    

    var body: some View {
          NavigationView {
        ZStack{
             Color(hex: "#F7F8FA").ignoresSafeArea()
             VStack{
               VStack(alignment:.leading,spacing:50){
                  HStack{
                    Text("头像")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    AsyncImage(url: URL(string: profileData?.avatar ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    } placeholder: {
                        Image("icon_default_avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                  }
                  .contentShape(Rectangle())
                  .onTapGesture {
                    handleAvatarTap()
                  }
                  HStack{
                     Text("昵称")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    HStack{
                        Text(profileData?.name ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                  }
                  .contentShape(Rectangle())
                  .onTapGesture{
                    nickname = profileData?.name ?? ""
                    showEditNickname = true
                  }
                  HStack{
                     Text("Tomo")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Text(profileData?.moid ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                  }
                 HStack{
                     Text("账户管理")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                     Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                  }
                  .contentShape(Rectangle())
                  .onTapGesture{
                       Task { @MainActor in
                                let vc = UIHostingController(
                                    rootView: AccountManageController(mobile:profileData?.mobile ?? "",openid:profileData?.openid ?? "",alipay_openid:profileData?.alipay_openid ?? "")
                                    .toolbar(.hidden, for: .navigationBar)
                                    .toolbarColorScheme(.dark)
                                )
                                vc.hidesBottomBarWhenPushed = true
                                MOAppDelegate().transition.push(vc, animated: true)
                        }
                  }
                  VStack(spacing:20){
                     HStack{
                        Text("我的空间")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(profileData?.zone_size_used_txt ?? "")/\(profileData?.zone_size_total_txt ?? "")")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    customProgressBar(
                        progress: Double(profileData?.zone_size_used ?? 0) / Double(profileData?.zone_size_total ?? 1),
                        filledColor: Color(hex: "#9A1E2E"),
                        unfilledColor: Color(hex: "#F9EAE9")
                    )
                  }
                

               }
               .padding(20)
               .frame(maxWidth: .infinity)
               .background(Color.white)
               .cornerRadius(10)
               .padding(.horizontal,10)
               Spacer()
             }

             if showEditAvatar {
                EditAvatarView()
                .zIndex(100)
             }

             if showEditNickname {
                EditNicknameView(nickname: $nickname)
                .zIndex(110)
             }
        }
        .navigationTitle("个人中心")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                       
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
         .onAppear{
                fetchMyData()
              }
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let item = newValue {
                    // 方法1: 获取图片数据
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImage = UIImage(data: data)
                        print("✅ 图片数据已加载")
                        print("📸 图片大小: \(data.count) 字节")
                    }
                    
                    // 方法2: 获取图片的 URL（临时路径）
                    if let url = try? await item.loadTransferable(type: URL.self) {
                        print("📁 图片临时路径: \(url.path)")
                        
                        // 将图片复制到应用的 Documents 目录
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let imageFileName = "avatar_\(UUID().uuidString).jpg"
                        let destinationURL = documentsPath.appendingPathComponent(imageFileName)
                        
                        // 复制文件
                        try? FileManager.default.copyItem(at: url, to: destinationURL)
                        print("💾 图片已保存到: \(destinationURL.path)")
                    }
                    
                    // 方法3: 直接将图片上传到服务器
                    uploadAvatarToServer(image: selectedImage)
                }
            }
        }
          }
       
    }


}
