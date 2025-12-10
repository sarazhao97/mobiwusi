//
//  MineViewController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/13.
//

import SwiftUI
import Foundation
import AVFoundation

// 用于管理 MyProject 选中状态的可观察对象
class MyProjectStateManager: ObservableObject {
    @Published var selectedTab: Int = 0
    
    func setSelectedTab(_ tab: Int) {
        selectedTab = tab
    }
}
struct MineViewController:View {
     @Environment(\.dismiss) private var dismiss
    @State private var navigateToMyData: Bool = false
    @State private var selectedDataType: Int = 1  // 1: 音频, 2: 图片, 3: 文本, 4: 视频 ,5: 多模态
    @State private var currentSelectedCategory: Int = 1  // 当前选中的分类，用于传递给MyDataController
    @State private var errorMessage: String?
    @State private var profileData: UserProfileData?
    @State private var hasLoadedData: Bool = false  // 标记是否已经加载过数据
    @State private var isRefreshing: Bool = false  // 刷新状态
    @State var navigateToNotification: Bool = false
    @State var navigateToMyProject: Bool = false
    @State private var currentSelectedTab: Int = 0
    @StateObject private var myProjectStateManager = MyProjectStateManager()
    @State private var navigateToDataPartner: Bool = false
    @State private var navigateToLoginConfirm: Bool = false
    @State private var scanId: String = ""
    @State private var scanLoading: Bool = false
    // 新增：显示扫码页面的状态
    @State private var showQRScanner: Bool = false
    @State private var scannedURL: String? = nil


    // 解析 URL 中的指定 query 参数
    private func extractQueryValue(from url: String, key: String) -> String? {
        guard let components = URLComponents(string: url) else { return nil }
        return components.queryItems?.first(where: { $0.name == key })?.value
    }

    var body: some View {
        ZStack{
            Color(hex: "#F7F8FA").ignoresSafeArea()
            VStack{
                 ScrollView(showsIndicators: false){
                        // 顶部导航栏
                        topNavigationBar
                        // 用户信息
                        userInfoSection
                         // Mobi积分部分
                        mobiScoreSection
                        //  // 我的数据
                        myDataSection
                         // 我的项目
                        myProjectSection
                         // 我的钱包
                        myWalletSection
                        Spacer()
                 }
                .refreshable {
                            await refreshData()
                            }
            }
            .padding(.horizontal, 20)
              NavigationLink(destination: DataPartnerController(), isActive: $navigateToDataPartner) {
                                EmptyView()
                            }
              NavigationLink(destination: MyProjectController(initialSelectedTab:myProjectStateManager.selectedTab), isActive: $navigateToMyProject) {
                                EmptyView()
                            }
                NavigationLink(destination:MyDataController(initialCategory: currentSelectedCategory), isActive: $navigateToMyData) {
                    EmptyView()
                }
             NavigationLink(destination:NotificationController(), isActive: $navigateToNotification) {
                    EmptyView()
                }
            // 自定义刷新指示器
                VStack {
                    refreshIndicator
                        .opacity(isRefreshing ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isRefreshing)
                    Spacer()
                }
            
            if navigateToLoginConfirm {
                NavigationLink(destination: LoginConfirmView(id: scanId), isActive: $navigateToLoginConfirm) {
                                 EmptyView()
                             }
            }

            if scanLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#007AFF")))
                    .scaleEffect(1.5)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
         .onAppear {
                // 只在第一次加载时调用 fetchMyData
                if !hasLoadedData {
                    fetchMyData()
                    hasLoadedData = true
                }
            }
    }

    private func scanCode(id:String){
         errorMessage = ""
         scanLoading = true
         let requestBody: [String: Any] = [
                "id": id,
            ]
        
         NetworkManager.shared.post(APIConstants.Login.scanCode, 
                                 businessParameters: requestBody) { (result: Result<ScanCodeResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        navigateToLoginConfirm = true
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage ?? "", to: nil, afterDelay: 3.0)
                    }
                    scanLoading = false
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                     scanLoading = false
                }
            }
        }
    }

     // MARK: - 计算属性
    private var topNavigationBar: some View {
        HStack {
            Spacer()
            HStack(spacing: 15) {
                Image("icon_me_scan")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .padding(.vertical,0)
                    .onTapGesture { showQRScanner = true }
                    .fullScreenCover(isPresented: $showQRScanner) {
                        QRScannerView { url in
                            scannedURL = url
                            showQRScanner = false
                             scanId = extractQueryValue(from: url, key: "id") ?? ""
                            print("扫描到的二维码内容: \(scanId)")
                            // navigateToLoginConfirm = true
                            scanCode(id: scanId)
                        }
                    }

                  Button(action: {                       
                            navigateToNotification = true
                        }) {
                            Image("icon_notification")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding(.vertical,0)
                        }   
                        
                        .contentShape(Rectangle())  
                 Button(action:{
                     Task { @MainActor in
                            let vc = UIHostingController(
                                rootView: SettingViewController()
                                .toolbar(.hidden, for: .navigationBar)
                                .navigationBarBackButtonHidden(true)
                            )
                        vc.hidesBottomBarWhenPushed = true
                        MOAppDelegate().transition.push(vc, animated: true)
                                    }
                 }){
                      Image("icon_me_setting")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                               .padding(.vertical,0)
                 }
                 .contentShape(Rectangle())  
        
            }
           
        }
        .frame(height: 40) // 设置固定高度，模拟导航条高度
        .padding(.horizontal,5)
    }
     private var userInfoSection: some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: profileData?.avatar ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("icon_default_avatar")
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 10) {
                Text(profileData?.name ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.black)
                Text("Tomo: \(profileData?.moid ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#626262"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("Arrow___Caret_Down_MD 1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture{
            Task { @MainActor in
                let vc = UIHostingController(
                    rootView: PersonCenterController()
                        .toolbar(.hidden, for: .navigationBar)
                        .toolbarColorScheme(.dark)
                        .navigationTitle("个人中心")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(false)
                        .toolbar{
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.black)
                                        .font(.system(size: 18, weight: .medium))
                                }
                            }
                        }
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }
        }
       
    }
     private var refreshIndicator: some View {
        HStack(spacing: 8) {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            } else {
                Image(systemName: "arrow.down")
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(isRefreshing ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isRefreshing)
            }
            
            Text(isRefreshing ? "正在刷新" : "释放立即刷新")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 2)
    }
     // 异步刷新数据
    private func refreshData() async {
        await withCheckedContinuation { continuation in
            fetchMyData(isRefresh: true)
            // 等待刷新完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                continuation.resume()
            }
        }
    }
      private func fetchMyData(isRefresh: Bool = false) {
        if isRefresh {
            isRefreshing = true
        }
        errorMessage = nil
        
        NetworkManager.shared.post(APIConstants.Profile.getMyData, businessParameters: [:]) { (result: Result<UserProfileResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        profileData = response.data
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                
                // 刷新完成后重置状态
                if isRefresh {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRefreshing = false
                    }
                }
            }
        }
    }
    private var mobiScoreSection: some View {
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 40
        return HStack {
            VStack {
                HStack {
                    Image("icon_data_partner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: maxWidth * 0.2)
                    Spacer()
                }
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("图3_1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                            
                            Text("Mobi分：\(profileData?.mobi_point ?? 0)/\(profileData?.level_point ?? 0)")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                        }
                        .padding(.bottom,10)
                        HStack {
                            // 进度条背景
                            ZStack(alignment: .leading) {
                                // 背景条
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#D03230").opacity(0.1))
                                    .frame(width: maxWidth * 0.7,height: 5)
                                    .cornerRadius(5)
                                
                                // 进度条
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#9A1E2E"))
                                    .frame(width: calculateProgressWidth(), height: 5)
                                     .cornerRadius(5)
                            }
                            .frame(width: maxWidth * 0.7)
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
            HStack {
                Image(getLevelImageName())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: maxWidth * 0.2, height: maxWidth * 0.2)
            }
        }
        .padding(.leading, 20)
        .padding(.vertical, 20)
        .frame( maxHeight: 120)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#fde0e1"), Color(hex: "#ffffff")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .padding(.top, 20)
        .onTapGesture{
           navigateToDataPartner = true

        }
        
    }
     private func calculateProgressWidth() -> CGFloat {
        guard let levelPoint = profileData?.level_point,
              let mobiPoint = profileData?.mobi_point,
              levelPoint > 0 else {
            return 0
        }
        
        let progress = Double(mobiPoint) / Double(levelPoint)
        return 250 * CGFloat(progress)
    }
      // 根据用户等级获取对应的图片名称
    private func getLevelImageName() -> String {
        guard let level = profileData?.level else {
            return "image(1)" // 默认等级1
        }
        
        switch level {
        case 1:
            return "image(1)"
        case 2:
            return "image(2)"
        case 3:
            return "image(3)"
        case 4:
            return "image(4)"
        default:
            return "image(5)" // 等级5或更高
        }
    }
    private var myDataSection: some View {
        VStack(spacing: 5) {
            HStack {
                Text("我的数据")
                    .font(.system(size: 20))
                    .foregroundColor(Color.black)
                Spacer()
            }
            .padding(.bottom, 10)
            
            HStack(alignment: .center, spacing: 10) {
                dataTypeButton(
                    imageName: "icon_me_audio",
                    title: "音频数据",
                    dataType: 1
                )
                Spacer()
                
                dataTypeButton(
                    imageName: "icon_me_img",
                    title: "图片数据",
                    dataType: 2
                )
                Spacer()
                
                dataTypeButton(
                    imageName: "icon_me_file",
                    title: "文本数据",
                    dataType: 3
                )
                Spacer()
                
                dataTypeButton(
                    imageName: "icon_me_video",
                    title: "视频数据",
                    dataType: 4
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }

    private func dataTypeButton(imageName: String, title: String, dataType: Int) -> some View {
        Button(action: {
            selectedDataType = dataType
            currentSelectedCategory = dataType
            navigateToMyData = true
        }) {
            VStack(spacing: 5) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#333333"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
            }
        }
    }
    private var myProjectSection: some View {
        VStack(spacing: 5) {
            HStack {
                Text("我的项目")
                    .font(.system(size: 20))
                    .foregroundColor(Color.black)
                Spacer()
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 10) {
                projectItem(imageName: "icon_project_all", title: "全部项目",id:0)
                Spacer()
                projectItem(imageName: "icon_project_prossing", title: "进行中",id:1)
                Spacer()
                projectItem(imageName: "icon_project_awaiting_review", title: "待审核",id:2)
                Spacer()
                projectItem(imageName: "icon_project_revised", title: "待修正",id:3)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
    private func projectItem(imageName: String, title: String, id: Int) -> some View {
        VStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#333333"))
        }
        .onTapGesture{
            currentSelectedTab = id
            myProjectStateManager.setSelectedTab(id)
            // 使用 withAnimation 确保状态更新完成
            withAnimation(.easeInOut(duration: 0.1)) {
                navigateToMyProject = true
            }
        }
    }
    private var myWalletSection: some View {
            VStack(spacing: 5) {
                HStack {
                    Text("我的钱包")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                HStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text(profileData?.account_balance ?? "0.00")
                            .font(.custom("Satoshi-Bold", size: 24))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                        Text("总资产（元）")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9B9B9B"))
                    }
                    .padding(.leading, 10)
                    Spacer()
                    
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "#EDEEF5"))
                            .frame(width: 1, height: 40)
                    }
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text(profileData?.yesterday_income ?? "0.00")
                             .font(.custom("Satoshi-Bold", size: 24))
                            .foregroundColor(Color.black)
                        Text("昨日新增")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9B9B9B"))
                    }
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text(profileData?.income_val ?? "0.00")
                            .font(.custom("Satoshi-Bold", size: 24))
                            .foregroundColor(Color.black)
                        Text("累计收益")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9B9B9B"))
                    }
                }
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
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
    }
}

// MARK: - MOPropertyVC Wrapper
struct MOPropertyViewControllerWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MOPropertyVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MOPropertyVC") as? MOPropertyVC else {
            fatalError("无法创建 MOPropertyVC")
        }
        
        // 不需要设置返回按钮，让 SwiftUI 的 NavigationView 处理
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MOPropertyVC, context: Context) {
        // 不需要更新
    }
    
}

// MARK: - 内置全屏二维码扫码视图（避免外部文件未加入 Target 导致找不到）
final class InlineQRScannerModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var lastCode: String?
    let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var scanRectInLayer: CGRect = .zero

    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        session.commitConfiguration()
        if !session.isRunning { session.startRunning() }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let layer = previewLayer else { return }
        for obj in metadataObjects {
            guard let codeObj = obj as? AVMetadataMachineReadableCodeObject,
                  codeObj.type == .qr,
                  let transformed = layer.transformedMetadataObject(for: codeObj) as? AVMetadataMachineReadableCodeObject,
                  let value = codeObj.stringValue else { continue }
            if scanRectInLayer == .zero || scanRectInLayer.intersects(transformed.bounds) {
                lastCode = value
                if session.isRunning { session.stopRunning() }
                break
            }
        }
    }
}

struct InlineCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    @ObservedObject var model: InlineQRScannerModel

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        model.previewLayer = view.videoPreviewLayer
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.videoPreviewLayer.videoGravity = .resizeAspectFill
        model.previewLayer = uiView.videoPreviewLayer
    }

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// 修复后的 QRScannerView（仅保留核心修改部分）
struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = InlineQRScannerModel()
    var onSuccess: (String) -> Void
    @State private var cameraAuthorized = false
    @State private var scanProgress: CGFloat = 0.0 // 0=扫描框顶部，1=扫描框底部
    @State private var isAnimating = false // 控制动画状态，避免重复启动
    @State private var showCameraPermissionDialog = false // 显示摄像头权限提示对话框

    var body: some View {
        ZStack {
            // 相机预览（最底层）
            InlineCameraPreview(session: scanner.session, model: scanner)
                .ignoresSafeArea()
            
            // 遮罩 + 扫描框 + 动画（中间层）
            GeometryReader { geo in
                let scanSide = min(geo.size.width, geo.size.height) * 0.6
                let scanRect = CGRect(
                    x: (geo.size.width - scanSide) / 2,
                    y: (geo.size.height - scanSide) / 2 - 20,
                    width: scanSide,
                    height: scanSide
                )
                
                // 半透明遮罩（扫描框外）
                Color.black.opacity(0.35)
                    .mask(
                        ZStack {
                            Rectangle().frame(maxWidth: .infinity, maxHeight: .infinity)
                            Rectangle().path(in: scanRect).fill(Color.clear)
                        }
                    )
                    .allowsHitTesting(false)
                
                // 四角 L 形扫描框（保持原有）
                let cornerLen = scanSide * 0.22
                let lineW: CGFloat = 2
                Group {
                    Path { p in
                        p.move(to: CGPoint(x: scanRect.minX, y: scanRect.minY + cornerLen))
                        p.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.minY))
                        p.addLine(to: CGPoint(x: scanRect.minX + cornerLen, y: scanRect.minY))
                    }.stroke(Color(hex:"#f06362"), lineWidth: lineW)
                    
                    Path { p in
                        p.move(to: CGPoint(x: scanRect.maxX - cornerLen, y: scanRect.minY))
                        p.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY))
                        p.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY + cornerLen))
                    }.stroke(Color(hex:"#f06362"), lineWidth: lineW)
                    
                    Path { p in
                        p.move(to: CGPoint(x: scanRect.minX, y: scanRect.maxY - cornerLen))
                        p.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.maxY))
                        p.addLine(to: CGPoint(x: scanRect.minX + cornerLen, y: scanRect.maxY))
                    }.stroke(Color(hex:"#f06362"), lineWidth: lineW)
                    
                    Path { p in
                        p.move(to: CGPoint(x: scanRect.maxX - cornerLen, y: scanRect.maxY))
                        p.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY))
                        p.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY - cornerLen))
                    }.stroke(Color(hex:"#f06362"), lineWidth: lineW)
                }
                .onAppear { updateScanRectLayer(from: scanRect) }
                .onChange(of: geo.size) { _ in updateScanRectLayer(from: scanRect) }
                
                // MARK: 扫描线（位置精准 + 持续匀速滚动）
                let scanLineHeight: CGFloat = 3
                let scanLineY = scanRect.minY + (scanRect.height - scanLineHeight) * scanProgress
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#f06362").opacity(0.5),
                                Color(hex: "#f06362").opacity(1.0),
                                Color(hex: "#f06362").opacity(0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: scanSide - 16, height: scanLineHeight)
                    .position(x: scanRect.midX, y: scanLineY + scanLineHeight/2)
                    .opacity(1.0)
                    .shadow(color: Color(hex: "#f06362").opacity(0.8), radius: 3)
                
                // 原有网格动画（可选保留）
                let cellSize: CGFloat = 4
                let columns = Int(floor(scanSide / cellSize))
                let barH = cellSize * 3
                let barY = scanRect.minY + (scanSide - barH) * scanProgress
                let strokeW: CGFloat = 0.6
                let fadeInSpan: CGFloat = 0.08
                let fadeOutSpan: CGFloat = 0.08
                let gridOpacity = min(scanProgress / fadeInSpan, max(0, 1 - (scanProgress - (1 - fadeOutSpan)) / fadeOutSpan))
                
                ZStack {
                    let cBottom = Color.red.opacity(1.0)
                    let cMiddle = Color.red.opacity(0.7)
                    let cTop = Color.red.opacity(0.45)
                    
                    ForEach(0..<columns, id: \.self) { col in
                        let startX = scanRect.minX + cellSize * CGFloat(col)
                        let endX = startX + cellSize
                        Path { p in
                            p.move(to: CGPoint(x: startX, y: barY))
                            p.addLine(to: CGPoint(x: endX, y: barY))
                        }.stroke(cTop, lineWidth: strokeW)
                    }
                    
                    ForEach(0..<columns, id: \.self) { col in
                        let startX = scanRect.minX + cellSize * CGFloat(col)
                        let endX = startX + cellSize
                        Path { p in
                            p.move(to: CGPoint(x: startX, y: barY + cellSize))
                            p.addLine(to: CGPoint(x: endX, y: barY + cellSize))
                        }.stroke(cMiddle, lineWidth: strokeW)
                        Path { p in
                            p.move(to: CGPoint(x: startX, y: barY + cellSize * 2))
                            p.addLine(to: CGPoint(x: endX, y: barY + cellSize * 2))
                        }.stroke(cMiddle, lineWidth: strokeW)
                    }
                    
                    ForEach(0..<columns, id: \.self) { col in
                        let startX = scanRect.minX + cellSize * CGFloat(col)
                        let endX = startX + cellSize
                        Path { p in
                            p.move(to: CGPoint(x: startX, y: barY + cellSize * 2))
                            p.addLine(to: CGPoint(x: endX, y: barY + cellSize * 2))
                        }.stroke(cBottom, lineWidth: strokeW)
                        Path { p in
                            p.move(to: CGPoint(x: startX, y: barY + cellSize * 3))
                            p.addLine(to: CGPoint(x: endX, y: barY + cellSize * 3))
                        }.stroke(cBottom, lineWidth: strokeW)
                    }
                }
                .opacity(Double(gridOpacity))
                .mask(
                    Rectangle()
                        .frame(width: scanSide, height: scanSide)
                        .position(x: scanRect.midX, y: scanRect.midY)
                )
                
                // 提示文字
                Text("将二维码放入框内，即可自动扫描")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .position(x: scanRect.midX, y: scanRect.maxY + 28)
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 2)
                    }
                }.padding(.top, 12).padding(.horizontal, 16)
                Spacer()
            }
        }
        .onAppear {
            requestCameraPermissionAndStart()
        }
        .onChange(of: cameraAuthorized) { authorized in
            if authorized {
                showCameraPermissionDialog = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startScanAnimation()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // 当应用从后台返回前台时，重新检查权限状态
            requestCameraPermissionAndStart()
        }
        .onReceive(scanner.$lastCode.compactMap { $0 }) { code in
            onSuccess(code)
            stopScanAnimation()
            dismiss()
        }
        .onDisappear {
            stopScanAnimation()
        }
        .overlay {
            // 摄像头权限提示对话框
            if showCameraPermissionDialog {
                cameraPermissionDialog
                    .zIndex(1000)
            }
        }
    }
    
    // MARK: - 摄像头权限提示对话框
    @ViewBuilder
    private var cameraPermissionDialog: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showCameraPermissionDialog = false
                }
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#f06362"))
                
                Text("需要摄像头权限")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("为了扫描二维码，请在系统设置中为本应用开启摄像头权限。")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Button(action: {
                        showCameraPermissionDialog = false
                        dismiss()
                    }) {
                        Text("取消")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#f06362"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#f06362").opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showCameraPermissionDialog = false
                        openAppSettings()
                    }) {
                        Text("前往设置")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#f06362"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .frame(maxWidth: 320)
        }
    }
    
    // 跳转到系统设置中的应用权限管理页面
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                if success {
                    print("成功跳转到系统设置")
                } else {
                    print("跳转到系统设置失败")
                }
            }
        }
    }
    
    // 权限请求（保持原有）
    private func requestCameraPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            scanner.configure()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraAuthorized = granted
                    if granted {
                        scanner.configure()
                    } else {
                        // 用户拒绝了权限请求，显示提示对话框
                        showCameraPermissionDialog = true
                    }
                }
            }
        case .denied, .restricted:
            // 权限被拒绝或受限，显示提示对话框
            cameraAuthorized = false
            showCameraPermissionDialog = true
        @unknown default:
            cameraAuthorized = false
            showCameraPermissionDialog = true
        }
    }
    
    // 更新扫描区域（保持原有）
    private func updateScanRectLayer(from rect: CGRect) {
        scanner.scanRectInLayer = rect
    }
    
    // MARK: 修复核心：持续循环动画（无停顿、匀速）
    private func startScanAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let scanDuration: TimeInterval = 1.5 // 单次滚动时长（匀速）
        let resetDelay: TimeInterval = 0.1 // 重置延迟（避免卡顿）
        
        // 定义动画循环函数
        func animateLoop() {
            guard isAnimating else { return }
            
            // 1. 从顶部滚动到底部（匀速）
            withAnimation(.linear(duration: scanDuration)) {
                scanProgress = 1.0
            }
            
            // 2. 滚动结束后，延迟重置到顶部
            DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) {
                guard isAnimating else { return }
                
                // 重置时用无动画，瞬间回到顶部
                withAnimation(.none) {
                    scanProgress = 0.0
                }
                
                // 3. 延迟后再次执行循环
                DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                    animateLoop()
                }
            }
        }
        
        // 启动第一次循环
        animateLoop()
    }
    
    // 停止动画（页面消失或扫描成功时调用）
    private func stopScanAnimation() {
        isAnimating = false
        withAnimation(.none) {
            scanProgress = 0.0
        }
    }
}