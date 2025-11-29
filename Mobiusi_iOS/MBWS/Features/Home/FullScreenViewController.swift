//
//  FullScreenViewController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/28.
//

import SwiftUI
import Foundation
import Photos
import UIKit
import SDWebImage
import WebKit

struct InlineWebView: UIViewRepresentable {
    let urlString: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastURLStringLoaded: String?
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.preferredContentMode = .mobile
        config.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        var s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return }
        let lower = s.lowercased()
        if !lower.hasPrefix("http://") && !lower.hasPrefix("https://") {
            s = "https://" + s
        }
        var url = URL(string: s)
        if url == nil {
            let encoded = s.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            if let e = encoded { url = URL(string: e) }
        }
        guard let finalURL = url else { return }
        if context.coordinator.lastURLStringLoaded == s { return }
        context.coordinator.lastURLStringLoaded = s
        let request = URLRequest(url: finalURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        uiView.load(request)
    }
}

struct InlineWebPageView: View {
    let urlString: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            InlineWebView(urlString: urlString)
        }
    }
}





struct FullScreenViewController: View {
    let data: IndexItem
    @Environment(\.dismiss) private var dismiss
    @State private var showShareModal = false
    @State private var share_url = ""
    @State private var errorMessage = ""
    @State private var showSystemShare = false
    // @State private var detail: GhibliDetailData? = nil
    @State private var translationDetail: ImageTranslationDetailData? = nil
    @State private var newsAnalysisDetail: UserDataSummaryDetailData? = nil
    @State private var ghibliDetail: GhibliDetailData? = nil
    @State private var showImagePreview = false
    @State private var previewImageURL: String = ""
    @State private var showMessageSheet = false
    @State private var operationType: Int = 1   //操作类型 ， 1是点赞3是分享
    @State private var operation_status: Int = 1 //操作状态 ， 1是操作0是取消
    //操作返回的数量
    @State private var likeCount: Int = 0
    @State private var shareCount: Int = 0

    @State private var currentPage = 1
    @State private var limit = 10
    @State private var summaryMessageList:[SummaryMessageItem] = []
    @State private var summaryMsgTotal: Int = 0
    @State private var isLoadingMore = false
    @State private var hasMoreData = true

    @State private var showVideoPreview = false
    @State private var currentPreviewVideoURL: String = ""
   



    
    // 新增刷新状态管理变量
    @State private var isRefreshing = false
    @State private var refreshOpacity: Double = 1.0
    @State private var refreshScale: CGFloat = 1.0
    @State private var buttonRotation: Double = 0.0
    
    
    // @ViewBuilder
    var body: some View {
        ZStack{
        Group {
            switch data.source {
            case 1: // 吉卜力
                GhibliFullScreenView(item: data, dismiss: dismiss)
            case 4: // 翻译
                TranslationFullScreenView(item: data, dismiss: dismiss)
            case 5: // 资讯分析
                AnalysisFullScreenView(item: data, dismiss: dismiss)
            default:
                HStack{
                    Text("暂无数据")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showMessageSheet) {
            MessageSheetView()
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color(hex:"#EDEEF5"))
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
        }
        if showVideoPreview {
                   FullScreenVideoView(videoURL: currentPreviewVideoURL, isPresented: $showVideoPreview)
                   .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                   .background(Color.black)
                   .ignoresSafeArea()
                   .zIndex(200)
        }
    }
    }

    @ViewBuilder
    private func GhibliFullScreenView(item: IndexItem, dismiss: DismissAction) -> some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            VStack(spacing:0){    
                AsyncImage(url: URL(string: ghibliDetail?.result_url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 180)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                if let imgUrl = ghibliDetail?.result_url, !imgUrl.isEmpty {
                HStack(alignment: .center){
                    Spacer()
                    Button(action: {
                        let imageSaveHelper = ImageSaveHelper()
                        imageSaveHelper.saveImageToAlbum(from: imgUrl)
                    }) {
                        VStack(spacing:10){
                            Image("保存到相册_(1) 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("保存")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                      Spacer()
                    Button(action:{
                          let shareInfo = formatShareJSON(ghibliDetail?.share_sharejson)
                          let title = shareInfo.title
                          let description = shareInfo.summary
                          let imageUrl = imgUrl
                          let shareURL = ghibliDetail?.share_url ?? "https://www.mobiwusi.com"
                    
                    // 获取当前的UIViewController
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        var currentVC = rootViewController
                        while let presentedVC = currentVC.presentedViewController {
                            currentVC = presentedVC
                        }
                        
                        MOSharingManager.shared.share(
                            title: title,
                            description: description,
                            imageUrl: imageUrl,
                            shareURL: shareURL,
                            from: currentVC,
                            shareOption: .shareLink
                        ) { success in
                            // 只有分享成功才调用统计接口
                            if success {
                               
                            }
                        }
                        }

                    }) {
                        VStack(spacing:10){
                            Image("share_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("分享")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                      Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 180)
                .background(Color(hex:"#18283A"))
                }
             }

              // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
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


        }
          .navigationBarBackButtonHidden(true)
       
        .onAppear{
            getVariationPhotographerDetail(id:data.id)
        }
    }
    


    @ViewBuilder
    private func AnalysisFullScreenView(item: IndexItem, dismiss: DismissAction) -> some View {
         ZStack {
            // 背景
            Color(hex: "#f7f8fa")
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
        
                VStack(spacing: 12) {
                ScrollView(showsIndicators: false) {
                    // 图片预览组件
                    if item.cate == 2 {
                        NewsImagePreviewView()
                        .padding(.horizontal,12)
                    }else if item.cate == 3 {
                        NewsTextPreviewView()
                         .padding(.horizontal,12)
                    }else if item.cate == 4 {
                        NewsVideoPreviewView()
                         .padding(.horizontal,12)
                    }
                    
                    // 全文摘要组件
                    SummaryContentView()
                     .padding(.horizontal,12)
                    
                    // 导图组件
                    MindMapSectionView()
                     .padding(.horizontal,12)

                     if let params = newsAnalysisDetail?.param, !params.isEmpty {
                        ParamsSectionView(params: params)
                        .padding(.horizontal,12)
                     }
                    
                    // 标签组件
                    TagsSectionView()
                    .padding(.horizontal,12)
                    
                      
                     }
                      Spacer()
                    
                    // 底部操作栏
                    BottomActionBarView()
                }
                .frame(maxWidth: .infinity)
                
           
         }
         .onAppear {
            getNewsAnalysisDetail(id: data.id)
         }
        .navigationTitle("资讯分析师")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .overlay(
            Group {
                if showImagePreview {
                    ImagePreviewModal(imageURL: previewImageURL, isPresented: $showImagePreview)
                        .transition(.opacity)
                }
            }
        )
        
    }
    
    // MARK: - 子组件
    
    @ViewBuilder
    private func NewsImagePreviewView() -> some View {
        HStack {
            AsyncImage(url: URL(string: newsAnalysisDetail?.result.first?.path ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .opacity(refreshOpacity)
                    .scaleEffect(refreshScale)
            } placeholder: {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                if let imageURL = newsAnalysisDetail?.result.first?.path, !imageURL.isEmpty {
                    previewImageURL = imageURL
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showImagePreview = true
                    }
                }
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }

    @ViewBuilder
    private func NewsVideoPreviewView() -> some View {
         HStack {
            ZStack{
                 AsyncImage(url: URL(string: newsAnalysisDetail?.result.first?.snapshot ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .opacity(refreshOpacity)
                    .scaleEffect(refreshScale)
            } placeholder: {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                if let videoURL = newsAnalysisDetail?.result.first?.path, !videoURL.isEmpty {
                    currentPreviewVideoURL = videoURL
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showVideoPreview = true
                    }
                }
            }
                Image("icon_data_play")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            }
           
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }

    @ViewBuilder
    private func NewsTextPreviewView() -> some View {
        NavigationLink(destination: InlineWebPageView(urlString: newsAnalysisDetail?.paste_board_url ?? "")) {
         HStack {
            HStack(alignment:.center,spacing:10){
                Image("icon_wb@3x_3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(newsAnalysisDetail?.result.first?.file_name ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(hex:"#EDEEF5"))
            .cornerRadius(10)
        }
        .disabled((newsAnalysisDetail?.paste_board_url ?? "").isEmpty)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        }
    }
    
    @ViewBuilder
    private func SummaryContentView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("全文摘要")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(refreshOpacity)
                    .animation(.easeInOut(duration: 0.5), value: refreshOpacity)
                Spacer()
            }
            
            Text(formatShareJSON(newsAnalysisDetail?.share_sharejson).summary ?? "")
                .font(.system(size: 16))
                .foregroundColor(.black)
                .opacity(refreshOpacity)
                .animation(.easeInOut(duration: 0.5), value: refreshOpacity)
                .lineSpacing(12)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func MindMapSectionView() -> some View {
        VStack {
            // 标题和按钮
            HStack {
                Text("导图")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .opacity(refreshOpacity)
                    .animation(.easeInOut(duration: 0.5), value: refreshOpacity)
                Spacer()
                
                MindMapActionButtons()
            }
            .padding(.bottom, 20)
            
            // 导图图片
            MindMapImageView()
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func MindMapActionButtons() -> some View {
        HStack(alignment: .center, spacing: 15) {
            Button(action: {
                performRefreshWithAnimation()
            }) {
                Image("icon_summary_refresh")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(buttonRotation))
                    .scaleEffect(isRefreshing ? 0.8 : 1.0)
                    .opacity(isRefreshing ? 0.6 : 1.0)
            }
            .contentShape(Rectangle())
            .disabled(isRefreshing)
            .animation(.easeInOut(duration: 0.2), value: isRefreshing)

            NavigationLink(destination: MindMapFullSrceenView(imageURL: newsAnalysisDetail?.mind_map ?? "")) {
                Image("icon_horizontal_screen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    @ViewBuilder
    private func MindMapImageView() -> some View {
        ZStack {
            AsyncImage(url: URL(string: newsAnalysisDetail?.mind_map ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .opacity(refreshOpacity)
                    .scaleEffect(refreshScale)
            } placeholder: {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .opacity(refreshOpacity)
                    .scaleEffect(refreshScale)
            }
            .animation(.easeInOut(duration: 0.5), value: refreshOpacity)
            .animation(.easeInOut(duration: 0.5), value: refreshScale)
            .onTapGesture {
                if let imageURL = newsAnalysisDetail?.mind_map, !imageURL.isEmpty {
                    previewImageURL = imageURL
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showImagePreview = true
                    }
                }
            }
            
            // 刷新时的加载指示器
            if isRefreshing {
                RefreshLoadingView()
            }
        }
    }
    
    @ViewBuilder
    private func RefreshLoadingView() -> some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            Text("正在刷新...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: isRefreshing)
    }

    @ViewBuilder
    private func ParamsSectionView(params: [SummaryParam]?) -> some View {
         VStack(spacing:20) {
            HStack {
                Text("参数")
                    .font(.system(size: 18))
                    .foregroundColor(.black)         
                Spacer()
            }
            
               LazyVGrid(columns: [
                   GridItem(.flexible(), spacing: 10),
                   GridItem(.flexible(), spacing: 10)
               ], spacing: 20) {
                   ForEach(params ?? [], id: \.self) { param in
                     HStack(alignment: .top, spacing: 10) {
                        Text(param.name) 
                         .font(.system(size: 12))
                         .foregroundColor(.gray)
                         .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(param.value)
                         .font(.system(size: 12))
                         .foregroundColor(.black)
                         .frame(maxWidth: .infinity, alignment: .leading)
                        
                     }
                   }
               }
            
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func TagsSectionView() -> some View {
        VStack(spacing:20) {
            HStack {
                Text("标签")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    
                Spacer()
            }
            
            HStack {
                Text(newsAnalysisDetail?.tags ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                   
                    Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func BottomActionBarView() -> some View {
        HStack {
            Spacer()
            
            // 分享
            ActionButton(
                imageName: "分享_1",
                count: shareCount,
                action: {
                    // 使用MOSharingManager进行分享，只有分享成功才调用统计接口
                    let title = formatShareJSON(newsAnalysisDetail?.share_sharejson).title ?? "Mobiwusi总结"
                    let description = formatShareJSON(newsAnalysisDetail?.share_sharejson).summary ?? ""
                    let imageUrl = newsAnalysisDetail?.mind_map ?? "" // 根据需要设置图片URL
                    let shareURL = newsAnalysisDetail?.share_url ?? "https://www.mobiwusi.com"
                    
                    // 获取当前的UIViewController
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        var currentVC = rootViewController
                        while let presentedVC = currentVC.presentedViewController {
                            currentVC = presentedVC
                        }
                        
                        MOSharingManager.shared.share(
                            title: title,
                            description: description,
                            imageUrl: imageUrl,
                            shareURL: shareURL,
                            from: currentVC,
                            shareOption: .shareLink
                        ) { success in
                            // 只有分享成功才调用统计接口
                            if success {
                                operationType = 3 // 3表示分享操作
                                operation_status = 1 // 1表示执行操作
                                handleSummaryOperation()
                            }
                        }
                    }
                }
            )
            .padding(.trailing, 20)
            
            
            Spacer()
            
            // 点赞
            ActionButton(
                imageName: operation_status == 1 ? "icon_summary_praise_big_select" : "icon_summary_praise_big_normal",
                count: likeCount ?? 0,
                action: {
                    operationType = 1
                    operation_status = operation_status == 1 ? 0 : 1
                    handleSummaryOperation()
                }
            )
            
            Spacer()
            
            // 消息
            ActionButton(
                imageName: "icon_summary_message_big",
                count: nil,
                action: {
                    showMessageSheet = true
                }
            )
              .padding(.leading,20)
            
            Spacer()
        }
        .padding(.vertical,20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        //忽略底部安全区域
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func ActionButton(imageName: String, count: Int?, action: @escaping () -> Void) -> some View {
        HStack(alignment: .center, spacing: 5) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
            }
        }
        .onTapGesture {
            action()
        }
    
    }

      @ViewBuilder
    private func TranslationFullScreenView(item: IndexItem, dismiss: DismissAction) -> some View { 
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            VStack(spacing:0){

            
                AsyncImage(url: URL(string: translationDetail?.result_url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 180)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                if translationDetail?.result_url != nil {
                HStack(alignment: .center){
                    Spacer()
                    Button(action: {
                        let imageSaveHelper = ImageSaveHelper()
                        imageSaveHelper.saveImageToAlbum(from: translationDetail?.result_url ?? "")
                    }) {
                        VStack(spacing:10){
                            Image("保存到相册_(1) 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("保存")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                      Spacer()
                    Button(action:{

                    let shareInfo = formatShareJSON(translationDetail?.share_sharejson)
                    let title = shareInfo.title.isEmpty ? "Mobiwusi总结" : shareInfo.title
                    let description = shareInfo.summary
                    let imageUrl = translationDetail?.result_url ?? ""
                    let shareURL = translationDetail?.share_url ?? "https://www.mobiwusi.com"
                    
                    // 获取当前的UIViewController
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        var currentVC = rootViewController
                        while let presentedVC = currentVC.presentedViewController {
                            currentVC = presentedVC
                        }

                          MOSharingManager.shared.share(
                            title: title,
                            description: description,
                            imageUrl: imageUrl,
                            shareURL: shareURL,
                            from: currentVC,
                            shareOption: .shareLink
                        ) { success in
                            // 只有分享成功才调用统计接口
                            if success {
                               
                            }
                        }
                       }

                    }){
                        VStack(spacing:10){
                            Image("share_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("分享")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                      Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 180)
                .background(Color(hex:"#18283A"))
                }
             }

              // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
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

            //翻译按钮
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    if let translationDetail = translationDetail {
                        NavigationLink(destination: TranslationResultController(translationDetail: translationDetail)) {
                            Image("Group_137")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 220)
                                .padding(.trailing, 30)
                        }
                    }
                }
            }


        }
          .navigationBarBackButtonHidden(true)
        .onAppear{
            getTranslationDetail(id:data.id)
        }
    }

    
    
    @ViewBuilder
    private func MessageSheetView() -> some View {
        VStack(spacing: 20) {
            
            // 标题栏
            HStack {
                 Spacer()
                Text("消息")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                 Spacer()
                Button(action: {
                    showMessageSheet = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            if !summaryMessageList.isEmpty {
            // 消息内容区域
            ScrollView(showsIndicators: false) {
                LazyVStack{
                    ForEach(summaryMessageList, id: \.id) { item in
                    VStack(spacing:15){
                        HStack(alignment:.center){
                            HStack(spacing:10){
                                Image(item.operation_type == 1 ? "icon_summary_praise_big_select" : "分享_5")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 20, height: 20)
                                Text(item.operation_type_text + "消息")
                                   .font(.system(size: 16))
                                   .fontWeight(.medium)
                                   .foregroundColor(.black)
                            }
                            Spacer()
                            Text(item.create_time)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom,10)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(hex:"#F2F2F2")),
                            alignment: .bottom
                        )
                       
                        HStack(alignment: .center, spacing: 12) {
                            // 头像
                            AsyncImage(url: URL(string: item.user_avatar)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                            } placeholder: {
                              Image("占位图")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            }
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                           HStack(spacing:20){
                              Text(item.user_name)
                                .font(.subheadline)
                                .foregroundColor(Color.black)
                              Text(item.operation_content)
                                .font(.subheadline)
                                .foregroundColor(Color.black)
                           }
                            
                            Spacer()
                        }
                        
                    }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .onAppear {
                            // 检查是否是最后一个item，如果是则加载更多
                            if item.id == summaryMessageList.last?.id && hasMoreData && !isLoadingMore {
                                getSummaryMessageList(isLoadMore: true)
                            }
                        }
                    }
                    
                    // 加载更多指示器
                    if isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("加载中...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    } else if !hasMoreData && summaryMessageList.count > 0 {
                        HStack {
                            Spacer()
                            Text("没有更多数据了")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                }
                
            }
            }else{
                Text("暂无消息")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
                Spacer()
            }
            
        }
        .onAppear{
            // 重置分页状态
            currentPage = 1
            hasMoreData = true
            summaryMessageList = []
            getSummaryMessageList()
        }
        .refreshable {
            // 刷新时重置分页状态
            currentPage = 1
            hasMoreData = true
            summaryMessageList = []
            getSummaryMessageList()
        }
        .padding(10)
        .frame(height: 350)
        .background(Color(hex:"#EDEEF5"))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // 创建分享内容的辅助函数
    private func createShareContent(image: String) -> URL {
        // 优先使用share_url，如果没有则使用图片URL
        if !share_url.isEmpty, let url = URL(string: share_url) {
            return url
        } else if let imageUrl = URL(string: image) {
            return imageUrl
        } else {
            // 如果都没有，返回一个默认URL
            return URL(string: "https://www.mobiwusi.com")!
        }
    }
    
    private func createShareContentFromJSON(_ jsonString: String?) -> URL {
        // 从JSON中获取url字段作为分享内容
        let shareData = formatShareJSON(jsonString)
        
        // 优先使用JSON中的url
        if !shareData.url.isEmpty, let url = URL(string: shareData.url) {
            return url
        }
        
        // 如果JSON中没有url，使用share_url
        if !share_url.isEmpty, let url = URL(string: share_url) {
            return url
        }
        
        // 最后使用默认URL
        return URL(string: "https://www.mobiwusi.com")!
    }
    
    private func createWeChatCompatibleShareContent(_ jsonString: String?) -> String {
        // 创建微信兼容的分享内容 - 使用简洁的文本格式
        let shareData = formatShareJSON(jsonString)
        
        var shareText = ""
        
        // 添加标题（如果有）
        if !shareData.title.isEmpty {
            shareText += shareData.title
        }
        
        // 添加描述或简介（如果有且与标题不同）
        let description = shareData.brief.isEmpty ? shareData.description : shareData.brief
        if !description.isEmpty && description != shareData.title {
            if !shareText.isEmpty {
                shareText += "\n"
            }
            shareText += description
        }
        
        // 添加链接
        var shareUrl = ""
        if !shareData.url.isEmpty {
            shareUrl = shareData.url
        } else if !share_url.isEmpty {
            shareUrl = share_url
        } else {
            shareUrl = "https://www.mobiwusi.com"
        }
        
        if !shareText.isEmpty {
            shareText += "\n"
        }
        shareText += shareUrl
        
        return shareText
    }
    
   
    
    private func formatShareJSON(_ jsonString: String?) -> (title: String, description: String, brief: String, url:String,summary:String) {
        guard let jsonString = jsonString,
              !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            return (title: "分享内容", description: "", brief: "", url:"",summary:"")
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let title = jsonObject["title"] as? String ?? 
                           jsonObject["name"] as? String ?? 
                           jsonObject["subject"] as? String ?? 
                           "分享内容"
                
                let description = jsonObject["description"] as? String ?? 
                                jsonObject["desc"] as? String ?? 
                                jsonObject["content"] as? String ?? 
                                jsonObject["message"] as? String ?? 
                                ""
                
                let brief = jsonObject["brief"] as? String ?? 
                           jsonObject["summary"] as? String ?? 
                           jsonObject["abstract"] as? String ?? 
                           jsonObject["preview"] as? String ?? 
                           ""
                
                let url = jsonObject["url"] as? String ?? ""
                let summary = jsonObject["summary"] as? String ?? ""
                
                return (title: title, description: description, brief: brief, url:url,summary:summary)
            }
        } catch {
            print("JSON解析错误: \(error.localizedDescription)")
        }
        
        // 如果JSON解析失败，尝试直接使用字符串作为标题
        let fallbackText = jsonString.count > 50 ? String(jsonString.prefix(50)) + "..." : jsonString
        return (title: fallbackText, description: "", brief: fallbackText, url:"",summary:"")
    }

    //MARK：- 总结消息列表
    func getSummaryMessageList(isLoadMore: Bool = false){
        guard let detailId = newsAnalysisDetail?.id else {
            print("newsAnalysisDetail is nil, cannot get summary message list")
            return
        }
        
        // 如果是加载更多，检查是否还有更多数据
        if isLoadMore && !hasMoreData {
            return
        }
        
        // 设置加载状态
        if isLoadMore {
            isLoadingMore = true
        }
        
        let requestBody: [String: Any] = [
                "user_paste_board_id": detailId,
                "page": isLoadMore ? currentPage + 1 : 1,
                "limit":limit
            ]
         NetworkManager.shared.post(APIConstants.Index.getSummaryMessageList, 
                                 businessParameters: requestBody) { (result: Result<SummaryMessageListResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        let newList = response.data?.list ?? []
                        summaryMsgTotal = response.data?.total ?? 0
                        
                        if isLoadMore {
                            // 追加数据
                            summaryMessageList.append(contentsOf: newList)
                            currentPage += 1
                        } else {
                            // 替换数据（首次加载或刷新）
                            summaryMessageList = newList
                            currentPage = 1
                        }
                        
                        // 检查是否还有更多数据
                        hasMoreData = summaryMessageList.count < summaryMsgTotal
                        
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
                
                // 重置加载状态
                if isLoadMore {
                    isLoadingMore = false
                }
            }
        }
    }

    //MARK：- 获取多变摄影师详情
    func getVariationPhotographerDetail(id: Int) {
        let requestBody: [String: Any] = [
                "id": id,
            ]
         NetworkManager.shared.post(APIConstants.Index.getVariationPhotographerDetail, 
                                 businessParameters: requestBody) { (result: Result<GhibliDetailResponse, APIError>) in
            DispatchQueue.main.async {       
                switch result {
                case .success(let response):
                    if response.code == 1{
                        share_url = response.data?.share_url ?? ""
                        ghibliDetail = response.data 
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    //MARK：- 获取图片翻译详情
    func getTranslationDetail(id: Int) {
        let requestBody: [String: Any] = [
                "id": id,
            ]
         NetworkManager.shared.post(APIConstants.Index.getImageTranslationDetail, 
                                 businessParameters: requestBody) { (result: Result<ImageTranslationDetailResponse, APIError>) in
            DispatchQueue.main.async {       
                switch result {
                case .success(let response):
                    if response.code == 1{
                        share_url = response.data?.share_url ?? ""
                        translationDetail = response.data 
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    //MARK: - 获取资讯分析详情
    func getNewsAnalysisDetail(id: Int){
        let requestBody: [String: Any] = [
                "id": id,
            ]
         NetworkManager.shared.post(APIConstants.Index.getNewsAnalysisDetail, 
                                 businessParameters: requestBody) { (result: Result<UserDataSummaryDetailResponse, APIError>) in
            DispatchQueue.main.async {       
                switch result {
                case .success(let response):
                    if response.code == 1{
                        share_url = response.data?.share_url ?? ""
                        newsAnalysisDetail = response.data 
                        shareCount = response.data?.share_num ?? 0
                        likeCount = response.data?.like_num ?? 0
                        operation_status =  response.data?.is_like ?? 0
                        
                        // 刷新完成后的动画效果
                        if isRefreshing {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                refreshOpacity = 1.0
                                refreshScale = 1.0
                                isRefreshing = false
                                buttonRotation = 0.0
                            }
                        }
                    } else {
                        errorMessage = response.msg
                        if isRefreshing {
                            isRefreshing = false
                            buttonRotation = 0.0
                        }
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    if isRefreshing {
                        isRefreshing = false
                        buttonRotation = 0.0
                    }
                }
            }
        }
    }

    //MARK：- 分享、点赞操作
    func handleSummaryOperation() {
        let requestBody: [String: Any] = [
            "id": data.id,
            "operation_type": operationType,
            "operation_status": operation_status
        ]
        
        NetworkManager.shared.post(APIConstants.Index.likeNewsAnalysis, 
                                businessParameters: requestBody) { (result: Result<SummaryOperationResponse, APIError>) in
            DispatchQueue.main.async {       
                switch result {
                case .success(let response):
                    if response.code == 1{
                        if operationType == 1 {
                            likeCount = response.data ?? 0
                        } else {
                            shareCount = response.data ?? 0
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
    
    // 新增：带动画效果的刷新函数
    private func performRefreshWithAnimation() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        // 按钮旋转动画
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            buttonRotation = 360.0
        }
        
        // 内容淡出动画
        withAnimation(.easeInOut(duration: 0.3)) {
            refreshOpacity = 0.3
            refreshScale = 0.95
        }
        
        // 延迟一点时间让用户看到动画效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            getNewsAnalysisDetail(id: data.id)
        }
    }

    
    // MARK: - 导航到食品安全分析详情页面
    private func navigateToFoodSafetyDetail(item: IndexItem) {
   
        
        DispatchQueue.main.async {
            // 创建 MOFoodSafetyAnalysisDetail SwiftUI 视图
            let foodSafetyDetailView = MOFoodSafetyAnalysisDetail(item: item)
            
            // 使用 UIHostingController 包装 SwiftUI 视图
            let hostingController = UIHostingController(rootView: foodSafetyDetailView)
            hostingController.title = "食品安全分析"
            
            // 获取当前的 UIViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                print("🍎 找到 rootViewController: \(type(of: rootViewController))")
                
                // 找到最顶层的导航控制器
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                    print("🍎 找到 presentedViewController: \(type(of: topViewController))")
                }
                
                // 尝试多种方式找到导航控制器
                var navigationController: UINavigationController?
                
                if let navController = topViewController as? UINavigationController {
                    navigationController = navController
                    print("🍎 topViewController 就是 NavigationController")
                } else if let navController = topViewController.navigationController {
                    navigationController = navController
                    print("🍎 topViewController 的 navigationController 存在")
                } else if let tabBarController = topViewController as? UITabBarController,
                          let selectedViewController = tabBarController.selectedViewController {
                    if let navController = selectedViewController as? UINavigationController {
                        navigationController = navController
                        print("🍎 通过 TabBarController 找到 NavigationController")
                    } else if let navController = selectedViewController.navigationController {
                        navigationController = navController
                        print("🍎 通过 TabBarController 的 selectedViewController 找到 NavigationController")
                    }
                }
                
                if let navController = navigationController {
                    print("🍎 开始导航到食品安全分析页面")
                    navController.pushViewController(hostingController, animated: true)
                } else {
                    print("🍎 错误：无法找到 NavigationController")
                    // 如果找不到导航控制器，尝试模态展示
                    topViewController.present(hostingController, animated: true)
                    print("🍎 使用模态展示方式")
                }
            } else {
                print("🍎 错误：无法获取 rootViewController")
            }
        }
    }

}




// MARK: - 可缩放图片视图组件
struct ZoomableImageView: View {
    let imageURL: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            // 缩放手势
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 0.5), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale < 1.0 {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            scale = 1.0
                                            offset = .zero
                                        }
                                    }
                                },
                            // 拖拽手势
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    
                                    // 限制拖拽范围
                                    let maxOffsetX = max(0, (geometry.size.width * scale - geometry.size.width) / 2)
                                    let maxOffsetY = max(0, (geometry.size.height * scale - geometry.size.height) / 2)
                                    
                                    offset = CGSize(
                                        width: min(max(newOffset.width, -maxOffsetX), maxOffsetX),
                                        height: min(max(newOffset.height, -maxOffsetY), maxOffsetY)
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        // 双击重置缩放
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if scale > 1.0 {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                            }
                        }
                    }
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}





// MARK: - 图片预览模态框
struct ImagePreviewModal: View {
    let imageURL: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            
            // 垂直居中的图片容器
            VStack {
                Spacer()
                
                // 可缩放的图片
                ZoomableImageView(imageURL: imageURL)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.8) // 限制最大高度为屏幕的80%
                    .padding(.horizontal)
                
                Spacer()
            }
            
          
        }
    }
}

// MARK: - 图片保存辅助类
class ImageSaveHelper: ObservableObject {
    func saveImageToAlbum(from imagePath: String) {
        guard let imageURL = URL(string: imagePath) else {
            print("❌ 无效的图片URL")
            DispatchQueue.main.async {
                MBProgressHUD.showMessag("无效的图片URL", to: nil, afterDelay: 2.0)
            }
            return
        }
        
        // 检查是否是本地文件路径
        if imageURL.isFileURL {
            // 本地文件，直接读取
            guard let imageData = try? Data(contentsOf: imageURL),
                  let image = UIImage(data: imageData) else {
                DispatchQueue.main.async {
                    MBProgressHUD.showMessag("读取图片失败", to: nil, afterDelay: 2.0)
                }
                return
            }
            
            // 保存到相册
            saveImageToPhotoLibrary(image: image)
        } else {
            // 网络URL，下载图片
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ 下载图片失败: \(error?.localizedDescription ?? "未知错误")")
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessag("下载图片失败", to: nil, afterDelay: 2.0)
                    }
                    return
                }
                
                // 保存到相册
                self.saveImageToPhotoLibrary(image: image)
            }.resume()
        }
    }
    
    // 保存图片到相册
    private func saveImageToPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("✅ 图片保存成功")
                            MBProgressHUD.showMessag("已保存到相册", to: nil, afterDelay: 2.0)
                        } else {
                            print("❌ 保存失败: \(error?.localizedDescription ?? "未知错误")")
                            MBProgressHUD.showMessag("保存失败", to: nil, afterDelay: 2.0)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    MBProgressHUD.showMessag("需要相册权限", to: nil, afterDelay: 2.0)
                }
            }
        }
    }
    
  
}

