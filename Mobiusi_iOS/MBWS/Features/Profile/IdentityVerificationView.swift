//
//  IdentityVerificationView.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/12.
//

import SwiftUI
import Foundation
import PhotosUI
import Photos
import AVFoundation
import AVKit
import CryptoKit


struct IdentityVerificationView:View {
    @Environment(\.dismiss) var dismiss
     @State private var showPhotoPicker = false
    @State private var showEditEducation = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var errorMessage: String?
    @State private var presignedDatas: [PresignedUrlItem] = []
    @State private var localFrontImageURL: URL?
    @State private var localReverseImageURL: URL?
    private let displayImageHeight: CGFloat = 200
    @State private var loading = false

     // 新增：区分主页/副页的选择槽位
     private enum LicenceSlot { case main, deputy }
     @State private var activeSlot: LicenceSlot?
     // 新增：分别保存两张图片
     @State private var selectedMainImage: UIImage?
     @State private var selectedDeputyImage: UIImage?
     // 处理点击事件（新增参数：槽位）
     private func handleEducationTap(slot: LicenceSlot) {
         activeSlot = slot
         let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
         switch status {
         case .authorized, .limited:
             showPhotoPicker = true
         case .denied, .restricted:
             showEditEducation = true
         case .notDetermined:
             showEditEducation = true
         @unknown default:
             break
         }
     }

      @ViewBuilder
    func EditEducationView() -> some View {
              ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showEditEducation = false
                }
            // 居中的提示面板
            VStack(spacing: 20) {
                // 标题
                Text("温馨提示")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                // 内容
                Text("为了选择本地图片或者拍照进行上传，我们需要您提供摄像头拍照和读取相册存储的权限。")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#626262"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineSpacing(5)
                
                // 按钮区域
                HStack(spacing: 15) {
                    // 左边按钮：拒绝
                    Button(action: {
                        showEditEducation = false
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

    // 请求相册访问权限并打开相册
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // 已有权限，打开相册
            DispatchQueue.main.async {
                showEditEducation = false
                showPhotoPicker = true
            }
        case .denied, .restricted:
            // 已拒绝权限，跳转到设置
            showEditEducation = false
            openAppSettings()
        case .notDetermined:
            // 未请求过权限，请求权限
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    showEditEducation = false
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

    

  

   

    private func putUpload(data: Data, to url: String, completion: @escaping @Sendable (Bool, Int, Error?) -> Void) {
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


    var body: some View {
        ZStack{
              Color(hex: "#f7f8fa")
               .ignoresSafeArea()
            
             VStack{
                ScrollView(showsIndicators: false){
                VStack(spacing:15){
                    HStack{
                        Text("第1步：请拍摄您的身份证正面")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    HStack{
                        Text("请确保证件边框完整、字体清晰、亮度均匀")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex:"#B4B4B4"))
                        Spacer()
                    }
                    if let localURL = localFrontImageURL, let uiImg = UIImage(contentsOfFile: localURL.path) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: displayImageHeight)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.top,10)
                            .overlay(alignment:.center){
                                VStack(alignment:.center,spacing:20){
                                    Button(action:{
                                        handleEducationTap(slot: .main)
                                    }){
                                        Image("icon_capture")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:70)
                                    }
                                    Text("点击拍摄/上传")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                    } else{
                        Image("身份证-正面")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: displayImageHeight)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.top,10)
                            .overlay(alignment:.center){
                                VStack(alignment:.center,spacing:20){
                                    Button(action:{
                                        handleEducationTap(slot: .main)
                                    }){
                                        Image("icon_capture")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:70)
                                    }
                                    Text("点击拍摄/上传")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                    }
                }
                 .padding(.horizontal, 25)
                .padding(.vertical,25)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal,10)
                VStack(spacing:15){
                    HStack{
                        Text("第2步：请拍摄您的身份证反面")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    HStack{
                        Text("请确保证件边框完整、字体清晰、亮度均匀")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex:"#B4B4B4"))
                        Spacer()
                    }
                    if let localURL = localReverseImageURL, let uiImg = UIImage(contentsOfFile: localURL.path) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: displayImageHeight)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.top,10)
                            .overlay(alignment:.center){
                                VStack(alignment:.center,spacing:20){
                                    Button(action:{
                                        handleEducationTap(slot: .deputy)
                                    }){
                                        Image("icon_capture")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:70)
                                    }
                                    Text("点击拍摄/上传")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                    } else{
                        Image("身份证-反面")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: displayImageHeight)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.top,10)
                            .overlay(alignment:.center){
                                VStack(alignment:.center,spacing:20){
                                    Button(action:{
                                        handleEducationTap(slot: .deputy)
                                    }){
                                        Image("icon_capture")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:70)
                                    }
                                    Text("点击拍摄/上传")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical,25)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal,10)

                Spacer()
                }
                HStack{
                    Spacer()
                    Image("icon_information_encryption")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                    Text("MOBIUSI将对信息智能加密，实时保障信息安全")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex:"#000000"))
                    Spacer()
                }
                Button(action:{
                    loading = true
                    uploadBothAndSubmit()
                }){
                    Text("上传认证")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#9A1E2E"))
                        .cornerRadius(16)
                        .padding(.horizontal,20)
                }
                 
             }
              if showEditEducation {
                EditEducationView()
                .zIndex(100)
            }

            if loading{
                ProgressView()
                
            }
            

        }
          .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) { newValue in
            Task { @MainActor in
                guard let item = newValue else {
                    print("⚠️ selectedPhoto is nil after picker dismissed.")
                    return
                }
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        let uiImage = UIImage(data: data)
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        if let image = uiImage, let jpeg = image.jpegData(compressionQuality: 0.9) {
                            let savedURL = documentsPath.appendingPathComponent("avatar_\(UUID().uuidString).jpg")
                            do {
                                try jpeg.write(to: savedURL)
                                switch activeSlot {
                                case .main:
                                    selectedMainImage = image
                                    localFrontImageURL = savedURL
                                case .deputy:
                                    selectedDeputyImage = image
                                    localReverseImageURL = savedURL
                                case .none:
                                    // 默认回落到主页
                                    localFrontImageURL = savedURL
                                }
                            } catch {
                                print("❌ 写入 Documents 失败: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("❌ Data transferable 返回 nil")
                    }
                
                    // 尝试 URL transferable（某些来源只提供文件 URL）
                    if let url = try await item.loadTransferable(type: URL.self) {
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let imageFileName = "avatar_\(UUID().uuidString).jpg"
                        let destinationURL = documentsPath.appendingPathComponent(imageFileName)
                        do {
                            try FileManager.default.copyItem(at: url, to: destinationURL)
                            switch activeSlot {
                            case .main:
                                localFrontImageURL = destinationURL
                                selectedMainImage = UIImage(contentsOfFile: destinationURL.path)
                            case .deputy:
                                localReverseImageURL = destinationURL
                                selectedDeputyImage = UIImage(contentsOfFile: destinationURL.path)
                            case .none:
                                localFrontImageURL = destinationURL
                            }
                        } catch {
                            print("❌ 复制到 Documents 失败: \(error.localizedDescription)")
                        }
                    } else {
                        print("❌ URL transferable 返回 nil")
                    }
                } catch {
                    print("🧯 加载 transferable 失败: \(error.localizedDescription)")
                }
            }
        }
        .navigationTitle("驾驶证认证")
        .navigationBarBackButtonHidden(true)
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


// 替换：将原基于回调的单图上传改为 async/await，避免在 @Sendable 闭包中捕获非 Sendable 回调
private func requestPresignedAndUpload(image: UIImage) async -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
    let fileHash = sha256Hex2(of: imageData)
    let imageItem: [String: Any] = [
        "file_name": "education_\(UUID().uuidString).jpg",
        "file_size": imageData.count,
        "file_hash": fileHash
    ]
    let filesArray = [imageItem]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: filesArray, options: []),
          let base64String = jsonData.base64EncodedString() as String? else {
        return nil
    }
    let requestBody: [String: Any] = ["files": base64String]
    // 等待预签名结果
    let presignedItem: PresignedUrlItem? = await withCheckedContinuation { continuation in
        NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl, businessParameters: requestBody) { (result: Result<GetPresignedUrlsResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1, let item = response.data.first {
                        continuation.resume(returning: item)
                    } else {
                        continuation.resume(returning: nil)
                    }
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    guard let item = presignedItem else { return nil }
    // 等待上传完成
    let uploadOK: Bool = await withCheckedContinuation { continuation in
        self.putUpload(data: imageData, to: item.upload_url) { success, _, _ in
            continuation.resume(returning: success)
        }
    }
    return uploadOK ? item.path : nil
}

// 更新：串行上传两张图片并提交认证，使用 Task + await
private func uploadBothAndSubmit() {
    Task {
        guard let mainImg = selectedMainImage, let deputyImg = selectedDeputyImage else {
            MBProgressHUD.showMessag("请先选择两张图片", to: nil, afterDelay: 2.0)
            loading = false
            return
        }
        loading = true
        let mainPath = await requestPresignedAndUpload(image: mainImg)
        guard let mainPath else {
            MBProgressHUD.showMessag("主页上传失败", to: nil, afterDelay: 2.0)
            loading = false
            return
        }
        let deputyPath = await requestPresignedAndUpload(image: deputyImg)
        guard let deputyPath else {
            MBProgressHUD.showMessag("副页上传失败", to: nil, afterDelay: 2.0)
            loading = false
            return
        }
        self.submitDriverVerification(mainImageUrl: mainPath, deputyImageUrl: deputyPath)
    }
}

// 新增：提交驾驶证认证（两个参数）
private func submitDriverVerification(mainImageUrl: String, deputyImageUrl: String){
    errorMessage = ""
    let requestBody: [String: Any?] = [
        "auth_type": "1",
        "identity_card_front": mainImageUrl,
        "identity_card_back": deputyImageUrl,
    ]
    NetworkManager.shared.post(APIConstants.Profile.applyVerification, businessParameters: requestBody) { (result: Result<ApplyVerificationResponse, APIError>) in
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                if response.code == 1{
                    MBProgressHUD.showMessag("认证申请已提交，等待审核", to: nil, afterDelay: 3.0)
                    dismiss()
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
}
