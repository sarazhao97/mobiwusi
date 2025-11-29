import SwiftUI
import AVKit
import UIKit
import SDWebImage
import Combine
import ObjectiveC


struct CategoryItem: Identifiable {
    let id: Int
    let title: String
    let xOffset: CGFloat
    let count:Int
    
}




// 音频类型中间内容
struct MyAudioMiddleContent: MiddleContent {
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
                               
            }
            .frame(height: 60)
            if let task_title = item.task_title, !task_title.isEmpty {
                 HStack{
                    Image("icon_home_connect 1")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 10, height: 10)
                    Spacer()
                 }
                 .padding(.vertical,0)
                        HStack{
                            Text(task_title)
                             .font(.system(size: 16))
                             .foregroundColor(Color(hex: "#57548E"))
                            Spacer()
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
// 文本类型中间内容
struct MyTextMiddleContent: MiddleContent {
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
                               Spacer()   
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
                                        .multilineTextAlignment(.leading)
                                   
                                    
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
                    if let task_title = item.task_title, !task_title.isEmpty {
                        HStack{
                            Image("icon_home_connect 1")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 10, height: 10)
                            Spacer()
                        }
                        .padding(.vertical,0)
                        Text(item.task_title ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#57548E"))
                        .lineLimit(2)
                        .padding(.bottom,10)
                    }
                       
                    if let description = item.description, !description.isEmpty {
                        VStack(alignment:.leading){
                            Text("数据介绍")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#9B9B9B"))
                                .lineLimit(1)
                                 .padding(.bottom,10)
                          
                                Text(description ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#000000"))
                                .multilineTextAlignment(.leading)
                              
                            
                               
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
struct MyGhibliMiddleContent: MiddleContent {
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
                imageURL = item.meta_data?.first?.original_image_path ?? ""
                showFullScreen = true
            }
        }
    }
}

//翻译类型中间内容
struct MyTranslateMiddleContent: MiddleContent {
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
                imageURL = item.meta_data?.first?.original_image_path ?? ""
                showFullScreen = true
            }
        }
    }
}

  //资讯分析
struct MyInfoMiddleContent: MiddleContent {
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
                 .padding(.vertical,8)
                .padding(.horizontal,12)
                .background(Color(hex: "#ffffff"))
                .cornerRadius(10)
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
                 .padding(.vertical,8)
                .padding(.horizontal,12)
                .background(Color(hex: "#ffffff"))
                .cornerRadius(10)
                .onTapGesture{
                    imageURL = item.meta_data?.first?.path ?? ""
                    showFullScreen = true
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
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                }
                .padding(.vertical,8)
                .padding(.horizontal,12)
                .background(Color(hex: "#ffffff"))
                .cornerRadius(10)
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
                     Text(item.meta_data?.first?.title ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#000000"))
                        
                    Spacer()
                }
                 .padding(.vertical,8)
                .padding(.horizontal,12)
                .background(Color(hex: "#ffffff"))
                .cornerRadius(10)
                .onTapGesture{
                    videoURL = item.meta_data?.first?.path ?? ""
                    showVideoPreview = true
                }
            }



            
           
        }
        }
    }

//食品内容
struct MyFoodMiddleContent: MiddleContent {
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
                            imageURL = item.meta_data?.first?.original_image_path ?? ""
                            showFullScreen = true
                        }

              }
        }
    }

    //图片类型视图
struct MyImageMiddleContent: MiddleContent {
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
                        imageURL = item.meta_data?.first?.path ?? ""
                        showFullScreen = true
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
struct MyVideoMiddleContent: MiddleContent {
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
                        AsyncImage(url: URL(string: item.meta_data?.first?.preview_url ?? "")) { image in
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
                            videoURL = item.meta_data?.first?.path ?? ""
                            showVideoPreview = true
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
struct MyMediaItemRow: View {
    var category: Int
    var item: IndexItem
    @Binding var currentMyPreviewVideoURL: String
    @Binding var showVideoPreview: Bool
    @Binding var currentMyPreviewImageURL: String
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
        Group {
            if shouldEnableNavigation(for: item) {
                // 对于文件类型（cate == 3），直接调用导航，不使用 NavigationLink
                if item.source == 6 || item.source == 3, item.cate == 3 {
                    Button(action: {
                        // 直接调用静态导航方法
                        MyDataController.navigateToPreview(path: item.meta_data?.first?.relative_path ?? "")
                    }) {
                        itemContentView
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if item.source == 6 || item.source == 3, item.cate != 3 {
                     itemContentView
                }else {
                    NavigationLink(destination: destinationView(for: item)) {
                        itemContentView
                    }
                }
            } else {
                itemContentView
            }
        }
    }
    
    @ViewBuilder
    private var itemContentView: some View {
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
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            
            // 中间内容
            middleContent
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#fef0f0"), Color(hex: "#fef0f0").opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#feeff0"), lineWidth: 1)
                )
                .shadow(color: Color(hex: "#feeff0"), radius: 3, x: 0, y: 8)
            
            // 底部选项
            VStack(spacing: 10) {
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
                    
                  
                }
                .padding(.top, 10)
                
                
            }
            //数据类型
             HomeNavigator.link(item) {
                    MyDataTypeModuleView(item: item)
                        .padding(.bottom,10)
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
        .padding(.vertical, 0)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#f5f5f5"), lineWidth: 1)
        )
        }
    
   
    
    // 根据item类型返回对应的目标视图
    @ViewBuilder
    private func destinationView(for item: IndexItem) -> some View {
        if item.source == 2 {
            MOFoodSafetyAnalysisDetail(item: item)
                .toolbarColorScheme(.dark)
        } else {
            FullScreenViewController(data: item)
                .toolbarColorScheme(.dark)
        }
    }


   
    
    // 检查是否应该启用导航
    private func shouldEnableNavigation(for item: IndexItem) -> Bool {
        // 对于所有情况都启用导航，但文件类型会使用 Button 而不是 NavigationLink
       
          return true
    }
    
    // 中间内容视图
    @ViewBuilder
    private var middleContent: some View {
        switch item.source {
        case 1: // 吉卜力
            MyGhibliMiddleContent(item: item, imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview)
        case 2: // 食品安全
            MyFoodMiddleContent(item: item,imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview)
        case 3: // 自由传
            if item.cate == 1 {
                MyAudioMiddleContent(item: item)
            } else if item.cate == 2 {
                MyImageMiddleContent(item: item, imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview)
            } else if item.cate == 3 {
                MyTextMiddleContent(item: item)
            } else if item.cate == 4 {
                MyVideoMiddleContent(item: item, videoURL: $currentMyPreviewVideoURL, showVideoPreview: $showVideoPreview)
            }
        case 4: // 翻译
           MyTranslateMiddleContent(item: item,imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview)
        case 5: // 资讯分析
            MyInfoMiddleContent(item: item,imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview,videoURL: $currentMyPreviewVideoURL, showVideoPreview: $showVideoPreview)  
        case 6: // 项目
             MyProjectMiddleContent(item: item,imageURL: $currentMyPreviewImageURL, showFullScreen: $showImagePreview,videoURL: $currentMyPreviewVideoURL, showVideoPreview: $showVideoPreview, showRemainingDataModal: $showRemainingDataModal, taskTitle: $taskTitle, metaItems: $metaItems, sheetPayload: $sheetPayload,sheetAudioPayload:$sheetAudioPayload,sheetTextPayload:$sheetTextPayload)
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
struct MyProjectMiddleContent: MiddleContent{
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
                        .font(.system(size: 14))
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
                HStack(alignment: .center,spacing:4){
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
                .background(Color(hex:"#ffffff"))
                .cornerRadius(8)
                .onTapGesture{
                  MyDataController.navigateToPreview(path: md.relative_path ?? "")
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
                .padding(.leading,0)
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
struct MyDataTypeModuleView: View {
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


struct MyDataController:View{
     var initialCategory: Int
    @State private var selectedCategory: Int = 1
    @State private var myDataInfo: [IndexItem]?
    @State private var allDataCount: [MyDataStatisticsItem]  // 存储全部数据用于计算count
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentPage: Int = 1
    @State private var limit: Int = 20
    @State private var cate: Int = 1
    @State private var isLoadingMore: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var allMyData: [IndexItem] = []  // 存储所有已加载的数据
    
    // 数据缓存：每个分类的数据、加载状态、页码等
    @State private var cachedData: [Int: [IndexItem]] = [:]  // 每个分类的数据缓存
    @State private var categoryDataCache: [Int: [IndexItem]] = [:]  // 备用缓存（如果其他地方使用）
    @State private var categoryLoadingState: [Int: Bool] = [:]
    @State private var categoryErrorState: [Int: String?] = [:]
    @State private var categoryPages: [Int: Int] = [:]  // 每个分类的当前页码
    @State private var categoryHasMoreData: [Int: Bool] = [:]  // 每个分类是否还有更多数据
    @State private var categoryLoadingMore: [Int: Bool] = [:]  // 每个分类是否正在加载更多
    @State private var hasLoadedCategory: Set<Int> = []  // 记录哪些分类已经加载过数据
//    private let initialCategory: Int  // 添加属性来存储初始分类
    @State private var selectedTranslationItem: IndexItem? // 选中的翻译项目
    @State private var showTranslationPreview = false // 翻译预览模态状态
    @State private var foodSafetyImageURL: String = ""
    @State private var currentFoodSafetyItem: IndexItem?
    @State private var currentTranslationImageURL: String = ""
    @State private var currentJibliImageURL: String = ""
     @State private var showContinuity = false
     @State private var current_post_id: String = ""  //当前记录的parent_post_id
       @State private var sheetPayload: ProjectSheetPayload? = nil
    @State private var sheetAudioPayload: ProjectSheetPayload? = nil
    @State private var sheetTextPayload: ProjectSheetPayload? = nil
    @State private var showRemainingDataModal: Bool = false
    @State private var taskTitle: String = ""
    @State private var metaItems: [MetaData] = []
    @State private var navigateToUploadAudio = false
    @State private var sheetFeaturePayload: FeatureSheetPayload? = nil
    
    // 初始化方法，接收从上一个页面传来的数据
    init(initialCategory: Int = 1) {
        self.initialCategory = initialCategory
        self._cate = State(initialValue: initialCategory)
        self._selectedCategory = State(initialValue: initialCategory)
        self._allDataCount = State(initialValue: [])

      
    }
    
    @State private var showFullScreen = false
    @State private var showOriginalFullScreen = false
    @State private var showFoodSafetyFullScreen = false
    @State private var showFoodSafetyOriginalFullScreen = false
    @State private var showTranslationFullScreen = false
    @State private var showTranslationOriginalFullScreen = false
    @State private var isRefreshing = false
    @State private var lastRefreshTime: Date = Date()
    @State private var showRefreshComplete = false
    @State private var showAddMenu = false
    @State private var showRecordingView = false // 添加录音页面状态变量
    @State private var showSummarizeView = false // 添加摘要页面状态变量
    @State private var selectedSummaryModel: MOSummaryDetailModel? // 选中的摘要模型

    @State private var currentMyPreviewVideoURL: String = ""
    @State private var showVideoPreview: Bool = false
    @State private var currentMyPreviewImageURL: String = ""
    @State private var showImagePreview: Bool = false
    
    // 页面状态管理变量
    @State private var isFirstLoad: Bool = true
    @State private var isViewAppearing: Bool = false
    @State private var shouldRestorePosition: Bool = false
    @State private var savedScrollPosition: CGFloat = 0.0
  
  
    

      // 静态方法，用于直接导航到预览页面
    static func navigateToPreview(path: String) {
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
                            MBProgressHUD.showMessag("预览URL无效或为空", to: nil, afterDelay: 3.0)
                        }
                    } else {
                        MBProgressHUD.showMessag("\(response.msg)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    MBProgressHUD.showMessag("\(error.localizedDescription)", to: nil, afterDelay: 3.0)
                }
            }
        }
    }
    
    func openFeatureSheet(post_id: String?) {
        guard let pid = post_id else { return }
        sheetFeaturePayload = FeatureSheetPayload(post_id:pid)
    }

    // 动态生成分类项目
    private var categoryItems: [CategoryItem] {
        [
            CategoryItem(id: 1, title: "音频", xOffset: 0, count: getCountForCategory(1)),
            CategoryItem(id: 2, title: "图片", xOffset: 0, count: getCountForCategory(2)),
            CategoryItem(id: 3, title: "文本", xOffset: 0, count: getCountForCategory(3)),
            CategoryItem(id: 4, title: "视频", xOffset: 0, count: getCountForCategory(4)),
            CategoryItem(id: 5, title: "多模态", xOffset: 0, count: getCountForCategory(5)),
        ]
    }

    func getCountForCategory(_ category: Int) -> Int {
        return allDataCount.first(where: { $0.cate == category })?.total ?? 0
    }
    
   
    
    // 安全获取meta_data的第一个元素
    private func getFirstMetaData(from item: IndexItem) -> MetaData? {
        return item.meta_data?.first
    }
    
   
   
    
    // 获取指定分类的数据用于显示（从缓存中获取）
    private func getCategoryData(_ category: Int) -> [IndexItem] {
        return cachedData[category] ?? []
    }
    
    // MARK: - 自定义导航栏
    @ViewBuilder
    private func customNavigationBar() -> some View {
        HStack {
            // 左侧返回按钮
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // 中间标题
            Text("我的数据")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
                    // 右侧加号按钮
                    Image("a-xitongguanlixinzenganniuicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        showAddMenu.toggle()
                    }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .background(Color(hex:"#F7F8FA"))
    }
    
    // MARK: - API调用
    private func fetchMyData(isRefresh: Bool = false) {
        if isRefresh {
            isLoading = true
            currentPage = 1
            categoryPages[cate] = 1
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil

         let requestBody: [String: Any] = [
                "page": currentPage,
                "limit": limit,
                "cate": cate
            ]
        
        NetworkManager.shared.post(APIConstants.Index.index, 
                                 businessParameters: requestBody) { (result: Result<IndexResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false
                isLoadingMore = false
                
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        var categoryData: [IndexItem]
                        
                        if isRefresh {
                            // 刷新时替换数据
                            categoryData = response.data
                            cachedData[cate] = categoryData
                            hasLoadedCategory.insert(cate)
                        } else {
                            // 加载更多时追加数据
                            let existingData = cachedData[cate] ?? []
                            categoryData = existingData + response.data
                            cachedData[cate] = categoryData
                        }
                        
                        // 更新当前显示的数据（如果当前选中的分类就是请求的分类）
                        if cate == selectedCategory {
                            myDataInfo = categoryData
                        }
                        
                        // 判断是否还有更多数据
                        let hasMore = response.data.count >= limit
                        categoryHasMoreData[cate] = hasMore
                        hasMoreData = hasMore
                        
                        if hasMore {
                            let nextPage = currentPage + 1
                            currentPage = nextPage
                            categoryPages[cate] = nextPage
                        }
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 加载更多数据
    private func loadMoreData() {
        guard hasMoreData && !isLoadingMore else { return }
        // 确保使用当前选中分类的页码和分类ID
        cate = selectedCategory
        if let savedPage = categoryPages[selectedCategory] {
            currentPage = savedPage
        }
        fetchMyData(isRefresh: false)
    }
    
    // 获取全部数据用于计算count
    private func fetchMyDataCount() {
        
        NetworkManager.shared.post(APIConstants.Index.myDataCount, 
                                 businessParameters: [:]) { (result: Result<MyDataStatisticsResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        allDataCount = response.data
                        // 获取全部数据后，再获取当前分类的数据
                       
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - 刷新相关方法
    @MainActor
    private func refreshData() async {
        isRefreshing = true
        showRefreshComplete = false
        
        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        
        // 重新获取数据
        fetchMyDataCount()
        fetchMyData(isRefresh: true)
        
        // 更新刷新时间
        lastRefreshTime = Date()
        
        // 刷新完成
        isRefreshing = false
        showRefreshComplete = true
        
        // 1秒后隐藏完成提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
            showRefreshComplete = false
        }
    }
    
    // 刷新状态视图
    @ViewBuilder
    private func refreshStatusView() -> some View {
        if isRefreshing || showRefreshComplete {
            HStack {
                Spacer()
                
                if isRefreshing {
                    // 刷新进行中
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                            // .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            // .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRefreshing)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("正在刷新...")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text("上次更新 \(formatRefreshTime(lastRefreshTime))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                } else if showRefreshComplete {
                    // 刷新完成
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("刷新完成")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text("上次更新 \(formatRefreshTime(lastRefreshTime))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // 格式化刷新时间
    private func formatRefreshTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M-d HH:mm"
        return formatter.string(from: date)
    }

    @ViewBuilder 
    private func categoryItemView(_ item: CategoryItem) -> some View {
        categoryButton(item)
            .overlay(alignment: .bottomLeading) {
                categoryIndicator(item)
            }
    }

    // 选项卡按钮
    @ViewBuilder
    private func categoryButton(_ item: CategoryItem) -> some View {
        Button(item.title + "(" + String(item.count) + ")") {
            // 立即切换分类，不等待网络请求
            selectedCategory = item.id
            cate = item.id  // 更新cate参数
            
            // 如果有缓存数据，立即显示
            if let cached = cachedData[item.id], !cached.isEmpty {
                myDataInfo = cached
                // 恢复该分类的页码和hasMoreData状态
                currentPage = categoryPages[item.id] ?? 1
                hasMoreData = categoryHasMoreData[item.id] ?? true
            } else {
                // 没有缓存数据，显示空数组，等待加载
                myDataInfo = []
            }
            
            // 如果该分类从未加载过数据，才请求接口
            if !hasLoadedCategory.contains(item.id) {
                currentPage = 1
                categoryPages[item.id] = 1
                fetchMyData(isRefresh: true)
            }
            // 如果已有缓存数据，不请求接口，直接使用缓存
        }
        // .font(selectedCategory == item.id ? .headline : .subheadline)
        .fontWeight(selectedCategory == item.id ? .bold : .regular)
        .foregroundColor(selectedCategory == item.id ? .black : .gray)
        .lineLimit(nil)
        // .frame(maxWidth: .infinity)
    }

     // 选项卡指示器
    @ViewBuilder
    private func categoryIndicator(_ item: CategoryItem) -> some View {
        if selectedCategory == item.id {
            Image("Rectangle 149")
                .resizable()
                .scaledToFit()
                .frame(height: 10)
                .offset(x: item.xOffset)
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
    

   

     // 根据选中的选项卡显示对应的内容视图（使用视图缓存）
    @ViewBuilder
    private func tabCategoryView() -> some View{
        ZStack {
            // 为每个分类创建独立的视图，使用 id 保持状态
            ForEach(categoryItems) { categoryItem in
                categoryContentView(categoryItem.id)
                    .opacity(selectedCategory == categoryItem.id ? 1 : 0)
                    .disabled(selectedCategory != categoryItem.id)
                    .allowsHitTesting(selectedCategory == categoryItem.id)
            }
        }
    }
    
    // MARK: - 内容视图（为每个分类创建独立的视图，保持状态）
    @ViewBuilder
    private func categoryContentView(_ category: Int) -> some View {
        let currentItems = getCategoryData(category)
        let categoryIsLoading = isLoading && cate == category && !hasLoadedCategory.contains(category)
        let categoryHasMore = categoryHasMoreData[category] ?? true
        let categoryIsLoadingMore = isLoadingMore && cate == category
        
        if categoryIsLoading {
            VStack {
                ProgressView("加载中...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !currentItems.isEmpty {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(currentItems) { item in
                        MyMediaItemRow(category: category, item: item, currentMyPreviewVideoURL: $currentMyPreviewVideoURL, showVideoPreview: $showVideoPreview, currentMyPreviewImageURL: $currentMyPreviewImageURL, showImagePreview: $showImagePreview,showContinuity: $showContinuity,current_post_id: $current_post_id,showRemainingDataModal: $showRemainingDataModal,taskTitle: $taskTitle,metaItems: $metaItems,sheetPayload: $sheetPayload, sheetAudioPayload: $sheetAudioPayload, sheetTextPayload: $sheetTextPayload,openFeatureSheet: openFeatureSheet)
                    }
                    
                    // 底部加载视图（使用分类特定的状态）
                    categoryBottomLoadingView(category: category, hasMore: categoryHasMore, isLoadingMore: categoryIsLoadingMore)
                }
                .padding(.horizontal,10)
            }
            .id("category_\(category)") // 使用 id 保持视图状态
        } else {
            emptyStateView("无数据")
                .id("category_empty_\(category)") // 使用 id 保持视图状态
        }
    }
    
    // MARK: - 分类特定的底部加载视图
    @ViewBuilder
    private func categoryBottomLoadingView(category: Int, hasMore: Bool, isLoadingMore: Bool) -> some View {
        VStack(spacing: 10) {
            if isLoadingMore {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                    Text("加载中...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
            } else if !hasMore && !getCategoryData(category).isEmpty {
                Text("没有更多数据了")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
            }
            
            // 触发加载更多的透明视图
            if hasMore && !isLoadingMore {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        // 确保使用正确的分类
                        if selectedCategory == category {
                            loadMoreData()
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func emptyStateView(_ message: String) -> some View {
        VStack {
            Image("icon_data_empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            Text(message)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top,50)
    }

    @Environment(\.dismiss) var dismiss
   

    var body:some View{
        ZStack{
             Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0){
                // 自定义顶部导航栏
                customNavigationBar()
                
                // 主要内容区域
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            let visibleCount = 5
                            let itemWidth = geometry.size.width / CGFloat(visibleCount)
                            ForEach(categoryItems) { item in
                                categoryItemView(item)
                                    .frame(width: itemWidth)
                            }
                        }
                        .frame(width: geometry.size.width, alignment: .leading)
                    }
                }
                .frame(height: 40)
                .padding(.horizontal,10)
                .padding(.top,20)
                // .padding(.horizontal,10)
                // .padding(.top,20)
                
                // 刷新状态提示
                refreshStatusView()

                 // 显示对应选项卡的内容（视图已缓存，不会销毁）
                tabCategoryView()
                    .refreshable {
                        await refreshData()
                    }
              
               Spacer()
              
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
               .cornerRadius(20)
               
           }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                              
                // 确保cate参数与selectedCategory同步
                cate = selectedCategory
                
                // 只在真正的首次加载时获取数据，从内页返回时不刷新
                if isFirstLoad && !isViewAppearing {
                    fetchMyDataCount()  // 先获取全部数据计算count
                    
                    // 检查是否有缓存数据
                    if let cached = cachedData[selectedCategory], !cached.isEmpty {
                        // 有缓存，直接显示
                        myDataInfo = cached
                        currentPage = categoryPages[selectedCategory] ?? 1
                        hasMoreData = categoryHasMoreData[selectedCategory] ?? true
                    } else {
                        // 没有缓存，才请求接口
                        fetchMyData(isRefresh: true)
                    }
                    isFirstLoad = false
                } else {
                    // 非首次加载，如果有缓存数据，直接显示
                    if let cached = cachedData[selectedCategory], !cached.isEmpty {
                        myDataInfo = cached
                        currentPage = categoryPages[selectedCategory] ?? 1
                        hasMoreData = categoryHasMoreData[selectedCategory] ?? true
                    }
                }
                isViewAppearing = true
            }
            
            // 添加菜单蒙版层
            if showAddMenu {
                addMenuOverlay()
            }

            NavigationLink(destination: UploadAudioController(), isActive: $navigateToUploadAudio) {
                EmptyView()
            }

              .sheet(item: $sheetFeaturePayload) { payload in
            FeatureSheetController(post_id: payload.post_id, onClose: { sheetFeaturePayload = nil })
              .presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(20)   // 在这设置圆角半径
               
            }    
        }
         
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
          .overlay(
            ZStack {
                if showImagePreview {
                    FullScreenImgView(imageURL: currentMyPreviewImageURL, isPresented: $showImagePreview)
                }
                if showVideoPreview {
                    FullScreenVideoView(videoURL: currentMyPreviewVideoURL, isPresented: $showVideoPreview)
                }
            }
        )
         .sheet(item: $sheetPayload) { payload in
            MyProjectPictureVideoDataView(title: payload.title, data: payload.data, showImagePreview: $showImagePreview, showVideoPreview: $showVideoPreview, imageURL: $currentMyPreviewImageURL, videoURL: $currentMyPreviewVideoURL)
        }
        .presentationDetents([.fraction(0.9), .medium])
        .presentationDragIndicator(.hidden)

         .sheet(item: $sheetAudioPayload) { payload in
            MyProjectAudioDataView(title: payload.title, data: payload.data)
        }
        .presentationDetents([.fraction(0.5), .medium])
        .presentationDragIndicator(.hidden)
          
            
        .sheet(item: $sheetTextPayload) { payload in
            MyProjectTextDataView(title: payload.title, data: payload.data)
        }
        .presentationDetents([.fraction(0.5), .medium])
        .presentationDragIndicator(.hidden)

    }
    
    // MARK: - 添加菜单蒙版层
    @ViewBuilder
    private func addMenuOverlay() -> some View {
        ZStack {
            // 半透明蒙版层
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showAddMenu = false
                }
            
            // 右上角小面板
            addMenuPanel()
        }
    }
    
    // MARK: - 菜单面板
    @ViewBuilder
    private func addMenuPanel() -> some View {
        VStack(spacing: 0) {
            // 音频选项
          Button(action:{
            navigateToUploadAudio = true
          }) {
                addMenuRow(
                    icon: "icon_data_yp", 
                    title: "音频",
                    color: Color.green,
                    action: {
                        print("选择音频")
                       
                    }
                 
                )
            }
            
            // 图片选项
             NavigationLink(destination: PictureReleasePanel()) {
                      addMenuRow(
                        icon: "icon_data_tp@3x_1", 
                        title: "图片",
                        color: Color.green,
                        action: {
                            print("选择图片")
                        
                        }
                    )
             }
          
            
            
            // 文本选项
            NavigationLink(destination:  TextReleasePanel()) {
            addMenuRow(
                icon: "icon_data_wb",
                title: "文本", 
                color: Color.blue,
                action: {
                    print("选择文本")
                    
                }
            )
            }
            
            
            // 视频选项
            NavigationLink(destination:  VideoReleasePanel()) {
            addMenuRow(
                icon: "icon_data_sp",
                title: "视频",
                color: Color.pink,
                action: {
                    print("选择视频")
                    
                }
            )
             }
        }
        .background(Color.white)
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(width: 100)
        .overlay(addMenuTriangle())
        .position(x: UIScreen.main.bounds.width - 70, y: 150) // 将y从120调整为150，向下移动30点
    }
    
    // MARK: - 菜单三角形
    @ViewBuilder
    private func addMenuTriangle() -> some View {
        Triangle()
            .fill(Color.white)
            .frame(width: 12, height: 8)
            .position(x: 88, y: -4)
    }
    
    // MARK: - 添加菜单行
    @ViewBuilder
    private func addMenuRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
            HStack(spacing: 4) {
                Spacer()
                // 图标
                Image(icon)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 30, height: 30)
                
                // 标题
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .frame(maxWidth:.infinity)
            .padding(.vertical, 8)
       
    }
    
  
    
    
}

// MARK: - 主视图
struct MyProjectPictureVideoDataView: View {
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

struct MyProjectAudioDataView: View {
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

struct MyProjectTextDataView: View {
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

// MARK: - 通用全屏图片查看器组件
struct FullScreenImageView: View {
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
                    withAnimation {
                        isPresented = false
                    }
                }
            
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
                    
                case .success(let image):
                    // 显示图片
                    GeometryReader { geometry in
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
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
                    }
                    
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
                    
                @unknown default:
                    EmptyView()
                }
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - 视频封面组件

struct VideoCoverView: View {
    let previewURL: String
    let videoURL: String
    @State private var showFullScreenVideo = false
    
    var body: some View {
        Button(action: {
            showFullScreenVideo = true
        }) {
            ZStack {
                // 封面图片
                AsyncImage(url: URL(string: previewURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))


                }
                
                // 播放图标覆盖层
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showFullScreenVideo) {
            FullScreenVideoPlayer(videoURL: videoURL)
        }
    }
}

// MARK: - 全屏视频播放器

struct FullScreenVideoPlayer: View {
    let videoURL: String
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        isPlaying = true
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
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        player?.pause()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
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




// MARK: - 自定义三角形形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - 录音视图包装器
struct RecordingViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let recordingView = MOStartRecordingView()
        
        // 设置录音视图的回调
        recordingView.didClickBtn = { isSelected in
            print("录音状态: \(isSelected)")
        }
        
        // 设置背景色
        viewController.view.backgroundColor = UIColor.systemBackground
        
        // 添加录音视图
        viewController.view.addSubview(recordingView)
        
        // 设置约束，确保录音视图填满整个视图
        recordingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordingView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            recordingView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            recordingView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 更新视图控制器
    }
}

// MARK: - 摘要视图包装器
struct SummarizeViewWrapper: UIViewControllerRepresentable {
    let dataModel: MOSummaryDetailModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let summarizeView = MOSummarizeScrollView()
        
        // 配置视图数据
        summarizeView.configView(dataModel: dataModel)
        
        // 设置链接点击回调
        summarizeView.linkDidClick = {
            print("链接被点击")
            // 这里可以添加链接处理逻辑
        }
        
        // 设置背景色
        viewController.view.backgroundColor = UIColor.systemBackground
        
        // 添加摘要视图
        viewController.view.addSubview(summarizeView)
        
        // 设置约束
        summarizeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summarizeView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            summarizeView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            summarizeView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            summarizeView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 更新视图控制器
    }
}




