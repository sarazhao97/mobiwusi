//
//  HomeViewController.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/8/15.
//

import SwiftUI
import UIKit
import AVKit
import AVFoundation
import CoreLocation



// 图片缓存管理器
@MainActor
class ImageCacheManager: ObservableObject, Sendable {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // 最多缓存100张图片
        cache.totalCostLimit = 50 * 1024 * 1024 // 最多50MB
    }
    
    func getImage(for url: String) -> UIImage? {
        return cache.object(forKey: NSString(string: url))
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: NSString(string: url))
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// 可缓存图片视图组件
struct CachedImageView: View {
    let urlString: String
    @State private var uiImage: UIImage?

    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear { loadImage() }
    }

    private func loadImage() {
        if let cached = ImageCacheManager.shared.getImage(for: urlString) {
            self.uiImage = cached
            return
        }
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.uiImage = image
                ImageCacheManager.shared.setImage(image, for: urlString)
            }
        }.resume()
    }
}

// 滚动位置偏好键
struct ScrollOffsetPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// HEX 颜色扩展
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// 媒体类型枚举
enum MediaType: Int {
    case audio = 1
    case image = 2
    case text = 3
    case video = 4
}

enum ContentCategory: Int{
     case ghibli = 1           // 吉卜力
    case foodSafety = 2       // 食品安全
    case freeTransmission = 3 // 自由传
    case translation = 4      // 翻译
    case newsAnalysis = 5     // 资讯分析
    case project = 6          // 项目
}

// 下拉刷新状态枚举
enum PullRefreshState {
    case idle           // 空闲状态
    case pulling        // 下拉中
    case readyToRefresh // 达到阈值，准备刷新
    case refreshing     // 正在刷新
    case completed      // 刷新完成
}


// 选项类型枚举
enum OptionType: String, Identifiable {
    case 标注
    case 交易
    case 连续
    case 图谱
    
    var id: String { rawValue }
}

// 选项详情
struct OptionDetail {
    var count: Int
    var price: Double? // 可选，只有交易类型可能有
    var createTime: String
    var userAvatar: String? // 可选，显示操作用户头像
    var hasNew: Bool = false // 是否有新消息标记
}

// 选项模型
struct annotationOption: Identifiable {
    let id = UUID()
    let total: Int
    let isRead: Bool
    let avatar: String
    let time: String
}

struct transactionOption: Identifiable {
    let id = UUID()
    let total: Int
    let is_read: Bool
    let avatar: String
    let time: String
    let price: Double
}

struct continuityOption: Identifiable {
    let id = UUID()
    let total: Int
    let time: String
}

struct knowledge_graphOption: Identifiable {
    let id = UUID()
    let total: Int
    let time: String
}

struct meta_dataOption: Identifiable {
    let id = UUID()
    let isVideo: Bool
    let path: String
    let fileName: String
    let duration: Int
    let previewUrl: String
    let taskText: String
}

// 媒体项数据模型 - 直接使用 IndexItem，无需重复定义

// 中间内容视图协议
protocol MiddleContent: View {
    init(item: IndexItem)
}

// 音频类型中间内容
struct AudioMiddleContent: MiddleContent {
    private let item: IndexItem
    
    init(item: IndexItem) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading) {
              if let idea = item.idea, !idea.isEmpty {
                        HStack{
                            Text(idea)
                             .font(.system(size: 16))
                             .foregroundColor(Color(hex: "#000000"))
                            Spacer()
                        }
                    }
            
            HStack {
                    AudioSpectrogram(audioURL: item.meta_data?.first?.path ?? "")
                    Spacer()
            }
            .frame(height: 60)
             if let location = item.location, !location.isEmpty {
                        HStack(alignment:.center,spacing:4){
                            Image("location")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            Text(item.location ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#828282"))
                            Spacer()
                        }
                    }   
            
           
        }
    }
}
// 文本类型中间内容
struct TextMiddleContent: MiddleContent {
    private let item: IndexItem
    
    init(item: IndexItem) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading) {
              if let idea = item.idea, !idea.isEmpty {
                               HStack{
                                Text(idea)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                     Spacer()
                               }
                               .padding(.vertical,8)
                               .frame(maxWidth: .infinity)      
                            }
                        HStack{
                          
                                HStack {
                                    Image("icon_wb@3x_3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    
                                    Text(item.meta_data?.first?.file_name ?? "")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                    
                                    Spacer()       
                                }
                                .padding(.vertical,8)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(10)

                                // 显示剩余文件个数
                                    if let metaData = item.meta_data, metaData.count > 1 {
                                        Text("+ \(metaData.count - 1)")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.red)
                                            
                                        
                                    }
                                }
                        Text(item.task_title ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#57548E"))
                        .lineLimit(2)
                       
                    if let description = item.description, !description.isEmpty {
                        VStack(alignment:.leading,spacing:10){
                            Text("数据介绍")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#9B9B9B"))
                                .lineLimit(1)
                            Text(item.description ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#000000"))
                               
                        }
                    }   

                    if let location = item.location, !location.isEmpty {
                        HStack(alignment:.center,spacing:4){
                            Image("location")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            Text(item.location ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#828282"))
                            Spacer()
                        }
                    }   
        }
    }
}

//吉卜力类型中间内容
struct GhibliMiddleContent: MiddleContent {
    @Binding var imageURL: String
    @Binding var showFullScreen: Bool
    let item: IndexItem
    
    // 符合MiddleContent协议的初始化器
    init(item: IndexItem) {
        self.item = item
        self._imageURL = .constant("")
        self._showFullScreen = .constant(false)
    }
    init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>) {
        self.item = item
        self._imageURL = imageURL
        self._showFullScreen = showFullScreen
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("\(item.meta_data?.first?.feature ?? "") - \(item.meta_data?.first?.style_name ?? "")")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#000000"))
                Spacer()
            }
            HStack{
                AsyncImage(url: URL(string: item.meta_data?.first?.original_image_path ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                } placeholder: {
                     Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .onTapGesture{
                let url = item.meta_data?.first?.original_image_path ?? ""
                imageURL = url
                if !url.isEmpty {
                    DispatchQueue.main.async {
                        showFullScreen = true
                    }
                }
            }
        }
    }
}

//翻译类型中间内容
struct TranslateMiddleContent: MiddleContent {
    @Binding var imageURL: String
    @Binding var showFullScreen: Bool
    let item: IndexItem
    
    // 符合MiddleContent协议的初始化器
    init(item: IndexItem) {
        self.item = item
        self._imageURL = .constant("")
        self._showFullScreen = .constant(false)
    }
    
    init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>) {
        self.item = item
        self._imageURL = imageURL
        self._showFullScreen = showFullScreen
    }
    

    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(item.meta_data?.first?.feature ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#000000"))
                Spacer()
            }
            HStack{
                AsyncImage(url: URL(string: item.meta_data?.first?.original_image_path ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                } placeholder: {
                    Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .onTapGesture{
                let url = item.meta_data?.first?.original_image_path ?? ""
                imageURL = url
                if !url.isEmpty {
                    DispatchQueue.main.async {
                        showFullScreen = true
                    }
                }
            }
        }
    }
}

  //资讯分析
struct InfoMiddleContent: MiddleContent {
        @Binding var imageURL: String
        @Binding var showFullScreen: Bool
        @Binding var videoURL: String
        @Binding var showVideoPreview: Bool
        let item: IndexItem
        
        // 符合MiddleContent协议的初始化器
        init(item: IndexItem) {
            self.item = item
            self._imageURL = .constant("")
            self._showFullScreen = .constant(false)
            self._videoURL = .constant("")
            self._showVideoPreview = .constant(false)
        }
        
        init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>, videoURL: Binding<String>, showVideoPreview: Binding<Bool>) {
            self.item = item
            self._imageURL = imageURL
            self._showFullScreen = showFullScreen
            self._videoURL = videoURL
            self._showVideoPreview = showVideoPreview
        }
        var body: some View {
            VStack(alignment: .leading) {  
            if item.cate == 1 {
                HStack{
                    AudioSpectrogram(audioURL: item.meta_data?.first?.path ?? "")
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    // 滚动检测逻辑可以在这里添加，但我们主要依赖 onAppear 触发
                }
            }
            if item.cate == 2 {    
                HStack {
                    AsyncImage(url: URL(string: item.meta_data?.first?.path ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:100,height: 100)
                             .clipShape(RoundedRectangle(cornerRadius: 12))

                    } placeholder: {
                         Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer()           
                }
                .onTapGesture{
                    let url = item.meta_data?.first?.path ?? ""
                    imageURL = url
                    if !url.isEmpty {
                        DispatchQueue.main.async {
                            showFullScreen = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)    
            }   
            if item.cate == 3 {
                HStack{
                    Image("icon_wb@3x_3")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 30, height: 30)
                     Text(item.meta_data?.first?.title ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#000000"))
                        
                    Spacer()
                }
                .padding(.horizontal,8)
                .padding(.vertical,8)
                .background(Color.white)
                .cornerRadius(8)
            }
            if item.cate == 4 {
                 HStack{
                    ZStack{
                       
                    AsyncImage(url: URL(string: item.meta_data?.first?.preview_url ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:100,height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                         Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                      Image("icon_data_play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    }
                     .onTapGesture{
                        let url = item.meta_data?.first?.path ?? ""
                        videoURL = url
                        if !url.isEmpty {
                            DispatchQueue.main.async {
                                showVideoPreview = true
                            }
                        }
                    }
                    
                        
                    Spacer()
                }
               
            }



            
           
        }
        }
    }
//食品内容
struct FoodMiddleContent: MiddleContent {
    @Binding var imageURL: String
    @Binding var showFullScreen: Bool
    let item: IndexItem
    
    // 符合MiddleContent协议的初始化器
    init(item: IndexItem) {
        self.item = item
        self._imageURL = .constant("")
        self._showFullScreen = .constant(false)
    }
    
    init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>) {
        self.item = item
        self._imageURL = imageURL
        self._showFullScreen = showFullScreen
    }
        var body: some View {
              VStack(alignment: .leading) { 
                    HStack{
                        Text(item.meta_data?.first?.feature ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#000000"))
                        Spacer()
                    }

                     HStack{
                        AsyncImage(url: URL(string: item.meta_data?.first?.original_image_path ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                        } placeholder: {
                            Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Spacer()
                    }
                     .onTapGesture{
                            let url = item.meta_data?.first?.original_image_path ?? ""
                            imageURL = url
                            if !url.isEmpty {
                                DispatchQueue.main.async {
                                    showFullScreen = true
                                }
                            }
                        }

              }
        }
    }


//图片类型视图
struct ImageMiddleContent: MiddleContent {
    @Binding var imageURL: String
    @Binding var showFullScreen: Bool
    let item: IndexItem
    
    // 符合MiddleContent协议的初始化器
    init(item: IndexItem) {
        self.item = item
        self._imageURL = .constant("")
        self._showFullScreen = .constant(false)
    }
    
    init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>) {
        self.item = item
        self._imageURL = imageURL
        self._showFullScreen = showFullScreen
    }
    
    var body: some View {
            VStack(alignment: .leading) { 
                   if let idea = item.idea, !idea.isEmpty {
                        HStack{
                            Text(idea)
                             .font(.system(size: 16))
                             .foregroundColor(Color(hex: "#000000"))
                            Spacer()
                        }
                    }
                HStack{
                    AsyncImage(url: URL(string: item.meta_data?.first?.path ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                    } placeholder: {
                         Image("占位图")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .onTapGesture {
                        let url = item.meta_data?.first?.path ?? ""
                        imageURL = url
                        if !url.isEmpty {
                            DispatchQueue.main.async {
                                showFullScreen = true
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.bottom,10)
                 if let location = item.location, !location.isEmpty {
                        HStack(alignment:.center,spacing:4){
                            Image("location")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            Text(item.location ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#828282"))
                            Spacer()
                        }
                    }   
            }
        }
    }
//视频类型视图
struct VideoMiddleContent: MiddleContent {
        @Binding var videoURL: String
        @Binding var showVideoPreview: Bool
        let item: IndexItem
        init(item: IndexItem) {
            self.item = item
            self._videoURL = .constant("")
            self._showVideoPreview = .constant(false)
        }
        init(item: IndexItem, videoURL: Binding<String>, showVideoPreview: Binding<Bool>) {
            self.item = item
            self._videoURL = videoURL
            self._showVideoPreview = showVideoPreview
        }
        var body: some View {
            VStack(alignment: .leading) { 
                  if let idea = item.idea, !idea.isEmpty {
                        HStack{
                            Text(idea)
                             .font(.system(size: 16))
                             .foregroundColor(Color(hex: "#000000"))
                            Spacer()
                        }
                    }
                HStack{                
                    ZStack {
                        let previewURLString = item.meta_data?.first?.preview_url ?? ""
                         CachedImageView(urlString: previewURLString)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            let url = item.meta_data?.first?.path ?? ""
                            videoURL = url
                            if !url.isEmpty {
                                DispatchQueue.main.async {
                                    showVideoPreview = true
                                }
                            }
                        }
                        Image("icon_data_play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.bottom,10)
                 if let location = item.location, !location.isEmpty {
                        HStack(alignment:.center,spacing:4){
                            Image("location")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            Text(item.location ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#828282"))
                            Spacer()
                        }
                    }   
            }
        }
    }






// 媒体项行视图
// 用于驱动 Sheet 的数据载体
struct ProjectSheetPayload: Identifiable {
    let id = UUID()
    let title: String
    let data: [MetaData]
}

struct FeatureSheetPayload: Identifiable {
    let id = UUID()
    let post_id: String
}



struct MediaItemRow: View {
    var item: IndexItem
    @Binding var currentPreviewVideoURL: String
    @Binding var showVideoPreview: Bool
    @Binding var currentPreviewImageURL: String
    @Binding var showImagePreview: Bool
    @Binding var showContinuity: Bool
    @Binding var current_post_id: String
    @Binding var showRemainingDataModal: Bool
    @Binding var taskTitle: String
    @Binding var metaItems: [MetaData]
    @Binding var sheetPayload: ProjectSheetPayload?
    @Binding var sheetAudioPayload: ProjectSheetPayload?
    @Binding var sheetTextPayload: ProjectSheetPayload?
    var openFeatureSheet: (String?) -> Void


    var body: some View {
        let bgColors = [Color(hex: "#fef0f0"), Color(hex: "#fef0f0").opacity(0.05)]
        let bgGradient = LinearGradient(gradient: Gradient(colors: bgColors), startPoint: .top, endPoint: .bottom)
        let borderStroke = RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#feeff0"), lineWidth: 1)
        let containerBase = AnyView(
            VStack(alignment: .leading, spacing: 0) {
                // 顶部时间
                HStack {
                    HStack {
                        Image("icon_home_time_point")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        Text(item.create_time)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.top,5)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture{
                    Task { @MainActor in
                        HomeNavigator.navigate(item)
                    }
                }
                
                // 中间内容
                let baseContent = AnyView(middleContent)
                let paddedContent = baseContent
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                let styledContent = paddedContent
                    .background(bgGradient)
                    .cornerRadius(10)
                let overlayedContent = styledContent
                    .overlay(borderStroke)
                let finalMiddleContent = overlayedContent
                    .shadow(color: Color(hex: "#feeff0"), radius: 3, x: 0, y: 8)

                finalMiddleContent
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture{
                        Task { @MainActor in
                            HomeNavigator.navigate(item)
                        }
                    }
                
                // 底部选项
                let bottomOptionsView = AnyView(VStack(spacing: 10) {
                    HStack {
                        HStack {
                            if item.is_authentication == 1 {
                                Image("icon_home_certification")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 55, height: 55)
                                    .padding(.trailing, 5)
                            } else{
                                Image("Group_221")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 55, height: 55)
                                    .padding(.trailing, 5)
                            }

                            if item.is_feature == 1 {
                                Image("icon_home_feature")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 45)
                                    .padding(.trailing, 5)
                                    .onTapGesture{
                                        openFeatureSheet(item.post_id)
                                    }
                            }
                            
                           
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            Image("icon_home_add")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            Text("再发一条")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#FF4949"))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#fef0f3"))
                        .cornerRadius(10)
                        .onTapGesture {
                            if item.source == 1 {
                                let aiCameraVC = MOAICameraVC()
                                    aiCameraVC.dataItem = item
                                let navController = UINavigationController(rootViewController: aiCameraVC)
                                navController.modalPresentationStyle = .fullScreen
                                navController.modalTransitionStyle = .coverVertical
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    var topVC = rootVC
                                    while let presentedVC = topVC.presentedViewController {
                                        topVC = presentedVC
                                    }
                                    topVC.present(navController, animated: true)
                                }
                            } else if item.source == 2 {
                                // 食品安全
                                let foodSafetyVC = MOFoodSafetyVC()
                                    foodSafetyVC.dataItem = item
                                let navController = UINavigationController(rootViewController: foodSafetyVC)
                                navController.modalPresentationStyle = .fullScreen
                                navController.modalTransitionStyle = .coverVertical
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    var topVC = rootVC
                                    while let presentedVC = topVC.presentedViewController {
                                        topVC = presentedVC
                                    }
                                    topVC.present(navController, animated: true)
                                }
                            } else if item.source == 3 {
                                if item.cate == 1 {
                                    Task { @MainActor in
                                        let baseView = UploadAudioController(dataItem: item)
                                        let rootView = baseView
                                            .toolbar(.hidden, for: .navigationBar)
                                            .toolbarColorScheme(.dark)
                                        let vc = UIHostingController(rootView: rootView)
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                } else if item.cate == 2 {
                                    Task { @MainActor in
                                        let baseView = PictureReleasePanel(dataItem: item)
                                        let rootView = baseView
                                            .toolbar(.hidden, for: .navigationBar)
                                            .toolbarColorScheme(.dark)
                                        let vc = UIHostingController(rootView: rootView)
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                } else if item.cate == 3 {
                                    Task { @MainActor in
                                        let baseView = TextReleasePanel(dataItem: item)
                                        let rootView = baseView
                                            .toolbar(.hidden, for: .navigationBar)
                                            .toolbarColorScheme(.dark)
                                        let vc = UIHostingController(rootView: rootView)
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                } else {
                                    Task { @MainActor in
                                        let baseView = VideoReleasePanel(dataItem: item)
                                        let rootView = baseView
                                            .toolbar(.hidden, for: .navigationBar)
                                            .toolbarColorScheme(.dark)
                                        let vc = UIHostingController(rootView: rootView)
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                }
                            } else if item.source == 4 {
                                let translateVC = MOTranslateTextOnImageVC()
                                 translateVC.dataItem = item
                                let navController = UINavigationController(rootViewController: translateVC)
                                navController.modalPresentationStyle = .fullScreen
                                navController.modalTransitionStyle = .coverVertical
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootVC = window.rootViewController {
                                    var topVC = rootVC
                                    while let presentedVC = topVC.presentedViewController {
                                        topVC = presentedVC
                                    }
                                    topVC.present(navController, animated: true)
                                }
                            } else if item.source == 5 {
                                // 资讯分析
                                Task { @MainActor in
                                    let baseView = InformationAnalysis(dataItem: item)
                                    let rootView = baseView
                                        .toolbarColorScheme(.dark)
                                    let vc = UIHostingController(rootView: rootView)
                                    vc.hidesBottomBarWhenPushed = true
                                    MOAppDelegate().transition.push(vc, animated: true)
                                }
                            }else if item.source == 6 {
                                //项目类型
                                if let userTaskId = item.user_task_id, userTaskId > 0 {
                                    // 进入项目详情页
                                     Task { @MainActor in
                                            guard let taskId = item.task_id else { return }
                                            let vc = UIHostingController(
                                                rootView: TaskDetailController(taskId: taskId, userTaskId: userTaskId)
                                                    .toolbar(.hidden, for: .navigationBar)
                                            )
                                            vc.hidesBottomBarWhenPushed = true
                                            MOAppDelegate().transition.push(vc, animated: true)
                                        }
                                }else{
                                    //先领取任务
                                     guard let taskId = item.task_id else { return }
                                     SceneTabContentViews.receiveTask(taskId: taskId) { success, newUserTaskId in
                                    guard success, let userTaskId = newUserTaskId else {
                                        return
                                    }
                                    Task { @MainActor in
                                        guard let taskId = item.task_id else { return }
                                        let vc = UIHostingController(
                                            rootView: TaskDetailController(taskId: taskId, userTaskId: userTaskId)
                                                .toolbar(.hidden, for: .navigationBar)
                                                
                                        )
                                        vc.hidesBottomBarWhenPushed = true
                                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                                 }
                                }
                            }
                        }
                    }
                    .padding(.top,-10)
                })
                let finalBottomOptionsView = bottomOptionsView
                    .padding(.top, 10)
                finalBottomOptionsView
                .contentShape(RoundedRectangle(cornerRadius: 10))
               

                //数据类型
                DataTypeModuleView(item: item)
                    .padding(.bottom,10)
                    .onTapGesture{
                        Task { @MainActor in
                            HomeNavigator.navigate(item)
                        }
                    }

                //连续
                ContinuityModuleView(item: item)
                .onTapGesture{
                    let parentPostID = item.parent_post_id
                    let pid = parentPostID.isEmpty ? item.post_id : parentPostID
                    if !pid.isEmpty {
                        current_post_id = pid
                        
                        showContinuity = true
                    } else {
                        MBProgressHUD.showMessag("未找到有效记录ID", to: nil, afterDelay: 2.0)
                    }
                }

            }
        )
        let paddedContainer = containerBase
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        let styledContainer = paddedContainer
            .background(Color.white)
            .cornerRadius(10)
        let containerBorder = RoundedRectangle(cornerRadius: 10)
            .stroke(Color(hex: "#f5f5f5"), lineWidth: 1)
        let finalContainer = styledContainer
            .overlay(containerBorder)
        finalContainer
       
    }
    
    // 中间内容视图
    @ViewBuilder
    private var middleContent: some View {
        switch item.source {
        case 1: // 吉卜力
            GhibliMiddleContent(item: item, imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview)
        case 2: // 食品安全
            FoodMiddleContent(item: item,imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview)
        case 3: // 自由传
            if item.cate == 1 {
                AudioMiddleContent(item: item)
            } else if item.cate == 2 {
                ImageMiddleContent(item: item, imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview)
            } else if item.cate == 3 {
                TextMiddleContent(item: item)
            } else if item.cate == 4 {
                VideoMiddleContent(item: item, videoURL: $currentPreviewVideoURL, showVideoPreview: $showVideoPreview)
            }
        case 4: // 翻译
           TranslateMiddleContent(item: item,imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview)
        case 5: // 资讯分析
            InfoMiddleContent(item: item,imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview,videoURL: $currentPreviewVideoURL, showVideoPreview: $showVideoPreview)  
        case 6: // 项目
            ProjectMiddleContent(item: item,imageURL: $currentPreviewImageURL, showFullScreen: $showImagePreview,videoURL: $currentPreviewVideoURL, showVideoPreview: $showVideoPreview, showRemainingDataModal: $showRemainingDataModal, taskTitle: $taskTitle, metaItems: $metaItems, sheetPayload: $sheetPayload,sheetAudioPayload:$sheetAudioPayload,sheetTextPayload:$sheetTextPayload)
        default:
              HStack{
                Text("暂无数据")
                  .font(.system(size: 16))
                  .foregroundColor(Color(hex: "#9B9B9B"))
              }
            
        }
    }
    
   
    
}

//项目类型视图
struct ProjectMiddleContent: MiddleContent{
     @Binding var imageURL: String
        @Binding var showFullScreen: Bool
        @Binding var videoURL: String
        @Binding var showVideoPreview: Bool
        @Binding var showRemainingDataModal: Bool
        @Binding var taskTitle: String
        @Binding var metaItems: [MetaData]
        @Binding var sheetPayload: ProjectSheetPayload?
        @Binding var sheetAudioPayload: ProjectSheetPayload?
        @Binding var sheetTextPayload: ProjectSheetPayload?
        
        let item: IndexItem
        
        // 符合MiddleContent协议的初始化器
        init(item: IndexItem) {
            self.item = item
            self._imageURL = .constant("")
            self._showFullScreen = .constant(false)
            self._videoURL = .constant("")
            self._showVideoPreview = .constant(false)
            self._showRemainingDataModal = .constant(false)
            self._taskTitle = .constant("")
            self._metaItems = .constant([])
            self._sheetPayload = .constant(nil)
            self._sheetAudioPayload = .constant(nil)
            self._sheetTextPayload = .constant(nil)
        }
        
        init(item: IndexItem, imageURL: Binding<String>, showFullScreen: Binding<Bool>, videoURL: Binding<String>, showVideoPreview: Binding<Bool>, showRemainingDataModal: Binding<Bool>, taskTitle: Binding<String>, metaItems: Binding<[MetaData]>, sheetPayload: Binding<ProjectSheetPayload?>,sheetAudioPayload: Binding<ProjectSheetPayload?>,sheetTextPayload: Binding<ProjectSheetPayload?> ) {
            self.item = item
            self._imageURL = imageURL
            self._showFullScreen = showFullScreen
            self._videoURL = videoURL
            self._showVideoPreview = showVideoPreview
            self._showRemainingDataModal = showRemainingDataModal
            self._taskTitle = taskTitle
            self._metaItems = metaItems
            self._sheetPayload = sheetPayload
            self._sheetAudioPayload = sheetAudioPayload
            self._sheetTextPayload = sheetTextPayload
        }
        var body: some View {
            VStack(alignment: .leading) {
                metaDataView
            }
        }
        
      
        
        @ViewBuilder
        private var metaDataView: some View {
            let metasArr = Array(item.meta_data ?? [])
            if !metasArr.isEmpty {
                VStack(alignment: .leading){
                    imageVideoView(metasArr: metasArr)
                    audioView(metasArr: metasArr)
                    textView(metasArr: metasArr)
                    
                }
                   HStack{
                    Image("icon_home_connect 1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                    Spacer()
                }
                .padding(.vertical,0)
                HStack{
                    Text(item.task_title ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#57548E"))
                    Spacer()
                }
                if let description = item.description, !description.isEmpty {
                    HStack{
                        Text("数据介绍")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#57548E"))
                        Spacer()
                    }
                    .padding(.vertical,10)
                    Text(description ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#000000"))
                        .lineLimit(2)
                        .padding(.bottom,10)
                        .multilineTextAlignment(.leading)
                }
              
            }
        }
        
        @ViewBuilder
        private func imageVideoView(metasArr: [MetaData]) -> some View {
            let imageVideo = metasArr.filter { $0.cate == 2 || $0.cate == 4 }
            if !imageVideo.isEmpty {
                GeometryReader { geometry in
                    let imageVideoLimited = Array(imageVideo.prefix(4))
                    let imageCount = imageVideoLimited.count
                    let spacing: CGFloat = 6
                    let hasMoreButton = imageVideo.count > 4
                    // 为"+剩余个数"按钮预留空间（估算：文字宽度 + padding）
                    let moreButtonWidth: CGFloat = hasMoreButton ? 45 : 0
                    
                    // 计算每个图片的宽度
                    // 可用宽度 = 总宽度 - 间距总和 - 按钮宽度（如果有）
                    let totalSpacing = CGFloat(max(0, imageCount - 1)) * spacing
                    let availableWidth = geometry.size.width - totalSpacing - moreButtonWidth
                    // 每个图片的宽度，最小50像素，最大70像素
                    let imageWidth = max(50, min(70, availableWidth / CGFloat(imageCount)))
                    
                    HStack(spacing: spacing) {
                        ForEach(Array(imageVideoLimited.enumerated()), id: \.offset) { idx, md in
                            imageVideoCell(
                                md: md,
                                idx: idx,
                                totalCount: imageVideo.count,
                                metasArr: metasArr,
                                imageWidth: imageWidth
                            )
                        }
                        // "+剩余个数"按钮放在第四个数据右边
                        if hasMoreButton {
                            Button(action:{
                                // 改为用 payload 驱动 sheet，确保数据就绪
                                let titleValue = item.task_title ?? ""
                                taskTitle = titleValue
                                metaItems = metasArr
                                if !titleValue.isEmpty {
                                    DispatchQueue.main.async {
                                        // 通过设置 payload 打开 sheet
                                        sheetPayload = ProjectSheetPayload(title: titleValue, data: metasArr)
                                    }
                                }
                            }){
                                Text("+ \(imageVideo.count - 4)")
                                .font(.system(size: 14))
                                .foregroundColor(Color.red)
                                .monospacedDigit()
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        Spacer()
                    }
                }
                .frame(height: 70) // 固定高度，避免布局跳动
                .padding(.vertical, 4)
            }
        }
        
        @ViewBuilder
        private func imageVideoCell(md: MetaData, idx: Int, totalCount: Int, metasArr: [MetaData], imageWidth: CGFloat) -> some View {
            ZStack {
                let isVideoCell = (md.is_video ?? 0) == 1 || md.cate == 4
                let previewURLString = md.preview_url ?? ""
                if isVideoCell {
                    CachedImageView(urlString: previewURLString)
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Image("icon_data_play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                } else {
                    CachedImageView(urlString: md.path ?? "")
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .onTapGesture {
                // 将两种来源统一解包为非可选 String，避免对 String? 调用 isEmpty
                let url: String = md.path ?? ""
                if md.is_video == 1 {
                    self.videoURL = url
                } else {
                    self.imageURL = url
                }
                if !url.isEmpty {
                    DispatchQueue.main.async {
                        if md.is_video == 1 {
                            self.showVideoPreview = true
                        } else {
                            self.showFullScreen = true
                        }
                    }
                }
            }
        }
    @ViewBuilder
    private func audioView(metasArr: [MetaData]) -> some View {
    let audios = metasArr.filter { $0.cate == 1 }
    if !audios.isEmpty {
        HStack(spacing: 8) {
            let audioLimited = Array(audios.prefix(1))
           ForEach(Array(audioLimited.enumerated()), id: \.offset) { idx, md in
                        audioCell(md: md, idx: idx, totalCount: audios.count, metasArr: metasArr)
                    }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    }

      @ViewBuilder
        private func audioCell(md: MetaData, idx: Int, totalCount: Int, metasArr: [MetaData]) -> some View {
            ZStack {
                let previewURLString = md.path ?? ""
                HStack{
                    AudioSpectrogram(audioURL: previewURLString)
                    Spacer()
                }
               
            }
            // “+剩余个数”放在第四个数据右边
            if idx == 0 && totalCount > 1 {
                Button(action:{
                    // 改为用 payload 驱动 sheet，确保数据就绪
                    let titleValue = item.task_title ?? ""
                    taskTitle = titleValue
                    metaItems = metasArr
                    if !titleValue.isEmpty {
                        DispatchQueue.main.async {
                            // 通过设置 payload 打开 sheet
                            sheetAudioPayload = ProjectSheetPayload(title: titleValue, data: metasArr)
                        }
                    }
                }){
                    Text("+ \(totalCount - 1)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.red)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading,0)
                .contentShape(Rectangle())
                
            }
        }

     @ViewBuilder
    private func textView(metasArr: [MetaData]) -> some View {
    let texts = metasArr.filter { $0.cate == 3 }
    if !texts.isEmpty {
        HStack(spacing: 8) {
            let textLimited = Array(texts.prefix(1))
            ForEach(Array(textLimited.enumerated()), id: \.offset) { idx, md in
                        textCell(md: md, idx: idx, totalCount: texts.count, metasArr: metasArr)
                    }
            Spacer()
        }
        .padding(.vertical, 4) // 与 audioView 保持一致的内边距
    }
    }

     @ViewBuilder
        private func textCell(md: MetaData, idx: Int, totalCount: Int, metasArr: [MetaData]) -> some View {
            ZStack {
                HStack(alignment: .center, spacing: 4) {
                    Image("icon_wb@3x_3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text(md.file_name ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color.black)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                // .frame(width: 300) // 与 audioCell 的宽度一致
                .background(Color(hex:"#ffffff"))
                .cornerRadius(8)
                .onTapGesture{
                    HomeViewController().NavigateToPreview(path: md.relative_path ?? "")
                }
            }
            // “+剩余个数”放在第一个数据右边
            if idx == 0 && totalCount > 1 {
                Button(action:{
                    // 改为用 payload 驱动 sheet，确保数据就绪
                    let titleValue = item.task_title ?? ""
                    taskTitle = titleValue
                    metaItems = metasArr
                    if !titleValue.isEmpty {
                        DispatchQueue.main.async {
                            // 通过设置 payload 打开 sheet
                            sheetTextPayload = ProjectSheetPayload(title: titleValue, data: metasArr)
                        }
                    }
                }){
                    Text("+ \(totalCount - 1)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.red)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, 0)
                .contentShape(Rectangle())
            }
        }
        
     
        
        // MARK: - Helpers
        private func isImage(_ url: String) -> Bool {
            let lower = url.lowercased()
            return lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") || lower.hasSuffix(".png") || lower.hasSuffix(".webp") || lower.contains("x-oss-process=image")
        }
        
        private func isAudio(_ url: String) -> Bool {
            let lower = url.lowercased()
            return lower.hasSuffix(".mp3") || lower.hasSuffix(".m4a") || lower.hasSuffix(".wav") || lower.hasSuffix(".aac") || lower.hasSuffix(".flac")
        }
}

// 数据类型模块视图
struct DataTypeModuleView: View {
    let item: IndexItem
    var body: some View {
        if item.source != 6 && item.source != 3 {
            HStack{
                if item.source == 1 {
                    HStack(alignment:.center,spacing:5){
                         Image("icon_ai_camera_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(item.ai_tool?.name ?? "")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex: "#000000"))
                              .lineLimit(1)
                    }
                    Spacer()
                    HStack(alignment:.center,spacing:5){
                        Text(item.create_time)
                              .font(.system(size: 12))
                              .foregroundColor(Color(hex: "#AFAFAF"))
                              .lineLimit(1)                             
                        Image("Right_(右) 1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                    }
                   
                } else if item.source == 2 {
                     HStack(alignment:.center,spacing:5){
                         Image("icon_home_analys")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(item.ai_tool?.name ?? "")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex: "#000000"))
                              .lineLimit(1)
                    }
                    Spacer()
                    HStack(alignment:.center,spacing:5){
                        Text(item.create_time)
                              .font(.system(size: 12))
                              .foregroundColor(Color(hex: "#AFAFAF"))
                              .lineLimit(1)                             
                        Image("Right_(右) 1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                    }
                } else if item.source == 4 {
                      HStack(alignment:.center,spacing:5){
                         Image("icon_home_translate")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(item.ai_tool?.name ?? "")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex: "#000000"))
                              .lineLimit(1)
                    }
                    Spacer()
                    HStack(alignment:.center,spacing:5){
                        Text(item.create_time)
                              .font(.system(size: 12))
                              .foregroundColor(Color(hex: "#AFAFAF"))
                              .lineLimit(1)                             
                        Image("Right_(右) 1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                    }
                } else if item.source == 5 {
                    HStack(alignment:.center,spacing:5){
                         Image("icon_home_analyze")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(item.ai_tool?.name ?? "")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex: "#000000"))
                              .lineLimit(1)
                    }
                    Spacer()
                    HStack(alignment:.center,spacing:5){
                        Text(item.create_time)
                              .font(.system(size: 12))
                              .foregroundColor(Color(hex: "#AFAFAF"))
                              .lineLimit(1)                             
                        Image("Right_(右) 1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                    }
                } 
            }
            .padding(.vertical,10)
            .padding(.horizontal,5)
            .frame(maxWidth: .infinity)
          
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#f5f5f5"), lineWidth: 1)
            )
        }
    }
}

// 连续模块视图
struct ContinuityModuleView: View {
    let item: IndexItem
    var body: some View {
        if ((item.continuity?.total ?? 0) > 0) || ((item.continuity?.time?.isEmpty == false)) {
            HStack{
                HStack(alignment:.center,spacing:5){
                    Image("icon_home_continuous")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("连续")
                          .font(.system(size: 16))
                          .foregroundColor(Color(hex: "#000000"))
                          .lineLimit(1)
                    Text("\(item.continuity?.total ?? 0)")
                          .font(.system(size: 12))
                          .foregroundColor(Color(hex: "#AFAFAF"))
                          .lineLimit(1)
                }
                Spacer()
                HStack(alignment:.center,spacing:5){
                    Text(item.continuity?.time ?? "")
                          .font(.system(size: 12))
                          .foregroundColor(Color(hex: "#AFAFAF"))
                          .lineLimit(1)
                      Image("Right_(右) 1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(.vertical,10)
            .padding(.horizontal,5)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#f5f5f5"), lineWidth: 1)
            )
        }
    }
}

// 主视图控制器
struct HomeViewController: View {
    @State private var currentPage: Int = 1
    @State private var limit: Int = 10
    @State private var showImagePreview: Bool = false
    @State private var currentPreviewImageURL: String = ""
    @State private var currentPreviewVideoURL: String = ""
    @State private var showVideoPreview: Bool = false
    @State private var showRemainingDataModal: Bool = false
    @State private var sheetPayload: ProjectSheetPayload? = nil
    @State private var sheetAudioPayload: ProjectSheetPayload? = nil
    @State private var sheetTextPayload: ProjectSheetPayload? = nil
    @State private var sheetFeaturePayload: FeatureSheetPayload? = nil

    @State private var taskTitle: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var loadMoreError: String? = nil
    @State private var errorMessage: String? = nil
    @State private var mediaItems: [IndexItem] = []
    @State private var data_count: Int = 0
    @State private var task_count: Int = 0
    @State private var account_balance: String = "0.00"
    @State private var yesterday_income: String = "0.00"
    @State private var current_post_id: String = ""  //当前记录的parent_post_id
    @State private var metaItems: [MetaData] = []

     @State private var showContinuity = false
    @State private var bellPressed = false
    
    // 下拉刷新相关状态变量
    @State private var pullRefreshState: PullRefreshState = .idle
    @State private var pullOffset: CGFloat = 0
    @State private var lastRefreshTime: Date = Date()
    @State private var refreshThreshold: CGFloat = 80
    @State private var arrowRotation: Double = 0
    @State private var showRefreshView: Bool = false
    
    // 新增性能优化相关状态
    @State private var preloadThreshold: Int = 3 // 距离底部3个item时开始预加载
    @State private var isInitialLoading: Bool = true
    @State private var loadingTask: Task<Void, Never>? = nil

    @State private var showNotificationModal = false
    @State private var isLocationAuthorized: Bool = false
    @State private var showPermissionGrantedToast: Bool = false
    @State private var fileUrl: String = ""
    func openFeatureSheet(post_id: String?) {
        guard let pid = post_id else { return }
        sheetFeaturePayload = FeatureSheetPayload(post_id:pid)
    }

    // 定位权限状态更新
    func updateLocationAuthorizationStatus() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = CLLocationManager.authorizationStatus()
        } else {
            status = CLLocationManager().authorizationStatus
        }
        isLocationAuthorized = (status == .authorizedAlways || status == .authorizedWhenInUse)
    }

    //开启定位对话框
    @ViewBuilder
    func openLocation() -> some View {
        HStack{
            Text("在设置中开启定位权限，以获取当前位置的Mobiwusi数据项目")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#000000"))
                Spacer()
            HStack{
                Text("去开启")
                 .font(.system(size: 14))
                 .foregroundColor(Color(hex: "#ffffff"))
            }
            .padding(.horizontal,10)
            .padding(.vertical,5)
            .background(Color(hex:"#9A1E2E"))
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture {
                Task { @MainActor in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .padding(.vertical,12)
        .padding(.horizontal,10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal,14)
       
    }
    
   
  
    var body: some View {
            ZStack(alignment:.top) {
                if showPermissionGrantedToast {
                    VStack {
                        Spacer()
                        Text("用户已经在权限设置页授予了所需权限")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(8)
                            .padding(.top, 80)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .zIndex(1000)
                }
                // 全屏背景色
                Color(hex: "#f7f8fa")
                    .ignoresSafeArea()
                
                // 顶部背景图片
                VStack {
                    Image("bg_home")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .ignoresSafeArea()
               VStack{
                VStack(spacing:2){
                      // 顶部导航栏
                        HStack {
                            Image("home_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 160, alignment: .center)
                            
                            Spacer()
                                 Button(action: {
                                    showNotificationModal = true
                                    }) {
                                      
                                            Image("fi_bell")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .padding(.vertical,20)
                                            .padding(.horizontal,20)
                                            .scaleEffect(bellPressed ? 0.9 : 1.0)
                                            .opacity(bellPressed ? 0.7 : 1.0)
                                            .animation(.easeInOut(duration: 0.1), value: bellPressed)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                     .contentShape(Rectangle())  
                                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                        bellPressed = pressing
                                    }, perform: {})
                                    .padding(.trailing,-20)
                                Button(action:{
                                      Task { @MainActor in
                                                        let vc = UIHostingController(
                                                            rootView: SearchViewController()
                                                                .toolbar(.hidden, for: .navigationBar)
                                                                
                                                        )
                                                        vc.hidesBottomBarWhenPushed = true
                                                        MOAppDelegate().transition.push(vc, animated: true)
                                                    }
                                }){
                                     Image("icon_home_search")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .padding(.vertical,20)
                                        .padding(.leading,20)
                                }
                                 .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())  
                               
                                     
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top,-20)
                        .onAppear {
                            updateLocationAuthorizationStatus()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                            let wasAuth = isLocationAuthorized
                            updateLocationAuthorizationStatus()
                            if !wasAuth && isLocationAuthorized {
                                // 授权刚生效，立即启动一次定位更新以获取经纬度
                                MOLocationManager.shared.startUpdatingLocation()
                                showPermissionGrantedToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showPermissionGrantedToast = false
                                    }
                                }
                            }
                        }
                     
                        ZStack(alignment:.top){
                        // 统计信息
                        HStack(alignment: .center,spacing: 0) {                         
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("总资产（元）")
                                         .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Text("\(account_balance)")
                                        .font(.custom("Satoshi-Bold", size: 20))
                                        .foregroundColor(Color(hex: "#9A1E2E"))
                                }
                                 .onTapGesture{
                                    Task { @MainActor in
                                                let vc = UIHostingController(
                                                    rootView:   MOPropertyViewControllerWrapper()
                                                    .toolbar(.hidden, for: .navigationBar)
                                                    .ignoresSafeArea(.all)
                                                )
                                                vc.hidesBottomBarWhenPushed = true
                                                MOAppDelegate().transition.push(vc, animated: true)
                                        }
                                }
                                .frame(maxWidth: .infinity)             
                            .buttonStyle(PlainButtonStyle())

                            VStack(alignment: .leading, spacing: 10) {
                                Text("新增收益")
                                      .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("\(yesterday_income)")
                                      .font(.custom("Satoshi-Bold", size: 20))
                                    .foregroundColor(Color.black)
                            }
                            .onTapGesture{
                                Task { @MainActor in
                                            let vc = UIHostingController(
                                                rootView:   MOPropertyViewControllerWrapper()
                                                .toolbar(.hidden, for: .navigationBar)
                                                 .ignoresSafeArea(.all)
                                            )
                                            vc.hidesBottomBarWhenPushed = true
                                            MOAppDelegate().transition.push(vc, animated: true)
                                    }
                            }
                            .frame(maxWidth: .infinity)     
                         .buttonStyle(PlainButtonStyle())
                            VStack(alignment: .leading, spacing: 10) {
                                Text("我的数据")
                                     .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("\(data_count)")
                                      .font(.custom("Satoshi-Bold", size: 20))
                                     .foregroundColor(Color.black)
                            }
                            .onTapGesture{
                                   Task { @MainActor in
                                            let vc = UIHostingController(
                                                rootView:  MyDataController(initialCategory: 1)
                                            )
                                            vc.hidesBottomBarWhenPushed = true
                                            MOAppDelegate().transition.push(vc, animated: true)
                                    }
                            }
                            .frame(maxWidth: .infinity)                       
                            VStack(alignment: .leading, spacing: 10) {
                                Text("我的项目")
                                     .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("\(task_count)")
                                      .font(.custom("Satoshi-Bold", size: 20))
                                    .foregroundColor(Color.black)
                            }
                             .onTapGesture{
                                   Task { @MainActor in
                                            let vc = UIHostingController(
                                                rootView:   MyProjectController(initialSelectedTab: 0)
                                                .toolbar(.hidden, for: .navigationBar)
                                            )
                                            vc.hidesBottomBarWhenPushed = true
                                            MOAppDelegate().transition.push(vc, animated: true)
                                    }
                            }
                            .frame(maxWidth: .infinity)
                         
                         .buttonStyle(PlainButtonStyle())
                        }
                          if !isLocationAuthorized {
                              openLocation()
                              .padding(.top,30)
                          }
                }
                        
                       
                }
              
                ScrollView(showsIndicators:false) {                              
                        VStack(spacing: 0) {                                              
                            // 媒体项列表
                        if mediaItems.isEmpty {
                            VStack(spacing: 20) {
                                Image("icon_data_empty")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                
                                Text("无数据")
                                    .font(.system(size: 16).bold())
                                    .foregroundColor(Color(hex: "#000000"))
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(Array(mediaItems.enumerated()), id: \.offset) { index, item in
                                    MediaItemRow(item: item, currentPreviewVideoURL: $currentPreviewVideoURL, showVideoPreview: $showVideoPreview, currentPreviewImageURL: $currentPreviewImageURL, showImagePreview: $showImagePreview, showContinuity: $showContinuity, current_post_id: $current_post_id, showRemainingDataModal: $showRemainingDataModal, taskTitle: $taskTitle, metaItems: $metaItems, sheetPayload: $sheetPayload, sheetAudioPayload: $sheetAudioPayload, sheetTextPayload: $sheetTextPayload, openFeatureSheet: openFeatureSheet)
                                        .onAppear {
                                            // 预加载机制：当接近列表底部时开始加载更多数据
                                            if index >= mediaItems.count - preloadThreshold && hasMoreData && !isLoadingMore {
                                                loadIndexData(isLoadMore: true)
                                            }
                                        }
                                }
                                
                                // 初始加载状态指示器
                                if isInitialLoading && mediaItems.isEmpty {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                        Text("正在加载数据...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 40)
                                }
                                
                                // 分页加载状态指示器
                                if hasMoreData && !mediaItems.isEmpty {
                                    HStack {
                                        Spacer()
                                        if isLoadingMore {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("加载中...")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                                .padding(.leading, 8)
                                        } else {
                                            Text("上拉加载更多")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                    .onAppear {
                                        if !isLoadingMore && hasMoreData {
                                            loadIndexData(isLoadMore: true)
                                        }
                                    }
                                } else if !mediaItems.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("已加载全部数据")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                }
                                
                                // 错误重试
                                if let error = loadMoreError, !error.isEmpty {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 10) {
                                            Text("加载失败")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red)
                                            Button("点击重试") {
                                                loadMoreError = nil
                                                loadIndexData(isLoadMore: true)
                                            }
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                }
                            }
                            // .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 14)
            
               
            }
            // Spacer()
            }
             .sheet(isPresented: $showContinuity) {       
               NavigationStack {
                   ContinuousController(current_post_id: $current_post_id)
                       .id(current_post_id)
                       .navigationTitle("连续")
                       .navigationBarTitleDisplayMode(.inline)
               }
               .presentationDetents([.fraction(0.9), .large])
               .presentationDragIndicator(.hidden)
               //设置sheet面板的左右上角的圆角大小
               .presentationCornerRadius(20)   // 在这设置圆角半径
               
           }      
          NavigationLink(destination: NotificationController(), isActive: $showNotificationModal) {
                                EmptyView()
                            }
          
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // 取消之前的加载任务
            loadingTask?.cancel()
            
            // 防重复加载：只有在数据为空或距离上次刷新超过5分钟时才重新加载
            let shouldReload = mediaItems.isEmpty || 
                              Date().timeIntervalSince(lastRefreshTime) > 300
            
            if shouldReload {
                // 重置分页状态，确保从第一页开始显示
                currentPage = 1
                hasMoreData = true
                
                // 异步加载数据，避免阻塞主线程
                loadingTask = Task {
                    isInitialLoading = true
                    
                    // 并发加载数据
                    async let indexDataTask = loadIndexDataAsync()
                    async let myDataTask = fetchMyDataAsync()
                    
                    await indexDataTask
                    await myDataTask
                    
                    await MainActor.run {
                        isInitialLoading = false
                    }
                }
            }
        }
        .refreshable {
            await performRefreshAsync()
        }
        .onDisappear {
            // 取消正在进行的加载任务
            loadingTask?.cancel()
            loadingTask = nil
            
            // 清理图片缓存以释放内存
            if mediaItems.count > 50 {
                ImageCacheManager.shared.clearCache()
            }
        }
        .sheet(item: $sheetPayload) { payload in
            ProjectPictureVideoDataView(title: payload.title, data: payload.data, showImagePreview: $showImagePreview, showVideoPreview: $showVideoPreview, imageURL: $currentPreviewImageURL, videoURL: $currentPreviewVideoURL)
        }
        .presentationDetents([.fraction(0.9), .medium])
        .presentationDragIndicator(.hidden)

         .sheet(item: $sheetAudioPayload) { payload in
            ProjectAudioDataView(title: payload.title, data: payload.data)
        }
        .presentationDetents([.fraction(0.5), .medium])
        .presentationDragIndicator(.hidden)
          
            
        .sheet(item: $sheetTextPayload) { payload in
            ProjectTextDataView(title: payload.title, data: payload.data)
        }
        .presentationDetents([.fraction(0.5), .medium])
        .presentationDragIndicator(.hidden)

        .sheet(item: $sheetFeaturePayload) { payload in
            FeatureSheetController(post_id: payload.post_id, onClose: { sheetFeaturePayload = nil })
              .presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(20)   // 在这设置圆角半径
               
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

    @ViewBuilder
    private func ProjectAllData(title:String,data:[MetaData]) -> some View {
        VStack(spacing: 10) {
            // 标题：非空则显示标题，空则显示默认文案
            Text(title.isEmpty ? "" : title)
                .font(.system(size: 16))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
                .padding(.horizontal,12)
            if data.isEmpty {
                // 空态占位，避免看起来是“空白”视图
                HStack{
                    Spacer()
                    VStack(spacing:10){
                        Image("icon_data_empty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        Text("暂无数据")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#000000"))
                    }
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        // 图片/视频：三列网格
                        let imageVideoItems = data.filter { ($0.cate == 2) || ($0.cate == 4) }
                       
                        if !imageVideoItems.isEmpty {
                            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(imageVideoItems.indices, id: \.self) { idx in
                                    let item = imageVideoItems[idx]
                                    ZStack {
                                        CachedImageView(urlString: (item.is_video ?? 0) == 1 ? (item.preview_url ?? "") : (item.path ?? ""))
                                            .frame(width: 120, height: 120)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        if (item.cate == 4) || ((item.is_video ?? 0) == 1) {
                                            Image("icon_data_play")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.5))
                                                .clipShape(Circle())
                                        }
                                    }
                                      .onTapGesture {
                                        let isVideo = ((item.is_video ?? 0) == 1) || (item.cate == 4)
                                        if isVideo {
                                            let videoURL = item.path ?? ""
                                            if !videoURL.isEmpty {
                                                currentPreviewVideoURL = videoURL
                                                DispatchQueue.main.async { showVideoPreview = true }
                                            }
                                        } else {
                                            let imageURL = item.path ?? ""
                                            if !imageURL.isEmpty {
                                                currentPreviewImageURL = imageURL
                                                DispatchQueue.main.async { showImagePreview = true }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                        }

                        // 音频/文本：独占一行
                        let audioTextItems = data.filter { ($0.cate == 1) || ($0.cate == 3) }
                        if !audioTextItems.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(audioTextItems.indices, id: \.self) { idx in
                                    let item = audioTextItems[idx]
                                    HStack(spacing: 10) {
                                        Image(item.cate == 1 ? "icon_data_sp" : "icon_data_wb")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                        Text(item.file_name ?? "数据项")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#333333"))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
        }
        .padding(.vertical,10)
    }

    
    // 首页数据 - 传统回调模式
    // 在 HomeViewController 中添加这个方法
    private func loadIndexData(isLoadMore: Bool = false) {
        // 如果是加载更多，设置相应状态
        if isLoadMore {
            if isLoadingMore || !hasMoreData {
                return // 防止重复请求或没有更多数据时的请求
            }
            isLoadingMore = true
            loadMoreError = nil
        } else {
            // 首次加载或刷新
            isLoading = true
            currentPage = 1
            hasMoreData = true
            errorMessage = nil
        }
        
        let requestBody: [String: Any] = [
            "page": currentPage,
            "limit": limit
        ]
        
        NetworkManager.shared.post(APIConstants.Index.index, businessParameters: requestBody) { (result: Result<IndexResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):                 
                    if response.code == 1 {
                        let newItems = response.data
                        
                        if isLoadMore {
                            // 追加数据
                            self.mediaItems.append(contentsOf: newItems)
                            self.isLoadingMore = false
                            
                            // 检查是否还有更多数据
                            if newItems.count < self.limit {
                                self.hasMoreData = false
                            } else {
                                self.currentPage += 1
                            }
                        } else {
                            // 首次加载或刷新，替换数据
                            self.mediaItems = newItems
                            self.isLoading = false
                            
                            // 检查是否还有更多数据
                            if newItems.count < self.limit {
                                self.hasMoreData = false
                            } else {
                                self.currentPage += 1 // 递增页码
                            }
                        }
                        
                        self.errorMessage = nil
                        self.loadMoreError = nil
                    } else {
                        let errorMsg = "服务器返回错误: \(response.msg)"
                        print("❌ 服务器返回错误码: \(response.code)")
                        print("⚠️ 错误信息: \(response.msg)")
                        
                        if isLoadMore {
                            self.loadMoreError = errorMsg
                            self.isLoadingMore = false
                        } else {
                            self.errorMessage = errorMsg
                            self.isLoading = false
                        }
                    }
                    
                case .failure(let error):
                    let errorMsg = "网络请求失败: \(error.localizedDescription)"
                    print("❌ 网络请求失败: \(error.localizedDescription)")
                    
                    if isLoadMore {
                        self.loadMoreError = errorMsg
                        self.isLoadingMore = false
                    } else {
                        self.errorMessage = errorMsg
                        self.isLoading = false
                    }
                }
            }
        }
    }

    //MARK：- 我的数据
     private func fetchMyData(isRefresh: Bool = false) {
        errorMessage = nil
        
        NetworkManager.shared.post(APIConstants.Profile.getMyData, businessParameters: [:]) { (result: Result<UserProfileResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        data_count = response.data?.data_count ?? 0
                        task_count = response.data?.task_count ?? 0
                        account_balance = response.data?.account_balance ?? "0.0"
                        yesterday_income = response.data?.yesterday_income ?? "0.0"
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                
               
            }
        }
    }
    
    
    
    // 执行刷新操作（异步版本，用于 refreshable）
    private func performRefreshAsync() async {
        // 重置分页参数
        currentPage = 1
        hasMoreData = true
        loadMoreError = nil
        
        // 使用 Task 来包装网络请求
        await withTaskGroup(of: Void.self) { group in
            // 加载首页数据
            group.addTask {
                await self.loadIndexDataAsync()
            }
            
            // 加载我的数据
            group.addTask {
                await self.fetchMyDataAsync()
            }
        }
        
        // 更新刷新时间
        lastRefreshTime = Date()
    }
    
    // 异步加载首页数据
    private func loadIndexDataAsync(isLoadMore: Bool = false) async {
        let requestBody: [String: Any] = [
            "page": currentPage,
            "limit": limit
        ]
        
        return await withCheckedContinuation { continuation in
            NetworkManager.shared.post(APIConstants.Index.index, businessParameters: requestBody) { (result: Result<IndexResponse, APIError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.code == 1 {
                            let newItems = response.data
                            
                            if isLoadMore {
                                // 加载更多：追加到现有数据
                                self.mediaItems.append(contentsOf: newItems)
                                self.isLoadingMore = false
                            } else {
                                // 首次加载或刷新：替换所有数据
                                self.mediaItems = newItems
                                self.isLoading = false
                            }
                            
                            // 检查是否还有更多数据
                            if newItems.count < self.limit {
                                self.hasMoreData = false
                            } else {
                                self.currentPage += 1 // 递增页码
                            }
                            
                            self.errorMessage = nil
                            self.loadMoreError = nil
                        } else {
                            let errorMsg = "服务器返回错误: \(response.msg)"
                            if isLoadMore {
                                self.loadMoreError = errorMsg
                                self.isLoadingMore = false
                            } else {
                                self.errorMessage = errorMsg
                                self.isLoading = false
                            }
                        }
                    case .failure(let error):
                        let errorMsg = "网络请求失败: \(error.localizedDescription)"
                        if isLoadMore {
                            self.loadMoreError = errorMsg
                            self.isLoadingMore = false
                        } else {
                            self.errorMessage = errorMsg
                            self.isLoading = false
                        }
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    // 异步加载我的数据
    private func fetchMyDataAsync() async {
        return await withCheckedContinuation { continuation in
            NetworkManager.shared.post(APIConstants.Profile.getMyData, businessParameters: [:]) { (result: Result<UserProfileResponse, APIError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.code == 1 {
                            self.data_count = response.data?.data_count ?? 0
                            self.task_count = response.data?.task_count ?? 0
                            self.account_balance = response.data?.account_balance ?? "0.0"
                            self.yesterday_income = response.data?.yesterday_income ?? "0.0"
                        } else {
                            self.errorMessage = response.msg
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                    continuation.resume()
                }
            }
        }
    }

     func NavigateToPreview(path:String) {
             let requestBody: [String: Any] = [
                    "path": path,
                ]
             NetworkManager.shared.post(APIConstants.Index.getPreviewUrl, 
                                 businessParameters: requestBody) { (result: Result<GetPreviewUrlResponse, APIError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.code == 1{
                            if let url = response.data?.url, !url.isEmpty, URL(string: url) != nil {
                                // 创建网页预览视图
                                let previewView = TutorialWebViewPage(urlString: url, title: "预览")
                                // 使用 UIHostingController 包装并推入新页面
                                let vc = UIHostingController(rootView: previewView)
                                vc.hidesBottomBarWhenPushed = true
                                MOAppDelegate().transition.push(vc, animated: true)
                            } else {
                                errorMessage = "预览URL无效或为空"
                                MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                            }
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
    
    
    
   

}

// 图片预览覆盖层
// MARK: - 通用全屏图片查看器组件
// MARK: - 子视图：标题
struct SectionTitleView: View {
    let title: String
    var body: some View {
        Text(title.isEmpty ? "" : title)
            .font(.system(size: 16))
            .foregroundColor(Color.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
            .padding(.horizontal,12)
    }
}

// MARK: - 子视图：空态
struct DataEmptyView: View {
    var body: some View {
        HStack{
            Spacer()
            VStack(spacing:10){
                Image("icon_data_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                Text("暂无数据")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#000000"))
            }
            Spacer()
        }
    }
}

// MARK: - 子视图：图片/视频网格
struct ImageVideoGridView: View {
    let items: [MetaData]
    let onItemTap: (MetaData) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                let item = items[idx]
                let isVideoThumb = ((item.is_video ?? 0) == 1)
                let thumbURL = isVideoThumb ? (item.preview_url ?? "") : (item.path ?? "")
                ZStack {
                    CachedImageView(urlString: thumbURL)
                        .frame(width: 120, height: 120)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    if (item.cate == 4) || ((item.is_video ?? 0) == 1) {
                        Image("icon_data_play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .onTapGesture { onItemTap(item) }
            }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - 子视图：音频列表
struct AudioListView: View {
    let items: [MetaData]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                let item = items[idx]
                HStack(spacing: 10) {
                    AudioSpectrogram(audioURL: item.path ?? "")
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
    }
}

struct TextListView: View {
    let items: [MetaData]
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                let item = items[idx]
                HStack{
                HStack(spacing: 10) {
                    Image("icon_wb@3x_3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text(item.file_name ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#000000"))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex:"#F7F8FA"))
                .cornerRadius(8)
               
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - 主视图
struct ProjectPictureVideoDataView: View {
    let title: String
    let data: [MetaData]
    @Binding var showImagePreview: Bool
    @Binding var showVideoPreview: Bool
    @Binding var imageURL: String
    @Binding var videoURL: String

    // 本地覆盖层预览状态（项目类型 sheet 内使用）
    @State private var localShowImagePreview: Bool = false
    @State private var localShowVideoPreview: Bool = false
    @State private var localImageURL: String = ""
    @State private var localVideoURL: String = ""

    private var imageVideoItems: [MetaData] { data.filter { ($0.cate == 2) || ($0.cate == 4) } }
    private var audioTextItems: [MetaData] { data.filter { ($0.cate == 1) || ($0.cate == 3) } }

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                SectionTitleView(title: title)
                if data.isEmpty {
                    DataEmptyView()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            if !imageVideoItems.isEmpty {
                                ImageVideoGridView(items: imageVideoItems) { item in
                                    let isVideo = ((item.is_video ?? 0) == 1) || (item.cate == 4)
                                    if isVideo {
                                        let url = item.path ?? ""
                                        if !url.isEmpty {
                                            localVideoURL = url
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0.2)) {
                                                localShowVideoPreview = true
                                            }
                                        }
                                    } else {
                                        let url = item.path ?? ""
                                        if !url.isEmpty {
                                            localImageURL = url
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0.2)) {
                                                localShowImagePreview = true
                                            }
                                        }
                                    }
                                }
                            }
                           
                        }
                    }
                }
            }

            if localShowImagePreview {
                FullScreenImgView(imageURL: localImageURL, isPresented: $localShowImagePreview)
                    .id(localImageURL)
                    .toolbar(.hidden, for: .tabBar)
                    .transition(.asymmetric(insertion: .scale(scale: 0.98).combined(with: .opacity), removal: .opacity))
                    .zIndex(10)
            }
            if localShowVideoPreview {
                FullScreenVideoView(videoURL: localVideoURL, isPresented: $localShowVideoPreview)
                    .id(localVideoURL)
                    .toolbar(.hidden, for: .tabBar)
                    .transition(.asymmetric(insertion: .scale(scale: 0.98).combined(with: .opacity), removal: .opacity))
                    .zIndex(10)
            }
        }
    }
}

struct ProjectAudioDataView: View {
    let title: String
    let data: [MetaData]
    private var audioItems: [MetaData] { data.filter { ($0.cate == 1) } }

    var body: some View {
        ZStack {
            Color(hex:"#F7F8FA")
             .ignoresSafeArea()
            VStack(spacing: 10) {
                SectionTitleView(title: title)
                if data.isEmpty {
                    DataEmptyView()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            if !audioItems.isEmpty {
                                AudioListView(items: audioItems)
                            }
                        }
                    }
                }
            }
            
        }
    }
}

struct ProjectTextDataView: View {
    let title: String
    let data: [MetaData]
    private var textItems: [MetaData] { data.filter { ($0.cate == 3) } }

    var body: some View {
        ZStack {
            Color(hex:"#F7F8FA")
             .ignoresSafeArea()
            VStack(spacing: 10) {
                SectionTitleView(title: title)
                if data.isEmpty {
                    DataEmptyView()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            if !textItems.isEmpty {
                                TextListView(items: textItems)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FeatureSheetController: View{
    let post_id: String
    // var height: CGFloat = UIScreen.main.bounds.height * 0.4
    var onClose: (() -> Void)? = nil
    @State private var featureData: [FeatureItem] = []
    @State private var errorMessage: String? = nil
    var body: some View {
        ZStack {
            Color(hex:"#F7F8FA")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack{
                   Text("数据特征")
                       .font(.system(size: 16,weight: .bold))
                       .foregroundColor(Color(hex: "#000000"))
               }
               .padding(.vertical,18)
               if !featureData.isEmpty {
                
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(Array(featureData.enumerated()), id: \.offset) { index, item in
                                featureView(item: item)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical,10)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
              .onAppear{
                    fetchFeatureData(post_id: post_id)
                }

         }
        
    

    @ViewBuilder
    func featureView(item: FeatureItem) -> some View {
        switch item.cate {
        case 1:
            AudioFeatureView(item: item)
        case 2:
            ImageFeatureView(item: item)
        case 3:
            TextFeatureView(item: item)
        case 4:
            VideoFeatureView(item: item)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func AudioFeatureView(item: FeatureItem) -> some View {
        VStack(spacing:10){
            HStack{
                AudioSpectrogram(audioURL: item.file_url)
            }
             .padding(.horizontal, 12)
            .padding(.vertical,8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex:"#F7F8FA"))
            .cornerRadius(12)
            //分割线
            Divider()
            //每行4列遍历item.feature,标题是name，值是value
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(item.feature, id: \.name) { feature in
                    HStack(spacing:20){
                        Text(feature.name)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9B9B9B"))
                        Text(feature.value)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#000000"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.vertical,10)
                }
            }
        }
    }

     @ViewBuilder
    func TextFeatureView(item: FeatureItem) -> some View {
        VStack(spacing:10){
            HStack{
                Image("icon_wb@3x_3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(item.file_name ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#000000"))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical,8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex:"#F7F8FA"))
            .cornerRadius(12)
            //分割线
            Divider()
           LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(item.feature, id: \.name) { feature in
                    HStack(spacing:20){
                        Text(feature.name)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9B9B9B"))
                        Text(feature.value)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#000000"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.vertical,10)
                }
            }
        }
    }

      @ViewBuilder
    func ImageFeatureView(item: FeatureItem) -> some View {
        VStack(spacing:10){
            HStack{
                AsyncImage(url: URL(string: item.file_url ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } placeholder: {
                    Image("占位图")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            //分割线
            Divider()
           LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(item.feature, id: \.name) { feature in
                    HStack(spacing:20){
                        Text(feature.name)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9B9B9B"))
                        Text(feature.value)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#000000"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.vertical,10)
                }
            }
        }
    }

       @ViewBuilder
    func VideoFeatureView(item: FeatureItem) -> some View {
        VStack(spacing:10){
            HStack{
                ZStack{
                AsyncImage(url: URL(string: item.preview_url ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } placeholder: {
                    Image("占位图")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Image("icon_data_play")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 20, height: 20)
            }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            //分割线
            Divider()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(item.feature, id: \.name) { feature in
                    HStack(spacing:20){
                        Text(feature.name)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9B9B9B"))
                        Text(feature.value)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#000000"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.vertical,10)
                }
            }
        }
    }

    func fetchFeatureData(post_id: String) {
        let requestBody: [String: Any] = [
                "post_id": post_id,
            ]
          NetworkManager.shared.post(APIConstants.Login.featureData, 
                                 businessParameters: requestBody) { (result: Result<FeatureDataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        featureData = response.data ?? []
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
}



struct FullScreenImgView: View {
    let imageURL: String
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
                .zIndex(0)
            
            // 图片内容
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    // 加载中
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("加载中...")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .zIndex(1)
                    
                case .success(let image):
                    // 显示图片
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .zIndex(1)  // 图片在背景之上但低于关闭按钮
                            .gesture(
                                // 捏合手势缩放
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        // 限制最小和最大缩放
                                        if scale < 1.0 {
                                            withAnimation {
                                                scale = 1.0
                                                lastScale = 1.0
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        } else if scale > 4.0 {
                                            withAnimation {
                                                scale = 4.0
                                                lastScale = 4.0
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                // 拖拽手势移动
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    
                    
                case .failure(_):
                    // 加载失败
                    VStack(spacing: 20) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("图片加载失败")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 16))
                    }
                    .zIndex(1)
                    
                @unknown default:
                    EmptyView()
                }
            }
            .id(imageURL)
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .padding(.top, 60)
                            .padding(.trailing, 30)
                    }
                    .contentShape(Rectangle())
                }
                Spacer()
            }
            .zIndex(100)  // 确保关闭按钮在最上层
        }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



struct FullScreenVideoView: View {
    let videoURL: String
    @Binding var isPresented: Bool
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    player?.pause()
                    // 恢复音频会话
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                    } catch {
                        print("❌ 音频会话恢复失败: \(error)")
                    }
                    isPresented = false
                }
                .zIndex(0)
            
            if let player = player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .zIndex(10)
                    .onAppear {
                        // 配置音频会话为播放模式，确保视频有声音
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
                            try audioSession.setActive(true)
                        } catch {
                            print("❌ 音频会话配置失败: \(error)")
                        }
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        // 关闭时恢复音频会话
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("❌ 音频会话恢复失败: \(error)")
                        }
                    }
            } else {
                // 加载状态
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("加载中...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
                .zIndex(1)
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        player?.pause()
                        // 恢复音频会话
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("❌ 音频会话恢复失败: \(error)")
                        }
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .padding(.top, 60)
                            .padding(.trailing, 30)
                    }
                    .contentShape(Rectangle())
                }
                Spacer()
            }
            .zIndex(100)  // 确保关闭按钮在最上层
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            // 恢复音频会话
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("❌ 音频会话恢复失败: \(error)")
            }
        }
        .onChange(of: videoURL) { _ in
            // 当URL在展示后变化时，重新初始化播放器
            player?.pause()
            player = nil
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard !videoURL.isEmpty, let url = URL(string: videoURL) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // 监听播放状态
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            DispatchQueue.main.async {
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
    
   
    
}







// 视频首帧封面视图组件
struct VideoThumbnailView: View {
    let urlString: String
    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear { preloadFromCache(); if thumbnail == nil { generateThumbnail() } }
    }

    private func generateThumbnail() {
        guard let url = URL(string: urlString) else { return }
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: false])
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                    ImageCacheManager.shared.setImage(uiImage, for: urlString)
                }
            } catch {
                // 保持占位图
            }
        }
    }
}





// 为视频首帧视图加入缓存读取与写入，避免重复生成
extension VideoThumbnailView {
    func preloadFromCache() {
        if let cached = ImageCacheManager.shared.getImage(for: urlString) {
            self.thumbnail = cached
        }
    }
}




