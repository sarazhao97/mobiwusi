//
//  FeedbackController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/10.
//
import SwiftUI
import Foundation
import PhotosUI
import Photos
import AVFoundation
import AVKit
import CryptoKit


struct FeedbackController:View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var image_url = ""
    @State private var contactInfo = ""
    @State private var showPhotoPicker = false
    @State private var showTips = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var presignedDatas: [PresignedUrlItem] = []
    @State private var errorMessage: String? = nil
    @State private var loading = false

      // 计算文件 SHA256 哈希值
    private func sha256Hex2(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    var body: some View {
      ZStack{
           Color(hex: "#F7F8FA").ignoresSafeArea()
           VStack(alignment:.leading,spacing:10){
            Text("反馈内容")
             .font(.system(size: 14))
             .foregroundColor(Color(hex:"#959998"))
             .padding(.top,30)
            VStack{
                ZStack(alignment:.topLeading){
                    TextEditor(text: $feedbackText)
                    if feedbackText.isEmpty{
                        Text("请在此输入详细问题或意见")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex:"#E6E6E6"))
                            .padding(10)
                    }
                }
                HStack{
                    if image_url.isEmpty{
                        Button(action:{
                            handleImgTap()
                        }){
                        Image("icon_choose_pic")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 120, height: 120)
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                       
                    }else{
                         Button(action:{
                            handleImgTap()
                        }){
                        AsyncImage(url: URL(string: image_url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } placeholder: {
                            Image("icon_choose_pic")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                          
                    }
                    Spacer()
                }
                
            
                 Spacer()
               
            }
            .padding(10)
            .frame(maxWidth:.infinity)
            .frame(height:300)
            .background(Color.white)
            .cornerRadius(10)
           
              Text("联系方式")
             .font(.system(size: 14))
             .foregroundColor(Color(hex:"#959998"))
             .padding(.vertical,10)
            
            ZStack(alignment: .leading) {
                if contactInfo.isEmpty {
                    Text("电话号码/电子邮箱（仅工作人员可见）")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#E6E6E6"))
                }
                TextField("", text: $contactInfo)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#000000"))
            }
            .padding(10)
            .background(Color(hex:"#ffffff"))
            .cornerRadius(5)
           
            Spacer()
             Button(action: {
                 // 提交反馈
                 submitFeedback()
             }) {
                 Text("提交")
                     .font(.system(size: 16))
                     .foregroundColor(.white)
                     .padding(.vertical,14)
                     .frame(maxWidth: .infinity)
                     .background(Color(hex:"#9A1E2E"))
                     .cornerRadius(5)
             }
             .padding(.bottom,20)
           }
           .padding(.horizontal,20)

             if showTips {
                TipsView()
                .zIndex(100)
             }

             if loading {
                ProgressView()
             }

      }
      .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
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
                    uploadImageToServer(image: selectedImage)
                }
            }
        }
      .navigationTitle("意见反馈")
      .navigationBarBackButtonHidden(true)
      .toolbar{
          ToolbarItem(placement: .navigationBarLeading) {
              Button(action: {
                  dismiss()
              }) {
                  Image(systemName: "chevron.left")
                      .foregroundColor(.black)
              }
          }
      }
    }
    //MARK: - 提交反馈
    func submitFeedback() {
       
        let feedbackContent = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !feedbackContent.isEmpty else {
            MBProgressHUD.showMessag("请输入详细问题或意见", to: nil, afterDelay: 1.0)
            return
        }
        let contact = contactInfo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !contact.isEmpty else {
            MBProgressHUD.showMessag("请输入电话号码/电子邮箱", to: nil, afterDelay: 2.0)
            return
        }

        var requestBody: [String: Any] = [
            "content": feedbackContent,
            "contact_info": contact
        ]
         loading = true

        if image_url != nil {
            requestBody["detail_img"] = image_url
        }

         NetworkManager.shared.post(APIConstants.Profile.feedback, 
                                 businessParameters: requestBody) { (result: Result<FeedbackSubmitResponse, APIError>) in
            DispatchQueue.main.async {  
                loading = false
                switch result {
                case .success(let response):
                    if response.code == 1{
                        MBProgressHUD.showMessag("意见反馈提交成功", to: nil, afterDelay: 3.0)
                        dismiss()
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
            }
        }
        
    }

     @ViewBuilder
    func TipsView() -> some View {
              ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showTips = false
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
                        showTips = false
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

    func handleImgTap (){
          let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            // 已有权限，直接打开相册
            showPhotoPicker = true
        case .denied, .restricted:
            // 已拒绝权限，显示提示面板
            showTips = true
        case .notDetermined:
            // 未请求过权限，显示提示面板
            showTips = true
        @unknown default:
            break
        }
    }

       // 上传头像获取预签名URL
    private func uploadImageToServer(image: UIImage?) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ 无法获取图片数据")
            return
        }
        
        // 计算文件哈希值
        let fileHash = sha256Hex2(of: imageData)
        
        // 构建文件信息字典
        let imageItem: [String: Any] = [
            "file_name": "\(UUID().uuidString).jpg",
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
                        performImageUpload(presignedItems: response.data, imageData: imageData)
                        
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

    private func performImageUpload(presignedItems: [PresignedUrlItem], imageData: Data) {
        // 上传图片到预签名URL
        for item in presignedItems {
            putUpload(data: imageData, to: item.upload_url) { success, status, error in
                if success {
                    print("✅ 图片上传成功: \(item)")
                    image_url = item.preview_url
                   
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
    // 请求相册访问权限并打开相册
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            // 已有权限，打开相册
            DispatchQueue.main.async {
                showTips = false
                showPhotoPicker = true
            }
        case .denied, .restricted:
            // 已拒绝权限，跳转到设置
            showTips = false
            openAppSettings()
        case .notDetermined:
            // 未请求过权限，请求权限
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    showTips = false
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
    

    
}
