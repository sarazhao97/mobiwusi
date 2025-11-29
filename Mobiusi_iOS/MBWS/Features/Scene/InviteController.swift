//
//  InviteController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/13.
//
import SwiftUI
import Foundation


struct InviteController:View {
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage = ""
    // 横向滚动的示例数据（可替换为你的实际数据）
    @State private var shareimgs: [ShareStyleItem] = []
    @State var currentIndex: Int = 0
     @State var isAnimation: Bool = true
     let spacing: CGFloat = 20
      /// 拖拽的偏移量
    @State var dragOffset: CGFloat = .zero
    @State private var cardImageUrl: String = "" // 生成的卡片图片路径
    // @State var dragOffset: CGFloat = .zero

     /// 定义拖拽手势
    private var dragGesture: some Gesture{
        
        DragGesture()
            /// 拖动改变
            .onChanged {
                
                isAnimation = true
                dragOffset = $0.translation.width
            }
            /// 结束
            .onEnded {
                
                dragOffset = .zero
                // dragOffset = .zero
                /// 拖动右滑，偏移量增加，显示 index 减少
                if $0.translation.width > 50{
                    currentIndex -= 1
                }
                /// 拖动左滑，偏移量减少，显示 index 增加
                if $0.translation.width < -50{
                    currentIndex += 1
                }
                /// 防止越界（根据实际数据量）
                currentIndex = max(min(currentIndex, max(shareimgs.count - 1, 0)), 0)
            }
    }

    var body: some View {
        let viewportWidth = UIScreen.main.bounds.width
        let imgWidth = viewportWidth * 0.8
        let contentInset: CGFloat = 16 // 与 .padding(.horizontal, 16) 保持一致
         /// 选中卡片居中偏移：内容左内边距 + 累计卡片宽度与间距 - 视口居中修正
        let currentOffset = contentInset +  CGFloat(currentIndex) * (imgWidth  + spacing) - (viewportWidth - imgWidth)/2 
        ZStack{
            // 全屏背景色
            Color(hex: "#f7f8fa")
                .ignoresSafeArea()
              VStack{
                // 横向滚动轴
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(shareimgs, id: \.self) { item in
                        
                           VStack(spacing:0){
                               AsyncImage(url: URL(string: item.image ?? "")) { image in
                                   image
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: imgWidth)
                                       .clipped()
                               } placeholder: {
                                   ProgressView()
                                       .frame(width: imgWidth)
                               }
                               HStack(alignment:.center){
                                  AsyncImage(url: URL(string: item.avatar ?? "")) { image in
                                      image
                                          .resizable()
                                          .scaledToFill()
                                          .frame(width:60,height:60)
                                          .cornerRadius(8)
                                          .clipped()
                                  } placeholder: {
                                      Image("占位图")
                                          .resizable()
                                          .scaledToFill()
                                          .frame(width:40,height:40)
                                          .cornerRadius(8)
                                          .clipped()
                                  }
                                  Text(item.nick_name ?? "")
                                      .font(.system(size: 18, weight: .medium))
                                      .foregroundColor(Color(hex: "#000000"))
                                    Spacer()
                                  AsyncImage(url: URL(string: item.qrcode_url ?? "")) { image in
                                      image
                                          .resizable()
                                          .scaledToFit()
                                          .frame(width:90,height:90)
                                          .clipped()
                                  } placeholder: {
                                      Image("占位图")
                                          .resizable()
                                          .scaledToFit()
                                          .frame(width:90,height:90)
                                          .clipped()
                                  }
                               }
                               .padding(.horizontal,10)
                               .padding(.vertical,18)
                               .frame(width: imgWidth)
                               .background(Color.white)
                              

                           }
                           .frame(width: imgWidth) // 固定整卡片宽度，保证计算一致
                           
                         }
                    }
                    .padding(.horizontal, contentInset)
                    .offset(x: dragOffset - currentOffset)
                    .gesture(dragGesture)
                } 

                


                Spacer()
                if shareimgs.count > 0 && currentIndex < shareimgs.count {
                    SharingManager(
                        ImgUrl: cardImageUrl,
                        currentItem: shareimgs[currentIndex],
                        onSaveRequest: { completion in
                            generateCardImage(for: shareimgs[currentIndex], completion: completion)
                        }
                    )
                }
               

              
            }
            .padding(.top,10)

         }
         .navigationBarBackButtonHidden(true)
         .navigationBarTitle("邀请好友", displayMode: .inline)
         .toolbar{
             ToolbarItem(placement: .navigationBarLeading) {
                 Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#000000"))
                    }
             }
         }
         .onAppear{
            fetchShareimgs()
         }
    }

     func fetchShareimgs(){
        errorMessage = ""
        NetworkManager.shared.post(APIConstants.Scene.shareImage, 
                                 businessParameters: [:]) { (result: Result<ShareStylesResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{    
                        shareimgs = response.data ?? []
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
    
    // 生成卡片图片并保存到临时文件
    private func generateCardImage(for item: ShareStyleItem, completion: @escaping (String?) -> Void) {
        Task {
            await MainActor.run {
                // MBProgressHUD.showMessag("正在生成图片...", to: nil, afterDelay: 0)
            }
            
            // 下载所有图片
            let (mainImage, avatarImage, qrcodeImage) = await downloadAllImages(item: item)
            
            let cardWidth = UIScreen.main.bounds.width * 0.8
            let topMargin: CGFloat = 20 // 顶部白色外边距
            // 计算实际卡片高度
            let mainImageHeight: CGFloat
            if let mainImage = mainImage {
                let aspectRatio = mainImage.size.height / mainImage.size.width
                mainImageHeight = cardWidth * aspectRatio
            } else {
                mainImageHeight = cardWidth * 0.75
            }
            let estimatedHeight = topMargin + mainImageHeight + 96 // 顶部边距 + 主图高度 + 底部信息区域高度
            
            // 创建卡片视图
            let cardView = CardImageView(
                item: item,
                cardWidth: cardWidth,
                mainImage: mainImage,
                avatarImage: avatarImage,
                qrcodeImage: qrcodeImage
            )
            
            // 渲染为图片
            guard let image = await renderCardToImage(cardView: cardView, size: CGSize(width: cardWidth, height: estimatedHeight)) else {
                await MainActor.run {
                    MBProgressHUD.showMessag("生成图片失败", to: nil, afterDelay: 2.0)
                    completion(nil)
                }
                return
            }
            
            // 保存到临时文件
            if let fileURL = saveImageToTempFile(image: image) {
                await MainActor.run {
                    cardImageUrl = fileURL.absoluteString
                    completion(fileURL.absoluteString)
                }
            } else {
                await MainActor.run {
                    MBProgressHUD.showMessag("保存图片失败", to: nil, afterDelay: 2.0)
                    completion(nil)
                }
            }
        }
    }
    
    // 下载所有图片
    private func downloadAllImages(item: ShareStyleItem) async -> (UIImage?, UIImage?, UIImage?) {
        async let mainImageTask = downloadImage(from: item.image)
        async let avatarImageTask = downloadImage(from: item.avatar)
        async let qrcodeImageTask = downloadImage(from: item.qrcode_url)
        
        let (mainImage, avatarImage, qrcodeImage) = await (mainImageTask, avatarImageTask, qrcodeImageTask)
        return (mainImage, avatarImage, qrcodeImage)
    }
    
    // 下载单张图片
    private func downloadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // 渲染卡片视图为图片（使用隐藏的容器，不添加到窗口）
    @MainActor
    private func renderCardToImage(cardView: CardImageView, size: CGSize) async -> UIImage? {
        let hostingController = UIHostingController(rootView: cardView)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = .white
        
        // 创建一个隐藏的容器视图来触发布局，但不显示在屏幕上
        let containerView = UIView(frame: CGRect(origin: CGPoint(x: -size.width, y: -size.height), size: size))
        containerView.addSubview(hostingController.view)
        containerView.isHidden = true
        
        // 添加到窗口但位置在屏幕外（不可见）
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(containerView)
        }
        
        // 强制布局和渲染
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // 等待一个运行循环以确保视图完全渲染
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
        
        // 渲染为图片
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
        
        // 移除视图
        containerView.removeFromSuperview()
        
        return image
    }
    
    // 保存图片到临时文件
    private func saveImageToTempFile(image: UIImage) -> URL? {
        guard let imageData = image.pngData() else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "share_card_\(UUID().uuidString).png"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

// 卡片图片视图（用于渲染）
struct CardImageView: View {
    let item: ShareStyleItem
    let cardWidth: CGFloat
    let mainImage: UIImage?
    let avatarImage: UIImage?
    let qrcodeImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // 主图片（带顶部白色边距）
            if let mainImage = mainImage {
                Image(uiImage: mainImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth)
                    .clipped()
                    .padding(.top, 20) // 顶部白色外边距
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: cardWidth, height: cardWidth * 0.75)
                    .padding(.top, 20) // 顶部白色外边距
            }
            
            // 底部信息区域
            HStack(alignment: .center) {
                // 头像
                if let avatarImage = avatarImage {
                    Image(uiImage: avatarImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    Image("占位图")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                        .clipped()
                }
                
                // 昵称
                Text(item.nick_name ?? "")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#000000"))
                
                Spacer()
                
                // 二维码
                if let qrcodeImage = qrcodeImage {
                    Image(uiImage: qrcodeImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .clipped()
                } else {
                    Image("占位图")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .clipped()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 18)
            .frame(width: cardWidth)
            .background(Color.white)
        }
        .frame(width: cardWidth)
        .background(Color.white)
    }
}


