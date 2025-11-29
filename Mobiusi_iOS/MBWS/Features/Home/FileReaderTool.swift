//
//  FileReaderTool.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/29.
//

import SwiftUI
import Foundation
import PDFKit
import QuickLook
import Compression

struct DocPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
struct FileReaderTool:View {
    let item: IndexItem
    @Environment(\.dismiss) private var dismiss
    
    @State private var fileContent: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    
    // 简单的内存缓存
    private static var contentCache: [String: String] = [:]
    
    var body: some View {
        ZStack{
            Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // 表头
                VStack {
                    Text(item.meta_data?.first?.file_name ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#E8E9ED"))
                }
                
                // 可滚动的表格内容
                ScrollView {
                    VStack(spacing: 0) {
                        if isLoading {
                            // 加载状态
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .padding(.bottom, 8)
                                Text("正在加载文件内容...")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 40)
                            .frame(maxWidth: .infinity)
                        } else if !errorMessage.isEmpty {
                            // 错误状态
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                
                                Text("读取文件失败")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(errorMessage)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("重试") {
                                    loadFileContent()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        } else {
                            // 显示文件内容
                            VStack(alignment: .leading, spacing: 0) {
                                Text(fileContent)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .background(Color.black)
                        }
                    }
                }
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("预览")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                   dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            loadFileContent()
        }
    }
    
    // MARK: - 文件读取函数
    private func loadFileContent() {
        isLoading = true
        errorMessage = ""
        
        // 检查 item 是否有文件路径信息
        guard let filePath = getFilePathFromItem() else {
            errorMessage = "无法获取文件路径"
            isLoading = false
            return
        }
        
        // 检查缓存
        if let cachedContent = Self.contentCache[filePath] {
            self.fileContent = cachedContent
            self.isLoading = false
            return
        }
        
        // 判断是网络URL还是本地文件路径
        if filePath.hasPrefix("http://") || filePath.hasPrefix("https://") {
            // 网络文件，需要下载
            downloadFileContent(from: filePath)
        } else {
            // 本地文件，直接读取
            loadLocalFileContent(from: filePath)
        }
    }
    
    // 下载网络文件内容
    private func downloadFileContent(from urlString: String) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "无效的URL地址"
                self.isLoading = false
            }
            return
        }
        
        // 使用URLSession下载文件
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    if error.localizedDescription.contains("网络") || error.localizedDescription.contains("network") {
                        self.errorMessage = "网络连接失败，请检查网络设置"
                    } else if error.localizedDescription.contains("超时") || error.localizedDescription.contains("timeout") {
                        self.errorMessage = "下载超时，请稍后重试"
                    } else {
                        self.errorMessage = "下载失败: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                    return
                }
                
                // 检查HTTP响应状态码
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        DispatchQueue.main.async {
                            switch httpResponse.statusCode {
                            case 404:
                                self.errorMessage = "文件不存在或已被删除"
                            case 403:
                                self.errorMessage = "访问被拒绝，文件可能已过期"
                            case 500...599:
                                self.errorMessage = "服务器错误，请稍后重试"
                            default:
                                self.errorMessage = "下载失败，HTTP状态码: \(httpResponse.statusCode)"
                            }
                            self.isLoading = false
                        }
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "下载的文件数据为空"
                    self.isLoading = false
                    return
                }
                
                // 检测文件类型（优先从响应头获取，其次从URL判断）
                let fileType = self.detectFileType(from: response, urlString: urlString, data: data)
                
                // 根据文件类型处理数据
                self.processFileData(data: data, fileType: fileType, cacheKey: urlString)
            }
        }.resume()
    }
    
    // 读取本地文件内容
    private func loadLocalFileContent(from filePath: String) {
        Task {
            do {
                // 检测文件类型
                let fileType = getFileType(from: filePath)
                
                // 读取文件数据
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                
                // 根据文件类型处理数据
                await MainActor.run {
                    self.processFileData(data: data, fileType: fileType, cacheKey: filePath)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "读取文件失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // 检测文件类型（从路径）
    private func getFileType(from path: String) -> String {
        var cleanPath = path
        
        // 尝试从URL解析路径（优先使用URL解析，更可靠）
        if let url = URL(string: path) {
            cleanPath = url.path
        } else {
            // 如果无法解析为URL，手动移除查询参数和片段标识符
            if let queryIndex = cleanPath.firstIndex(of: "?") {
                cleanPath = String(cleanPath[..<queryIndex])
            }
            if let fragmentIndex = cleanPath.firstIndex(of: "#") {
                cleanPath = String(cleanPath[..<fragmentIndex])
            }
        }
        
        let lowercasedPath = cleanPath.lowercased()
        if lowercasedPath.hasSuffix(".pdf") {
            return "pdf"
        } else if lowercasedPath.hasSuffix(".doc") || lowercasedPath.hasSuffix(".docx") {
            return "doc"
        } else if lowercasedPath.hasSuffix(".txt") {
            return "txt"
        } else if lowercasedPath.hasSuffix(".rtf") {
            return "rtf"
        }
        return "unknown"
    }
    
    // 检测文件类型（从HTTP响应和URL）
    private func detectFileType(from response: URLResponse?, urlString: String, data: Data) -> String {
        // 优先从Content-Type响应头获取
        if let httpResponse = response as? HTTPURLResponse,
           let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() {
            if contentType.contains("application/pdf") || contentType.contains("pdf") {
                return "pdf"
            } else if contentType.contains("application/msword") || contentType.contains("application/vnd.openxmlformats-officedocument.wordprocessingml.document") {
                return "doc"
            } else if contentType.contains("text/plain") {
                return "txt"
            } else if contentType.contains("text/rtf") || contentType.contains("application/rtf") {
                return "rtf"
            }
        }
        
        // 其次从URL路径判断
        let urlType = getFileType(from: urlString)
        if urlType != "unknown" {
            return urlType
        }
        
        // 最后尝试从文件数据的前几个字节判断（文件签名）
        if data.count >= 4 {
            let header = data.prefix(4)
            // PDF文件签名：%PDF
            if header.starts(with: [0x25, 0x50, 0x44, 0x46]) { // "%PDF"
                return "pdf"
            }
            // DOC文件签名（旧格式）：D0 CF 11 E0
            if header.starts(with: [0xD0, 0xCF, 0x11, 0xE0]) {
                return "doc"
            }
            // DOCX文件签名：PK（ZIP格式）
            if header.starts(with: [0x50, 0x4B, 0x03, 0x04]) { // "PK"
                // 检查是否是DOCX（ZIP格式，但包含word/目录）
                if data.count > 30 {
                    let checkData = String(data: data.prefix(2000), encoding: .utf8) ?? ""
                    if checkData.contains("word/") {
                        return "doc"
                    }
                }
            }
        }
        
        return "unknown"
    }
    
    // 处理文件数据
    private func processFileData(data: Data, fileType: String, cacheKey: String) {
        print("fileType: \(fileType)")
        switch fileType {
        case "pdf":
            // 处理 PDF 文件
            if let pdfText = extractPDFText(from: data) {
                self.fileContent = pdfText
                Self.contentCache[cacheKey] = pdfText
                self.isLoading = false
            } else {
                self.errorMessage = "无法从PDF文件中提取文本内容，该PDF可能包含图片或扫描件"
                self.isLoading = false
            }
            
        case "doc", "docx":
            // 尝试提取 DOC/DOCX 文件内容
            Task {
                if let content = await extractDocContent(from: data, fileType: fileType) {
                    await MainActor.run {
                        self.fileContent = content
                        Self.contentCache[cacheKey] = content
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "无法读取Word文档内容，该文档可能包含图片或使用了不支持的格式"
                        self.isLoading = false
                    }
                }
            }
            
        case "txt", "rtf":
            // 文本文件，尝试不同编码
            if let content = String(data: data, encoding: .utf8) {
                self.fileContent = content
                Self.contentCache[cacheKey] = content
                self.isLoading = false
            } else {
                // 尝试GBK编码
                let gbkEncoding = CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
                let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(gbkEncoding)
                if let content = String(data: data, encoding: String.Encoding(rawValue: nsStringEncoding)) {
                    self.fileContent = content
                    Self.contentCache[cacheKey] = content
                    self.isLoading = false
                } else {
                    self.errorMessage = "文件内容无法解析，可能是不支持的编码格式"
                    self.isLoading = false
                }
            }
            
        default:
            // 未知类型，尝试作为文本文件处理
            if let content = String(data: data, encoding: .utf8) {
                self.fileContent = content
                Self.contentCache[cacheKey] = content
                self.isLoading = false
            } else {
                // 尝试GBK编码
                let gbkEncoding = CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
                let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(gbkEncoding)
                if let content = String(data: data, encoding: String.Encoding(rawValue: nsStringEncoding)) {
                    self.fileContent = content
                    Self.contentCache[cacheKey] = content
                    self.isLoading = false
                } else {
                    self.errorMessage = "文件内容无法解析，可能是不支持的编码格式或文件类型"
                    self.isLoading = false
                }
            }
        }
    }
    
    // 从 PDF 数据中提取文本
    private func extractPDFText(from data: Data) -> String? {
        guard let pdfDocument = PDFDocument(data: data) else {
            return nil
        }
        
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    fullText += pageText
                    if pageIndex < pageCount - 1 {
                        fullText += "\n\n"
                    }
                }
            }
        }
        
        return fullText.isEmpty ? nil : fullText
    }
    
    // 从 DOC/DOCX 文件中提取文本内容
    private func extractDocContent(from data: Data, fileType: String) async -> String? {
        // 判断是 DOCX 还是 DOC
        if fileType == "docx" || (data.count >= 4 && data.prefix(4).starts(with: [0x50, 0x4B, 0x03, 0x04])) {
            // DOCX 文件（ZIP 格式）
            return await extractDocxContent(from: data)
        } else {
            // DOC 文件（旧格式，二进制）
            return await extractDocContentOldFormat(from: data)
        }
    }
    
    // 从 DOCX 文件中提取文本（DOCX 是 ZIP 格式，包含 XML）
    private func extractDocxContent(from data: Data) async -> String? {
        return await withCheckedContinuation { continuation in
            Task {
                // 创建临时文件
                let tempDir = FileManager.default.temporaryDirectory
                let tempZipFile = tempDir.appendingPathComponent("\(UUID().uuidString).zip")
                let extractDir = tempDir.appendingPathComponent("\(UUID().uuidString)_extract")
                
                do {
                    // 保存 ZIP 数据到临时文件
                    try data.write(to: tempZipFile)
                    
                    // 创建解压目录
                    try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
                    
                    // 使用系统命令解压（或者使用第三方库）
                    // 由于 iOS 没有内置 ZIP 解压 API，我们使用 Foundation 的 FileManager
                    // 但实际上需要使用第三方库如 ZipFoundation 或者手动解析 ZIP
                    
                    // 尝试使用简单的 ZIP 解析
                    if let content = try? await extractTextFromDocxZip(data: data) {
                        // 清理临时文件
                        try? FileManager.default.removeItem(at: tempZipFile)
                        try? FileManager.default.removeItem(at: extractDir)
                        continuation.resume(returning: content)
                        return
                    }
                    
                    // 如果简单方法失败，尝试使用系统 API
                    // 注意：iOS 没有内置的 ZIP 解压 API，这里使用一个简化的方法
                    // 实际项目中可能需要使用第三方库如 ZipFoundation
                    
                    // 清理临时文件
                    try? FileManager.default.removeItem(at: tempZipFile)
                    try? FileManager.default.removeItem(at: extractDir)
                    
                    continuation.resume(returning: nil)
                } catch {
                    // 清理临时文件
                    try? FileManager.default.removeItem(at: tempZipFile)
                    try? FileManager.default.removeItem(at: extractDir)
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // 从 DOCX ZIP 数据中提取文本（简化版本，直接解析 ZIP 结构）
    private func extractTextFromDocxZip(data: Data) async throws -> String? {
        // DOCX 文件是 ZIP 格式，我们需要找到 word/document.xml
        // 这里使用一个简化的 ZIP 解析方法
        
        let zipData = data
        let targetFileName = "word/document.xml"
        
        // 简化的 ZIP 解析：查找 Central Directory
        // ZIP 文件结构：
        // - Local File Headers + File Data
        // - Central Directory (在文件末尾)
        // - End of Central Directory Record (最后 22 字节)
        
        // 1. 读取 End of Central Directory Record (最后 22 字节)
        guard zipData.count >= 22 else { return nil }
        
        let eocdOffset = zipData.count - 22
        let eocdData = zipData.subdata(in: eocdOffset..<zipData.count)
        
        // 检查 ZIP 签名 (0x06054b50)
        guard eocdData[0] == 0x50 && eocdData[1] == 0x4B && eocdData[2] == 0x05 && eocdData[3] == 0x06 else {
            return nil
        }
        
        // 读取 Central Directory 的偏移量 (字节 16-19)
        let cdOffset = Int(eocdData[16]) | (Int(eocdData[17]) << 8) | (Int(eocdData[18]) << 16) | (Int(eocdData[19]) << 24)
        
        guard cdOffset < zipData.count else { return nil }
        
        // 2. 遍历 Central Directory 查找 word/document.xml
        var currentOffset = cdOffset
        
        while currentOffset < zipData.count - 4 {
            // 检查 Central Directory File Header 签名 (0x02014b50)
            guard zipData[currentOffset] == 0x50,
                  zipData[currentOffset + 1] == 0x4B,
                  zipData[currentOffset + 2] == 0x01,
                  zipData[currentOffset + 3] == 0x02 else {
                break
            }
            
            // 读取文件名长度 (字节 28-29)
            let fileNameLength = Int(zipData[currentOffset + 28]) | (Int(zipData[currentOffset + 29]) << 8)
            let extraFieldLength = Int(zipData[currentOffset + 30]) | (Int(zipData[currentOffset + 31]) << 8)
            let commentLength = Int(zipData[currentOffset + 32]) | (Int(zipData[currentOffset + 33]) << 8)
            
            // 读取文件名 (从字节 46 开始)
            let fileNameOffset = currentOffset + 46
            guard fileNameOffset + fileNameLength <= zipData.count else { break }
            
            let fileNameData = zipData.subdata(in: fileNameOffset..<(fileNameOffset + fileNameLength))
            if let fileName = String(data: fileNameData, encoding: .utf8) ?? String(data: fileNameData, encoding: .ascii) {
                if fileName == targetFileName {
                    // 找到了！读取 Local File Header 的偏移量 (字节 42-45)
                    let localHeaderOffset = Int(zipData[currentOffset + 42]) | (Int(zipData[currentOffset + 43]) << 8) | (Int(zipData[currentOffset + 44]) << 16) | (Int(zipData[currentOffset + 45]) << 24)
                    
                    // 读取压缩大小 (字节 20-23)
                    let compressedSize = Int(zipData[currentOffset + 20]) | (Int(zipData[currentOffset + 21]) << 8) | (Int(zipData[currentOffset + 22]) << 16) | (Int(zipData[currentOffset + 23]) << 24)
                    
                    // 读取未压缩大小 (字节 24-27)
                    let uncompressedSize = Int(zipData[currentOffset + 24]) | (Int(zipData[currentOffset + 25]) << 8) | (Int(zipData[currentOffset + 26]) << 16) | (Int(zipData[currentOffset + 27]) << 24)
                    
                    // 读取压缩方法 (字节 10-11)
                    let compressionMethod = Int(zipData[currentOffset + 10]) | (Int(zipData[currentOffset + 11]) << 8)
                    
                    // 读取 Local File Header
                    guard localHeaderOffset < zipData.count else { break }
                    let localHeaderData = zipData.subdata(in: localHeaderOffset..<min(localHeaderOffset + 30, zipData.count))
                    
                    // 检查 Local File Header 签名 (0x04034b50)
                    guard localHeaderData[0] == 0x50 && localHeaderData[1] == 0x4B && localHeaderData[2] == 0x03 && localHeaderData[3] == 0x04 else {
                        break
                    }
                    
                    // 读取 Local File Header 中的文件名长度和额外字段长度
                    let localFileNameLength = Int(localHeaderData[26]) | (Int(localHeaderData[27]) << 8)
                    let localExtraFieldLength = Int(localHeaderData[28]) | (Int(localHeaderData[29]) << 8)
                    
                    // 文件数据从 Local File Header 之后开始
                    let fileDataOffset = localHeaderOffset + 30 + localFileNameLength + localExtraFieldLength
                    
                    guard fileDataOffset + compressedSize <= zipData.count else { break }
                    
                    // 提取文件数据
                    let fileData = zipData.subdata(in: fileDataOffset..<(fileDataOffset + compressedSize))
                    
                    // 如果未压缩，直接使用；如果压缩了（方法 8 = deflate），需要解压
                    if compressionMethod == 0 {
                        // 未压缩，直接解析 XML
                        return parseDocxXML(data: fileData)
                    } else if compressionMethod == 8 {
                        // Deflate 压缩，需要解压
                        if let decompressed = try? decompressDeflate(data: fileData, uncompressedSize: uncompressedSize) {
                            return parseDocxXML(data: decompressed)
                        }
                    }
                    
                    break
                }
            }
            
            // 移动到下一个 Central Directory 条目
            currentOffset += 46 + fileNameLength + extraFieldLength + commentLength
        }
        
        return nil
    }
    
    // 解压 Deflate 压缩的数据
    private func decompressDeflate(data: Data, uncompressedSize: Int) throws -> Data? {
        // 使用 Compression 框架解压
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: uncompressedSize)
        defer { buffer.deallocate() }
        
        let result = data.withUnsafeBytes { inputBytes in
            compression_decode_buffer(
                buffer, uncompressedSize,
                inputBytes.bindMemory(to: UInt8.self).baseAddress!, data.count,
                nil, COMPRESSION_ZLIB
            )
        }
        
        guard result > 0 else { return nil }
        
        return Data(bytes: buffer, count: result)
    }
    
    // 解析 DOCX XML 并提取文本
    private func parseDocxXML(data: Data) -> String? {
        guard let xmlString = String(data: data, encoding: .utf8) else { return nil }
        
        // 使用简单的正则表达式或字符串处理提取文本
        // DOCX XML 中的文本在 <w:t> 标签中
        var text = ""
        var inTextTag = false
        var currentText = ""
        
        // 简单的 XML 解析（使用正则表达式）
        let pattern = "<w:t[^>]*>([^<]*)</w:t>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = xmlString as NSString
            let results = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for result in results {
                if result.numberOfRanges > 1 {
                    let textRange = result.range(at: 1)
                    if textRange.location != NSNotFound {
                        let extractedText = nsString.substring(with: textRange)
                        text += extractedText + " "
                    }
                }
            }
        }
        
        // 清理文本（移除多余空格，保留换行）
        text = text.replacingOccurrences(of: "  ", with: " ")
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text.isEmpty ? nil : text
    }
    
    // 从旧格式 DOC 文件中提取文本（更困难，可能需要第三方库）
    private func extractDocContentOldFormat(from data: Data) async -> String? {
        // DOC 文件是 Microsoft 的旧格式，是二进制格式
        // 解析 DOC 文件非常复杂，通常需要专门的库
        
        // 尝试一些基本的方法：
        // 1. 查找文本块（这只是一个非常简化的方法，可能不准确）
        // 2. 使用第三方库
        
        // 这里返回 nil，因为 DOC 格式解析需要专门的库
        // 实际项目中可以考虑使用第三方库如 libmspack 或其他 DOC 解析库
        return nil
    }
    
    // 从 IndexItem 中获取文件路径
    private func getFilePathFromItem() -> String? {
        // 从 meta_data 中获取文件路径
        guard let metaData = item.meta_data?.first,
              let path = metaData.path else {
            return nil
        }
        
        // 如果是file://协议，转换为本地路径
        if path.hasPrefix("file://") {
            return URL(string: path)?.path
        }
        
        // 直接返回路径（支持网络URL和本地路径）
        return path
    }
}
