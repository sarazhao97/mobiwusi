import Foundation
import Security

// MARK: - 通知名称扩展
extension Notification.Name {
    static let loginRequired = Notification.Name("loginRequired")
}

final class NetworkManager: @unchecked Sendable {
    static let shared = NetworkManager()
    private init() {}
    
    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - POST 请求（自动生成 timestamp + data + sign）
    func post<T: Decodable>(_ endpoint: String,
                            businessParameters: [String: Any?],
                            completion: @escaping @Sendable (Result<T, APIError>) -> Void) {
        
        // 构建完整 URL
        guard let baseURL = URL(string: APIConstants.baseURL),
              let url = URL(string: endpoint, relativeTo: baseURL)?.absoluteURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 处理 Optional/nil，生成安全字典
        let safeParams = sanitizeParameters(businessParameters)
        
        // 生成请求体：timestamp + data + sign
        guard let body = makeRequestBody(dataDict: safeParams),
              let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(.encodingError("请求参数序列化失败")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 自动添加token到请求头
        if let token = getCurrentUserToken() {
            request.setValue("\(token)", forHTTPHeaderField: "token")
            #if DEBUG
            print("Token已添加到请求头: \(token)")
            #endif
        } else {
            #if DEBUG
            print("警告: 未找到token，请求可能失败")
            #endif
        }
        
        // 添加其他请求头
        addCommonHeaders(to: &request)
        
        request.httpBody = jsonData
        
        #if DEBUG
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("请求 URL: \(url.absoluteString)")
            print("请求 JSON: \(jsonString)")
            
            // 打印所有请求头
            print("请求头信息:")
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                print("  \(key): \(value)")
            }
        }
        #endif
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResponse(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
    }
    
    // MARK: - 添加通用请求头
    private func addCommonHeaders(to request: inout URLRequest) {
        // app-version: 应用版本
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(appVersion, forHTTPHeaderField: "app-version")
        }
        
        // device-version: 系统版本
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
        request.setValue(versionString, forHTTPHeaderField: "device-version")
        
        // system-id: 系统ID
        request.setValue("1", forHTTPHeaderField: "system-id")
        
        // os: 操作系统
        request.setValue("ios", forHTTPHeaderField: "os")
        
        // device-brand: 设备品牌和型号
        let deviceModel = getDeviceModel()
        let deviceName = getDeviceName()
        let deviceBrand = "\(deviceModel)_\(deviceName)"
        request.setValue(deviceBrand, forHTTPHeaderField: "device-brand")
        
        // think-lang: 语言设置
        let currentLanguage = Locale.current.identifier.lowercased()
        let isChinese = currentLanguage.contains("zh_cn") || currentLanguage.contains("zh-hans")
        request.setValue(isChinese ? "zh_cn" : "en", forHTTPHeaderField: "think-lang")
    }
    
    // MARK: - 获取设备信息（避免主线程隔离问题）
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private func getDeviceName() -> String {
        return "iPhone" // 简化处理，避免主线程隔离问题
    }
    
    // MARK: - 去除 nil / Optional
    private func sanitizeParameters(_ dict: [String: Any?]) -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in dict {
            if let value = value {
                result[key] = value
            }
        }
        return result
    }
    
    // MARK: - 生成请求体
    private func makeRequestBody(dataDict: [String: Any]) -> [String: Any]? {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        
        // JSON 编码
        guard let dataJson = try? JSONSerialization.data(withJSONObject: dataDict, options: []),
              let dataString = String(data: dataJson, encoding: .utf8) else {
            print("dataDict 序列化失败")
            return nil
        }
        print("dataJson 字符串: \(dataString)")
        
        // 使用标准Base64编码方式，显式指定编码选项
        let dataBase64 = Data(dataString.utf8).base64EncodedString(options: [])
        print("dataBase64: \(dataBase64)")
        
        // 拼接待签名字符串
        let stringToSign = "data=\(dataBase64)&timestamp=\(timestamp)"
        
        // 生成签名
        guard let signature = sign(string: stringToSign) else {
            print("签名失败")
            return nil
        }
        
        return [
            "timestamp": timestamp,
            "data": dataBase64,
            "sign": signature
        ]
    }
    
    // MARK: - RSA 签名
    private func sign(string: String) -> String? {
        guard let privateKey = loadPrivateKey(pem: APIConstants.privateKeyPEM),
              let data = string.data(using: .utf8) else {
            print("私钥加载失败")
            return nil
        }
        
        // 输出私钥信息
        print("私钥加载成功: \(privateKey)")
      
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA1,
            data as CFData,
            &error
        ) as Data? else {
            print("签名失败:", error?.takeRetainedValue() ?? "未知错误")
            return nil
        }
        
        // 签名结果使用标准Base64编码
        return signature.base64EncodedString(options: [])
    }
    
    // MARK: - 加载私钥
    func loadPrivateKey(pem: String) -> SecKey? {
        // 直接解码 Base64 字符串为 DER 数据
            guard let derData = Data(base64Encoded: pem, options: .ignoreUnknownCharacters) else {
                print("Base64 解码失败")
                return nil
            }
            
            // 如果是 PKCS#8 格式，进行 unwrap 到 PKCS#1（否则直接用 derData）
            let pkcs1Data = unwrapPkcs8ToPkcs1(derData: derData) ?? derData
            
            let attributes: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits: 2048 // 替换为你的密钥位数，如 1024 或 2048
            ]
            
            var error: Unmanaged<CFError>?
            let privateKey = SecKeyCreateWithData(pkcs1Data as CFData, attributes as CFDictionary, &error)
            if let error = error?.takeRetainedValue() {
                print("导入私钥失败: \(error)")
                return nil
            }
            return privateKey
    }
    
    func unwrapPkcs8ToPkcs1(derData: Data) -> Data? {
        // PKCS#8 结构: SEQUENCE { INTEGER(0), SEQUENCE { OID(rsaEncryption), NULL }, OCTET STRING (PKCS#1) }
        var index = 0
        let bytes = [UInt8](derData)
        
        // 检查 SEQUENCE (0x30)
        if bytes[index] != 0x30 { return nil }
        index += 1
        
        // 跳过长度字段 (假设短长度 < 128)
        let lengthByte = bytes[index]
        index += 1
        if lengthByte > 0x80 { // 长长度，跳过额外字节
            let lenBytes = Int(lengthByte & 0x7F)
            index += lenBytes
        }
        
        // 跳过版本 INTEGER(0)
        if bytes[index] == 0x02 { // INTEGER
            index += 1 // 类型
            index += 1 // 长度 (假设1)
            index += 1 // 值(0)
        } else { return nil }
        
        // 跳过算法 SEQUENCE { OID 1.2.840.113549.1.1.1, NULL }
        if bytes[index] == 0x30 { // SEQUENCE
            index += 1
            let algLen = Int(bytes[index])
            index += 1 + algLen // 跳过整个算法部分
        } else { return nil }
        
        // 现在是 OCTET STRING (0x04)
        if bytes[index] != 0x04 { return nil }
        index += 1
        
        // 获取长度
        var octLen = Int(bytes[index])
        index += 1
        if octLen > 0x80 { // 长长度
            let lenBytes = octLen & 0x7F
            octLen = 0
            for _ in 0..<lenBytes {
                octLen = (octLen << 8) + Int(bytes[index])
                index += 1
            }
        }
        
        // 提取 PKCS#1 数据
        let pkcs1Data = Data(bytes[index..<index + octLen])
        return pkcs1Data
    }
    
    func encryptData(_ data: Data, with publicKey: SecKey) -> Data? {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            print("算法不支持")
            return nil
        }
        
        // 检查数据长度（必须小于密钥大小减填充开销）
        let blockSize = SecKeyGetBlockSize(publicKey)
        guard data.count < blockSize - 130 else { // 对于 OAEP，预留空间
            print("数据太长")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data?
        if let error = error?.takeRetainedValue() {
            print("加密失败: \(error)")
        }
        return encryptedData
    }
    
    // MARK: - 处理响应
    private func handleResponse<T: Decodable>(data: Data?,
                                              response: URLResponse?,
                                              error: Error?,
                                              completion: @escaping (Result<T, APIError>) -> Void) {
        
        // #if DEBUG
        if let data = data, let str = String(data: data, encoding: .utf8) {
            print("接口返回: \(str)")
        }
        // #endif
        
        if let error = error {
            completion(.failure(.networkError(error.localizedDescription)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // #if DEBUG
        print("响应状态码: \(httpResponse.statusCode)")
        // #endif
        
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        // 首先检查响应中的 code 字段
        if let codeResponse = try? JSONDecoder().decode(CodeResponse.self, from: data) {
            if codeResponse.code.isEqual(to: 2) || codeResponse.code.isEqual(to: "2") {
                // code = 2 表示需要重新登录
                DispatchQueue.main.async {
                    self.handleLoginRequired()
                }
                completion(.failure(.loginRequired))
                return
            }
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decoded))
        } catch {
            print("JSON解析失败 - 错误类型: \(type(of: error))")
            print("JSON解析失败 - 错误描述: \(error)")
            print("JSON解析失败 - 本地化描述: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("解码错误详情: \(decodingError)")
            }
            completion(.failure(.decodingError(error.localizedDescription)))
        }
    }
    
    // MARK: - Token 管理
    private func getCurrentUserToken() -> String? {
        // 通过 Objective-C 桥接访问 MOUserModel
        let userModel = MOUserModel.unarchive()
        if userModel != nil {
            #if DEBUG
            print("从 MOUserModel 获取到用户信息:")
            print("  用户ID: \(userModel.modelId ?? "nil")")
            print("  用户名: \(userModel.name ?? "nil")")
            print("  Token: \(userModel.token ?? "nil")")
            #endif
            return userModel.token
        } else {
            #if DEBUG
            print("未找到已保存的用户信息")
            #endif
        }
        return nil
    }
    
    // MARK: - 检查登录状态
    func isUserLoggedIn() -> Bool {
        return getCurrentUserToken() != nil
    }
    
    // MARK: - 清除用户数据（退出登录）
    func clearUserData() {
        MOUserModel.remove()
        #if DEBUG
        print("用户数据已清除")
        #endif
    }
    
    // MARK: - 处理需要重新登录的情况
    private func handleLoginRequired() {
        // 清除用户数据
        clearUserData()
        
        // 发送通知，让应用跳转到登录页面
        NotificationCenter.default.post(name: .loginRequired, object: nil)
        
        #if DEBUG
        print("检测到需要重新登录，已清除用户数据并发送通知")
        #endif
    }
    
    // MARK: - 上传文件（multipart/form-data，包含 timestamp/data/sign 与可选参数）
    func uploadFile<T: Decodable>(fileURL: URL,
                                  endpoint: String,
                                  isConvertWav: Int? = nil,
                                  lat: String? = nil,
                                  lng: String? = nil,
                                  completion: @escaping (Result<T, APIError>) -> Void) {
        // 构建完整 URL
        guard let baseURL = URL(string: APIConstants.baseURL),
              let url = URL(string: endpoint, relativeTo: baseURL)?.absoluteURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 业务参数（可选）
        let businessParams: [String: Any?] = [
            "is_convert_wav": isConvertWav,
            "lat": lat,
            "lng": lng
        ]
        let safeBusinessParams = sanitizeParameters(businessParams)
        
        // 生成 RSA 包装参数
        guard let rsaDict = makeRequestBody(dataDict: safeBusinessParams) else {
            completion(.failure(.encodingError("生成签名参数失败")))
            return
        }
        
        // 构建 multipart/form-data 请求
        let boundary = "Boundary-" + UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 头部添加 token 与通用头
        if let token = getCurrentUserToken() {
            request.setValue("\(token)", forHTTPHeaderField: "token")
        }
        addCommonHeaders(to: &request)
        
        // 文件数据
        let fileName = fileURL.lastPathComponent
        let mimeType = guessMimeType(from: fileURL)
        guard let fileData = try? Data(contentsOf: fileURL) else {
            completion(.failure(.encodingError("读取文件失败")))
            return
        }
        
        // 组装 multipart body
        var body = Data()
        let lineBreak = "\r\n"
        
        // 文本字段（timestamp/data/sign）
        for (key, value) in rsaDict {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 额外业务字段（如果有）
        for (key, value) in safeBusinessParams {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 文件字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append(lineBreak.data(using: .utf8)!)
        
        // 结束边界
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        #if DEBUG
        print("上传 URL: \(url.absoluteString)")
        print("上传文件名: \(fileName), 类型: \(mimeType), 大小: \(fileData.count) 字节")
        #endif
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResponse(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
    }
    
    // 简易 MIME 类型判断
    private func guessMimeType(from url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "txt": return "text/plain"
        case "pdf": return "application/pdf"
        case "json": return "application/json"
        case "csv": return "text/csv"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "mp4": return "video/mp4"
        default: return "application/octet-stream"
        }
    }
   
}
