
//
//  TextReleasePanel.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/3.
//

import SwiftUI
import UniformTypeIdentifiers
import CryptoKit

struct TextReleasePanel: View {
  var dataItem: IndexItem? = nil
    @Environment(\.dismiss) private var dismiss
     init(dataItem: IndexItem? = nil) {
        self.dataItem = dataItem
    }

    @State private var ideaText: String = ""
    @State private var showFileImporter: Bool = false
    @State private var selectedFileURL: URL?
    @State private var isUploading: Bool = false
    @State private var uploadError: String?
    @State private var locationData: [String: [String: [String]]] = [:]
    @State private var location: String = ""
    @State private var showLocationPicker: Bool = false
    @State private var selectedProvince: String = ""
    @State private var selectedCity: String = ""
    @State private var selectedDistrict: String = ""
    @State private var cate_id: Int = 3
    @State private var path: String = ""
    @State private var errorMessage: String = ""

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
                        if selectedFileURL == nil {
                            Spacer()
                             Image("icon_file_add")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            Text("本地上传")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.gray)
                            Spacer()
                        }else{
                        if let url = selectedFileURL {
                             Image("icon_wb@3x_3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                           
                        Text(url.lastPathComponent)
                        .font(.footnote)
                        .foregroundColor(Color(hex:"#000000"))
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.leading, -10)
                        Spacer()
                        Button(action: { selectedFileURL = nil }) {
                            Image("icon_data_close")
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 15, height: 15)
                        }
                        }
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex:"#EDEEF5"))
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                    .onTapGesture{
                        showFileImporter = true
                    }
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
        }
         //隐藏导航栏
        .navigationBarHidden(true)
        .onAppear{
             loadLocationData()
        }
        // 系统文件选择器
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFileURL = urls.first
                getPresignedURL()
            case .failure(let error):
                selectedFileURL = nil
                uploadError = error.localizedDescription
            }
        }
        .alert("上传失败", isPresented: .constant(uploadError != nil)) {
            Button("好", role: .cancel) { uploadError = nil }
        } message: {
            Text(uploadError ?? "")
        }
    }

    private func uploadAction() {
        guard let url = selectedFileURL else { return }
        if ideaText.isEmpty {
            MBProgressHUD.showMessag("说一说这一刻的想法", to: nil, afterDelay: 1.0)
            return
        }
        isUploading = true
        freeUploadData()
       
    }

       //自由上传数据
    func freeUploadData(){
        isUploading = true
        
        // 构造 user_data（文本发布场景）
        var userDatas: [[String: Any]] = []
        
        // 如果有选择文件，添加文件信息
        if let fileURL = selectedFileURL {
            let fileName = fileURL.lastPathComponent.isEmpty ? "未知文件" : fileURL.lastPathComponent
            let fileExtension = fileURL.pathExtension.lowercased()
            
            // 尝试获取文件大小
            var fileSize = 0
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let size = attributes[.size] as? Int {
                fileSize = size
            }
            
            let fileDict: [String: Any] = [
                "type": "file",
                "file_name": fileName,
                "format": fileExtension.isEmpty ? "unknown" : fileExtension,
                "size": fileSize,
                "url": path // 使用显示的文件名或路径
            ]
            userDatas.append(fileDict)
        }
        
        // 如果有文本内容，添加文本信息
        if !ideaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let textDict: [String: Any] = [
                "type": "text",
                "content": ideaText,
                "length": ideaText.count
            ]
            userDatas.append(textDict)
        }
        
        let userDataStr: String = {
            if let data = try? JSONSerialization.data(withJSONObject: userDatas, options: []),
               let str = String(data: data, encoding: .utf8) {
                return str
            } else { return "[]" }
        }()
        
        var requestBody: [String: Any] = [
            "cate_id": cate_id,
            "idea": ideaText, // 使用文本内容作为想法
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

        if !location.isEmpty{
            requestBody["location"] = location
        }

        
        
        NetworkManager.shared.post(APIConstants.Scene.freeUploadData, 
                                 businessParameters: requestBody) { (result: Result<FreeUploadDataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                      
                        isUploading = false
                        MBProgressHUD.showMessag("数据上传成功", to: nil, afterDelay: 3.0)
                         // 稍作延时，避免 HUD 覆盖动画冲突
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
                // 可选：设置Content-Type为octet-stream，部分存储不要求
                // request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.uploadTask(with: request, from: fileData) { _, response, error in
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let success = (200...299).contains(statusCode)
                    Task { @MainActor in
                        if success {
                            print("✅ 文档上传成功: \(fileName)")
                            print("🔗 预览URL: \(previewURL)")
                            print("🆔 文件ID: \(fileId)")
                            MBProgressHUD.showMessag("文档上传成功", to: nil, afterDelay: 1.0)
                        } else {
                            print("❌ 文档上传失败: \(fileName), 状态码: \(statusCode)")
                            if let error = error { print("❌ 错误详情: \(error)") }
                            MBProgressHUD.showMessag("文档上传失败(\(statusCode))", to: nil, afterDelay: 2.0)
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

struct UploadPanelView_Previews: PreviewProvider {
    static var previews: some View {
        TextReleasePanel()
    }
}