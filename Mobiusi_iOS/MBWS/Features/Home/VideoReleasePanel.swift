//
//  TextReleasePanel.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/3.
//

import SwiftUI
import UniformTypeIdentifiers
import CryptoKit
import AVFoundation
import AVKit
import Photos
import UIKit

struct VideoReleasePanel: View {
    var dataItem: IndexItem? = nil
    
    @Environment(\.dismiss) private var dismiss
     init(dataItem: IndexItem? = nil) {
        self.dataItem = dataItem
    }

    @State private var ideaText: String = ""
    @State private var selectedFileURL: URL?
    @State private var isUploading: Bool = false
    @State private var uploadError: String?
    @State private var locationData: [String: [String: [String]]] = [:]
    @State private var location: String = ""
    @State private var showLocationPicker: Bool = false
    @State private var selectedProvince: String = ""
    @State private var selectedCity: String = ""
    @State private var selectedDistrict: String = ""
    @State private var cate_id: Int = 4
    @State private var path: String = ""
    @State private var errorMessage: String = ""
    @State private var showPermissionAlert: Bool = false
    @State private var showVideoRecorder: Bool = false
    @State private var uploadedPreviewURL: URL?
    @State private var uploadedThumbnail: UIImage?
    @State private var showVideoPreview: Bool = false


    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                // 顶部栏
                HStack {
                    Button("取消") { dismiss() }
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: uploadAction) {
                         Text("上传")
                         .font(.system(size: 16,weight:.bold))
                         .foregroundColor(.white)
                         .padding(.vertical,5)
                         .padding(.horizontal,20)
                         .background(Color(hex:"#9A1E2E"))
                         .cornerRadius(10)
                    }
                    .disabled(selectedFileURL == nil || isUploading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack{
                    HStack{
                       if let url = uploadedPreviewURL {
                           if let thumb = uploadedThumbnail {
                            ZStack {
                                 Image(uiImage: thumb)
                                     .resizable()
                                     .scaledToFill()
                                     .frame(width: 120, height: 120)
                                     .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                 // 居中播放按钮
                                 Image("icon_data_play")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 30, height: 30)
                                     
                             }
                             .onTapGesture{
                                 showVideoPreview = true
                               
                             }
                           
                             // 右上角关闭按钮
                             .overlay(alignment: .topTrailing) {
                                 Image("icon_data_close")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 30, height: 30)
                                     .padding(4)
                                     .onTapGesture {
                                         uploadedPreviewURL = nil
                                         uploadedThumbnail = nil
                                     }
                             }
                               
                           } else {
                               Image("占位图")
                                   .resizable()
                                   .scaledToFill()
                                   .frame(width: 120, height: 120)
                                   .overlay(
                                       RoundedRectangle(cornerRadius: 10)
                                   )
                                   .onAppear {
                                       generateVideoThumbnail(from: url) { image in
                                           uploadedThumbnail = image
                                       }
                                   }
                           }
                       } else {
                           Image("icon_data_video_add")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 120, height: 120)
                               .onTapGesture {
                                   checkCameraPermission()
                               }
                               .alert("温馨提示", isPresented: $showPermissionAlert) {
                                   Button("拒绝", role: .cancel) { }
                                   Button("同意") { openSettings() }
                               } message: {
                                   Text("为了选择本地视频或者录制视频进行上传，我们需要您提供摄像头和读取相册存储的权限。")
                               }
                       }
                      Spacer()
                    }
                    .padding(.vertical,10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                 
                     ZStack(alignment: .topLeading) {
                         // 多行文本编辑器
                         TextEditor(text: $ideaText)
                             .font(.system(size: 14))
                             .foregroundColor(Color(hex:"#333333"))
                             .background(Color.clear)
                             .scrollContentBackground(.hidden)
                             .frame(minHeight: 80, maxHeight: 120)
                             .padding(.leading,5)
                         
                         // 占位符文本 - 精确对齐 TextEditor 的文本位置
                         if ideaText.isEmpty {
                             Text("这一刻的想法...")
                                 .font(.system(size: 14))
                                 .foregroundColor(Color(hex:"#B3B3B3"))
                                 .padding(.horizontal, 10)
                                 .padding(.vertical, 8)
                                 .allowsHitTesting(false) // 允许点击穿透到 TextEditor
                         }
                     }
                     .background(Color(hex:"#ffffff"))

                }
                .padding(.horizontal, 16)
                .padding(.vertical,16)
                .frame(maxWidth: .infinity)
                .background(Color(hex:"#ffffff"))
                .cornerRadius(10)
                .padding(.horizontal,16)

                // 位置行
               VStack{
                    HStack{
                         Image("icon_free_location")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 25, height: 25)
                     .foregroundColor(Color(hex:"#9B9B9B"))
                     Text(location.isEmpty ? "不显示位置" : location)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#333333"))
                    Spacer()
                    }
                }
                .padding(15)
                .background(Color(hex:"#ffffff"))
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .onTapGesture {
                    if locationData.isEmpty {
                        loadLocationData()
                    }
                    showLocationPicker = true
                }

                Spacer()
            }
            // 省市区选择器面板
             if showLocationPicker {
                 LocationPickerView(
                     isPresented: $showLocationPicker,
                     locationData: locationData,
                     selectedProvince: $selectedProvince,
                     selectedCity: $selectedCity,
                     selectedDistrict: $selectedDistrict,
                     onConfirm: { province, city, district in
                         let fullLocation = "\(province) \(city) \(district)"
                         location = fullLocation
                         showLocationPicker = false
                     }
                 )
                 .transition(.move(edge: .bottom))
                 .animation(.easeInOut(duration: 0.3), value: showLocationPicker)
             }

             if isUploading{
                 ProgressView()
             }

             if showVideoPreview, let previewString = uploadedPreviewURL?.absoluteString {
                 FullScreenVideoView(videoURL: previewString, isPresented: $showVideoPreview)
             }
        }
         //隐藏导航栏
        .navigationBarHidden(true)
        .onAppear{
             loadLocationData()
        }
        .sheet(isPresented: $showVideoRecorder) {
            VideoCameraRecorder(isPresented: $showVideoRecorder) { url in
                selectedFileURL = url
                path = url.lastPathComponent
                // 录制完成后，直接进行预签名并直传
                getPresignedURL()
            }
        }
      
    }

    private func uploadAction() {
        guard let url = selectedFileURL else { return }
        isUploading = true
        freeUploadData()
       
    }



           //自由上传数据
    func freeUploadData(){
        // 适配视频上传：构造视频元数据并调用自由上传接口
        guard let videoURL = selectedFileURL else { return }
        isUploading = true
        
        // 文件名、扩展名、大小
        let fileName = videoURL.lastPathComponent.isEmpty ? "未知视频" : videoURL.lastPathComponent
        let fileExtension = videoURL.pathExtension.lowercased()
        var fileSize = 0
        if let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path),
           let size = attributes[.size] as? Int {
            fileSize = size
        } else if let data = try? Data(contentsOf: videoURL) {
            fileSize = data.count
        }
        
        // 时长(ms)与分辨率(quality: WxH)
        let asset = AVURLAsset(url: videoURL)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let durationMs = Int((durationSeconds.isFinite ? durationSeconds : 0) * 1000)
        var quality = ""
        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            let width = Int(abs(size.width))
            let height = Int(abs(size.height))
            if width > 0 && height > 0 {
                quality = "\(width)x\(height)"
            }
        }
        
        // 构造 user_data（视频场景）
        let videoDict: [String: Any] = [
            "file_name": fileName,
            "duration": durationMs,
            "format": fileExtension.isEmpty ? "mp4" : fileExtension,
            "size": fileSize,
            "url": path,
            "quality": quality
        ]
        let userDatas: [Any] = [videoDict]
        let userDataStr: String = {
            if let data = try? JSONSerialization.data(withJSONObject: userDatas, options: []),
               let str = String(data: data, encoding: .utf8) {
                return str
            } else { return "[]" }
        }()
        
        var requestBody: [String: Any] = [
            "cate_id": cate_id,
            "idea": ideaText,
            "user_data": userDataStr
        ]

         if let item = dataItem {
            let parentPostID = item.parent_post_id
            let postID = item.post_id
            if !parentPostID.isEmpty {
                requestBody["parent_post_id"] = parentPostID
            } else if !postID.isEmpty {
                requestBody["parent_post_id"] = postID
            }
        }
        
        if !location.isEmpty {
            requestBody["location"] = location
        }
        
        NetworkManager.shared.post(APIConstants.Scene.freeUploadData,
                                   businessParameters: requestBody) { (result: Result<FreeUploadDataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        isUploading = false
                        MBProgressHUD.showMessag("数据上传成功", to: nil, afterDelay: 3.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    } else {
                        isUploading = false
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    isUploading = false
                }
            }
        }
    }

       func  getPresignedURL(){
            guard let fileURL = selectedFileURL else {
                MBProgressHUD.showMessag("请选择要上传的文件", to: nil, afterDelay: 2.0)
                return
            }
            do {
                // 安全域访问，兼容从文件提供者/云盘选择的文件
                let didAccess = fileURL.startAccessingSecurityScopedResource()
                defer { if didAccess { fileURL.stopAccessingSecurityScopedResource() } }
                
                var data: Data?
                var coordError: NSError?
                let coordinator = NSFileCoordinator(filePresenter: nil)
                coordinator.coordinate(readingItemAt: fileURL, options: .withoutChanges, error: &coordError) { url in
                    data = try? Data(contentsOf: url)
                }
                if let e = coordError {
                    throw e
                }
                
                // 兜底：若直接读取失败，尝试拷贝到临时目录再读取（部分文件提供者需要）
                if data == nil {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + "-" + (fileURL.lastPathComponent.isEmpty ? "file" : fileURL.lastPathComponent))
                    do {
                        if FileManager.default.fileExists(atPath: tempURL.path) {
                            try? FileManager.default.removeItem(at: tempURL)
                        }
                        try FileManager.default.copyItem(at: fileURL, to: tempURL)
                        data = try Data(contentsOf: tempURL)
                    } catch {
                        throw error
                    }
                }
                
                guard let fileData = data else {
                    MBProgressHUD.showMessag("无法读取文件数据，请重试或更换文件", to: nil, afterDelay: 2.0)
                    return
                }
                
                let fileName = fileURL.lastPathComponent.isEmpty ? "file_\(UUID().uuidString)" : fileURL.lastPathComponent
                let fileSize = fileData.count
                let fileHash = {
                    let digest = SHA256.hash(data: fileData)
                    return digest.map { String(format: "%02x", $0) }.joined()
                }()
                
                let item: [String: Any] = [
                    "file_name": fileName,
                    "file_size": fileSize,
                    "file_hash": fileHash
                ]
                let filesArray = [item]
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: filesArray, options: []),
                      let base64String = String(data: jsonData.base64EncodedData(), encoding: .utf8) else {
                    MBProgressHUD.showMessag("参数编码失败", to: nil, afterDelay: 2.0)
                    return
                }
                
                let requestBody: [String: Any] = ["files": base64String]
                
                NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl,
                                           businessParameters: requestBody) { (result: Result<GetPresignedUrlsResponse, APIError>) in
                    Task { @MainActor in
                        switch result {
                        case .success(let response):
                            if response.code == 1 {
                                // MBProgressHUD.showMessag("预签名获取成功", to: nil, afterDelay: 1.0)
                                print("✅ 预签名获取成功：\(response.data.first?.upload_url ?? "")")
                                path = response.data.first?.path ?? ""
                                // 直传文档到预签名URL
                                performDocumentUploads(presignedItems: response.data, fileData: fileData)
                            } else {
                                MBProgressHUD.showMessag(response.msg, to: nil, afterDelay: 2.0)
                            }
                        case .failure(let error):
                            MBProgressHUD.showMessag(error.localizedDescription, to: nil, afterDelay: 2.0)
                        }
                    }
                }
            } catch {
                MBProgressHUD.showMessag("读取文件失败：\(error.localizedDescription)", to: nil, afterDelay: 2.0)
            }
        }
        
        // 文档直传到预签名URL（参照音频上传实现）
        func performDocumentUploads(presignedItems: [PresignedUrlItem], fileData: Data) {
            for item in presignedItems {
                let uploadURLString = item.upload_url
                let fileName = item.file_name
                let previewURL = item.preview_url
                let fileId = item.file_id
                
                guard let uploadURL = URL(string: uploadURLString) else {
                    print("❌ 无效的上传URL: \(uploadURLString)")
                    continue
                }
                
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "PUT"
                // 说明：阿里云 OSS 预签名通常会将 Content-Type 纳入签名字符串，
                // 如服务端未按相同值生成签名，客户端设置该头会导致 403。
                // 因此，这里不再设置 Content-Type，直接按预签名默认策略上传。
                // request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.uploadTask(with: request, from: fileData) { data, response, error in
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let success = (200...299).contains(statusCode)
                    Task { @MainActor in
                        if success {
                            print("✅ 视频上传成功: \(fileName)")
                            print("🔗 预览URL: \(previewURL)")
                            print("🆔 文件ID: \(fileId)")
                            uploadedPreviewURL = URL(string: previewURL)
                            if let u = uploadedPreviewURL {
                                generateVideoThumbnail(from: u) { image in
                                    uploadedThumbnail = image
                                }
                            }
                            MBProgressHUD.showMessag("视频上传成功", to: nil, afterDelay: 1.0)
                        } else {
                            let body = String(data: data ?? Data(), encoding: .utf8) ?? ""
                            print("❌ 视频上传失败: \(fileName), 状态码: \(statusCode)")
                            if let error = error { print("❌ 错误详情: \(error)") }
                            if !body.isEmpty { print("❌ 响应体: \(body)") }
                            MBProgressHUD.showMessag("视频上传失败(\(statusCode))", to: nil, afterDelay: 2.0)
                        }
                    }
                }
                task.resume()
            }
        }

      func loadLocationData() {
        // 优先从 app bundle 读取
        if let url = Bundle.main.url(forResource: "pca-code", withExtension: "json") {
            if let data = try? Data(contentsOf: url), let parsed = parseLocationJSON(data: data) {
                locationData = parsed
                return
            }
        }
        
        // 开发环境兜底：尝试使用工程绝对路径（真机不可用，建议加入Bundle）
        // let devPath = "/Users/mobios/Downloads/MBWS/Mobiusi_iOS/Mobiusi_iOS/MBWS/Core/Utils/province-city-district.json"
        let devPath = Bundle.main.path(forResource: "pca-code", ofType: "json") ?? ""
        if FileManager.default.fileExists(atPath: devPath),
           let data = try? Data(contentsOf: URL(fileURLWithPath: devPath)),
           let parsed = parseLocationJSON(data: data) {
            locationData = parsed
            return
        }
    }

       /// 兼容两种常见结构：
    /// 1) 字典结构: { "省": { "市": ["区"] } }
    /// 2) 对象数组: [ { name: 省, city/cities/children: [ { name: 市, area/districts/children: [区] } ] } ]
    func parseLocationJSON(data: Data) -> [String: [String: [String]]]? {
        // 先尝试简单字典结构解码
        if let dict = try? JSONDecoder().decode([String: [String: [String]]].self, from: data) {
            return dict
        }
        
        // 退回到通用解析
        guard let json = try? JSONSerialization.jsonObject(with: data, options: [] ) else { return nil }
        
        var result: [String: [String: [String]]] = [:]
        
        if let arr = json as? [[String: Any]] {
            for p in arr {
                let provinceName = (p["name"] as? String)
                    ?? (p["province"] as? String)
                    ?? (p["label"] as? String)
                    ?? (p["text"] as? String)
                guard let provinceName else { continue }
                
                let citiesAny = (p["city"] as? [Any])
                    ?? (p["cities"] as? [Any])
                    ?? (p["children"] as? [Any])
                    ?? (p["items"] as? [Any])
                guard let citiesAny else { continue }
                
                var cityMap: [String: [String]] = [:]
                for cAny in citiesAny {
                    guard let c = cAny as? [String: Any] else { continue }
                    let cityName = (c["name"] as? String)
                        ?? (c["city"] as? String)
                        ?? (c["label"] as? String)
                        ?? (c["text"] as? String)
                    guard let cityName else { continue }
                    
                    let districtsAny = (c["area"] as? [Any])
                        ?? (c["districts"] as? [Any])
                        ?? (c["children"] as? [Any])
                        ?? (c["items"] as? [Any])
                        ?? []
                    let districts = districtsAny.compactMap { (d) -> String? in
                        if let s = d as? String { return s }
                        if let dd = d as? [String: Any] {
                            return (dd["name"] as? String)
                                ?? (dd["label"] as? String)
                                ?? (dd["text"] as? String)
                        }
                        return nil
                    }
                    cityMap[cityName] = districts
                }
                result[provinceName] = cityMap
            }
            return result
        }
        
        if let dict = json as? [String: Any] { // 也可能顶层是字典包裹
            var resultTop: [String: [String: [String]]] = [:]
            for (provinceName, cityVal) in dict {
                guard let cityDict = cityVal as? [String: Any] else { continue }
                var cityMap: [String: [String]] = [:]
                for (cityName, districtsVal) in cityDict {
                    if let arr = districtsVal as? [String] {
                        cityMap[cityName] = arr
                    } else if let arrAny = districtsVal as? [Any] {
                        let districts = arrAny.compactMap { $0 as? String }
                        cityMap[cityName] = districts
                    }
                }
                resultTop[provinceName] = cityMap
            }
            return resultTop
        }
        
        return nil
    }
}

   



extension VideoReleasePanel {
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showVideoRecorder = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showVideoRecorder = true }
                    else { showPermissionAlert = true }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }

    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}


// 系统相机录像（UIImagePickerController 封装）
struct VideoCameraRecorder: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onPicked: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.movie.identifier]
        picker.cameraCaptureMode = .video
        picker.videoQuality = .typeHigh
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoCameraRecorder
        init(parent: VideoCameraRecorder) { self.parent = parent }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.onPicked(url)
            }
            parent.isPresented = false
        }
    }
}


// 生成视频首帧缩略图
func generateVideoThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: 0.1, preferredTimescale: 600)
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async { completion(uiImage) }
        } catch {
            DispatchQueue.main.async { completion(nil) }
        }
    }
}

