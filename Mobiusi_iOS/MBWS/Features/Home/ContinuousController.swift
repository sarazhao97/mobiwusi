//
//  ContinuousController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/5.
//

import SwiftUI
import Foundation
import WebKit


struct ContinuousController:View {
    @Binding var current_post_id: String
    @State private var continuityRecords: [ContinuityRecordData] = []
    @State private var errorMessage: String? = nil
    @State private var responseModel: ContinuityRecordData? = nil
    @State private var showImagePreview: Bool = false
    @State private var showVideoPreview: Bool = false
    @State private var currentPreviewImageURL: String = ""
    @State private var currentPreviewVideoURL: String = ""
  
    var body: some View {
       ZStack{
             Color(hex:   "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(continuityRecords.indices, id: \.self) { idx in
                            let record = continuityRecords[idx]
                            let isLast = idx == continuityRecords.count - 1
                            ContinuityRecordRowView(record: record, isLast: isLast, showImagePreview: $showImagePreview, showVideoPreview: $showVideoPreview, currentPreviewImageURL: $currentPreviewImageURL, currentPreviewVideoURL: $currentPreviewVideoURL)
                                .padding(.horizontal, 16)
                        }
                    
                }
                .padding(.top, 12)
            }
       }
       .onAppear{
            if !current_post_id.isEmpty {
                getContinuityRecord()
            }
        }
        .onChange(of: current_post_id){ newID in
            if !newID.isEmpty {
                getContinuityRecord()
            }
        }
         .fullScreenCover(
            isPresented: Binding(
                get: { showVideoPreview && !currentPreviewVideoURL.isEmpty },
                set: { showVideoPreview = $0 }
            )
        ) {
            FullScreenVideoView(videoURL: currentPreviewVideoURL, isPresented: $showVideoPreview)
                .id(currentPreviewVideoURL)
                .toolbar(.hidden, for: .tabBar)
        }
         .fullScreenCover(
            isPresented: Binding(
                get: { showImagePreview && !currentPreviewImageURL.isEmpty },
                set: { showImagePreview = $0 }
            )
        ) { 
            FullScreenImgView(imageURL: currentPreviewImageURL, isPresented: $showImagePreview)
                .id(currentPreviewImageURL)
                .toolbar(.hidden, for: .tabBar) 
        }
    }


    //MARK: - 连续记录
    func getContinuityRecord() {
         errorMessage = nil
         let requestBody: [String: Any] = [
                "filter_post_id": current_post_id,
            ]
        
         NetworkManager.shared.post(APIConstants.Index.getContinuityRecord, 
                                 businessParameters: requestBody) { (result: Result<ContinuityRecordResponse, APIError>) in
            DispatchQueue.main.async {          
                switch result {
                case .success(let response):
                    if response.code == 1{
                        continuityRecords = response.data ?? []
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                }
            }
        }
    }
}

struct ContinuityRecordRowView: View {
    let record: ContinuityRecordData
    let isLast: Bool
    @Binding var showImagePreview: Bool
    @Binding var showVideoPreview: Bool
    @Binding  var currentPreviewImageURL: String
    @Binding  var currentPreviewVideoURL: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧时间轴
            VStack(alignment: .center, spacing: 0) {
                Image("icon_home_time_point")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
                if !isLast {
                    Rectangle()
                        .fill(Color(hex: "#EDEEF5"))
                        .frame(width: 2)
                        .padding(.top, 4)
                }
            }
            .frame(width: 16)

            // 右侧内容区域
            VStack(alignment: .leading, spacing: 8) {
                Text(formatDate(record.create_time))
                    .font(.system(size: 14))
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 8){
                if let metas = record.meta_data, !metas.isEmpty {
                    ForEach(metas.indices, id: \.self) { i in
                        MetaContentView(meta: metas[i],source: record.source ?? 0,showImagePreview: $showImagePreview,showVideoPreview: $showVideoPreview,currentPreviewImageURL: $currentPreviewImageURL,currentPreviewVideoURL: $currentPreviewVideoURL)
                    }
                } else {
                    if let text = record.description ?? record.idea, !text.isEmpty {
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#333333"))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("暂无内容")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                    }
                }
               }
             
            }
            
        }
        .padding(.vertical, 8)
    }
}

struct MetaContentView: View {
    let meta: MetaData
    let source: Int
    @State private var showWeb = false
    @Binding var showImagePreview: Bool
    @Binding var showVideoPreview: Bool
    @Binding var currentPreviewImageURL: String
    @Binding var currentPreviewVideoURL: String
    
    private var isVideo: Bool {
        if meta.cate == 4 && source == 3 {
            return true
        } else {
            return false
        }
            
    }
    private var isImage: Bool {
          if meta.cate == 2 && source == 3 {
            return true
        } else {
            return false
        }
       
    }
    private var isAudio: Bool {
       if meta.cate == 1 && source == 3 {
            return true
        } else {
            return false
        }
      
    }
    private var isText: Bool {
       if meta.cate == 3 && source == 3 {
            return true
        } else {
            return false
        }
      
    }

    //是否是资讯分析师
    private var isInfoAnalyst: Bool {
        return source == 5
    }

    //是否是多变摄影师
    private var isVariedPhotographer: Bool {
        return source == 1
    }
    //是否是食品安全
    private var isFoodSafety: Bool {
        return source == 2
    }
    //是否是翻译
    private var isTranslator: Bool {
        return source == 4
    }
    //是否是项目
    private var isProject: Bool {
        return source == 6
    }



    private var previewURLString: String? {
        meta.preview_url ?? meta.image_path ?? meta.original_image_path ?? meta.path
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isImage || isVideo {
                if let urlStr = previewURLString, let url = URL(string: urlStr) {
                    HStack{
                        ZStack{
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
                                .cornerRadius(8)
                                .clipped()
                                .onTapGesture{
                                    if isVideo {
                                        currentPreviewVideoURL = meta.path ?? ""
                                        showVideoPreview = true
                                    } else {
                                        currentPreviewImageURL = meta.path ?? ""
                                        showImagePreview = true
                                    }
                                    }
                        case .failure(_):
                            placeholder
                        case .empty:
                            placeholder
                        @unknown default:
                            placeholder
                        }
                    }
                    if meta.is_video == 1 {
                     Image("icon_data_play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                      }
                    

                    }
                    Spacer()
                }
                } else {
                    placeholder
                }
            } else if isAudio {
                HStack(spacing: 8) {
                   AudioSpectrogram(audioURL: meta.path ?? "")
                }
                .padding(10)
                .background(Color(hex: "#F7F8FA"))
                .cornerRadius(8)
            } else if isText {
               HStack(alignment:.center,spacing:5){
                Image("icon_wb@3x_3")
                  .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 30, height: 30)
                Text(meta.file_name ?? "文本")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#000000"))
                Spacer()
               }
            } else if isInfoAnalyst{
                    VStack(alignment:.leading,spacing:10){
                        Text(meta.feature ?? "资讯分析师")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#000000"))
                        Text(meta.title ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#000000"))
                        Text(meta.content ?? "")
                            .font(.system(size: 12))
                            .lineLimit(2)
                            .foregroundColor(Color(hex: "#000000"))
                        Button(action: { showWeb = true }){
                              HStack{
                                  Image("icon_home_link")
                                      .resizable()
                                      .aspectRatio(contentMode: .fit)
                                      .frame(width: 16, height: 16)
                                  Text(meta.path ?? "")
                                      .font(.system(size: 12))
                                      .lineLimit(2)
                                      .multilineTextAlignment(.leading)
                                      .fixedSize(horizontal: false, vertical: true)
                                      .layoutPriority(1)
                                      .foregroundColor(Color(hex: "#57548E"))
                                  Spacer()
                              }
                          }
                          .contentShape(Rectangle())
                          .padding(.vertical,4)
                          .padding(.horizontal,8)
                          .background(Color(hex: "#f2f3f5"))
                          .cornerRadius(8)
                          .fullScreenCover(isPresented: $showWeb) {
                              WebPageView(urlString: meta.path ?? "",title: meta.title ?? "")
                          }    
                    }
            }else if isVariedPhotographer{
                 VStack(alignment:.leading,spacing:10){
                      Text("\(meta.feature ?? "多变摄影师") - \(meta.style_name ?? "未知风格")")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#000000"))
                      HStack(alignment:.center,spacing:5){
                         AsyncImage(url: URL(string: meta.image_path ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
                                    .cornerRadius(8)
                                    .clipped()
                                    .onTapGesture {
                                        currentPreviewImageURL = meta.image_path ?? ""
                                        showImagePreview = true
                                    }
                            case .failure(_):
                                placeholder
                            case .empty:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                         AsyncImage(url: URL(string: meta.original_image_path ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
                                    .cornerRadius(8)
                                    .clipped()
                                     .onTapGesture {
                                        currentPreviewImageURL = meta.original_image_path ?? ""
                                        showImagePreview = true
                                    }
                            case .failure(_):
                                placeholder
                            case .empty:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                      }
                 }

            }else if isFoodSafety{
                 VStack(alignment:.leading,spacing:10){
                     Text("\(meta.feature ?? "食品安全员")")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#000000"))
                     HStack(alignment:.center){
                        HStack(alignment:.center,spacing:2){
                          Text("\(meta.score ?? 0)")
                                .font(.system(size: 34))
                                .foregroundColor(Color(hex: "#000000"))
                            Text("分")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#000000"))
                        }
                        Spacer()
                        VStack{
                            HStack{
                                Spacer()
                                Text(meta.tips ?? "")
                                  .font(.system(size: 14))
                                  .foregroundColor(Color(hex: "#999999"))
                            }

                            VStack{
                                GeometryReader { geo in
                                    let barHeight: CGFloat = 6
                                    let gap: CGFloat = 3
                                    let indicatorW: CGFloat = 8
                                    let indicatorH: CGFloat = 6
                                    let totalWidth = geo.size.width
                                    let scoreValue = meta.score ?? 0
                                    let clamped = max(0, min(100, scoreValue))
                                    let rawX = CGFloat(clamped) / 100.0 * totalWidth
                                    let anchorX = min(max(indicatorW/2, rawX), totalWidth - indicatorW/2)

                                    VStack(spacing: 6) {
                                        // 顶部三角指示器（指向下方进度条）
                                        Image("Vector_3")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: indicatorW, height: indicatorH)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .offset(x: anchorX - indicatorW/2)

                                        // 分段进度条（红/橙/绿），从左到右 0% 到 100%
                                        HStack(spacing: gap) {
                                            Rectangle()
                                                .fill(Color(hex: "FF0032"))
                                                .frame(height: barHeight)
                                                .cornerRadius(barHeight/2)

                                            Rectangle()
                                                .fill(Color(hex: "FF6000"))
                                                .frame(height: barHeight)
                                                .cornerRadius(barHeight/2)

                                            Rectangle()
                                                .fill(Color(hex: "20B37B"))
                                                .frame(height: barHeight)
                                                .cornerRadius(barHeight/2)
                                        }
                                        .frame(maxWidth: .infinity - 80)
                                    }
                                }
                                .frame(height: 22)
                            }


                        }
                       
                     }
                    .padding(20)
                    .frame(maxWidth:.infinity)
                    .background(Color(hex: "#ffffff"))
                    .cornerRadius(8)
                    HStack{
                        Image("icon_home_connect 1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        Spacer()
                    }
                    .padding(.vertical,-4)
                    HStack{
                        AsyncImage(url: URL(string: meta.original_image_path ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                                .clipped()
                                .onTapGesture {
                                    currentPreviewImageURL = meta.original_image_path ?? ""
                                    showImagePreview = true
                                }
                        } placeholder: {
                            Image("占位图")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                 .cornerRadius(5)
                                  .clipped()
                        }
                        Spacer()
                    }
                 }
            }else if isTranslator{
                 VStack(alignment:.leading,spacing:10){
                     Text("\(meta.feature ?? "出国翻译官")")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#000000"))
                      HStack(alignment:.center,spacing:5){
                         AsyncImage(url: URL(string: meta.image_path ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
                                    .cornerRadius(8)
                                    .clipped()
                                    .onTapGesture {
                                        currentPreviewImageURL = meta.image_path ?? ""
                                        showImagePreview = true
                                    }
                            case .failure(_):
                                placeholder
                            case .empty:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                         AsyncImage(url: URL(string: meta.original_image_path ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
                                    .cornerRadius(8)
                                    .clipped()
                                    .onTapGesture {
                                        currentPreviewImageURL = meta.original_image_path ?? ""
                                        showImagePreview = true
                                    }
                            case .failure(_):
                                placeholder
                            case .empty:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                      }
                 }
            }    
            else {
                Text(meta.file_name ?? "未知内容")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#999999"))
            }
        }
        .padding(.vertical, 8)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(hex: "#F0F1F5"))
            .frame(width:UIScreen.main.bounds.width/2-30,height:(UIScreen.main.bounds.width/2-30))
            .cornerRadius(8)
    }

    // 内嵌网页视图，使用 WKWebView
    // 简洁的导航栏跑马灯标题视图
    struct MarqueeTitleView: View {
        let text: String
        private let speed: CGFloat = 40 // 每秒像素
        @State private var startDate = Date()
        @State private var textWidth: CGFloat = 0
        var body: some View {
            GeometryReader { geo in
                let containerWidth = max(geo.size.width, 1)
                TimelineView(.animation) { context in
                    let elapsed = CGFloat(context.date.timeIntervalSince(startDate))
                    let shouldScroll = textWidth > containerWidth
                    let distance = shouldScroll ? (textWidth + containerWidth) : 1
                    let travel = shouldScroll ? (elapsed * speed).truncatingRemainder(dividingBy: distance) : 0
                    let x = shouldScroll ? (containerWidth - travel) : 0
                    ZStack(alignment: .leading) {
                        Text(text)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .offset(x: x)
                            .background(
                                GeometryReader { tGeo in
                                    Color.clear.onAppear { textWidth = tGeo.size.width }
                                }
                            )
                    }
                    .frame(width: containerWidth, alignment: .leading)
                }
            }
            .frame(height: 20)
            .clipped()
            .onAppear { startDate = Date() }
        }
    }
    
    struct WebPageView: View {
        let urlString: String
        let title: String?
        @Environment(\.dismiss) var dismiss
        var body: some View {
            NavigationView {
                WebView(urlString: urlString)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            MarqueeTitleView(text: title ?? "网页")
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .medium))
                            }
                        }
                    }
            }
        }
    }

    struct WebView: UIViewRepresentable {
        let urlString: String
        
        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            // 设置字符编码偏好，优先使用 UTF-8，也支持 GBK/GB2312
            let preferences = WKWebpagePreferences()
            preferences.preferredContentMode = .mobile
            config.defaultWebpagePreferences = preferences
            
            // 创建用户内容控制器，用于注入 JavaScript 修复编码
            let userContentController = WKUserContentController()
            
            // 注入 JavaScript 来检测编码并放大字体
            let script = """
            (function() {
                // 检测页面编码
                var metaCharset = document.querySelector('meta[charset]');
                var metaContentType = document.querySelector('meta[http-equiv="Content-Type"]');
                
                // 如果页面没有指定编码或编码不正确，尝试修复
                if (!metaCharset && !metaContentType) {
                    // 检查页面内容是否可能使用了 GBK 编码
                    var bodyText = document.body ? document.body.innerText : '';
                    if (bodyText && bodyText.length > 0) {
                        // 尝试检测并修复编码问题
                        console.log('检测页面编码状态');
                    }
                }
                
                // 确保页面使用正确的编码
                if (document.characterSet && document.characterSet !== 'UTF-8') {
                    console.log('当前页面编码: ' + document.characterSet);
                }
                
                // 放大页面字体
                function increaseFontSize() {
                    var style = document.createElement('style');
                    style.id = 'font-size-adjustment';
                    style.innerHTML = `
                        body, p, div, span, a, li, td, th, h1, h2, h3, h4, h5, h6 {
                            font-size: 18px !important;
                            line-height: 1.6 !important;
                        }
                        body {
                            -webkit-text-size-adjust: 100% !important;
                            text-size-adjust: 100% !important;
                        }
                    `;
                    var head = document.head || document.getElementsByTagName('head')[0];
                    if (head) {
                        var existingStyle = document.getElementById('font-size-adjustment');
                        if (existingStyle) {
                            existingStyle.remove();
                        }
                        head.appendChild(style);
                    }
                }
                
                // 页面加载完成后立即执行
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', increaseFontSize);
                } else {
                    increaseFontSize();
                }
                
                // 使用 MutationObserver 监听动态内容变化
                var observer = new MutationObserver(function(mutations) {
                    increaseFontSize();
                });
                observer.observe(document.body || document.documentElement, {
                    childList: true,
                    subtree: true
                });
            })();
            """
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(userScript)
            config.userContentController = userContentController
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.allowsBackForwardNavigationGestures = true
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            
            // 设置导航代理来处理编码问题
            webView.navigationDelegate = context.coordinator
            
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            var s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            if !s.lowercased().hasPrefix("http://") && !s.lowercased().hasPrefix("https://") {
                s = "https://" + s
            }
            var url = URL(string: s)
            if url == nil {
                let encoded = s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let e = encoded {
                    url = URL(string: e)
                }
            }
            guard let finalURL = url else { return }
            
            // 避免重复加载同一地址
            if context.coordinator.lastURLStringLoaded == s { return }
            context.coordinator.lastURLStringLoaded = s
            
            var request = URLRequest(url: finalURL)
            
            // 设置完整的请求头，包括字符编码
            request.setValue("zh-CN,zh;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.setValue("UTF-8,GBK,GB2312;q=0.9,*;q=0.8", forHTTPHeaderField: "Accept-Charset")
            request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
            
            // 取消上一次任务
            context.coordinator.currentTask?.cancel()
            
            // 先通过 URLSession 获取原始数据，按需使用国标编码解码
            context.coordinator.currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil, let data = data else {
                    DispatchQueue.main.async { uiView.load(request) }
                    return
                }
                
                var html: String?
                var charset: String?
                if let http = response as? HTTPURLResponse,
                   let contentType = http.allHeaderFields["Content-Type"] as? String {
                    let lower = contentType.lowercased()
                    if let range = lower.range(of: "charset=") {
                        let cs = lower[range.upperBound...]
                        if cs.contains("gb18030") { charset = "gb18030" }
                        else if cs.contains("gbk") { charset = "gbk" }
                        else if cs.contains("gb2312") { charset = "gb2312" }
                        else if cs.contains("utf-8") { charset = "utf-8" }
                    }
                }
                
                if charset == "utf-8" {
                    html = String(data: data, encoding: .utf8)
                } else if charset == "gb18030" {
                    let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    html = String(data: data, encoding: String.Encoding(rawValue: nsEnc))
                } else if charset == "gbk" {
                    let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GBK_95.rawValue))
                    html = String(data: data, encoding: String.Encoding(rawValue: nsEnc))
                } else if charset == "gb2312" {
                    let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue))
                    html = String(data: data, encoding: String.Encoding(rawValue: nsEnc))
                } else {
                    // 没有声明编码时，依次尝试 UTF-8 与国标系
                    html = String(data: data, encoding: .utf8)
                    if html == nil {
                        let e1 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                        html = String(data: data, encoding: String.Encoding(rawValue: e1))
                    }
                    if html == nil {
                        let e2 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GBK_95.rawValue))
                        html = String(data: data, encoding: String.Encoding(rawValue: e2))
                    }
                    if html == nil {
                        let e3 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue))
                        html = String(data: data, encoding: String.Encoding(rawValue: e3))
                    }
                }
                
                DispatchQueue.main.async {
                    if var html = html {
                        // 在 HTML 中插入字体放大样式
                        let fontSizeStyle = """
                        <style id="font-size-adjustment">
                            body, p, div, span, a, li, td, th, h1, h2, h3, h4, h5, h6 {
                                font-size: 30px !important;
                                line-height: 1.6 !important;
                            }
                            body {
                                -webkit-text-size-adjust: 100% !important;
                                text-size-adjust: 100% !important;
                            }
                        </style>
                        """
                        // 在 </head> 之前插入样式，如果没有 head 则在开头插入
                        if let headRange = html.range(of: "</head>", options: .caseInsensitive) {
                            html.insert(contentsOf: fontSizeStyle, at: headRange.lowerBound)
                        } else if let htmlTagRange = html.range(of: "<html", options: .caseInsensitive) {
                            if let afterHtml = html.range(of: ">", range: htmlTagRange.upperBound..<html.endIndex) {
                                html.insert(contentsOf: "<head>\(fontSizeStyle)</head>", at: afterHtml.upperBound)
                            }
                        } else {
                            html = fontSizeStyle + html
                        }
                        uiView.loadHTMLString(html, baseURL: finalURL)
                    } else {
                        uiView.load(request)
                    }
                }
            }
            context.coordinator.currentTask?.resume()
        }
        
        // Coordinator 类，用于管理 WebView 的导航代理
        class Coordinator: NSObject, WKNavigationDelegate {
            var lastURLStringLoaded: String?
            var currentTask: URLSessionDataTask?
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                // 页面加载完成后，检查是否需要修复编码
                webView.evaluateJavaScript("document.characterSet") { (result, error) in
                    if let charset = result as? String {
                        print("页面字符编码: \(charset)")
                        // 如果检测到非 UTF-8 编码，记录日志
                        if charset.uppercased() != "UTF-8" {
                            print("页面使用非 UTF-8 编码: \(charset)")
                        }
                    }
                }
                
                // 页面加载完成后，再次注入字体放大样式，确保生效
                let fontSizeScript = """
                (function() {
                    var style = document.createElement('style');
                    style.id = 'font-size-adjustment';
                    style.innerHTML = `
                        body, p, div, span, a, li, td, th, h1, h2, h3, h4, h5, h6 {
                            font-size: 30px !important;
                            line-height: 1.6 !important;
                        }
                        body {
                            -webkit-text-size-adjust: 100% !important;
                            text-size-adjust: 100% !important;
                        }
                    `;
                    var head = document.head || document.getElementsByTagName('head')[0];
                    if (head) {
                        var existingStyle = document.getElementById('font-size-adjustment');
                        if (existingStyle) {
                            existingStyle.remove();
                        }
                        head.appendChild(style);
                    }
                })();
                """
                webView.evaluateJavaScript(fontSizeScript, completionHandler: nil)
            }
        }
    }
}

// MARK: - Helpers
func formatDate(_ str: String?) -> String {
    guard let str = str, !str.isEmpty else { return "" }
    let input = DateFormatter()
    input.dateFormat = "yyyy-MM-dd HH:mm:ss"
    if let date = input.date(from: str) {
        let output = DateFormatter()
        output.dateFormat = "yyyy-MM-dd HH:mm"
        return output.string(from: date)
    }
    return str
}
