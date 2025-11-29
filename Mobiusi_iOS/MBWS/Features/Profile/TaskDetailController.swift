//
//  TaskDetailController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/12.
//

import SwiftUI
import Foundation
import UIKit
import WebKit
import Photos
import AVFoundation
import AVKit
import PhotosUI
import CryptoKit
import UniformTypeIdentifiers

// MARK: - TopRoundedRectangle Shape
struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), 
                   radius: cornerRadius, 
                   startAngle: Angle(degrees: 180), 
                   endAngle: Angle(degrees: 270), 
                   clockwise: false)
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius), 
                   radius: cornerRadius, 
                   startAngle: Angle(degrees: 270), 
                   endAngle: Angle(degrees: 0), 
                   clockwise: false)
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}



struct TaskDetailController: View {
    let taskId: Int
    let userTaskId: Int
    @Environment(\.dismiss) var dismiss
    
    // 公共初始化器，userTaskId 为可选参数
    public init(taskId: Int, userTaskId: Int? = nil) {
        self.taskId = taskId
        self.userTaskId = userTaskId ?? 0
       
    }
    @State var errorMessage: String?
    @State var taskDetail: TaskDetailData?
    // 说明sheet弹窗状态
    @State private var showInstructionSheet: Bool = false
    @State private var showExampleSheet: Bool = false
    // 录音面板状态
    @State private var showRecordingPanel: Bool = false
    // 全屏图片预览状态
    @State private var showFullScreenImagePreview: Bool = false
    @State private var selectedImageURL: String? = nil
    @State private var selectedImageIndex: Int = 0
    @State private var allImageURLs: [String] = []
    @State private var imagePreviewScale: CGFloat = 0.1
    // 全屏视频预览状态
    @State private var showFullScreenVideoPreview: Bool = false
    @State private var selectedVideoURL: String? = nil
    @State private var videoPlayer: AVPlayer? = nil
    // 当前选中的网格ID
    @State var currentSelectedGridId: Int = 0
    // 录制状态
    @State private var isRecording: Bool = false
    // 波形动画状态
    @State private var waveformAnimationTimer: Timer?
    @State private var currentWaveIndex: Int = 0
    
    // 音频录制相关状态
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingTimer: Timer?
    @State private var recordingDuration: TimeInterval = 0
    @State private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    @State private var recordingURL: URL?
    @State private var audioFiles: String = ""
    @State private var isAudioRecorderConfigured: Bool = false
    
    // 音频上传相关状态变量
    @State private var presignedAudioDatas: [PresignedUrlItem] = []
    @State var gridIdToPreviewUrl: [Int: String] = [:]
    @State var gridIdToFileName: [Int: String] = [:]
    @State private var uploadAudioGridIds: [Int] = []
    @State private var audioGridPathPairs: [(gridId: Int, path: String, file_name: String)] = []
    @State private var textGridPathPairs: [(gridId: Int, path: String, file_name: String)] = []
    
    // 放弃项目确认对话框状态
    @State private var showAbandonConfirmDialog: Bool = false
    @State private var isLoading: Bool = false
    // 底部弹窗是否处于最大高度（用于导航栏显示标题）
    @State private var isSheetAtMaxHeight: Bool = false
    //关注/取消关注任务
    @State private var followAction: Int = 1 // 1关注2取消关注
    @State private var showCancelFollowDialog: Bool = false
    //项目关注状态
    @State private var isFollowed: Bool = false

    @State private var share_url: String? = nil
    @State private var titleTextSize: CGSize = .zero
    @State private var descriTextSize: CGSize = .zero
    @State private var navigateToMyProject: Bool = false

   
    

    private var coverImageURL: URL? {
        guard let urlString = taskDetail?.cover_image, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private func getAuditStatusText() -> String {
        guard let status = taskDetail?.task_status?.intValue else { return "未知状态" }
        switch status {
        case 1:
            return "进行中"
        case 2:
            return "审核中"
        case 3:
            return "未通过"
        case 4:
            return "初审通过"
        case 5:
            return "已完成"
        default:
            return "未知状态"
        }
    }
    
    private func getRerecordProgressText() -> String {
        // 只有当审核状态为"未通过"或"初审未通过"时才显示重录进度
        let auditStatus = getAuditStatusText()
        guard auditStatus == "未通过" else { return "" }
        
        guard let topicList = taskDetail?.topic_list_data else { return "(0/0)" }
        
        // 计算总的被驳回音频数量（status == 3）
        let totalRejectedCount = topicList.filter { ($0.status ?? 0) == 3 }.count
        
        // 计算已重录的音频数量（被驳回但有新录制的音频）
        let rerecordedCount = topicList.filter { topic in
            let isRejected = (topic.status ?? 0) == 3
            let hasNewRecording = gridIdToPreviewUrl[topic.id ?? 0] != nil
            return isRejected && hasNewRecording
        }.count
        
        return "：\(rerecordedCount)/\(totalRejectedCount)"
    }


      private func sha256Hex2(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景：使用任务封面图，并添加磨砂（模糊）效果
            blurredBackground

            // 页面内容
            VStack(spacing: 10) {
                navigationBarItems
                imageAndDescription
               ScrollView(showsIndicators:false){
                 sceneIntroduction
                 scenePurpose
                 // 额外底部留白，确保滚动到底部能完全显示最后一个容器
                 Color.clear
                   .frame(height: 60)
               }
              
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.bottom,50)
            .navigationBarHidden(true)
            .onAppear {
                fetchTaskDetail()
            }         
                DraggableBottomSheet(taskDetail: taskDetail, onRefresh: { fetchTaskDetail() }, getAuditStatusText: getAuditStatusText, getRerecordProgressText: getRerecordProgressText,
                showInstructionSheet: $showInstructionSheet,showExampleSheet: $showExampleSheet, currentSelectedGridId: $currentSelectedGridId, showRecordingPanel: $showRecordingPanel,
                gridIdToPreviewUrl: $gridIdToPreviewUrl, gridIdToFileName: $gridIdToFileName, presignedAudioDatas: $presignedAudioDatas, showAbandonConfirmDialog: $showAbandonConfirmDialog, uploadAudioGridIds: $uploadAudioGridIds, audioGridPathPairs: $audioGridPathPairs, textGridPathPairs: $textGridPathPairs, isSheetAtMaxHeight: $isSheetAtMaxHeight)
                    .ignoresSafeArea(edges: .bottom)
            
        
            // 说明sheet弹窗覆盖层（最高层级）
            if showInstructionSheet {
                instructionSheetOverlay
                    .zIndex(1000)
            }

            // 示例sheet弹窗覆盖层
            if showExampleSheet {
                exampleSheetOverlay
                    .zIndex(1000)
            }

             // 录音面板覆盖层
            if showRecordingPanel {
                recordingPanelOverlay
                    .zIndex(1300)
            }
            //放弃项目面板覆盖层
            if showAbandonConfirmDialog {
                abandonTaskDialogOverlay
                    .zIndex(1400)
            }

            //关注/取消项目确认对话框
            if showCancelFollowDialog {
                cancelFollowTaskDialogOverlay
                    .zIndex(1500)
            }
            
            // 全屏图片预览
            if showFullScreenImagePreview, let imageURL = selectedImageURL {
                fullScreenImagePreviewView(imageURL: imageURL)
                    .id("\(imageURL)-\(selectedImageIndex)") // 使用 id 确保每次打开时视图重新创建
                    .zIndex(2000)
            }
            
            // 全屏视频预览
            if showFullScreenVideoPreview, let videoURL = selectedVideoURL {
                fullScreenVideoPreviewView(videoURL: videoURL)
                    .zIndex(2000)
            }

             NavigationLink(destination: MyProjectController(initialSelectedTab:0), isActive: $navigateToMyProject) {
                                EmptyView()
                            }
            
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WXOpenCustomerServiceResp"))) { notification in
            if let info = notification.userInfo as? [String: Any],
               let errCode = info["errCode"] as? Int {
                let extMsg = info["extMsg"] as? String ?? ""
                switch errCode {
                case 0:
                    MBProgressHUD.showMessag("已打开微信客服", to: nil, afterDelay: 2.0)
                case -2:
                    MBProgressHUD.showMessag("已取消打开客服", to: nil, afterDelay: 2.0)
                default:
                    let msg = extMsg.isEmpty ? "打开客服失败(\(errCode))" : extMsg
                    MBProgressHUD.showMessag(msg, to: nil, afterDelay: 3.0)
                }
            } else {
                MBProgressHUD.showMessag("客服回调异常", to: nil, afterDelay: 2.0)
            }
        }
    }

    // 模糊背景视图
    private var blurredBackground: some View {
        GeometryReader { proxy in
            ZStack {
                if let url = coverImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .blur(radius: 20)
                        default:
                            Color(hex: "#F7F8FA")
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                    // 叠加一层轻微暗色，提升内容可读性
                    Rectangle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .allowsHitTesting(false)
                } else {
                    Color(hex: "#3D4D75")
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
        .ignoresSafeArea(.all)
       
    }
    }

    //自定义导航
  var navigationBarItems: some View {
    GeometryReader { geo in
        ZStack {
           
            
            // 左右按钮分区
            HStack {
                // 左边返回
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                }

                // 右边“我的项目 + 分享”
                HStack(spacing: 20) {
                            // 中间 +关注（居中）
                    if !isFollowed {
                    HStack {
                        Text("+关注")
                            .font(.system(size: 16))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .fixedSize() // 原先为 .frame(width: geo.size.width, height: geo.size.height)
                    // .position(x: geo.size.width / 2 - 40, y: geo.size.height / 2)
                    // .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .onTapGesture {
                        followAction = 1
                        followTask()
                    }
                    } else {
                        HStack {
                        Text("取消关注")
                            .font(.system(size: 16))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .fixedSize() // 原先为 .frame(width: geo.size.width, height: geo.size.height)
                    // .position(x: geo.size.width / 2 - 40, y: geo.size.height / 2)
                    .onTapGesture {
                        followAction = 2
                        showCancelFollowDialog = true
                    }
                    }
                    Text("我的项目")
                        .font(.system(size: 16))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture{
                            navigateToMyProject = true
                        }
                        .padding(.leading,8)
                    Button(action:{
                        let title = taskDetail?.title ?? "分享内容"
                        let description = taskDetail?.simple_descri ?? ""
                        let imageUrl = taskDetail?.cover_image ?? ""
                        let shareURL = taskDetail?.share_url ?? ""
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
                           
                        }
                    }
                    }) {
                    Image("icon_project_details_share")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    }
                       
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
            }
            // .padding(.horizontal, 10)
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    .frame(height: 50)
    .padding(.top,-20)
    .foregroundColor(.white)
    .zIndex(10)
}


    


    private func fetchTaskDetail(){
            errorMessage = nil
            var requestBody: [String: Any] = [
                "task_id": taskId,
               
            ]

            if userTaskId != 0 {
                requestBody["user_task_id"] = userTaskId
            }

            NetworkManager.shared.post(APIConstants.Scene.getTaskDetail, 
                                 businessParameters: requestBody) { (result: Result<TaskDetailResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        taskDetail = response.data
                        isFollowed = response.data?.is_follow == 1
                        share_url = response.data?.share_url
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    } 
    
    // MARK: - 录制相关函数
    private func toggleRecording() {
        if isRecording {
            // 立即更新状态，确保UI响应迅速
            isRecording = false
            stopRecording()
        } else {
            // 先检查权限，再更新状态
            guard audioSession.recordPermission == .granted else {
                print("❌ 录音权限未授予")
                // 权限未授予时不更改状态
                return
            }
            
            // 立即更新状态，确保UI响应迅速
            isRecording = true
            startRecording()
        }
    }
    
    private func startRecording() {
        // 检查音频录制器是否已配置
        if !isAudioRecorderConfigured || audioRecorder == nil {
            print("❌ 音频录制器未配置或初始化失败")
            // 如果录制器未配置，尝试重新配置
            setupAudioRecorder()
            guard audioRecorder != nil else {
                print("❌ 音频录制器重新配置失败")
                isRecording = false
                return
            }
            print("✅ 音频录制器重新配置成功")
        }
        
        // 开始录音
        if audioRecorder!.record() {
            print("✅ 开始录音")
            
            // 立即启动录制时间计时器（在录音开始的同时）
            startRecordingTimer()
            
            // 启动波形动画
            startWaveformAnimation()
        } else {
            print("❌ 录音启动失败")
            // 如果录音启动失败，恢复状态
            isRecording = false
        }
    }
    
    private func stopRecording() {
       
        
        // 停止波形动画
        stopWaveformAnimation()
         // 停止录音
        audioRecorder?.stop()
        
        // 停止录制时间计时器
        stopRecordingTimer()
        
        print("✅ 录音已停止，文件保存至: \(recordingURL?.path ?? "未知路径")")
        
        // 处理录制完成的音频文件
        handleRecordingCompletion()
    }
    
    private func startWaveformAnimation() {
        currentWaveIndex = 0
        // 优化时序：更快的更新频率，更流畅的动画
        waveformAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            DispatchQueue.main.async {
                // 使用spring动画替代easeInOut，提供更自然的动画效果
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    self.currentWaveIndex = (self.currentWaveIndex + 1) % 12
                }
            }
        }
    }
    
    private func stopWaveformAnimation() {
        waveformAnimationTimer?.invalidate()
        waveformAnimationTimer = nil
        // 添加平滑的停止动画
        // withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
        //     currentWaveIndex = 0
        // }
    }
    
    // MARK: - 录制时间格式化
    private func formatRecordingTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func setupAudioRecorder() {
        // 避免重复配置
        guard !isAudioRecorderConfigured else {
            print("✅ 音频录制器已配置，跳过重复配置")
            return
        }
        
        do {
            // 配置音频会话
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            // 创建录音文件URL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
            recordingURL = audioFilename
            
            // 配置录音设置
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // 创建录音器
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            
            // 标记配置完成
            isAudioRecorderConfigured = true
            print("✅ 音频录制器配置成功")
            
        } catch {
            print("❌ 音频录制器配置失败: \(error)")
            isAudioRecorderConfigured = false
            // 可以在这里添加用户提示
        }
    }
    
    private func startRecordingTimer() {
        // 立即更新初始时间显示
        recordingDuration = 0
        
        // 创建每秒精确更新的计时器
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.recordingDuration += 1.0
            }
        }
        
        // 确保计时器在当前RunLoop中立即开始
        RunLoop.current.add(recordingTimer!, forMode: .common)
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    private func handleRecordingCompletion() {
        guard let audioURL = recordingURL else {
            print("❌ 录音文件URL为空")
            return
        }
        
        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: audioURL.path) {
            print("📁 录制完成，音频文件路径: \(audioURL.path)")
            print("⏱️ 录制时长: \(formatRecordingTime(recordingDuration))")
            
            // 获取文件大小
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: audioURL.path)
                if let fileSize = fileAttributes[.size] as? Int64 {
                    let fileSizeInMB = Double(fileSize) / (1024 * 1024)
                    print("📊 文件大小: \(String(format: "%.2f", fileSizeInMB)) MB")
                    
                    // 关闭录制面板
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRecordingPanel = false
                    }
                    
                    // 处理音频文件上传
                    processAudioFileUpload(audioURL: audioURL, fileSize: fileSize)
                }
            } catch {
                print("❌ 获取文件大小失败: \(error)")
            }
            
        } else {
            print("❌ 录音文件不存在: \(audioURL.path)")
        }
        
        // 重置音频会话
        do {
            try audioSession.setActive(false)
        } catch {
            print("❌ 重置音频会话失败: \(error)")
        }
    }
    
    // MARK: - 音频文件处理函数
    
    private func processAudioFileUpload(audioURL: URL, fileSize: Int64) {
        do {
            // 读取音频文件数据
            let audioData = try Data(contentsOf: audioURL)
            
            // 计算文件哈希值
            let fileHash = sha256Hex2(of: audioData)
            
            // 创建音频文件数据结构
            let audioFileData = createAudioFileData(
                audioURL: audioURL,
                fileSize: fileSize,
                fileHash: fileHash
            )
            
            // 将音频文件数据转换为Base64编码的JSON
            if let jsonData = try? JSONSerialization.data(withJSONObject: audioFileData, options: []) {
                audioFiles = jsonData.base64EncodedString()
                
                // 调用获取预签名URL的函数
                getAudioPresignedUrls()
            }
            
        } catch {
            print("❌ 处理音频文件失败: \(error)")
        }
    }
    
    private func createAudioFileData(audioURL: URL, fileSize: Int64, fileHash: String) -> [[String: Any]] {
        let fileName = audioURL.lastPathComponent
        
        let audioItem: [String: Any] = [
            "file_name": fileName,
            "file_size": fileSize,
            "file_hash": fileHash
        ]
        
        return [audioItem]
    }
    
    private func getAudioPresignedUrls() {
        guard !audioFiles.isEmpty else {
            print("❌ 音频文件数据为空")
            return
        }
        
        let parameters: [String: Any] = [
            "files": audioFiles
        ]
        
        NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl, 
                                 businessParameters: parameters) { (result: Result<GetPresignedUrlsResponse, APIError>) in
            DispatchQueue.main.async {
               
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        // 预签名url返回数据
                        presignedAudioDatas = response.data
                        // 按“逐条对应”维护映射：为每个预签名条目设置对应的gridId
                        uploadAudioGridIds = Array(repeating: currentSelectedGridId, count: response.data.count)
                        print("✅ 音频预签名url返回数据: \(response.data)")
                        print("✅ 已设置uploadAudioGridIds为: \(uploadAudioGridIds)")
                        performAudioUploads(presignedItems: response.data)
                    } else {
                        errorMessage = response.msg
                        print("❌ 获取音频预签名URL失败: \(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("❌ 获取音频预签名URL异常: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func performAudioUploads(presignedItems: [PresignedUrlItem]) {
        guard let audioURL = recordingURL else {
            print("❌ 音频文件URL为空")
            return
        }
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            
            for item in presignedItems {
                // 直接实现上传逻辑
                guard let uploadURL = URL(string: item.upload_url) else {
                    print("❌ 无效的上传URL: \(item.upload_url)")
                    continue
                }
                
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "PUT"
                
                let task = URLSession.shared.uploadTask(with: request, from: audioData) { responseData, response, error in
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let success = (200...299).contains(statusCode)
                    
                    DispatchQueue.main.async {
                        if success {
                            print("✅ 音频文件上传成功: \(item.file_name)")
                            print("🔗 预览URL: \(item.preview_url)")
                            print("🆔 文件ID: \(item.file_id)")
                            
                            updateAudioTaskMetadata(for: currentSelectedGridId,  item:item)
                            // 记录 gridId、path 与 file_name 的映射，用于提交任务
                            let pair = (gridId: currentSelectedGridId, path: item.path, file_name: item.file_name)
                            if let idx = self.audioGridPathPairs.firstIndex(where: { $0.gridId == currentSelectedGridId }) {
                                self.audioGridPathPairs[idx] = pair
                            } else {
                                self.audioGridPathPairs.append(pair)
                            }
                            print("✅ 已记录音频上传映射: gridId=\(currentSelectedGridId), path=\(item.path), file_name=\(item.file_name)")
                            
                        } else {
                            print("❌ 音频文件上传失败: \(item.file_name), 状态码: \(statusCode)")
                            if let error = error {
                                print("❌ 错误详情: \(error)")
                            }
                        }
                    }
                }
                task.resume()
            }
            
        } catch {
            print("❌ 读取音频文件数据失败: \(error)")
        }
    }
    // MARK: - 更新音频元数据
      private func updateAudioTaskMetadata(for gridId: Int, item: PresignedUrlItem) {
        print("更新音频元数据：gridId=\(gridId)")
        
        // 保存gridId与preview_url的关联
        gridIdToPreviewUrl[gridId] = item.preview_url
        
        let audioTopics = (taskDetail?.topic_list_data ?? []).filter { ($0.cate ?? 0) == 1 }
        guard let topic = audioTopics.first(where: { $0.id == gridId }) ?? audioTopics.first(where: { $0.id == gridId }) else { return }
            // 音频元数据更新（保持原有逻辑）
            updateAudioMetadata(for: gridId, topic: topic, item: item)
    }

    // 提取文件扩展名
    private func fileExtension2(from fileName: String) -> String {
        if let dotIndex = fileName.lastIndex(of: "."), dotIndex < fileName.endIndex {
            let extIndex = fileName.index(after: dotIndex)
            return String(fileName[extIndex...]).lowercased()
        }
        return ""
    }


    private func updateAudioMetadata(for gridId: Int, topic: TaskTopicItem, item: PresignedUrlItem) {
         
        print("presignedAudioDatas: \(presignedAudioDatas)")  
        print("更新音频元数据：gridId=\(gridId), topic=\(topic), item=\(item)")
        let format = fileExtension2(from: item.file_name)
        let audioMetadata: [String: Any] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": 1,                                
            "path": item.path,
            "duration": topic.duration ?? 0,          
            "file_name": item.file_name,
            "size": item.file_size,
            "format": format.isEmpty ? "wav" : format,
            "quality": "",
            "audio_rate": "",                         // 图片无采样率
            "location": NSNull()
        ]
        
        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: audioMetadata) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print(topic)
                        print("更新音频元数据成功：meta_id=\(topic.id)")
                      
                    } else {
                        errorMessage = response.msg
                        print("更新音频元数据失败：meta_id=\(topic.id)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("更新音频元数据异常：meta_id=\(topic.id)，error=\(error.localizedDescription)")
                }
            }
        }
       
    }

    // MARK: - 说明sheet弹窗覆盖层
    private var instructionSheetOverlay: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 半透明背景遮罩
                Color.black.opacity(showInstructionSheet ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showInstructionSheet = false
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: showInstructionSheet)
                
                // 底部sheet内容
                VStack(spacing: 0) {            
                    VStack(spacing: 20) {
                        // 标题
                        Text("说明")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        
                        ScrollView(showsIndicators: false) {
                            Text({
                                let rec = taskDetail?.recording_requirements?.trimmingCharacters(in: .whitespacesAndNewlines)
                                let pic = taskDetail?.picture_requirements?.trimmingCharacters(in: .whitespacesAndNewlines)
                                let txt = taskDetail?.text_requirements?.trimmingCharacters(in: .whitespacesAndNewlines)
                                let vid = taskDetail?.video_requirements?.trimmingCharacters(in: .whitespacesAndNewlines)
                                func nonEmpty(_ s: String?) -> String? {
                                    guard let s = s, !s.isEmpty else { return nil }
                                    return s
                                }
                                let cate = taskDetail?.cate ?? 0
                                switch cate {
                                case 1:
                                    return nonEmpty(rec) ?? nonEmpty(pic) ?? nonEmpty(txt) ?? nonEmpty(vid) ?? "暂无说明"
                                case 2:
                                    return nonEmpty(pic) ?? nonEmpty(rec) ?? nonEmpty(txt) ?? nonEmpty(vid) ?? "暂无说明"
                                case 3:
                                    return nonEmpty(txt) ?? nonEmpty(rec) ?? nonEmpty(pic) ?? nonEmpty(vid) ?? "暂无说明"
                                case 4:
                                    return nonEmpty(vid) ?? nonEmpty(rec) ?? nonEmpty(pic) ?? nonEmpty(txt) ?? "暂无说明"
                                default:
                                    return nonEmpty(rec) ?? nonEmpty(pic) ?? nonEmpty(txt) ?? nonEmpty(vid) ?? "暂无说明"
                                }
                            }())
                                .font(.system(size: 16))
                                .foregroundColor(Color.black)
                                .lineSpacing(8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                
                            // 额外底部留白，确保滚动到底部能完全显示最后一个容器
                            Color.clear
                                .frame(height: 60)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 2)
                .background(
                    TopRoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .offset(y: showInstructionSheet ? 0 : geometry.size.height / 2)
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: showInstructionSheet)
            }
        }
        .ignoresSafeArea()
    }
    
    private var exampleSheetOverlay: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                exampleSheetBackground
                exampleSheetContent(geometry: geometry)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private var exampleSheetBackground: some View {
        Color.black.opacity(showExampleSheet ? 0.4 : 0)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showExampleSheet = false
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showExampleSheet)
    }
    
    @ViewBuilder
    private func exampleSheetContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Text("示例")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                exampleSheetScrollContent
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height / 2)
        .background(
            TopRoundedRectangle(cornerRadius: 16)
                .fill(Color(hex:"#F7F8FA"))
        )
        .offset(y: showExampleSheet ? 0 : geometry.size.height / 2)
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: showExampleSheet)
    }
    
    @ViewBuilder
    private var exampleSheetScrollContent: some View {
        ScrollView(showsIndicators: false) {
            let samples = taskDetail?.sample_list ?? []
            if samples.isEmpty {
                emptyExampleView
            } else {
                let imageOrVideoSamples = samples.filter { ($0.cate ?? 0) == 2 || ($0.cate ?? 0) == 4 }
                let textOrAudioSamples = samples.filter { ($0.cate ?? 0) == 1 || ($0.cate ?? 0) == 3 }

                if !imageOrVideoSamples.isEmpty {
                    exampleImageGrid(samples: imageOrVideoSamples)
                }
                if !textOrAudioSamples.isEmpty {
                    exampleList(samples: textOrAudioSamples)
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyExampleView: some View {
        Text("暂无示例")
            .font(.system(size: 14))
            .foregroundColor(Color(hex: "#A1A6B3"))
            .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func exampleImageGrid(samples: [TaskSampleItem]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(samples.indices), id: \.self) { index in
                exampleImageItem(item: samples[index], index: index)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func exampleImageItem(item: TaskSampleItem, index: Int) -> some View {
        ZStack {
            exampleImageContent(item: item)
            exampleImageIndexBadge(index: index)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill) // 使用 fill 确保填满正方形
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#ECEEF2"), lineWidth: 1)
        )
        .onTapGesture {
            // 判断是视频还是图片
            if item.cate == 4 {
                // 视频预览
                if let videoURL = item.path_url, !videoURL.isEmpty {
                    selectedVideoURL = videoURL
                    showFullScreenVideoPreview = true
                }
            } else {
                // 图片预览
                let imageURL = item.path_url ?? ""
                if !imageURL.isEmpty {
                    // 收集所有图片URL
                    let samples = taskDetail?.sample_list ?? []
                    let urls = samples.compactMap { $0.path_url ?? $0.path_thumb }.filter { !$0.isEmpty }
                    
                    selectedImageURL = imageURL
                    selectedImageIndex = urls.firstIndex(of: imageURL) ?? index
                    allImageURLs = urls
                    
                    // 重置缩放状态
                    imagePreviewScale = 0.1
                    
                    // 显示全屏预览
                    showFullScreenImagePreview = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func exampleImageContent(item: TaskSampleItem) -> some View {
        if let urlStr = item.cate == 2 ? item.path_url : item.path_thumb, let url = URL(string: urlStr) {
            GeometryReader { geometry in
                ZStack {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        default:
                            Color(hex: "#ECEEF2")
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    if item.cate == 4 {
                        Image("icon_data_play")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fill) // 强制正方形
        } else {
            Color(hex: "#ECEEF2")
                .aspectRatio(1, contentMode: .fill) // 强制正方形
        }
    }
    
    @ViewBuilder
    private func exampleImageIndexBadge(index: Int) -> some View {
        VStack {
            HStack {
                Text("示例")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#E64E62"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                    .background(Color(hex: "#FCE9EB"))
                    .cornerRadius(10, corners: [.topLeft, .bottomRight])
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func exampleList(samples: [TaskSampleItem]) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(samples.indices), id: \.self) { index in
                exampleListItem(item: samples[index])
            }
        }
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func exampleListItem(item: TaskSampleItem) -> some View {
        if item.cate == 3 {
        VStack(spacing: 1) {
              HStack {
                Text("示例")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#E64E62"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                    .background(Color(hex: "#FCE9EB"))
                    .cornerRadius(10, corners: [.topLeft, .bottomRight])
                Spacer()
            }
            .padding(.leading,-12)
            .padding(.top,-12)
             HStack(alignment:.center,spacing:4){
                Image("icon_wb@3x_3")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                Text(item.file_name ?? "")
                .font(.system(size: 14))
                .foregroundColor(Color.black)
             }
             .padding(.vertical,10)
             .padding(.horizontal,10)
             .frame(maxWidth: .infinity,alignment: .leading)
             .background(Color(hex:"#F7F8FA"))
             .cornerRadius(10)
              
               
          }
          .padding(12)
        .frame(maxWidth: .infinity,alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .padding(.bottom,10)
        }else if item.cate == 1 {
          VStack(spacing: 1) {
              HStack {
                Text("示例")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#E64E62"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                    .background(Color(hex: "#FCE9EB"))
                    .cornerRadius(10, corners: [.topLeft, .bottomRight])
                Spacer()
            }
             AudioSpectrogram(audioURL: item.path_url ?? "" )
              
               
          }
        .frame(maxWidth: .infinity,alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 12)
         
        
        }
    }
    
   
    
    // MARK: - 全屏图片预览视图
    @ViewBuilder
    private func fullScreenImagePreviewView(imageURL: String) -> some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .opacity(showFullScreenImagePreview ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: showFullScreenImagePreview)
                .onTapGesture {
                    // 先缩小图片
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        imagePreviewScale = 0.1
                    }
                    // 然后隐藏视图
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showFullScreenImagePreview = false
                    }
                }
            
            // 图片内容
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height * 0.8)
                                .scaleEffect(imagePreviewScale)
                                .opacity(showFullScreenImagePreview ? 1.0 : 0.0)
                                .onAppear {
                                    // 图片加载完成后，确保缩放从 0.1 开始
                                    imagePreviewScale = 0.1
                                    // 立即触发流畅的放大动画，使用平滑的 spring 动画
                                    DispatchQueue.main.async {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            imagePreviewScale = 1.0
                                        }
                                    }
                                }
                        case .failure:
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("加载失败")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // 先缩小图片
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            imagePreviewScale = 0.1
                        }
                        // 然后隐藏视图
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showFullScreenImagePreview = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .opacity(showFullScreenImagePreview ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3).delay(0.2), value: showFullScreenImagePreview)
                }
                Spacer()
            }
        }
    }
    
    // MARK: - 全屏视频预览视图
    @ViewBuilder
    private func fullScreenVideoPreviewView(videoURL: String) -> some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    // 点击背景关闭视频预览
                    videoPlayer?.pause()
                    videoPlayer = nil
                    // 恢复音频会话
                    do {
                        let audioSession = AVAudioSession.sharedInstance()
                        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                    } catch {
                        print("❌ 音频会话恢复失败: \(error)")
                    }
                    showFullScreenVideoPreview = false
                }
            
            // 视频播放器
            if let url = URL(string: videoURL) {
                VideoPlayer(player: videoPlayer)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onAppear {
                        // 配置音频会话为播放模式，确保视频有声音
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
                            try audioSession.setActive(true)
                        } catch {
                            print("❌ 音频会话配置失败: \(error)")
                        }
                        
                        // 创建播放器并自动播放
                        videoPlayer = AVPlayer(url: url)
                        videoPlayer?.play()
                    }
                    .onDisappear {
                        // 关闭时停止播放
                        videoPlayer?.pause()
                        videoPlayer = nil
                        
                        // 恢复音频会话（如果需要）
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("❌ 音频会话恢复失败: \(error)")
                        }
                    }
            } else {
                // URL 无效时显示错误
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("视频加载失败")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16))
                }
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        videoPlayer?.pause()
                        videoPlayer = nil
                        // 恢复音频会话
                        do {
                            let audioSession = AVAudioSession.sharedInstance()
                            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("❌ 音频会话恢复失败: \(error)")
                        }
                        showFullScreenVideoPreview = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }

      // MARK: - 录音面板覆盖层
    private var recordingPanelOverlay: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 半透明背景遮罩
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showRecordingPanel = false
                        }
                    }
                
                
                // 录音面板内容
                VStack(spacing: 0) {
                    ZStack(alignment:.topLeading){
                         // 左上角序号角标
                        HStack {
                            let audioItems = taskDetail?.topic_list_data?.filter({ ($0.cate ?? 0) == 1 }) ?? []
                            let currentIndex = audioItems.firstIndex(where: { $0.id == currentSelectedGridId }) ?? 0
                            let displayNumber = String(format: "%02d", currentIndex + 1)
                            
                            Text(displayNumber)
                                .font(.system(size: 25, weight: .medium))
                                .foregroundColor(Color(hex: "#E64E62"))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                .background(Color(hex: "#FCE9EB"))
                                .clipShape(
                                    RoundedCorner(radius: 16, corners: [.topLeft, .bottomRight])
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 0)
                        .padding(.top, 0)
                    
                    
                    VStack(spacing: 20) {
                        
                       
                        
                        // 音频数据文本显示
                        VStack( spacing: 8) {
                            let audioItems = taskDetail?.topic_list_data?.filter({ ($0.cate ?? 0) == 1 }) ?? []
                            let currentAudioItem = audioItems.first(where: { $0.id == currentSelectedGridId })
                            
                            Text(currentAudioItem?.text ?? "")
                                .font(.system(size: 35))
                                .foregroundColor(.black)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // 底部录制按钮区域
                        ZStack {
                            VStack(spacing: 0) {
                                // 提示文本区域 - 固定高度
                                VStack {
                                    Text(isRecording ? "录制中" : "点击开始录制")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "#AFAFAF"))
                                }
                                .frame(height: 20)
                                .padding(.bottom, 40)
                                
                                // 波形动画录制按钮区域 - 固定位置
                                Button(action: {
                                    toggleRecording()
                                }) {
                                    WaveformView(isRecording: isRecording, currentWaveIndex: currentWaveIndex)
                                }
                                .scaleEffect(isRecording ? 1.05 : 1.0)
                             
                                
                                // 录制时间区域 - 固定高度
                                VStack {
                                    if isRecording {
                                        Text(formatRecordingTime(recordingDuration))
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "#FF4252"))
                                    }
                                }
                                .frame(height: 20)
                                .padding(.top, 25)
                            }
                        }
                        .padding(.bottom, 70)
                    }
                    .frame(alignment:.center)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 2)
                .background(
                    TopRoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .offset(y: showRecordingPanel ? 0 : geometry.size.height / 2)
                .animation(.easeInOut(duration: 0.3), value: showRecordingPanel)
                .onAppear {
                    // 录音面板显示时立即配置音频录制器
                    setupAudioRecorder()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    var imageAndDescription: some View {
        HStack(alignment: .center, spacing: 12) {
            // 任务封面图
            if let url = coverImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                              .frame(width:90,height: 90)
                            .clipped()
                            .cornerRadius(12)
                    default:
                       Image("占位图")
                        .resizable()
                        .scaledToFill()
                            .frame(width:90,height: 90)
                        .clipped()
                        .cornerRadius(12)
                    }
                }
            } else {
                 Image("占位图")
                        .resizable()
                        .scaledToFill()
                        .frame(width:90,height: 90)
                        .clipped()
                        .cornerRadius(12)
            }

            VStack(alignment:.leading,spacing:0){
                        // 任务标题
                        GeometryReader { proxy in
                            let availableWidth = proxy.size.width
                            Group {
                                if titleTextSize.width > availableWidth {
                                    MarqueeText(
                                        text: taskDetail?.title ?? "",
                                        font: .system(size: 20),
                                        speed: 30,
                                        gap: 30
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(taskDetail?.title ?? "")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .background(
                                Text(taskDetail?.title ?? "")
                                    .font(.system(size: 20))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0)
                                    .readSize { size in
                                        titleTextSize = size
                                    }
                            )
                        }
                        .frame(height: max(20, titleTextSize.height))
                            
                        //任务简介
                        GeometryReader { proxy in
                            let availableWidth = proxy.size.width
                            Group {
                                if descriTextSize.width > availableWidth {
                                    MarqueeText(
                                        text: taskDetail?.simple_descri ?? "",
                                        font: .system(size: 14),
                                        speed: 30,
                                        gap: 30
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(taskDetail?.simple_descri ?? "")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .background(
                                Text(taskDetail?.simple_descri ?? "")
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .opacity(0)
                                    .readSize { size in
                                        descriTextSize = size
                                    }
                            )
                        }
                        .frame(height: max(20, descriTextSize.height))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top,10)
                       HStack(alignment:.center){
                         Text("PoID:\(taskDetail?.task_no ?? "")")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.bottom,10)
                            Spacer()
                            HStack(spacing:0){
                               Image("icon_scene_reward")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 23)
                                HStack(alignment:.center,spacing:1){
                                      Text(taskDetail?.currency_unit ?? "¥")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex:"#FF4059"))
                                   Text(String(format: "%.0f", Double(taskDetail?.price ?? 0)))
                                        .font(.system(size: 19, weight: .bold))
                                        .foregroundColor(Color(hex:"#FF4059"))       
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                        .allowsTightening(true)
                                                                    
                                    Text(taskDetail?.unit ?? "")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex:"#FF4059"))
                                }
                               
                                
                                
                              
                             }
                             .padding(.trailing,10)
                              .frame(minWidth: 60)
                                .background(Color.white)
                                .cornerRadius(8) 
                             
                           
                           
                       }
                       .padding(.top,15)
                }
            
         
        }
        .padding(.vertical,5)
    }

    //场景介绍
    var sceneIntroduction: some View {
        // GeometryReader{ proxy in
        VStack(alignment:.leading,spacing:0){
           HStack(alignment:.center,spacing:2){
             Image("vuesax_bold_menu")
              .resizable()
              .scaledToFit()
              .frame(width: 20,height: 20)
             Text("场景介绍")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                Spacer()
           }
           .padding(.bottom,10)
           HStack{
             Text(taskDetail?.data_detail ?? "")
                 .font(.system(size: 14))
                 .foregroundColor(.white)
                 .lineLimit(nil)
                 .lineSpacing(5)
                 .multilineTextAlignment(.leading)
                 .fixedSize(horizontal: false, vertical: true)
                
            Spacer()
           }      
          
        }
        .padding(.horizontal,20)
        .padding(.vertical,20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        // .padding(.top,20)
       
        // }
    }

    //场景用途
    var scenePurpose: some View {
        VStack(alignment:.leading,spacing:0){
           HStack(alignment:.center,spacing:2){
             Image("vuesax_bold_command")
              .resizable()
              .scaledToFit()
              .frame(width: 20,height: 20)
             Text("场景用途")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
              
                Spacer()
           }
            .padding(.bottom,10)
           HStack{
             Text(taskDetail?.purpose ?? "")
                 .font(.system(size: 14))
                 .foregroundColor(.white)
                 .lineLimit(nil)
                 .lineSpacing(5)
                 .multilineTextAlignment(.leading)
                 .fixedSize(horizontal: false, vertical: true)
                
            Spacer()
           }      
          
        }
        .padding(.horizontal,20)
        .padding(.vertical,20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
       
    }

      // MARK: - 放弃任务确认弹窗UI
    private var abandonTaskDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("确定放弃项目？")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("您有关该项目已经上传的数据都会随之清空且不可恢复。")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showAbandonConfirmDialog  = false
                    }) {
                        Text("取消")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                        if !isLoading {
                            // 放弃项目
                            abandonProject()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("处理中...")
                                    .font(.system(size: 16))
                            } else {
                                Text("确定")
                                    .font(.system(size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .background(isLoading ? Color(hex: "#9B1E2E").opacity(0.7) : Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
          
        }
    }

    //MARK： - 取消关注确认弹窗UI
     private var cancelFollowTaskDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("温馨提示")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("确定取消关注该项目？")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showCancelFollowDialog  = false
                    }) {
                        Text("取消")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                        if !isLoading {
                            followAction = 2
                            // 取消任务
                            followTask()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("处理中...")
                                    .font(.system(size: 16))
                            } else {
                                Text("确定")
                                    .font(.system(size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .background(isLoading ? Color(hex: "#9B1E2E").opacity(0.7) : Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
          
        }
    }

      //MARK：- 放弃项目
    private func abandonProject(){
        isLoading = true
        errorMessage = nil
          let requestBody: [String: Any] = [
                "id": taskDetail?.user_task_id ?? 0,              
            ]
          NetworkManager.shared.post(APIConstants.Scene.abandonTask, 
                                 businessParameters: requestBody) { (result: Result<RecycleTaskResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false
                showAbandonConfirmDialog = false
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("放弃项目成功")
                        MBProgressHUD.showSuccess("操作成功", to: nil)
                        // 发送通知，通知上一页刷新任务列表
                        NotificationCenter.default.post(name: NSNotification.Name("TaskAbandonedSuccess"), object: nil)
                        dismiss()
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }

    }

    //MARK：- 关注/取消任务
    private func followTask(){
        isLoading = true
        errorMessage = nil
          let requestBody: [String: Any] = [
                "id": taskDetail?.task_id ?? 0,     
                "action": followAction         
            ]
          NetworkManager.shared.post(APIConstants.Scene.followTask, 
                                 businessParameters: requestBody) { (result: Result<FollowTaskResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("关注/取消任务成功")
                        if followAction == 1 {
                            isFollowed = true
                        } else {
                            isFollowed = false
                        }
                        showCancelFollowDialog = false
                        MBProgressHUD.showSuccess("操作成功", to: nil)
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }

    }

  
}

// MARK: - 跑马灯（滚动字幕）组件
struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double    // 滚动速度（pt/s）
    let gap: CGFloat     // 末尾空隙

    @State private var textSize: CGSize = .zero
    @State private var xOffset: CGFloat = 0
    @State private var started: Bool = false

    var body: some View {
        GeometryReader { _ in
            HStack(spacing: gap) {
                // 第一段文本用于测量宽度
                Text(text)
                    .font(font)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .readSize { size in
                        textSize = size
                        if !started { // 首次测量到文本宽度后开始动画
                            start()
                        }
                    }

                // 第二段文本用于无缝衔接
                Text(text)
                    .font(font)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: xOffset)
            .clipped()
            .onChange(of: text) { _ in
                // 文本变化后重新启动动画
                started = false
                xOffset = 0
                start()
            }
        }
        .frame(height: max(20, textSize.height))
    }

    private func start() {
        guard textSize.width > 0 else { return }
        // 始终滚动（不论文本是否超出容器）
        started = true
        // 初始即可见，左对齐，从当前位置开始缓慢左移
        xOffset = 0
        let distance = textSize.width + gap
        let duration = distance / speed
        DispatchQueue.main.async {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                xOffset = -distance
            }
        }
    }

}

// MARK: - 读取视图尺寸的辅助工具
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { .zero }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

enum HashAlgorithm {
    case md5
    case sha256
}

//可拖拽底部弹窗
struct DraggableBottomSheet: View {
    var taskDetail: TaskDetailData?
    var onRefresh: () -> Void
    var getAuditStatusText: () -> String
    var getRerecordProgressText: () -> String
      @Environment(\.dismiss) var dismiss
    @Binding var showInstructionSheet: Bool
    @Binding var showExampleSheet: Bool
        
    @Binding var currentSelectedGridId: Int
    @Binding var showRecordingPanel: Bool //当前选中的网格ID，用于录音面板
    @Binding var gridIdToPreviewUrl: [Int: String]
    @Binding var gridIdToFileName: [Int: String]
    @Binding var presignedAudioDatas: [PresignedUrlItem]
    @Binding var showAbandonConfirmDialog: Bool
    @Binding var uploadAudioGridIds: [Int]
    @Binding var audioGridPathPairs: [(gridId: Int, path: String, file_name: String)]
    @Binding var textGridPathPairs: [(gridId: Int, path: String, file_name: String)]
    @Binding var isSheetAtMaxHeight: Bool
    @State private var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.70
    private let minHeight: CGFloat = UIScreen.main.bounds.height * 0.15
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.85
    @State private var showBottomSection: Bool = false
    @GestureState private var dragTranslation: CGFloat = 0
    // 预设吸附高度与反馈状态
    private let snapHeights: [CGFloat] = [
        UIScreen.main.bounds.height * 0.15,
        UIScreen.main.bounds.height * 0.70,
        UIScreen.main.bounds.height * 0.85
    ]
    @State private var snapLevel: Int = 1
    @State private var snapPulse: Bool = false
    @State private var showPermissionDialog: Bool = false
    @State private var showPhotoPicker: Bool = false
    // 来源选择与相机展示状态
    @State private var showSourceDialog: Bool = false
    @State private var showCameraPicker: Bool = false

     @State private var showFullScreenURLVideo: Bool = false
    @State private var selectedVideoURL: String = ""
    @State var processingVideoMetadata: Set<Int> = [] // 正在处理元数据的视频gridId集合
    @State private var videoPlayer: AVPlayer? = nil // 视频播放器实例
   
    
    // 视频专用状态
    @State private var showVideoSourceDialog: Bool = false
    @State private var showVideoPicker: Bool = false
    @State private var showVideoCameraPicker: Bool = false
    
    // 录音权限对话框状态
    @State private var showRecordingPermissionDialog: Bool = false
    // 录音权限设置提示对话框状态
    @State private var showRecordingPermissionSettingsDialog: Bool = false
    // 录音权限状态
    @State private var recordingPermissionStatus: AVAudioSession.RecordPermission = .undetermined
    // 相册已选图片（UIImage）集合，使用网格ID作为键
    @State var pickedImages: [Int: UIImage] = [:]
    //相册已选视频
    @State var pickedVideos: [Int: URL] = [:]          // 视频文件路径
    @State var videoThumbnails: [Int: UIImage] = [:]   // 视频缩略图缓存
    @State var thumbnailGenerationTasks: [Int: Task<Void, Never>] = [:] // 缩略图生成任务
    @State private var pickedAudios: [Int: URL] = [:]          // 音频文件路径
    @State private var pickedTexts: [Int: String] = [:]        // 文本内容

    //文件状态
    @State private var showFilePermissionDialog: Bool = false // 文件权限对话框状态
    @State private var hasUserAgreedToFilePermission: Bool = false // 会话级别：用户是否已同意文件权限
    // 文件选择器状态变量
    @State private var showTextFilePicker: Bool = false
    //选取的文件的路径
    @State private var selectedTextFilePath: String = ""
    
    
    // 分页加载相关状态变量
    @State private var currentImagePage: Int = 0
    @State private var currentVideoPage: Int = 0
    @State private var currentAudioPage: Int = 0
    private let itemsPerPage: Int = 10  // 图片、视频每页显示的项目数量
    private let audioItemsPerPage: Int = 100  // 音频每页显示的项目数量
    
    // 视图回收和内存管理
    @State private var visibleImageIds: Set<String> = []
    @State private var visibleVideoIds: Set<String> = []
    @State private var imageCache: [String: UIImage] = [:]
    @State private var lastMemoryWarningTime: Date = Date()

    @State private var isLoading: Bool = false
    // 内存管理方法
    private func clearImageCache() {
        imageCache.removeAll()
    }
    
    private func handleMemoryWarning() {
        let now = Date()
        if now.timeIntervalSince(lastMemoryWarningTime) > 5.0 { // 5秒内只处理一次内存警告
            clearImageCache()
            lastMemoryWarningTime = now
        }
    }
    
    private func updateVisibleItems() {
        // 清理不可见项目的缓存
        let allVisibleIds = visibleImageIds.union(visibleVideoIds)
        imageCache = imageCache.filter { allVisibleIds.contains($0.key) }
    }
    
    enum CameraMode { case photo, video }
    @State private var cameraMode: CameraMode = .photo
    @State var files: String = ""
    @State var presignedDatas: [PresignedUrlItem] = []
    @State var pendingImageDatas: [Data] = []
    @State var uploadImageGridIds: [Int] = []
    @State var isUploading: Bool = false
     @State  var errorMessage: String?
    
    // 视频上传相关状态变量
    @State var videoFiles: String = ""
    @State var presignedVideoDatas: [PresignedUrlItem] = []
    @State var pendingVideoDatas: [Data] = []
    @State var uploadVideoGridIds: [Int] = []
    @State var isUploadingVideos: Bool = false
    
    // 音频上传相关状态变量

    // 文本上传相关状态变量
    @State private var textFiles: String = ""
    @State var presignedTextDatas: [PresignedUrlItem] = []
    @State private var pendingTextDatas: [Data] = []
    @State var uploadTextGridIds: [Int] = []
    @State private var isUploadingText: Bool = false
    @State private var pickedTextFiles: [Int: URL] = [:]

    @State private var showUploadSuccess: Bool = false
    @State private var showFullScreenImageView: Bool = false
    @State private var selectedImageIndex: Int = 0
    @State private var showFullScreenURLImage: Bool = false
    @State private var selectedImageURL: String = ""
    
    // 视频全屏显示状态
    @State private var showFullScreenVideoView: Bool = false
    @State private var selectedVideoIndex: Int = 0
    
   
    
    // 计算已上传图片数量
    private var uploadedImageCount: Int {
        // 1. 首先获取接口返回的已上传图片数量
        let apiUploadedCount = taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 2 && ($0.status ?? 0) != 0 }.count ?? 0
        
        // 2. 计算当前页面新上传的图片数量：已选择的图片中有预览URL的数量
        let newUploadedCount = pickedImages.keys.filter { gridIdToPreviewUrl[$0] != nil }.count
        
        // 3. 计算总数：接口数据 + 新上传数量
        let totalCount = apiUploadedCount + newUploadedCount
        
        // 4. 确保不超过总的图片项目数量
        let maxCount = cachedImageItems.count
        return min(totalCount, maxCount)
    }
    
    private var uploadedVideoCount: Int {
        // 1. 首先获取接口返回的已上传视频数量
        let apiUploadedCount = taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 4 && ($0.status ?? 0) != 0 }.count ?? 0
        
        // 2. 计算当前页面新上传的视频数量：已选择的视频中有预览URL的数量
        let newUploadedCount = pickedVideos.keys.filter { gridIdToPreviewUrl[$0] != nil }.count
        
        // 3. 计算总数：接口数据 + 新上传数量
        let totalCount = apiUploadedCount + newUploadedCount
        
        // 4. 确保不超过总的视频项目数量
        let maxCount = cachedVideoItems.count
        return min(totalCount, maxCount)
    }
    
    private var uploadedAudioCount: Int {
        // 1. 首先获取接口返回的已上传音频数量
        let apiUploadedCount = taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 1 && ($0.status ?? 0) != 0 }.count ?? 0
        
        // 2. 计算当前页面新上传的音频数量：已选择的音频中有预览URL的数量
        let newUploadedCount = pickedAudios.keys.filter { gridIdToPreviewUrl[$0] != nil }.count
        
        // 3. 计算总数：接口数据 + 新上传数量
        let totalCount = apiUploadedCount + newUploadedCount
        
        // 4. 确保不超过总的音频项目数量
        let maxCount = cachedAudioItems.count
        return min(totalCount, maxCount)
    }

    private var uploadedTextCount: Int {
        // 1. 首先获取接口返回的已上传文本文件数量
        let apiUploadedCount = taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 3 && ($0.status ?? 0) != 0 }.count ?? 0
        
        // 2. 计算当前页面新上传的文本文件数量：有文件名映射的数量
        let newUploadedCount = gridIdToFileName.count
        
        // 3. 计算总数：接口数据 + 新上传数量
        let totalCount = apiUploadedCount + newUploadedCount
        
        // 4. 确保不超过总的文本项目数量
        let maxCount = cachedTextItems.count
        return min(totalCount, maxCount)
    }
    
    // 缓存的数据过滤计算属性 - 优化ForEach性能
    private var cachedAudioItems: [TaskTopicItem] {
        return taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 1 } ?? []
    }
    
    private var cachedImageItems: [TaskTopicItem] {
        return taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 2 } ?? []
    }
    
    private var cachedVideoItems: [TaskTopicItem] {
        return taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 4 } ?? []
    }
    
    private var cachedTextItems: [TaskTopicItem] {
       return taskDetail?.topic_list_data?.filter { ($0.cate ?? 0) == 3 } ?? []
    }
    
    // 计算完成情况 - 包含接口已有的和本地已上传的文件数量（排除被驳回的文件）
    private func calculateCompletedCount() -> Int {
        // 1. 接口返回的已完成项目数量（status != 0 且 status != 3 的项目，排除被驳回的文件）
        let apiCompletedCount = taskDetail?.topic_list_data?.filter { 
            let status = $0.status ?? 0
            return status != 0 && status != 3  // 排除未上传(0)和被驳回(3)的文件
        }.count ?? 0
        
        // 2. 本地已上传但接口还未返回状态的文件数量
        // 使用Set来避免重复计数同一个gridId（文本数据会同时存在于两个字典中）
        let localUploadedGridIds = Set(gridIdToPreviewUrl.keys).union(Set(gridIdToFileName.keys))
        let localUploadedCount = localUploadedGridIds.count
        
        // 3. 返回总数：接口已完成 + 本地已上传
        let totalCount =  apiCompletedCount + localUploadedCount
         let maxCount = cachedTextItems.count + cachedImageItems.count + cachedVideoItems.count + cachedAudioItems.count
        return min(totalCount, maxCount)
    }
    
    // 新增辅助函数用于获取重录进度数据
    private func getRerecordProgress() -> (rerecorded: Int, total: Int) {
        let auditStatus = getAuditStatusText()
        guard auditStatus == "未通过" else { return (0, 0) }
        
        guard let topicList = taskDetail?.topic_list_data else { return (0, 0) }
        
        // 计算总的被驳回音频数量（status == 3）
        let totalRejectedCount = topicList.filter { ($0.status ?? 0) == 3 }.count
        
        // 计算已重录的音频数量（被驳回但有新录制的音频）
        let rerecordedCount = topicList.filter { topic in
            let isRejected = (topic.status ?? 0) == 3
            let hasNewRecording = gridIdToPreviewUrl[topic.id ?? 0] != nil
            return isRejected && hasNewRecording
        }.count
        
        return (rerecordedCount, totalRejectedCount)
    }
    
    // 分页数据计算属性 - 实现按需加载
    private var paginatedImageItems: [TaskTopicItem] {
        let endIndex = min((currentImagePage + 1) * itemsPerPage, cachedImageItems.count)
        return Array(cachedImageItems[0..<endIndex])
    }
    
    private var paginatedVideoItems: [TaskTopicItem] {
        let endIndex = min((currentVideoPage + 1) * itemsPerPage, cachedVideoItems.count)
        return Array(cachedVideoItems[0..<endIndex])
    }
    
    private var paginatedAudioItems: [TaskTopicItem] {
        let endIndex = min((currentAudioPage + 1) * audioItemsPerPage, cachedAudioItems.count)
        return Array(cachedAudioItems[0..<endIndex])
    }
    
    // 是否还有更多数据可以加载
    private var hasMoreImages: Bool {
        return paginatedImageItems.count < cachedImageItems.count
    }
    
    private var hasMoreVideos: Bool {
        return paginatedVideoItems.count < cachedVideoItems.count
    }
    
    private var hasMoreAudios: Bool {
        return paginatedAudioItems.count < cachedAudioItems.count
    }
    
    // 所有任务数据是否都已上传完成（status != 0）
    private var canSubmit: Bool {
        guard let taskDetail = taskDetail else { return false }
        let totalCount = taskDetail.topic_num ?? 0
        let completedCount = calculateCompletedCount()
        
        // 条件1：completedCount和totalCount相等
        let condition1 = completedCount == totalCount
        
        // 条件2：当审核状态为"未通过"时，rerecordedCount和totalRejectedCount相等
        let rerecordProgress = getRerecordProgress()
        let condition2 = rerecordProgress.rerecorded == rerecordProgress.total && rerecordProgress.total > 0
        
        // 满足任一条件即可提交
        return condition1 || condition2
    }
    
    private var taskStatus: Int {
        taskDetail?.task_status?.intValue ?? 0
    }

    private var taskStatusImageName: String {
        switch taskStatus {
        case 2: return "icon_under_review"
        case 3: return "icon_failed"
        case 4: return "icon_completed"
        default: return ""
        }
    }

    private var taskStatusColor: Color {
        switch taskStatus {
        case 2: return Color(hex: "#FEB600")
        case 3: return Color(hex: "#FF5D5D")
        case 4: return Color(hex: "#34C759")
        default: return Color.black
        }
    }

    private var auditStatusTextFull: String {
        getAuditStatusText() + getRerecordProgressText()
    }
    
    var body: some View {
        ZStack(alignment:.bottom){
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
              
            HStack(alignment: .center){
                Text("项目内容")
                 .font(.system(size: 20))
                 .foregroundColor(.black)
                 Spacer()
                HStack{
                    if taskDetail?.task_status?.intValue == 1 {
                        let completedCount = calculateCompletedCount()
                        let totalCount = (taskDetail?.topic_list_data?.count) ?? 0
                        Text("完成情况：\(completedCount)/\(totalCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    } else {
                        Image(taskStatusImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        Text(auditStatusTextFull)
                            .font(.system(size: 14))
                            .foregroundColor(taskStatusColor)
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding(.top,10)

            ScrollView(.vertical,showsIndicators: false){

                
                LazyVStack(alignment: .leading, spacing: 12){
                    // 计算首个有内容的分区：在其标题右侧放置唯一“说明”和唯一“示例”按钮
                    let showInstructionOnAudio = !cachedAudioItems.isEmpty
                    let showInstructionOnText = cachedAudioItems.isEmpty && !cachedTextItems.isEmpty
                    let showInstructionOnImage = cachedAudioItems.isEmpty && cachedTextItems.isEmpty && !cachedImageItems.isEmpty
                    let showInstructionOnVideo = cachedAudioItems.isEmpty && cachedTextItems.isEmpty && cachedImageItems.isEmpty && !cachedVideoItems.isEmpty

                    let canShowExample = (taskDetail?.sample_list?.count ?? 0) > 0
                    let showExampleOnAudio = canShowExample && !cachedAudioItems.isEmpty
                    let showExampleOnText = canShowExample && cachedAudioItems.isEmpty && !cachedTextItems.isEmpty
                    let showExampleOnImage = canShowExample && cachedAudioItems.isEmpty && cachedTextItems.isEmpty && !cachedImageItems.isEmpty
                    let showExampleOnVideo = canShowExample && cachedAudioItems.isEmpty && cachedTextItems.isEmpty && cachedImageItems.isEmpty && !cachedVideoItems.isEmpty
                    if !cachedAudioItems.isEmpty {
                    HStack{
                        Text("上传音频 (\(uploadedAudioCount)/\(cachedAudioItems.count))")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex:"#626262"))
                        if showExampleOnAudio {
                             Button(action: {
                                showExampleSheet = true
                            }) {
                               HStack(alignment:.center){
                                 Image("icon_project_example 1")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 16, height: 16)
                                Text("示例")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                               }
                               .padding(.vertical, 4)
                               .padding(.horizontal, 10)
                               .background(Color(hex:"#ffffff"))
                               .cornerRadius(8)
                            }
                        }
                       
                        if showInstructionOnAudio {
                            Button(action: {
                                showInstructionSheet = true
                            }) {
                               HStack(alignment:.center){
                                 Image("icon_project_introduce 1")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 14, height: 14)
                                Text("说明")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                               }
                               .padding(.vertical, 4)
                               .padding(.horizontal, 10)
                               .background(Color(hex:"#ffffff"))
                               .cornerRadius(8)
                            }
                        }
                         Spacer()
                    }
                    .padding(.top,20)
                    }
                    // 音频：分页加载
                    ForEach(Array(paginatedAudioItems.enumerated()), id: \.element.id) { index, step in
                        audioUploadComponent(item: step, index: index + 1, gridIdToPreviewUrl: $gridIdToPreviewUrl, presignedAudioDatas: $presignedAudioDatas)
                    }
                    
                    // 加载更多音频按钮
                    if hasMoreAudios {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentAudioPage += 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("加载更多音频")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                        }
                    }
                    

                       if !cachedTextItems.isEmpty {
                        HStack{
                            Text("上传文件 (\(uploadedTextCount)/\(cachedTextItems.count))")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#626262"))
                              if showExampleOnText {
                             Button(action: {
                                showExampleSheet = true
                            }) {
                               HStack(alignment:.center){
                                 Image("icon_project_example 1")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 14, height: 14)
                                Text("示例")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                               }
                               .padding(.vertical, 4)
                               .padding(.horizontal, 10)
                               .background(Color(hex:"#ffffff"))
                               .cornerRadius(8)
                            }
                        }
                           
                            if showInstructionOnText {
                                Button(action: {
                                    showInstructionSheet = true
                                }) {
                                   HStack(alignment:.center){
                                     Image("icon_project_introduce 1")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 14, height: 14)
                                    Text("说明")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                   }
                                   .padding(.vertical, 4)
                                   .padding(.horizontal, 10)
                                   .background(Color(hex:"#ffffff"))
                                   .cornerRadius(8)
                                }
                            }
                             Spacer()
                        }
                        .padding(.top,20)
                    }
                    // 文本和其他类型：每条占一行
                    ForEach(Array(cachedTextItems.enumerated()), id: \.element.id) { index, step in
                        textUploadComponent(item: step, index: index + 1)
                    }

                   
                  

                    // 图片：三列网格，左对齐
                    if !cachedImageItems.isEmpty {
                        VStack(alignment:.leading,spacing:10){
                            HStack{
                                Text("上传图片 (\(uploadedImageCount)/\(cachedImageItems.count))")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#626262"))
                                 if showExampleOnImage {
                                            Button(action: {
                                                showExampleSheet = true
                                            }) {
                                            HStack(alignment:.center){
                                                Image("icon_project_example 1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 14, height: 14)
                                                Text("示例")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.black)
                                            }
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(Color(hex:"#ffffff"))
                                            .cornerRadius(8)
                                            }
                                        }
                                if showInstructionOnImage {
                                    Button(action: {
                                        showInstructionSheet = true
                                    }) {
                                       HStack(alignment:.center){
                                         Image("icon_project_introduce 1")
                                         .resizable()
                                         .scaledToFit()
                                         .frame(width: 14, height: 14)
                                        Text("说明")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                       }
                                       .padding(.vertical, 4)
                                       .padding(.horizontal, 10)
                                       .background(Color(hex:"#ffffff"))
                                       .cornerRadius(8)
                                    }
                                }
                                 Spacer()
                            }
                            imageGridComponent(items: paginatedImageItems)
                            
                            // 加载更多图片按钮
                            if hasMoreImages {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentImagePage += 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle")
                                        Text("加载更多图片")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.top,20)
                        
                    }

                    // 视频：三列网格，左对齐
                    if !cachedVideoItems.isEmpty {
                        VStack(alignment:.leading,spacing:10){
                            HStack{
                                Text("上传视频 (\(uploadedVideoCount)/\(cachedVideoItems.count))")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#626262"))

                                  if showExampleOnVideo {
                                    Button(action: {
                                        showExampleSheet = true
                                    }) {
                                    HStack(alignment:.center){
                                        Image("icon_project_example 1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        Text("示例")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Color(hex:"#ffffff"))
                                    .cornerRadius(8)
                                    }
                                }
                               
                                if showInstructionOnVideo {
                                    Button(action: {
                                        showInstructionSheet = true
                                    }) {
                                       HStack(alignment:.center){
                                         Image("icon_project_introduce 1")
                                         .resizable()
                                         .scaledToFit()
                                         .frame(width: 14, height: 14)
                                        Text("说明")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                       }
                                       .padding(.vertical, 4)
                                       .padding(.horizontal, 10)
                                       .background(Color(hex:"#ffffff"))
                                       .cornerRadius(8)
                                    }
                                }
                                 Spacer()
                            }
                            videoGridComponent(items: paginatedVideoItems)
                            
                            // 加载更多视频按钮
                            if hasMoreVideos {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentVideoPage += 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle")
                                        Text("加载更多视频")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.top,20)
                        
                    }
                    
                    // 添加底部间距，确保最后一行网格完整显示
                    Color.clear
                        .frame(height: 80)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                handleMemoryWarning()
            }
            .onAppear {
                // 初始化可见项目跟踪
                updateVisibleItems()
            }

            Spacer()

           
            
        }
        .padding(.horizontal,20)
        // 将底部操作栏铺满屏幕宽度，移除外层水平内边距
        .frame(maxWidth: .infinity, maxHeight: sheetHeight, alignment: .top)
        .background(Color(hex:"#F7F8FA"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -6)
        .animation(.interactiveSpring(response: 0.21, dampingFraction: 0.6, blendDuration: 0.2), value: sheetHeight)
          .gesture(
                    DragGesture()
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onChanged { value in
                            let proposed = sheetHeight - value.translation.height
                            sheetHeight = max(minHeight, min(maxHeight, proposed))

                            // 根据高度阈值控制底部区域显示
                            showBottomSection = sheetHeight > 220
                            isSheetAtMaxHeight = (sheetHeight == maxHeight)

                            // 实时估算最近档位用于视觉提示
                            if let idx = snapHeights.enumerated().min(by: { abs($0.element - sheetHeight) < abs($1.element - sheetHeight) })?.offset {
                                snapLevel = idx
                            }
                        }
                        .onEnded { _ in
                            // 结束拖拽，吸附到最近预设高度
                            let nearest = snapHeights.enumerated().min(by: { abs($0.element - sheetHeight) < abs($1.element - sheetHeight) })
                            let targetIdx = nearest?.offset ?? 0
                            let target = nearest?.element ?? snapHeights[0]
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0.2)) {
                                sheetHeight = target
                                snapLevel = targetIdx
                                showBottomSection = sheetHeight > 220
                                isSheetAtMaxHeight = (sheetHeight == maxHeight)
                            }
                            // 轻微脉冲反馈增强吸附感知
                            snapPulse = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    snapPulse = false
                                }
                            }
                        }
                )

            // 固定在弹窗底部的操作栏（不受上方内容横向内边距影响）
            if showBottomSection && (taskDetail?.task_status?.intValue == 1 || taskDetail?.task_status?.intValue == 3) {
                HStack {
                    VStack(alignment: .center) {
                        Image("icon_project_abandon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("放弃项目")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .onTapGesture {
                        showAbandonConfirmDialog = true
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Image("icon_connect")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("联系客服")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    .onTapGesture {
                        // 1) 基础校验：是否安装微信
                        guard WXApi.isWXAppInstalled() else {
                            MBProgressHUD.showMessag("未检测到微信，请安装后再试", to: nil, afterDelay: 2.0)
                            return
                        }
                        // 2) 设置回调委托，确保能接收到 onResp
                        MOAppDelegate().wxApiDelegate = MOSharingManager.shared

                        // 3) 发送客服会话请求
                        let req = WXOpenCustomerServiceReq()
                        req.corpid = "ww8d6e2a50d131586d"  // 企业ID
                        req.url = "https://work.weixin.qq.com/kfid/kfc10b1911242d1e3df" // 客服URL
                        WXApi.send(req) { success in
                            if success {
                                return
                            }
                            // 兜底：尝试直接打开客服 H5 链接（Safari 或跳转到微信）
                             if let urlStr = req.url, let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                                 UIApplication.shared.open(url, options: [:]) { opened in
                                     if !opened {
                                         // 再兜底：提示升级或稍后重试
                                         if !WXApi.isWXAppSupport() {
                                             MBProgressHUD.showMessag("当前微信版本不支持客服，请升级微信", to: nil, afterDelay: 2.0)
                                         } else {
                                             MBProgressHUD.showMessag("拉起微信失败，请稍后重试", to: nil, afterDelay: 2.0)
                                         }
                                     }
                                 }
                            } else {
                                if !WXApi.isWXAppSupport() {
                                    MBProgressHUD.showMessag("当前微信版本不支持客服，请升级微信", to: nil, afterDelay: 2.0)
                                } else {
                                    MBProgressHUD.showMessag("拉起微信失败，请稍后重试", to: nil, afterDelay: 2.0)
                                }
                            }
                        }
                    }

                    Spacer()

                    HStack {
                        if isLoading {
                            // Loading动画
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("提交中...")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        } else {
                            Text("提交")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(8)
                    .frame(width: 200, height: 50)
                    .background(
                        Group {
                            if canSubmit && !isLoading {
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "#FF6B6B"), location: 0.0),
                                        .init(color: Color(hex: "#E62941"), location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            } else {
                                Color(hex: "#D9D9D9")
                            }
                        }
                    )
                    .cornerRadius(8)
                    .disabled(isLoading || !canSubmit)
                    .onTapGesture {
                        if canSubmit && !isLoading {
                            submitTask()
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.horizontal,20)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 60, alignment: .center)
                .background(Color.white)
            }
            
            // 权限弹窗覆盖层（居中显示）
            if showPermissionDialog {
                permissionDialogOverlay
                    .zIndex(100)
            }

            if showFilePermissionDialog && !hasUserAgreedToFilePermission {
                filePermissionDialogOverlay
                    .zIndex(1300)
            }

           // 全屏图片查看覆盖层
            if showFullScreenImageView {
                fullScreenImageOverlay
                    .zIndex(200)
            }
       
            
            // URL图片全屏查看覆盖层
            if showFullScreenURLImage {
                fullScreenURLImageOverlay
                    .zIndex(300)
            }
            
         
            
            // URL视频全屏查看覆盖层
            if showFullScreenURLVideo {
                fullScreenURLVideoOverlay
                    .zIndex(500)
            }
            

            
            // 录音权限对话框覆盖层 - 只在权限未确定或被拒绝时显示
            if showRecordingPermissionDialog && recordingPermissionStatus != .granted {
                recordingPermissionDialogOverlay
                    .zIndex(1100)
            }
            
            // 录音权限设置提示对话框覆盖层 - 只在权限被拒绝时显示
            if showRecordingPermissionSettingsDialog && recordingPermissionStatus == .denied {
                recordingPermissionSettingsDialogOverlay
                    .zIndex(1200)
            }

            


            

           
        
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectionLimit: max(1, cachedImageItems.count - uploadedImageCount)) { results in
                handlePhotoPickerResults(results)
            }
        }
        .sheet(isPresented: $showTextFilePicker) {
            DocumentPicker { urls in
                guard !urls.isEmpty else { return }
                selectedTextFilePath = urls.first?.path ?? ""

                var newPending: [Data] = []
                var aggregatedItems: [[String: Any]] = []

                for fileURL in urls {
                    // 获取文件信息（名称、大小、哈希）
                    guard let info = getFileInfo(from: fileURL) else { continue }
                    do {
                        let fileData = try Data(contentsOf: fileURL)
                        newPending.append(fileData)

                        // 将该文件的元数据追加到聚合数组
                        let textFileData = createTextFileData(
                            textName: info.name,
                            fileSize: info.size,
                            fileHash: info.hash
                        )
                        aggregatedItems.append(contentsOf: textFileData)
                    } catch {
                        print("❌ 读取文件内容失败: \(error.localizedDescription)")
                    }
                }

                // 仅当成功读取到至少一个文件时，更新待上传数据与 files 并发起预签名请求
                if !newPending.isEmpty {
                    pendingTextDatas = newPending
                    print("✅ 已选择文本文件数量: \(newPending.count)，当前选中的GridId: \(currentSelectedGridId)")

                    if let jsonData = try? JSONSerialization.data(withJSONObject: aggregatedItems, options: []) {
                        files = jsonData.base64EncodedString()
                        print("✅ 准备获取文件预签名URL（文本批量），files=")
                        getPresignedUrls(cate: 3)
                    } else {
                        print("❌ 构建 files JSON 失败")
                    }
                }
            }
        }
        // 来源选择：拍照 / 拍视频 / 相册
        .confirmationDialog("选择来源", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("拍照") {
                cameraMode = .photo
                showCameraPicker = true
            }
            // Button("拍视频") {
            //     cameraMode = .video
            //     showCameraPicker = true
            // }
            Button("相册") {
                showPhotoPicker = true
            }
            Button("取消", role: .cancel) {}
        }
        // 视频来源选择：拍摄 / 相册
        .confirmationDialog("选择视频来源", isPresented: $showVideoSourceDialog, titleVisibility: .visible) {
            Button("拍摄") {
                showVideoCameraPicker = true
            }
            Button("相册") {
                showVideoPicker = true
            }
            Button("取消", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPicker(mode: cameraMode == .photo ? .photo : .video) { image, url in
                if let image = image {
                    pickedImages[currentSelectedGridId] = image
                    startUploadFlow()
                }
                // 如需支持视频上传，可在此处理 url
                showCameraPicker = false
            }
        }
        // 视频专用相册选择器
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(selectionLimit: max(1, cachedVideoItems.count - uploadedVideoCount)) { results in
                handleVideoPickerResults(results)
            }
        }
        // 视频专用相机选择器
        .fullScreenCover(isPresented: $showVideoCameraPicker) {
            CameraPicker(mode: .video) { image, url in
                if let tempURL = url {
                  
                    
                    // 将临时文件复制到文档目录
                    copyVideoToDocuments(from: tempURL) { permanentURL in
                        DispatchQueue.main.async {
                            if let permanentURL = permanentURL {
                                pickedVideos[currentSelectedGridId] = permanentURL
                                print("相机拍摄视频成功，保存到 pickedVideos[\(currentSelectedGridId)] = \(permanentURL)")
                                print("当前 pickedVideos: \(pickedVideos)")
                                
                                // 生成视频缩略图
                                generateVideoThumbnail(for: currentSelectedGridId, videoURL: permanentURL)
                            } else {
                                print("相机拍摄视频文件复制失败")
                            }
                            startUploadFlow()
                        }
                    }
                } else {
                    print("相机拍摄视频失败")
                }
                showVideoCameraPicker = false
            }
        }
    }

 private func createTextFileData(textName: String, fileSize: Int64, fileHash: String) -> [[String: Any]] {
       
        let textItem: [String: Any] = [
            "file_name": textName,
            "file_size": fileSize,
            "file_hash": fileHash
        ]
        
        return [textItem]
    }
func getFileInfo(from url: URL, hashType: HashAlgorithm = .sha256) -> (name: String, size: Int64, hash: String)? {
    do {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .nameKey])
        let fileName = resourceValues.name ?? url.lastPathComponent
        let fileSize = resourceValues.fileSize ?? 0
        
        // 读取文件数据
        let fileData = try Data(contentsOf: url)
        
        // 计算哈希值
        let hashString: String
        switch hashType {
        case .md5:
            let digest = Insecure.MD5.hash(data: fileData)
            hashString = digest.map { String(format: "%02hhx", $0) }.joined()
        case .sha256:
            let digest = SHA256.hash(data: fileData)
            hashString = digest.map { String(format: "%02hhx", $0) }.joined()
        }
        
        return (name: fileName, size: Int64(fileSize), hash: hashString)
        
    } catch {
        print("❌ 读取文件信息失败：\(error)")
        return nil
    }
}

    private var filePermissionDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("温馨提示")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("为了选择文件进行上传，我们需要您提供读取存储的权限。")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showFilePermissionDialog = false
                    }) {
                        Text("拒绝")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                         showFilePermissionDialog = false
                         hasUserAgreedToFilePermission = true
                            // 跳转到文件管理器
                            // 注意：这里需要确保currentSelectedGridId已经在显示对话框之前设置
                            openFileManager()
                    }) {
                        Text("同意")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
          
        }
    }

    func openFileManager() {
        // 显示文本文件选择器
        showTextFilePicker = true
    }

   
   

    //  音频上传组件
    func audioUploadComponent(item: TaskTopicItem, index: Int, gridIdToPreviewUrl: Binding<[Int: String]>, presignedAudioDatas: Binding<[PresignedUrlItem]>) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.text ?? "")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .padding(.vertical,22)
                    .padding(.horizontal,25)
                //分割线
                Divider()
                .frame(maxWidth: .infinity)      
              
                // 根据URL或preview_url是否存在来显示不同的内容
                if let previewUrl = gridIdToPreviewUrl.wrappedValue[item.id], !previewUrl.isEmpty {
                    // 如果有新录制的音频预览URL，显示AudioSpectrogram和删除按钮
                    HStack {
                        AudioSpectrogram(audioURL: previewUrl)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            // 删除新录制的音频
                            gridIdToPreviewUrl.wrappedValue.removeValue(forKey: item.id)
                            presignedAudioDatas.wrappedValue.removeAll()
                            deleteTaskMetadata(for: item.id)

                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 18))
                        }
                        .padding(.trailing, 25)
                    }
                } else if  let url = item.url, !url.isEmpty {
                     AudioSpectrogram(audioURL: url)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }  else {
                    // 如果没有URL也没有preview_url，显示录音按钮
                    Button(action: {
                        currentSelectedGridId = item.id
                        if recordingPermissionStatus == .granted {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showRecordingPanel = true
                            }
                        } else {
                            showRecordingPermissionDialog = true
                        }
                    }) {
                          HStack{
                            Spacer()
                                Image("icon_record")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                             Spacer()
                          }
                          .padding(10)
                           .frame(maxWidth: .infinity, alignment: .leading)
                           
                    }
                }
                
                // 检查是否需要显示重录按钮（适用于所有有音频的情况）
                if (item.url != nil && !item.url!.isEmpty) || (gridIdToPreviewUrl.wrappedValue[item.id] != nil && !gridIdToPreviewUrl.wrappedValue[item.id]!.isEmpty) {
                    if item.status == 3 {
                        HStack{
                            HStack{
                                Image("IconParkOutlineFolderFailed.svg")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 20, height: 20)
                                Text(item.remark ?? "")
                                 .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#626262"))
                            }
                            Spacer()
                         HStack{
                            Text("重录")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex:"#E64E62"))
                         }
                         .padding(.vertical,4)
                         .padding(.horizontal,15)
                         .background(Color.white)
                         .cornerRadius(15)
                         .overlay(
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color(hex:"#E64E62"), lineWidth: 1)
                         )
                         .onTapGesture{
                              currentSelectedGridId = item.id
                        if recordingPermissionStatus == .granted {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showRecordingPanel = true
                            }
                        } else {
                            showRecordingPermissionDialog = true
                        }
                         }
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .background(Color(hex:"#FCE9EB"))
                        .frame(maxWidth:.infinity)
                    }
                }
            
            
            }
             .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                            .padding(.vertical, 8)
            
            // 序号角标
            Text(String(format: "%02d", index))
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#E64E62"))
                .frame(height: 20)
                .padding(.horizontal, 6)
                .background(Color(hex: "#FCE9EB"))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 10,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 10,
                        topTrailingRadius: 0
                    )
                )
                .offset(x: 0, y: 8)
        }
    }
    //  图片上传组件（左上角显示序号，右上角显示删除图标）
    func imageUploadComponent(item: TaskTopicItem, index: Int) -> some View {
        let size = UIScreen.main.bounds.width / 3.4
        let gridId = item.id
        let hasImage = pickedImages[gridId] != nil
        
        return ZStack {

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)

            // 内容
            VStack(spacing: 0) {
                // 图片显示优先级：已选择图片 > URL图片 > 占位图
                if hasImage, let image = pickedImages[gridId] {
                   ZStack(alignment:.bottom){ // 1. 优先显示已选择的图片
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                         .cornerRadius(12)
                         .onTapGesture {
                             // 点击图片上半部分：全屏预览
                             showFullScreenImage(gridId: gridId)
                         }
                      

                        // 状态栏 - 位于底部
                        if item.status == 3 {
                            HStack(alignment: .center, spacing: 5){
                                Image("icon_verify_fail_white 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                Spacer()
                                Text(item.remark ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical,5)
                            .padding(.horizontal, 10)
                            .frame(width: size, height: 25)
                            .background(Color.black.opacity(0.4))
                           
                            .onTapGesture{
                                // 审核失败：直接打开相册重新上传
                                currentSelectedGridId = gridId
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if hasPhotoAuthorized() {
                                        showPhotoPicker = true
                                    } else {
                                        showPermissionDialog = true
                                    }
                                }
                            }
                        }
                }
                } else if let urlString = item.url, !urlString.isEmpty, let url = URL(string: urlString) {
                    // 2. 其次显示URL图片
                  ZStack(alignment:.bottom){
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipped()
                                .cornerRadius(12)
                               
                        case .failure(_), .empty:
                            Image("icon_project_img_default")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size * 0.3, height: size * 0.3)
                        @unknown default:
                            Image("icon_project_img_default")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size * 0.3, height: size * 0.3)
                        }
                    }
                    .onTapGesture {
                        // 点击图片上半部分：全屏预览
                        showFullScreenImageFromURL(urlString: urlString)
                    }
                     // 状态栏 - 位于底部
                        if item.status == 3 {
                            HStack(alignment: .center, spacing: 5){
                                Image("icon_verify_fail_white 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                Spacer()
                                Text(item.remark ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical,5)
                            .padding(.horizontal, 10)
                            .frame(width: size, height: 25)
                            .background(Color.black.opacity(0.4))
                            
                            .onTapGesture{
                                // 审核失败：直接打开相册重新上传
                                currentSelectedGridId = gridId
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if hasPhotoAuthorized() {
                                        showPhotoPicker = true
                                    } else {
                                        showPermissionDialog = true
                                    }
                                }
                            }
                        }
                }
                } else {
                    // 3. 最后显示占位图
                    Image("icon_project_img_default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .onTapGesture {
                                 if hasImage {
                                    // 已上传图片：全屏查看
                                    showFullScreenImage(gridId: gridId)
                                } else if let urlString = item.url, !urlString.isEmpty {
                                    // URL图片：全屏查看URL图片
                                    showFullScreenImageFromURL(urlString: urlString)
                                } else {
                                    // 未上传图片：选择来源
                                    currentSelectedGridId = gridId
                                    handleImageTileTap()
                                }
                            }

                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
           

            // 左上角序号标记
            VStack {
                HStack {
                    Text(String(format: "%02d", index))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#E64E62"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 1)
                        .background(Color(hex: "#FCE9EB"))
                        .cornerRadius(10, corners: [.topLeft, .bottomRight])
                    Spacer()
                }
                Spacer()
            }
            
            
            // 右上角删除图标（仅在有图片时显示）
            if hasImage && item.status != 3 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                         deleteTaskMetadata(for: gridId)
                           
                        }) {
                            Image("icon_media_delete")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Spacer()
                }
                
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())

    }

    // 三列图片网格
    func imageGridComponent(items: [TaskTopicItem]) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(items, id: \.id) { item in
                // 根据 item.id 在原始 cachedImageItems 中的位置来确定序号，而不是使用当前数组的 offset
                let originalIndex = cachedImageItems.firstIndex(where: { $0.id == item.id }) ?? 0
                imageUploadComponent(item: item, index: originalIndex + 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    //文本上传组件
    func textUploadComponent(item: TaskTopicItem, index: Int)-> some View {
        ZStack(alignment: .topLeading) {
             VStack(alignment: .leading, spacing: 6) {
                 // 优先级1: 已选择的文件（最高优先级）
                 if let previewUrl = gridIdToPreviewUrl[item.id], !previewUrl.isEmpty {
                     HStack(alignment:.center){
                         Image("icon_wb@3x_3")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 24, height: 24)
                         Text(getTextFileName(for: item.id) ?? "已选择文件")
                             .font(.system(size: 14))
                             .foregroundColor(Color(hex: "#000000"))
                     Spacer()
                     }
                     .padding(12)
                     .frame(maxWidth: .infinity)
                     .background(Color(hex:"#E8F5E8"))
                     .padding(10)
                     .cornerRadius(8)

                     if item.status == 3 {
                        HStack{
                            HStack{
                                Image("IconParkOutlineFolderFailed.svg")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 20, height: 20)
                                Text(item.remark ?? "")
                                 .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#626262"))
                            }
                            Spacer()
                         HStack{
                            Text("重新上传")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex:"#E64E62"))
                         }
                         .padding(.vertical,4)
                         .padding(.horizontal,15)
                         .background(Color.white)
                         .cornerRadius(15)
                         .overlay(
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color(hex:"#E64E62"), lineWidth: 1)
                         )
                         .onTapGesture{
                             if hasUserAgreedToFilePermission {
                                // 用户已同意过权限，直接打开文件管理器
                                currentSelectedGridId = item.id
                             
                                openFileManager()
                            } else {
                                // 用户未同意过权限，先设置gridId再显示权限对话框
                                currentSelectedGridId = item.id
                                showFilePermissionDialog = true
                            }
                         }
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .background(Color(hex:"#FCE9EB"))
                        .frame(maxWidth:.infinity)
                     }
                 }
                 // 优先级2: URL文件（中等优先级）
                 else if let url = item.url, !url.isEmpty {
                            HStack(alignment:.center){
                                Image("icon_wb@3x_3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                Text(item.file_name ?? "")
                        Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#F7F8FA"))
                        .padding(10)
                        .cornerRadius(8)

                         // 只有在状态为3（失败）且没有本地上传文件时才显示重新上传按钮
                         if item.status == 3 && gridIdToPreviewUrl[item.id] == nil {
                        HStack{
                            HStack{
                                Image("IconParkOutlineFolderFailed.svg")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 20, height: 20)
                                Text(item.remark ?? "")
                                 .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#626262"))
                            }
                            Spacer()
                         HStack{
                            Text("重新上传")
                              .font(.system(size: 16))
                              .foregroundColor(Color(hex:"#E64E62"))
                         }
                         .padding(.vertical,4)
                         .padding(.horizontal,15)
                         .background(Color.white)
                         .cornerRadius(15)
                         .overlay(
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color(hex:"#E64E62"), lineWidth: 1)
                         )
                         .onTapGesture{
                            if hasUserAgreedToFilePermission {
                                // 用户已同意过权限，直接打开文件管理器
                                currentSelectedGridId = item.id
                             
                                openFileManager()
                            } else {
                                // 用户未同意过权限，先设置gridId再显示权限对话框
                                currentSelectedGridId = item.id
                                showFilePermissionDialog = true
                            }
                         }
                        }
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .background(Color(hex:"#FCE9EB"))
                        .frame(maxWidth:.infinity)
                     }
                } 
                // 优先级3: 占位图（最低优先级）
                else{
                 HStack{
                    Spacer()
                        HStack(alignment:.center){
                            Image("icon_project_file_local")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                            Text("本地上传")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#000000"))
                        }
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color(hex:"#F7F8FA"))
                .padding(10)
                .cornerRadius(8)
                 .onTapGesture{
                    if hasUserAgreedToFilePermission {
                        // 用户已同意过权限，直接打开文件管理器
                        currentSelectedGridId = item.id                     
                        openFileManager()
                    } else {
                        // 用户未同意过权限，先设置gridId再显示权限对话框
                        currentSelectedGridId = item.id
                        showFilePermissionDialog = true
                    }
                }
                }
               

             }
              .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                            .padding(.vertical, 8)
             // 序号角标
            Text(String(format: "%02d", index))
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#E64E62"))
                .frame(height: 20)
                .padding(.horizontal, 6)
                .background(Color(hex: "#FCE9EB"))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 10,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 10,
                        topTrailingRadius: 0
                    )
                )
                .offset(x: 0, y: 8)
            
            // 删除图标 - 仅在刚上传成功的文件上显示
            if gridIdToPreviewUrl[item.id] != nil {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            deleteRecentlyUploadedTextFile(gridId: item.id)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
        }
    }
    // 视频方块样式（与图片一致大小）
    func videoUploadComponent(item: TaskTopicItem, index: Int)-> some View {
        let size = UIScreen.main.bounds.width / 3.4
         let gridId = item.id
         let hasVideo = pickedVideos[gridId] != nil
        
        // 调试信息
        let hasUrl = item.url != nil && !(item.url?.isEmpty ?? true)
        let hasSnapshot = item.snapshot != nil && !(item.snapshot?.isEmpty ?? true)
        let isProcessing = processingVideoMetadata.contains(gridId)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
            VStack(spacing: 8) {
                // 根据状态显示不同内容
                if isProcessing {
                    // 正在处理元数据，显示loading
                    ZStack {
                        // 背景占位图
                        Image("icon_project_video_default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.3, height: size * 0.3)
                        
                        // Loading动画覆盖层
                        ZStack {
                            Rectangle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: size, height: size)
                                .cornerRadius(12)
                            
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                
                                Text("加载中")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .cornerRadius(12)
                }else if hasVideo, let video = pickedVideos[gridId]{
                    ZStack(alignment: .bottom){
                        // 显示视频缩略图
                        if let thumbnail = videoThumbnails[gridId] {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipped()
                        } else {
                            // 缩略图加载中或失败时的占位符
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: size, height: size)
                                .overlay(
                                    VStack {
                                        Image(systemName: "video")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                        Text("视频")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white)
                                    }
                                )
                                .onAppear {
                                    // 触发缩略图生成
                                    generateVideoThumbnail(for: gridId, videoURL: video)
                                }
                        }
                        // 中心播放图标
                        Button(action: {
                            selectedVideoURL = video.absoluteString
                            showFullScreenURLVideo = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 30, height: 30)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                               .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(x: size/2, y: size/2)
                        
                        // 状态栏 - 位于底部
                        if item.status == 3 {
                            HStack(alignment: .center, spacing: 5){
                                Image("icon_verify_fail_white 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                Spacer()
                                Text(item.remark ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical,5)
                            .padding(.horizontal, 10)
                            .frame(width: size, height: 25)
                            .background(Color.black.opacity(0.4))
                            .onTapGesture{
                                // 被驳回视频：选择来源
                                currentSelectedGridId = gridId
                                handleVideoTileTap()        
                            }
                        }
                    }
                    .cornerRadius(12)
                }else if let urlString = item.url, !urlString.isEmpty, let snapshot = item.snapshot, !snapshot.isEmpty {
                    // 有URL且有snapshot，显示snapshot图片+播放图标
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: snapshot)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipped()
                        } placeholder: {
                            Image("icon_project_video_default")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size * 0.3, height: size * 0.3)
                        }
                        
                        // 中心播放图标
                        Button(action: {
                            showFullScreenVideoFromURL(urlString: urlString)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(x: size/2, y: size/2)

                        if item.status == 3 {
                            HStack(alignment: .center, spacing: 5){
                                Image("icon_verify_fail_white 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                Spacer()
                                Text(item.remark ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical,5)
                            .padding(.horizontal, 10)
                              .frame(width: size,height:25,alignment:.bottom)
                            .background(Color.black.opacity(0.4))
                            .onTapGesture{
                                  // 被驳回视频：选择来源
                                currentSelectedGridId = gridId
                                handleVideoTileTap()        
                            }
                        }
                        
                    }
                    .cornerRadius(12)
                } else {
                    VStack(alignment: .center, spacing: 10) {
                        // 其他情况显示占位图
                        Image("icon_project_video_default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.3, height: size * 0.3)
                        if item.demand != nil {
                            Text(item.demand ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex:"#9B9B9B"))
                                .lineLimit(3)
                                .truncationMode(.tail)
                                .padding(.horizontal,10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
               
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            

            // 左上角序号标记
            VStack {
                HStack {
                    Text(String(format: "%02d", index))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#E64E62"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 1)
                        .background(Color(hex: "#FCE9EB"))
                        .cornerRadius(10, corners: [.topLeft, .bottomRight])
                    Spacer()
                }
                Spacer()
            }
           

            // 右上角删除图标（仅在有图片时显示）
            if hasVideo && item.status != 3 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                         deleteTaskMetadata(for: gridId)
                           
                        }) {
                            Image("icon_media_delete")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Spacer()
                }
               
            }


        }
        .frame(width: size, height: size)
         .contentShape(Rectangle())
         .onTapGesture {
             if let urlString = item.url, !urlString.isEmpty {
                // URL视频：全屏查看URL视频
                showFullScreenVideoFromURL(urlString: urlString)
            } else {
                // 未上传视频：选择来源
                currentSelectedGridId = gridId
                handleVideoTileTap()
            }
        }
    }

    // 三列视频网格
    func videoGridComponent(items: [TaskTopicItem]) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.element.id) { (offset, item) in
                videoUploadComponent(item: item, index: offset + 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    // MARK: - 权限相关
    private func hasCameraAuthorized() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    private func hasPhotoAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
    }
    
    /// 检查当前录音权限状态
    private func checkRecordingPermission() {
        let currentStatus = AVAudioSession.sharedInstance().recordPermission
        recordingPermissionStatus = currentStatus
        
        // 只有在权限被拒绝时才请求权限，如果已授权则不做任何操作
        if currentStatus == .denied {
            requestRecordingPermission()
        } else if currentStatus == .granted {
            print("✅ 录音权限已授权，无需显示对话框")
            // 权限已授权，确保对话框被隐藏
            showRecordingPermissionDialog = false
            showRecordingPermissionSettingsDialog = false
               // 权限授权后立即显示录音面板
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showRecordingPanel = true
                    }
            
        }
    }
    
    /// 请求录音权限
    private func requestRecordingPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.recordingPermissionStatus = granted ? .granted : .denied
                
                if granted {
                    print("✅ 录音权限已授权")
                    // 权限授权成功，隐藏所有录音权限相关对话框
                    self.showRecordingPermissionDialog = false
                    self.showRecordingPermissionSettingsDialog = false
                    
                    // 如果 currentSelectedGridId 为 0，设置为第一个音频项目的 ID
                    if self.currentSelectedGridId == 0 {
                        let audioItems = self.taskDetail?.topic_list_data?.filter({ ($0.cate ?? 0) == 1 }) ?? []
                        if let firstAudioItem = audioItems.first {
                            self.currentSelectedGridId = firstAudioItem.id
                        }
                    }
                   
                } else {
                    print("❌ 录音权限被拒绝")
                    // 权限被拒绝，显示设置提示对话框
                    self.showRecordingPermissionSettingsDialog = true
                }
            }
        }
    }

    private func handleImageTileTap() {
        if hasCameraAuthorized() && hasPhotoAuthorized() {
            // 已授权：展示来源选择（拍照/拍视频/相册）
            showSourceDialog = true
        } else {
            showPermissionDialog = true
        }
    }

      //MARK： - 提交任务
    private func submitTask(){
         isLoading = true
        errorMessage = nil
        
        // 将topic_list_data转换为base64字符串
        var base64String: String = ""
        if let topicList = taskDetail?.topic_list_data {
            // 将topicList转换为JSON数据，从预签名数据中获取path
            if let jsonData = try? JSONSerialization.data(withJSONObject: topicList.map { topic in
                // 从预签名数据中获取path和file_name，并优先使用音频/文本的覆盖映射；若无则回退到已有topic数据
                let gridId = topic.id ?? 0
                let cate = topic.cate ?? 0
                let pathFromPresigned = getPathFromPresignedData(gridId: gridId, cate: cate)
                let fileNameFromPresigned = getFileNameFromPresignedData(gridId: gridId, cate: cate)
                let audioOverridePair = (cate == 1) ? self.audioGridPathPairs.first(where: { $0.gridId == gridId }) : nil
                let textOverridePair = (cate == 3) ? self.textGridPathPairs.last(where: { $0.gridId == gridId }) : nil
                // 图片兜底：若服务端 path/file_name 为空，但有 url，则从 url 解析
                var imagePathFromURL: String? = nil
                var imageFileNameFromURL: String? = nil
                if cate == 2 {
                    let topicPathEmpty = (topic.path ?? "").isEmpty
                    let topicFileNameEmpty = (topic.file_name ?? "").isEmpty
                    if topicPathEmpty && topicFileNameEmpty, let urlStr = topic.url, let url = URL(string: urlStr) {
                        imageFileNameFromURL = url.lastPathComponent
                        let pathComponent = url.path
                        imagePathFromURL = pathComponent.hasPrefix("/") ? String(pathComponent.dropFirst()) : pathComponent
                    }
                }
                let finalPath = audioOverridePair?.path
                    ?? textOverridePair?.path
                    ?? imagePathFromURL
                    ?? pathFromPresigned
                    ?? topic.path
                    ?? ""
                let finalFileName = audioOverridePair?.file_name
                    ?? textOverridePair?.file_name
                    ?? imageFileNameFromURL
                    ?? fileNameFromPresigned
                    ?? topic.file_name
                    ?? ""
                
                print("🧪 提交参数校验 gridId=\(gridId), cate=\(cate), path=\(finalPath), file_name=\(finalFileName)")
                return [
                    "id": topic.id,
                    "relate_id": topic.relate_id,
                    "cate": topic.cate,
                    "path": finalPath,
                    "file_name": finalFileName
                ]
            }, options: []) {
                base64String = jsonData.base64EncodedString()
            }
        }
        
         let requestBody: [String: Any] = [
              "task_id": taskDetail?.task_id ?? 0,
              "user_task_id": taskDetail?.user_task_id ?? 0,
              "task_data": base64String
            ]
        
         NetworkManager.shared.post(APIConstants.Scene.submitTask, 
                                 businessParameters: requestBody) { (result: Result<CompleteTaskResponse, APIError>) in
            DispatchQueue.main.async {
                isLoading = false         
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("提交任务成功")
                        MBProgressHUD.showSuccess("操作成功", to: nil)
                          Task { @MainActor in
                                        let vc = UIHostingController(
                                            rootView: MyProjectController(initialSelectedTab:0)
                                                .toolbar(.hidden, for: .navigationBar)
                                        )
                                       
                                        MOAppDelegate().transition.push(vc, animated: true)
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

    
    // 跳转到系统设置中的应用权限管理页面
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                DispatchQueue.main.async {
                    if success {
                        print("成功跳转到系统设置")
                    } else {
                        print("跳转到系统设置失败")
                    }
                }
            }
        }
    }

    
        // 显示全屏图片查看
    private func showFullScreenImage(gridId: Int) {
        guard let image = pickedImages[gridId] else { return }
        selectedImageIndex = gridId
        showFullScreenImageView = true
    }

  
    
    // 显示URL图片的全屏查看
    private func showFullScreenImageFromURL(urlString: String) {
        selectedImageURL = urlString
        showFullScreenURLImage = true
    }
    
   
    
    // 显示URL视频的全屏查看
    private func showFullScreenVideoFromURL(urlString: String) {
        selectedVideoURL = urlString
        showFullScreenURLVideo = true
    }
    
    // 处理视频网格点击
    private func handleVideoTileTap() {
        showVideoSourceDialog = true
    }

    // 处理 PHPicker 选择结果，提取 UIImage（如需文件 URL 可扩展为 loadFileRepresentation）
    private func handlePhotoPickerResults(_ results: [PHPickerResult]) {
        let maxSelectable = max(0, cachedImageItems.count - uploadedImageCount)
        let effectiveLimit = max(maxSelectable, 1)

        if cachedImageItems.isEmpty {
            MBProgressHUD.showMessag("当前任务没有图片格可用", to: nil, afterDelay: 1.5)
            showPhotoPicker = false
            return
        }

        let assignCount = min(results.count, effectiveLimit)
        MBProgressHUD.showMessag("已选择\(results.count)张，最多可上传\(effectiveLimit)张", to: nil, afterDelay: 1.5)
        if results.count > effectiveLimit {
            MBProgressHUD.showMessag("超出上限，将上传前\(assignCount)张", to: nil, afterDelay: 1.5)
        }

        // 目标 gridId 列表：优先当前选中格，其次真正空闲格，不足则再覆盖（优先覆盖审核失败）
        var targetGridIds: [Int] = []
         // 仅在当前格为空或审核失败时优先占用
         let idToItem: [Int: TaskTopicItem] = Dictionary(uniqueKeysWithValues:
             cachedImageItems.map { item in
                 (item.id, item)
             }
         )
         let allImageIds = cachedImageItems.map({ $0.id })
          if allImageIds.contains(currentSelectedGridId) {
              let isLocalEmpty = gridIdToPreviewUrl[currentSelectedGridId] == nil && pickedImages[currentSelectedGridId] == nil
              let hasServerImage = !(idToItem[currentSelectedGridId]?.url?.isEmpty ?? true)
              let isRejected = (idToItem[currentSelectedGridId]?.status ?? 0) == 3
              if isLocalEmpty && (!hasServerImage || isRejected) {
                  targetGridIds.append(currentSelectedGridId)
              }
          }
        // 只把本地空闲且服务端未占用（或审核失败）作为空位
        let openIds = cachedImageItems
            .map { $0.id }
            .filter { id in
                guard !targetGridIds.contains(id),
                      gridIdToPreviewUrl[id] == nil,
                      pickedImages[id] == nil
                else { return false }
                let item = idToItem[id]
                let hasServerImage = !(item?.url?.isEmpty ?? true)
                let isRejected = (item?.status ?? 0) == 3
                return !hasServerImage || isRejected
            }
        targetGridIds.append(contentsOf: openIds.prefix(max(0, assignCount - targetGridIds.count)))
        if targetGridIds.count < assignCount {
            // 优先覆盖审核失败的格子
            let rejectedIds = cachedImageItems
                .map { $0.id }
                .filter { id in !targetGridIds.contains(id) && ((idToItem[id]?.status ?? 0) == 3) }
            targetGridIds.append(contentsOf: rejectedIds.prefix(assignCount - targetGridIds.count))
        }
        if targetGridIds.count < assignCount {
            // 再覆盖其他格子（可能已有图片）
            let fallbackIds = cachedImageItems
                .map { $0.id }
                .filter { id in !targetGridIds.contains(id) }
            targetGridIds.append(contentsOf: fallbackIds.prefix(assignCount - targetGridIds.count))
        }

        let group = DispatchGroup()
        let providers = Array(results.prefix(assignCount).map { $0.itemProvider })

        for (index, provider) in providers.enumerated() {
            guard index < targetGridIds.count else { break }
            let gridId = targetGridIds[index]
            group.enter()
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }
                    guard error == nil, let image = object as? UIImage else { return }
                    DispatchQueue.main.async {
                        pickedImages[gridId] = image
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier("public.image") {
                provider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                    defer { group.leave() }
                    guard error == nil, let data = data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        pickedImages[gridId] = image
                    }
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            showPhotoPicker = false
            startUploadFlow()
        }
    }
    
    // 处理视频选择结果（支持多选与数量上限）
    private func handleVideoPickerResults(_ results: [PHPickerResult]) {
        let selectedCount = results.count
        let maxSelectable = max(0, cachedVideoItems.count - uploadedVideoCount)
        let effectiveLimit = max(1, maxSelectable)
        let assignCount = min(selectedCount, effectiveLimit)
        
        MBProgressHUD.showMessag("已选择 \(selectedCount) 条", to: nil, afterDelay: 1.5)
        if selectedCount > effectiveLimit {
            MBProgressHUD.showMessag("超出上限，将上传前 \(effectiveLimit) 条", to: nil, afterDelay: 2.0)
        }
        
        // 目标 gridId 列表：优先空闲格；仅在无空闲格时考虑替换
        var targetGridIds: [Int] = []
        let allIds = cachedVideoItems.compactMap { $0.id }
        let isOpen: (Int) -> Bool = { id in
            gridIdToPreviewUrl[id] == nil && pickedVideos[id] == nil
        }
        // 当前选中格仅在空闲时优先
        if let currentId = allIds.first(where: { $0 == currentSelectedGridId }), isOpen(currentId) {
            targetGridIds.append(currentId)
        }
        // 先填充所有空闲格
        let openIds = allIds.filter { id in
            !targetGridIds.contains(id) && isOpen(id)
        }
        targetGridIds.append(contentsOf: openIds.prefix(max(0, assignCount - targetGridIds.count)))
        // 若仍不足，优先选择“未上传但已有本地选择”的格（gridIdToPreviewUrl为nil）
        if targetGridIds.count < assignCount {
            let notUploadedIds = allIds.filter { id in
                !targetGridIds.contains(id) && gridIdToPreviewUrl[id] == nil
            }
            targetGridIds.append(contentsOf: notUploadedIds.prefix(assignCount - targetGridIds.count))
        }
        // 若仍不足且已无空闲格，仅在没有剩余上传名额（maxSelectable==0）时才考虑替换已上传格
        if targetGridIds.count < assignCount && maxSelectable == 0 {
            let uploadedIds = allIds.filter { id in
                !targetGridIds.contains(id) && gridIdToPreviewUrl[id] != nil
            }
            targetGridIds.append(contentsOf: uploadedIds.prefix(assignCount - targetGridIds.count))
        }
        
        let group = DispatchGroup()
        for (index, result) in results.prefix(assignCount).enumerated() {
            guard index < targetGridIds.count else { break }
            let gridId = targetGridIds[index]
            let provider = result.itemProvider
            
            if provider.hasItemConformingToTypeIdentifier("public.movie") {
                group.enter()
                provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    guard error == nil, let tempURL = url else {
                        print("视频文件加载失败: \(error?.localizedDescription ?? "未知错误")")
                        group.leave()
                        return
                    }
                    
                    // 将临时文件复制到文档目录
                    copyVideoToDocuments(from: tempURL) { permanentURL in
                        DispatchQueue.main.async {
                            if let permanentURL = permanentURL {
                                pickedVideos[gridId] = permanentURL
                                print("视频选择成功，保存到 pickedVideos[\(gridId)] = \(permanentURL)")
                                print("当前 pickedVideos: \(pickedVideos)")
                                generateVideoThumbnail(for: gridId, videoURL: permanentURL)
                            } else {
                                print("视频文件复制失败")
                            }
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            showVideoPicker = false
            startUploadFlow()
        }
    }
    
    // 将视频文件复制到文档目录
    nonisolated private func copyVideoToDocuments(from tempURL: URL, completion: @escaping (URL?) -> Void) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "video_\(UUID().uuidString).mp4"
        let permanentURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            // 如果目标文件已存在，先删除
            if FileManager.default.fileExists(atPath: permanentURL.path) {
                try FileManager.default.removeItem(at: permanentURL)
            }
            
            // 复制文件
            try FileManager.default.copyItem(at: tempURL, to: permanentURL)
            print("视频文件复制成功: \(permanentURL)")
            completion(permanentURL)
        } catch {
            print("视频文件复制失败: \(error.localizedDescription)")
            completion(nil)
        }
    }

   
    
    

    // MARK: - 弹窗UI
    private var permissionDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("温馨提示")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("为了选择本地视频或者录制视频进行上传，我们需要您提供摄像头录制和读取相册存储的权限。")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showPermissionDialog = false
                    }) {
                        Text("拒绝")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                         showPermissionDialog = false
                            // 跳转到系统设置页面
                            openAppSettings()
                    }) {
                        Text("同意")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
          
        }
    }
    
    // MARK: - 录音权限对话框
    private var recordingPermissionDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showRecordingPermissionDialog = false
                }

            VStack(spacing: 16) {
                Text("温馨提示")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("为了方便您录制音频，我们需要您提供读取存储以及录音的权限。")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showRecordingPermissionDialog = false
                    }) {
                        Text("拒绝")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                        showRecordingPermissionDialog = false
                        // 调用录音权限请求
                        requestRecordingPermission()
                    }) {
                        Text("同意")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
            .onAppear {
                // 检查当前录音权限状态
                checkRecordingPermission()
            }
        }
    }
    
    // MARK: - 录音权限设置提示对话框
    private var recordingPermissionSettingsDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showRecordingPermissionSettingsDialog = false
                }

            VStack(spacing: 16) {
                Text("录音权限被拒绝")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text("为了使用录音功能，您需要在系统设置中为本应用开启录音权限。请点击\"前往设置\"按钮跳转到系统设置页面。")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                HStack(spacing: 12) {
                    Button(action: {
                        showRecordingPermissionSettingsDialog = false
                    }) {
                        Text("取消")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#EDEEF4"))
                    .foregroundColor(Color(hex: "#9B1E2E"))
                    .cornerRadius(10)

                    Button(action: {
                        showRecordingPermissionSettingsDialog = false
                        openAppSettings()
                    }) {
                        Text("前往设置")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .background(Color(hex: "#9B1E2E"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .frame(maxWidth: 320)
        }
    }
    
  

        // MARK: - 全屏图片查看覆盖层
    private var fullScreenImageOverlay: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    showFullScreenImageView = false
                }
            
            // 图片内容
            if let image = pickedImages[selectedImageIndex] {
                VStack {
                    // 图片显示
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                    
                    Spacer()
                }
                 .onTapGesture{
                    showFullScreenImageView = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }



    
    // MARK: - URL图片全屏查看覆盖层
    private var fullScreenURLImageOverlay: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    showFullScreenURLImage = false
                }
            
            // 图片内容
            if let url = URL(string: selectedImageURL) {
                VStack {               
                    // 图片显示
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure(_):
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text("图片加载失败")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        case .empty:
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                               
                            }
                        @unknown default:
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text("图片加载中...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                   
                }
                .onTapGesture{
                    showFullScreenURLImage = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
            }
        }
    }

    //MARK：- 上传文件-获取预签名url
    private func getPresignedUrls(cate:Int) {
          let requestBody: [String: Any] = [
                "files": files,
               
            ]
             NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl, 
                                 businessParameters: requestBody) { (result: Result<GetPresignedUrlsResponse, APIError>) in
            DispatchQueue.main.async {
               
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        //预签名url返回数据
                        if cate == 2 {
                            presignedDatas = response.data
                            print("✅ 图片预签名url返回数据: \(response.data)")
                            performUploads(presignedItems: response.data)
                        } else {
                            presignedTextDatas = response.data
                            // 按“逐条对应”维护映射：为每个预签名条目设置对应的gridId
                            uploadTextGridIds = Array(repeating: currentSelectedGridId, count: response.data.count)
                            print("✅ 文本预签名url返回数据: \(response.data)")
                            print("✅ 已设置uploadTextGridIds为: \(uploadTextGridIds)")
                            // 保存 (gridId, path, file_name) 到文本映射数组
                            let newPairs = response.data.map { item in
                                (gridId: currentSelectedGridId, path: item.path, file_name: item.file_name)
                            }
                            for pair in newPairs {
                    if let idx = self.textGridPathPairs.firstIndex(where: { $0.gridId == pair.gridId }) {
                        self.textGridPathPairs[idx] = pair
                    } else {
                        self.textGridPathPairs.append(pair)
                    }
                }
                print("✅ 已保存文本 gridId-path-file_name 对应关系: \(self.textGridPathPairs)")
                            performUploadsText(presignedItems: response.data)
                        }
                        
                    } else {
                        errorMessage = response.msg
                        print("❌ 获取预签名URL失败: \(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("❌ 获取预签名URL异常: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MARK：- 上传视频文件-获取预签名url
    private func getPresignedVideoUrls() {
          let requestBody: [String: Any] = [
                "files": videoFiles,
               
            ]
             NetworkManager.shared.post(APIConstants.Scene.getPresignedUrl, 
                                 businessParameters: requestBody) { (result: Result<GetPresignedUrlsResponse, APIError>) in
            DispatchQueue.main.async {
               
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        //预签名url返回数据
                        presignedVideoDatas = response.data
                        print("✅ 视频预签名url返回数据: \(response.data)")
                        performVideoUploads(presignedItems: response.data)
                    } else {
                        errorMessage = response.msg
                        print("❌ 获取视频预签名URL失败: \(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("❌ 获取视频预签名URL异常: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - 上传流程
    private func startUploadFlow() {
        guard !pickedImages.isEmpty || !pickedVideos.isEmpty else { return }

        var items: [[String: Any]] = []
        var imageDatas: [Data] = []
        var videoDatas: [Data] = []
        var imageGridIds: [Int] = []
        var videoGridIds: [Int] = []

        // 处理图片
        for (gridId, image) in pickedImages {
            guard let data = image.jpegData(compressionQuality: 0.9) else { continue }
            imageDatas.append(data)
            imageGridIds.append(gridId)
            let name = "image_\(Int(Date().timeIntervalSince1970))_\(gridId).jpg"
            let size = data.count
            let hash = sha256Hex(of: data)
            items.append([
                "file_name": name,
                "file_size": size,
                "file_hash": hash
            ])
        }

        // 处理视频
        for (gridId, videoURL) in pickedVideos {
            print("开始处理视频 - GridId: \(gridId), URL: \(videoURL)")
            
            // 检查文件是否存在
            guard FileManager.default.fileExists(atPath: videoURL.path) else {
                print("❌ 视频文件不存在: \(videoURL.path)")
                continue
            }
            
            // 检查文件格式
            let fileExtension = videoURL.pathExtension.lowercased()
            let supportedFormats = ["mp4", "mov", "avi", "m4v", "3gp", "mkv"]
            guard !fileExtension.isEmpty && supportedFormats.contains(fileExtension) else {
                print("❌ 不支持的视频格式: \(fileExtension), 支持的格式: \(supportedFormats)")
                continue
            }
            
            do {
                // 获取文件属性
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: videoURL.path)
                let fileSize = fileAttributes[.size] as? Int64 ?? 0
                
                // 检查文件大小（限制为100MB）
                let maxFileSize: Int64 = 100 * 1024 * 1024 // 100MB
                guard fileSize > 0 && fileSize <= maxFileSize else {
                    print("❌ 视频文件大小超出限制: \(fileSize) bytes, 最大允许: \(maxFileSize) bytes")
                    continue
                }
                
                print("✅ 视频文件验证通过 - 大小: \(fileSize) bytes, 格式: \(fileExtension)")
                
                // 读取视频数据
                let data = try Data(contentsOf: videoURL)
                videoDatas.append(data)
                videoGridIds.append(gridId)
                
                let name = "video_\(Int(Date().timeIntervalSince1970))_\(gridId).\(fileExtension)"
                let size = data.count
                let hash = sha256Hex(of: data)
                
                items.append([
                    "file_name": name,
                    "file_size": size,
                    "file_hash": hash
                ])
                
                print("✅ 视频处理成功 - 文件名: \(name), 大小: \(size) bytes")
                
            } catch let error as NSError {
                print("❌ 读取视频数据失败:")
                print("   - 错误代码: \(error.code)")
                print("   - 错误描述: \(error.localizedDescription)")
                print("   - 错误域: \(error.domain)")
                print("   - 文件路径: \(videoURL.path)")
                
                // 检查具体的错误类型
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    case NSFileReadNoSuchFileError:
                        print("   - 具体原因: 文件不存在")
                    case NSFileReadNoPermissionError:
                        print("   - 具体原因: 没有读取权限")
                    case NSFileReadCorruptFileError:
                        print("   - 具体原因: 文件损坏")
                    default:
                        print("   - 具体原因: 其他文件读取错误")
                    }
                }
                continue
            }
        }

        guard !items.isEmpty else { return }
        
        // 分别存储图片和视频数据
        pendingImageDatas = imageDatas
        pendingVideoDatas = videoDatas
        uploadImageGridIds = imageGridIds
        uploadVideoGridIds = videoGridIds

        // 分别处理图片和视频的预签名URL获取
        if !imageDatas.isEmpty {
            let imageItems = Array(items.prefix(imageDatas.count))
            if let jsonData = try? JSONSerialization.data(withJSONObject: imageItems, options: []) {
                files = jsonData.base64EncodedString()
                print("✅ 准备获取图片预签名URL，files=\(files)")
                getPresignedUrls(cate:2)
            }
        }
        
        if !videoDatas.isEmpty {
            let videoItems = Array(items.suffix(videoDatas.count))
            if let jsonData = try? JSONSerialization.data(withJSONObject: videoItems, options: []) {
                videoFiles = jsonData.base64EncodedString()
                print("✅ 准备获取视频预签名URL，videoFiles=\(videoFiles)")
                getPresignedVideoUrls()
            }
        }
    }
    
    private func sha256Hex(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    func performUploadsText(presignedItems: [PresignedUrlItem]){
        // 检查是否有待上传的文本文件数据
        guard !pendingTextDatas.isEmpty else {
            print("❌ 没有待上传的文本文件数据")
            return
        }
        
        // 确保预签名项目数量与待上传数据数量匹配
        guard presignedItems.count == pendingTextDatas.count else {
            print("❌ 预签名URL数量与文本文件数量不匹配")
            return
        }
        
        // 设置上传状态
        isUploadingText = true
        
        // 遍历每个文件进行上传
        for (index, item) in presignedItems.enumerated() {
            guard index < pendingTextDatas.count else { continue }
            
            let textData = pendingTextDatas[index]
            
            // 验证上传URL
            guard let uploadURL = URL(string: item.upload_url) else {
                print("❌ 无效的上传URL: \(item.upload_url)")
                continue
            }
            
            // 创建上传请求
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "PUT"
            
            // 执行上传任务
            let task = URLSession.shared.uploadTask(with: request, from: textData) { responseData, response, error in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let success = (200...299).contains(statusCode)
                
                DispatchQueue.main.async {
                    if success {
                        print("✅ 文本文件上传成功: \(item.file_name)")
                        print("🔗 预览URL: \(item.preview_url)")
                        print("🆔 文件ID: \(item.file_id)")
                        // 获取正确的 GridId - 使用对应索引的 GridId
                        let correctGridId = self.uploadTextGridIds.count > index ? self.uploadTextGridIds[index] : self.currentSelectedGridId
                        print("id:\(correctGridId) (index: \(index))")
                        
                        // 更新文本任务元数据 - 使用正确的 GridId
                        self.updateTextTaskMetadata(for: correctGridId, item: item)
                        
                        // 将gridId与预览URL关联 - 使用正确的 GridId
                        self.gridIdToPreviewUrl[correctGridId] = item.preview_url
                        
                        // 将gridId与文件名关联 - 使用正确的 GridId
                        self.gridIdToFileName[correctGridId] = item.file_name
                        
                    } else {
                        print("❌ 文本文件上传失败: \(item.file_name), 状态码: \(statusCode)")
                        if let error = error {
                            print("❌ 错误详情: \(error)")
                        }
                    }
                    
                    // 检查是否所有文件都已上传完成
                    if index == presignedItems.count - 1 {
                        self.isUploadingText = false
                        print("📝 所有文本文件上传完成")
                    }
                }
            }
            task.resume()
        }
    }
    
    
    
    // 更新文本任务元数据
    private func updateTextTaskMetadata(for gridId: Int, item: PresignedUrlItem) {
        // 关联gridId和preview_url
        gridIdToPreviewUrl[gridId] = item.preview_url
        
        // 查找对应的文本主题
        guard let textTopics = taskDetail?.topic_list_data?.filter({ $0.cate == 3 }),
              let topic = textTopics.first(where: { $0.id == gridId }) else {
            print("未找到对应的文本主题: gridId=\(gridId)")
            return
        }
        
        // 调用更新文本元数据的方法
        updateTextMetadata(for: gridId, topic: topic, item: item)
    }
    
    private func updateTextMetadata(for gridId: Int, topic: TaskTopicItem, item: PresignedUrlItem) {
        print("presignedTextDatas: \(presignedTextDatas)")
        print("更新文本元数据：gridId=\(gridId), topic=\(topic), item=\(item)")
        
        let format = fileExtension(from: item.file_name)
        let textMetadata: [String: Any] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": 3,                                // 文本类型为3
            "path": item.path,
            "duration": 0,                            // 文本文件无持续时间
            "file_name": item.file_name,
            "size": item.file_size,
            "format": format.isEmpty ? "txt" : format,
            "quality": "",
            "audio_rate": "",                         // 文本文件无采样率
            "location": NSNull()
        ]
        
        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: textMetadata) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("更新文本元数据成功：meta_id=\(topic.id)")
                        //刷新详情
                        // onRefresh()
                    } else {
                        errorMessage = response.msg
                        print("更新文本元数据失败：meta_id=\(topic.id)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("更新文本元数据异常：meta_id=\(topic.id)，error=\(error.localizedDescription)")
                }
            }
        }
    }
    
   

    private func performUploads(presignedItems: [PresignedUrlItem]) {
        // 只处理图片数据
        let count = min(presignedItems.count, pendingImageDatas.count)
        guard count > 0 else { return }
        isUploading = true
        
        // 添加上传完成计数器
        var completedCount = 0
        var successCount = 0
        
        for i in 0..<count {
            let item = presignedItems[i]
            let data = pendingImageDatas[i]
            putUpload(data: data, to: item.upload_url) { success, status, error in
                // 更新完成计数器
                completedCount += 1
                
                // 可根据需要更新 UI 或收集上传结果
                if !success {
                    errorMessage = error?.localizedDescription ?? "上传失败，状态码: \(status)"
                    print("图片上传失败，索引: \(i), 错误: \(errorMessage)")
                } else {
                    successCount += 1
                    print("图片上传成功，索引: \(i)")
                }
                
                // 单个文件上传成功后，立刻更新其元数据
                if success && i < uploadImageGridIds.count {
                    self.updateTaskMetadata(for: uploadImageGridIds[i])
                }
                
                // 检查是否所有文件都上传完成
                if completedCount == count {
                    print("所有图片上传完成，成功: \(successCount)/\(count)")
                    isUploading = false
                    
                    // 只有当所有文件都上传完成时才刷新任务详情
                    if successCount == count {
                        showUploadSuccess = true
                        print("所有图片上传成功，刷新任务详情")
                        // onRefresh()
                    } else {
                        print("部分图片上传失败，不刷新任务详情")
                    }
                }
            }
        }
    }
    
    private func performVideoUploads(presignedItems: [PresignedUrlItem]) {
        // 只处理视频数据
        let count = min(presignedItems.count, pendingVideoDatas.count)
        guard count > 0 else { return }
        isUploadingVideos = true
        
        // 添加上传完成计数器
        var completedCount = 0
        var successCount = 0
        
        for i in 0..<count {
            let item = presignedItems[i]
            let data = pendingVideoDatas[i]
            putUpload(data: data, to: item.upload_url) { success, status, error in
                // 更新完成计数器
                completedCount += 1
                
                // 可根据需要更新 UI 或收集上传结果
                if !success {
                    errorMessage = error?.localizedDescription ?? "上传失败，状态码: \(status)"
                    print("视频上传失败，索引: \(i), 错误: \(errorMessage)")
                } else {
                    successCount += 1
                    print("视频上传成功，索引: \(i)")
                }
                
                // 单个文件上传成功后，立刻更新其元数据
                if success && i < uploadVideoGridIds.count {
                    self.updateTaskMetadata(for: uploadVideoGridIds[i])
                }
                
                // 检查是否所有文件都上传完成
                if completedCount == count {
                    print("所有视频上传完成，成功: \(successCount)/\(count)")
                    isUploadingVideos = false
                    
                    // 只有当所有文件都上传完成时才刷新任务详情
                    if successCount == count {
                        showUploadSuccess = true
                        print("所有视频上传成功，刷新任务详情")
                        // onRefresh()
                    } else {
                        print("部分视频上传失败，不刷新任务详情")
                    }
                }
            }
        }
    }

    // 执行一次带指定头的上传，回调切回主线程
    private func executeUpload(data: Data, url: URL, headers: [String: String], tryIndex: Int, completion: @escaping (Bool, Int, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let ok = (200...299).contains(statusCode)
            if !ok {
                let respStr = responseData.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("PUT 上传失败[尝试\(tryIndex)]，状态码: \(statusCode), 响应: \(respStr)")
            }
            DispatchQueue.main.async {
                completion(ok, statusCode, error)
            }
        }
        task.resume()
    }

    @MainActor
    private func putUpload(data: Data, to urlString: String, completion: @escaping (Bool, Int, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false, 0, nil)
            return
        }
        // 策略 1：不带头
        executeUpload(data: data, url: url, headers: [:], tryIndex: 0) { ok, status, error in
            if status == 403 && !ok {
                // 策略 2：octet-stream
                self.executeUpload(data: data, url: url, headers: ["Content-Type": "application/octet-stream"], tryIndex: 1) { ok2, status2, error2 in
                    if status2 == 403 && !ok2 {
                        // 策略 3：image/jpeg（与我们的 jpegData 匹配）
                        self.executeUpload(data: data, url: url, headers: ["Content-Type": "image/jpeg"], tryIndex: 2, completion: completion)
                    } else {
                        completion(ok2, status2, error2)
                    }
                }
            } else {
                completion(ok, status, error)
            }
        }
    }

    // 提取文件扩展名
    private func fileExtension(from fileName: String) -> String {
        if let dotIndex = fileName.lastIndex(of: "."), dotIndex < fileName.endIndex {
            let extIndex = fileName.index(after: dotIndex)
            return String(fileName[extIndex...]).lowercased()
        }
        return ""
    }



   
    
    // MARK: - URL视频全屏查看覆盖层
    private var fullScreenURLVideoOverlay: some View {
        ZStack(alignment:.topLeading) {
          
            
            // 视频内容
            if let url = URL(string: selectedVideoURL) {
                ZStack {
                    // 视频播放器占满全屏
                    VideoPlayer(player: videoPlayer)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all)
                        .onAppear {
                            // 配置音频会话为播放模式，确保视频有声音
                            do {
                                let audioSession = AVAudioSession.sharedInstance()
                                try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
                                try audioSession.setActive(true)
                            } catch {
                                print("❌ 音频会话配置失败: \(error)")
                            }
                            // 创建播放器并自动播放
                            videoPlayer = AVPlayer(url: url)
                            videoPlayer?.play()
                        }
                        .onDisappear {
                            // 关闭时停止播放
                            videoPlayer?.pause()
                            // 恢复音频会话（如果需要）
                            do {
                                let audioSession = AVAudioSession.sharedInstance()
                                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                            } catch {
                                print("❌ 音频会话恢复失败: \(error)")
                            }
                            videoPlayer = nil
                        }
                        .onTapGesture {
                            // 点击视频播放器关闭全屏
                            showFullScreenURLVideo = false
                        }
                    
                    // 顶部关闭按钮
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showFullScreenURLVideo = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    //删除元数据
    private func deleteRecentlyUploadedTextFile(gridId: Int) {
        // 专门用于删除刚上传成功的文本文件
        let allTopics = taskDetail?.topic_list_data ?? []
        guard let topic = allTopics.first(where: { $0.id == gridId && $0.cate == 3 }) else { 
            print("未找到对应的文本主题: gridId=\(gridId)")
            return 
        }
        
        // 确认这是一个刚上传的文件（存在于gridIdToPreviewUrl中）
        guard gridIdToPreviewUrl[gridId] != nil else {
            print("该文件不是刚上传的文件，无法删除: gridId=\(gridId)")
            return
        }
        
        let requestBody: [String: Any?] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": 3,                                 // 文本类型
            "path": "",                                // 置为空字符串来删除文件
            "file_name": "",                           // 文件名也置为空
            "size": 0,                                 // 文件大小置为0
            "format": "",                              // 格式置为空
            "quality": "",                             // 质量置为空
            "duration": 0,
            "audio_rate": "",
            "location": nil
        ]

        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: requestBody) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("删除刚上传的文本文件成功：meta_id=\(topic.id)")
                        // 清理本地缓存
                        self.pickedTexts.removeValue(forKey: gridId)
                        self.gridIdToPreviewUrl.removeValue(forKey: gridId)
                        self.gridIdToFileName.removeValue(forKey: gridId)
                        // 刷新任务详情
                        // onRefresh()
                    } else {
                        self.errorMessage = response.msg
                        print("删除刚上传的文本文件失败：meta_id=\(topic.id)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("删除刚上传的文本文件异常：meta_id=\(topic.id)，error=\(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteTaskMetadata(for gridId: Int) {
        // 支持图片（cate = 2）和视频（cate = 4）的删除
        let allTopics = taskDetail?.topic_list_data ?? []
        guard let topic = allTopics.first(where: { $0.id == gridId }) else { return }
        
        let cate = topic.cate ?? 0
        
        // 根据媒体类型准备不同的参数
        var requestBody: [String: Any?] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": cate,
            "path": "",                                // 置为空字符串来删除文件
            "file_name": "",                           // 文件名也置为空
            "size": 0,                                 // 文件大小置为0
            "format": "",                              // 格式置为空
            "quality": "",                             // 质量置为空
            "location": nil
        ]
        
        // 根据媒体类型设置特定参数
        switch cate {
        case 2: // 图片
            requestBody["duration"] = 0
            requestBody["audio_rate"] = ""
        case 4: // 视频
            requestBody["duration"] = 0
            requestBody["audio_rate"] = ""
        case 1: // 音频
            requestBody["duration"] = 0
            requestBody["audio_rate"] = ""
        case 3: // 文本
            requestBody["duration"] = 0
            requestBody["audio_rate"] = ""
        default:
            requestBody["duration"] = 0
            requestBody["audio_rate"] = ""
        }

        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: requestBody) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("删除元数据成功：meta_id=\(topic.id)，类型=\(cate)")
                        // 根据媒体类型清理对应的本地缓存
                        switch cate {
                        case 2: // 图片
                            self.pickedImages.removeValue(forKey: gridId)
                            self.gridIdToPreviewUrl.removeValue(forKey: gridId)
                            // 清理上传相关的数据
                            if let uploadIndex = self.uploadImageGridIds.firstIndex(of: gridId) {
                                if uploadIndex < self.presignedDatas.count {
                                    self.presignedDatas.remove(at: uploadIndex)
                                }
                                if uploadIndex < self.pendingImageDatas.count {
                                    self.pendingImageDatas.remove(at: uploadIndex)
                                }
                                self.uploadImageGridIds.remove(at: uploadIndex)
                            }
                        case 4: // 视频
                            self.pickedVideos.removeValue(forKey: gridId)
                            self.gridIdToPreviewUrl.removeValue(forKey: gridId)
                        case 1: // 音频
                            self.pickedAudios.removeValue(forKey: gridId)
                            self.gridIdToPreviewUrl.removeValue(forKey: gridId)
                        case 3: // 文本
                            self.pickedTexts.removeValue(forKey: gridId)
                            self.gridIdToFileName.removeValue(forKey: gridId)
                        default:
                            break
                        }
                        // 刷新任务详情
                        // self.onRefresh()
                    } else {
                        self.errorMessage = response.msg
                        print("删除元数据失败：meta_id=\(topic.id)，类型=\(cate)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("删除元数据异常：meta_id=\(topic.id)，类型=\(cate)，error=\(error.localizedDescription)")
                }
            }
        }
    }

    // 更新指定网格ID的元数据：参考安卓参数规则
    private func updateTaskMetadata(for gridId: Int) {
        // 处理图片和视频的元数据更新
        let imageTopics = (taskDetail?.topic_list_data ?? []).filter { ($0.cate ?? 0) == 2 }
        let videoTopics = (taskDetail?.topic_list_data ?? []).filter { ($0.cate ?? 0) == 4 }
        guard let topic = imageTopics.first(where: { $0.id == gridId }) ?? videoTopics.first(where: { $0.id == gridId }) else { return }
        
        let cate = topic.cate ?? 0
        
        // 根据类型处理不同的元数据更新
        if cate == 2 {
            // 图片元数据更新（保持原有逻辑）
            updateImageMetadata(for: gridId, topic: topic)
        } else if cate == 4 {
            // 视频元数据更新
            updateVideoMetadata(for: gridId, topic: topic)
        } 
    }
    
    // 图片元数据更新（保持原有逻辑不变）
    private func updateImageMetadata(for gridId: Int, topic: TaskTopicItem) {
        // 找到对应的上传数据
        guard let uploadIndex = uploadImageGridIds.firstIndex(of: gridId),
              uploadIndex < presignedDatas.count && uploadIndex < pendingImageDatas.count else { return }
        
        let presigned = presignedDatas[uploadIndex]
        let data = pendingImageDatas[uploadIndex]

        // 分辨率（quality）：高*宽（与安卓一致）
        var quality: String? = nil
        if let img = pickedImages[topic.id] {
            let w = Int(img.size.width)
            let h = Int(img.size.height)
            if w > 0 && h > 0 { quality = "\(h)*\(w)" }
        } else if let img = UIImage(data: data) {
            let w = Int(img.size.width)
            let h = Int(img.size.height)
            if w > 0 && h > 0 { quality = "\(h)*\(w)" }
        }

        let format = fileExtension(from: presigned.file_name)

        // 按接口文档字段准备参数（与安卓风格对齐）
        let requestBody: [String: Any?] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": 2,                                 // 图片类别，使用整型
            "path": presigned.path,
            "duration": 0,                              // 图片时长为0
            "file_name": presigned.file_name,
            "size": data.count,
            "format": format.isEmpty ? "jpg" : format,
            "quality": quality,
            "audio_rate": "",                         // 图片无采样率
            "location": nil
        ]

        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: requestBody) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("更新图片元数据成功：meta_id=\(topic.id)")
                        // 元数据更新成功后，设置预览URL以便计数逻辑正确工作
                        if let image = pickedImages[topic.id] {
                            gridIdToPreviewUrl[topic.id] = "local_image_\(topic.id)"
                        }
                    } else {
                        errorMessage = response.msg
                        print("更新图片元数据失败：meta_id=\(topic.id)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("更新图片元数据异常：meta_id=\(topic.id)，error=\(error.localizedDescription)")
                }
            }
        }
    }
    
    // 视频元数据更新
    private func updateVideoMetadata(for gridId: Int, topic: TaskTopicItem) {
        print("更新视频元数据：gridId=\(gridId)，topic=\(topic)")
        
        // 添加到loading状态
        processingVideoMetadata.insert(gridId)
        print("✅ 添加loading状态：gridId=\(gridId)，当前loading状态：\(processingVideoMetadata)")
        
        // 找到对应的上传数据
        guard let uploadIndex = uploadVideoGridIds.firstIndex(of: gridId),
              uploadIndex < presignedVideoDatas.count && uploadIndex < pendingVideoDatas.count else { 
            print("❌ 找不到视频上传数据：gridId=\(gridId)，uploadVideoGridIds=\(uploadVideoGridIds)，presignedVideoDatas.count=\(presignedVideoDatas.count)，pendingVideoDatas.count=\(pendingVideoDatas.count)")
            // 移除loading状态
            processingVideoMetadata.remove(gridId)
            return 
        }
        
        let presigned = presignedVideoDatas[uploadIndex]
        let data = pendingVideoDatas[uploadIndex]
        
        print("✅ 找到视频上传数据：presigned=\(presigned)，data.size=\(data.count)")
        
        // 获取视频信息
        var duration: Double = 0
        var quality: String? = nil
        var audioRate: String? = nil
        
        if let videoURL = pickedVideos[topic.id] {
            print("✅ 找到视频文件：\(videoURL)")
            let asset = AVAsset(url: videoURL)
            duration = CMTimeGetSeconds(asset.duration)
            
            // 获取视频轨道信息
            let videoTracks = asset.tracks(withMediaType: .video)
            if let videoTrack = videoTracks.first {
                let size = videoTrack.naturalSize
                let w = Int(size.width)
                let h = Int(size.height)
                if w > 0 && h > 0 { quality = "\(h)*\(w)" }
                print("✅ 视频轨道信息：尺寸=\(size)，分辨率=\(quality ?? "未知")")
            }
            
            // 获取音频轨道信息
            let audioTracks = asset.tracks(withMediaType: .audio)
            if let audioTrack = audioTracks.first {
                audioRate = "\(audioTrack.naturalTimeScale)"
                print("✅ 音频轨道信息：采样率=\(audioRate ?? "未知")")
            }
            
            print("✅ 视频信息：时长=\(duration)秒，分辨率=\(quality ?? "未知")，音频采样率=\(audioRate ?? "未知")")
        } else {
            print("❌ 找不到视频文件：pickedVideos=\(pickedVideos)")
        }

        let format = fileExtension(from: presigned.file_name)
        print("✅ 文件格式：\(format.isEmpty ? "mp4" : format)")

        // 按接口文档字段准备参数（与安卓风格对齐）
        let requestBody: [String: Any?] = [
            "meta_data_id": topic.id,
            "user_task_result_id": topic.relate_id,
            "cate": 4,                                 // 视频类别，使用整型
            "path": presigned.path,
            "duration": Int(duration),                 // 视频时长（秒）
            "file_name": presigned.file_name,
            "size": data.count,
            "format": format.isEmpty ? "mp4" : format,
            "quality": quality,
            "audio_rate": audioRate ?? "",
            "location": nil
        ]
        
        print("✅ 发送视频元数据更新请求：\(requestBody)")

        NetworkManager.shared.post(APIConstants.Scene.updateTaskMetadata,
                                    businessParameters: requestBody) { (result: Result<UpdateTaskMetadataResponse, APIError>) in
            DispatchQueue.main.async {
                // 无论成功失败都移除loading状态
                processingVideoMetadata.remove(gridId)
                print("✅ 移除loading状态：gridId=\(gridId)，当前loading状态：\(processingVideoMetadata)")
                
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        print("✅ 更新视频元数据成功：meta_id=\(topic.id)，时长=\(duration)秒，分辨率=\(quality ?? "未知")")
                        
                        // 设置gridId与preview_url的关联，确保视频能正确计入uploadedVideoCount
                        gridIdToPreviewUrl[gridId] = presigned.preview_url
                        print("✅ 设置视频预览URL：gridId=\(gridId)，preview_url=\(presigned.preview_url)")
                        
                        // 元数据更新成功后，等待服务器生成缩略图，然后刷新任务详情
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            print("🔄 延迟刷新任务详情，获取视频缩略图")
                            // onRefresh()
                        }
                    } else {
                        errorMessage = response.msg
                        print("❌ 更新视频元数据失败：meta_id=\(topic.id)，msg=\(response.msg)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("❌ 更新视频元数据异常：meta_id=\(topic.id)，error=\(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 视频缩略图生成
    private func generateVideoThumbnail(for gridId: Int, videoURL: URL) {
        // 取消之前的任务
        thumbnailGenerationTasks[gridId]?.cancel()
        
        // 创建新的缩略图生成任务
        let task = Task { @MainActor in
            do {
                let asset = AVAsset(url: videoURL)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.maximumSize = CGSize(width: 300, height: 300)
                
                let time = CMTime(seconds: 1.0, preferredTimescale: 600)
                let cgImage = try await imageGenerator.image(at: time).image
                let thumbnail = UIImage(cgImage: cgImage)
                
                // 检查任务是否被取消
                if !Task.isCancelled {
                    videoThumbnails[gridId] = thumbnail
                    print("✅ 视频缩略图生成成功 - GridId: \(gridId)")
                }
            } catch {
                if !Task.isCancelled {
                    print("❌ 视频缩略图生成失败 - GridId: \(gridId), Error: \(error.localizedDescription)")
                }
            }
            
            // 清理任务引用
            thumbnailGenerationTasks.removeValue(forKey: gridId)
        }
        
        thumbnailGenerationTasks[gridId] = task
    }
    
    private func getTextFileName(for gridId: Int) -> String? {
        return gridIdToFileName[gridId]
    }
    
    // 从预签名数据中获取path（严格索引，无首项兜底）
    private func getPathFromPresignedData(gridId: Int, cate: Int) -> String? {
        switch cate {
        case 2: // 图片
            guard let uploadIndex = uploadImageGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedDatas.count && uploadIndex < pendingImageDatas.count else { return nil }
            return presignedDatas[uploadIndex].path
        case 4: // 视频
            guard let uploadIndex = uploadVideoGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedVideoDatas.count && uploadIndex < pendingVideoDatas.count else { return nil }
            return presignedVideoDatas[uploadIndex].path
        case 1: // 音频
            guard let uploadIndex = uploadAudioGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedAudioDatas.count else { return nil }
            return presignedAudioDatas[uploadIndex].path
        case 3: // 文本
            guard let uploadIndex = uploadTextGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedTextDatas.count && uploadIndex < pendingTextDatas.count else { return nil }
            return presignedTextDatas[uploadIndex].path
        default:
            return nil
        }
    }
    
    // 从预签名数据中获取file_name（严格索引，无首项兜底）
    private func getFileNameFromPresignedData(gridId: Int, cate: Int) -> String? {
        switch cate {
        case 2: // 图片
            guard let uploadIndex = uploadImageGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedDatas.count && uploadIndex < pendingImageDatas.count else { return nil }
            return presignedDatas[uploadIndex].file_name
        case 4: // 视频
            guard let uploadIndex = uploadVideoGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedVideoDatas.count && uploadIndex < pendingVideoDatas.count else { return nil }
            return presignedVideoDatas[uploadIndex].file_name
        case 1: // 音频
            guard let uploadIndex = uploadAudioGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedAudioDatas.count else { return nil }
            return presignedAudioDatas[uploadIndex].file_name
        case 3: // 文本
            if let name = gridIdToFileName[gridId], !name.isEmpty {
                return name
            }
            guard let uploadIndex = uploadTextGridIds.firstIndex(of: gridId),
                  uploadIndex < presignedTextDatas.count && uploadIndex < pendingTextDatas.count else { return nil }
            return presignedTextDatas[uploadIndex].file_name
        default:
            return nil
        }
    }

}

// MARK: - SwiftUI 封装：系统相册选择器（PHPicker）
struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    var selectionLimit: Int
    var onComplete: ([PHPickerResult]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selectionLimit = max(1, selectionLimit)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onComplete: ([PHPickerResult]) -> Void
        init(onComplete: @escaping ([PHPickerResult]) -> Void) {
            self.onComplete = onComplete
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onComplete(results)
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - SwiftUI 封装：系统相机采集（UIImagePickerController）
struct CameraPicker: UIViewControllerRepresentable {
    enum Mode { case photo, video }
    var mode: Mode
    var onComplete: (UIImage?, URL?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        
        // 先设置 mediaTypes，再设置 cameraCaptureMode
        switch mode {
        case .photo:
            picker.mediaTypes = ["public.image"]
            picker.cameraCaptureMode = .photo
        case .video:
            picker.mediaTypes = ["public.movie"]
            picker.cameraCaptureMode = .video
            picker.videoQuality = .typeHigh
            picker.videoMaximumDuration = 600 // 限制最大录制时长为60秒
        }
        
        // 确保相机可用
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌ 相机不可用")
            return picker
        }
        
        // 检查视频录制是否可用
        if mode == .video {
            guard UIImagePickerController.availableMediaTypes(for: .camera)?.contains("public.movie") == true else {
                print("❌ 视频录制不可用")
                return picker
            }
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onComplete: (UIImage?, URL?) -> Void
        init(onComplete: @escaping (UIImage?, URL?) -> Void) {
            self.onComplete = onComplete
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("✅ 相机拍摄完成")
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            onComplete(image, url)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("❌ 用户取消相机拍摄")
            onComplete(nil, nil)
            picker.dismiss(animated: true)
        }
        
        // 处理相机错误
        func imagePickerController(_ picker: UIImagePickerController, didFailWithError error: Error) {
            print("❌ 相机拍摄失败: \(error.localizedDescription)")
            onComplete(nil, nil)
            picker.dismiss(animated: true)
        }
    }
}


// MARK: - 视频专用相册选择器
struct VideoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    var selectionLimit: Int
    var onComplete: ([PHPickerResult]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .videos  // 只显示视频
        configuration.selectionLimit = max(1, selectionLimit)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: ([PHPickerResult]) -> Void
        
        init(onComplete: @escaping ([PHPickerResult]) -> Void) {
            self.onComplete = onComplete
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onComplete(results)
        }
    }
}






// MARK: - Color扩展，用于获取十六进制颜色值
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

private extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

// 波形动画组件 - 优化版本
struct WaveformView: View {
    let isRecording: Bool
    let currentWaveIndex: Int
    
    private let waveCount = 12
    private let waveWidth: CGFloat = 4
    private let waveHeight: CGFloat = 25
    private let waveSpacing: CGFloat = 6
    
    // 缓存计算结果以提高性能
    private var cycleIndex: Int {
        currentWaveIndex % waveCount
    }
    
    private var activeColor: Color {
        Color(hex: "#FF4252")
    }
    
    private var inactiveColor: Color {
        Color(hex: "#FF4252").opacity(0.1)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧波形（从右向左激活，循环）
            HStack(spacing: waveSpacing) {
                ForEach(0..<waveCount, id: \.self) { index in
                    WaveformBar(
                        index: index,
                        isLeftSide: true,
                        isRecording: isRecording,
                        cycleIndex: cycleIndex,
                        waveCount: waveCount,
                        waveWidth: waveWidth,
                        waveHeight: waveHeight,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor
                    )
                }
            }
            
            // 中间的录制按钮图标 - 立即切换优化
            ZStack {
                Image("Group_254")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .opacity(isRecording ? 0 : 1)
                    .scaleEffect(isRecording ? 0.8 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isRecording)
                
                Image("Group_253")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .opacity(isRecording ? 1 : 0)
                    .scaleEffect(isRecording ? 1.0 : 0.8)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isRecording)
            }
            
            // 右侧波形（从左向右激活，循环）
            HStack(spacing: waveSpacing) {
                ForEach(0..<waveCount, id: \.self) { index in
                    WaveformBar(
                        index: index,
                        isLeftSide: false,
                        isRecording: isRecording,
                        cycleIndex: cycleIndex,
                        waveCount: waveCount,
                        waveWidth: waveWidth,
                        waveHeight: waveHeight,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor
                    )
                }
            }
        }
    }
}

// 单个波形条组件 - 高性能优化版本
struct WaveformBar: View {
    let index: Int
    let isLeftSide: Bool
    let isRecording: Bool
    let cycleIndex: Int
    let waveCount: Int
    let waveWidth: CGFloat
    let waveHeight: CGFloat
    let activeColor: Color
    let inactiveColor: Color
    
    // 缓存计算结果以提高性能
    private var computedIndex: Int {
        isLeftSide ? waveCount - 1 - index : index
    }
    
    private var isActive: Bool {
        isRecording && computedIndex <= cycleIndex
    }
    
    private var distance: Int {
        abs(computedIndex - cycleIndex)
    }
    
    // 优化的透明度计算 - 使用查找表提高性能
    private var opacity: Double {
        guard isRecording else { return 0.1 }
        guard isActive else { return 0.1 }
        
        switch distance {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.6
        default: return 1.0
        }
    }
    
    // 优化的缩放计算 - 使用查找表提高性能
    private var scale: CGFloat {
        guard isRecording && isActive else { return 1.0 }
        
        switch distance {
        case 0: return 1.1
        case 1: return 1.05
        default: return 1.0
        }
    }
    
    // 优化的动画延迟计算
    private var animationDelay: Double {
        Double(computedIndex) * 0.02
    }
    
    var body: some View {
        Rectangle()
            .fill(isActive ? activeColor : inactiveColor)
            .frame(width: waveWidth, height: waveHeight)
            .cornerRadius(waveWidth / 2)
            .opacity(opacity)
            .scaleEffect(scale)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7)
                .delay(animationDelay),
                value: isActive
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: opacity
            )
            .drawingGroup() // 启用Metal渲染优化
    }
}









