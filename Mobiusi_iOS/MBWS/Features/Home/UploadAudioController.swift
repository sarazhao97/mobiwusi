//
//  UploadAudioController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/30.
//

import SwiftUI
import Foundation
import AVFoundation
import CryptoKit

struct UploadAudioController:View {
    @Environment(\.dismiss) private var dismiss
    let dataItem: IndexItem?

    init(dataItem: IndexItem? = nil) {
        self.dataItem = dataItem
    }

    @State private var recordTime: Int = 0 //秒数
    @State private var isRecorded: Bool = false //是否录制完成
    @State private var audioURL: String = "" //音频url
    @State private var isPlaying: Bool = false //是否正在播放
    @State private var isRecording: Bool = false //是否正在录制
    @State private var duration: Int = 0 //音频时长
    @State private var path: String = "" //音频路径
    @State private var navigateToReleasePanel: Bool = false // 上传成功后导航触发
     // 录音权限设置提示对话框状态
    @State private var showRecordingPermissionSettingsDialog: Bool = false
     // 录音权限状态
    @State private var recordingPermissionStatus: AVAudioSession.RecordPermission = .undetermined
    
    // 音频录制相关
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingTimer: Timer?
    @State private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var body: some View {
       ZStack{
           // 纵向渐变背景
           LinearGradient(
               gradient: Gradient(stops: [
                   .init(color: Color(hex: "#FFACB7"), location: 0.0),   // 粉色从顶部开始
                   .init(color: Color(hex: "#FFACB7"), location: 0.3),   // 粉色占30%
                   .init(color: Color(hex: "#EDEEF5"), location: 0.5),   // 从70%开始过渡到灰色
                   .init(color: Color(hex: "#EDEEF5"), location: 1.0)    // 灰色到底部
               ]),
               startPoint: .top,
               endPoint: .bottom
           )
           .ignoresSafeArea()
           VStack(spacing:30){
            HStack{
                Button(action:{
                    dismiss()
                }){
                      Text("取消")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                }
                .contentShape(Rectangle())
              
                    Spacer()
              //录制完音频才显示
                if isRecorded{
                    Button(action:{
                         if duration >= 5 {
                              getPreSignedURL()
                            
                            }else{
                                MBProgressHUD.showMessag("录音时长不能低于5s", to: nil, afterDelay: 3.0)
                            }
                    }){
                         Text("下一步")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(hex: "#9A1E2E"))
                        .cornerRadius(12)
                        
                    }
                    .contentShape(Rectangle())
                   
                
            }
            }
              .padding(.horizontal,25)
            Image("icon_free_record")
             .resizable()
             .scaledToFit()
             .frame(maxWidth: .infinity)
               .padding(.horizontal,25)
            HStack{
                Spacer()
                 VStack(alignment:.center,spacing:10){
                    Text("\(recordTime)s")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text("录音时长不能低于5s")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#9B9B9B"))
                 }
                Spacer()
            }
            Spacer()
            //录制完成的模块
            if isRecorded{
                VStack(alignment:.leading,spacing:20){
                    Text("录制完成，可点击试听")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#9B9B9B"))
                          .padding(.horizontal,25)
                     AudioSpectrogram(audioURL: audioURL)
                       .padding(.horizontal,25)
                     HStack{
                        Text("重新录制")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex:"#9A1E2E"))
                            .padding(.vertical,18)
                            .frame(width: UIScreen.main.bounds.width/2.4)
                            .background(Color(hex:"#9A1E2E").opacity(0.2))
                            .cornerRadius(12)
                            .onTapGesture {
                                resetRecording()
                            }
                            Spacer()
                            Button(action:{
                                if duration >= 5 {
                              getPreSignedURL()
                            
                            }else{
                                MBProgressHUD.showMessag("录音时长不能低于5s", to: nil, afterDelay: 3.0)
                            }
                            }){
                             Text("下一步")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex:"#ffffff"))
                            .padding(.vertical,18)
                            .frame(width: UIScreen.main.bounds.width/2.4)
                            .background(Color(hex:"#9A1E2E"))
                            .cornerRadius(12)
                          }
                          // 隐藏的导航链接：上传成功后跳转到发布面板
                          NavigationLink(
                              destination: AudioReleasePanel(audioURL: audioURL, duration: duration, path: path, dataItem: dataItem)
                                  .toolbar(.hidden, for: .navigationBar)
                                  .toolbarColorScheme(.dark),
                              isActive: $navigateToReleasePanel
                          ) {
                              EmptyView()
                          }
                          .hidden()
                     }
                     .padding(.vertical,15)
                     .padding(.horizontal,20)
                     .frame(width: .infinity)
                     .background(Color.white)
                  
                }
            }else{
                VStack(alignment:.center,spacing:20){
                   Image(isRecording ? "icon_record_micing" : "icon_record_mic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 67, height:  67 )
                        .onTapGesture{
                            handleRecordButtonTap()
                        }
                   Text(isRecording ? "再次点击停止录制" : "点击录制")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#9B9B9B"))

                }
                .padding(.bottom,20)
            
           }
          
           
       }
         .padding(.vertical,10)
       
         // 录音权限设置提示对话框覆盖层 - 只在权限被拒绝时显示
            if showRecordingPermissionSettingsDialog && recordingPermissionStatus == .denied {
                recordingPermissionSettingsDialogOverlay
                    .zIndex(1200)
            }
      
      
     }
     .navigationBarHidden(true)
     .toolbar(.hidden, for: .navigationBar)
       .ignoresSafeArea(edges: .bottom)
      .navigationBarBackButtonHidden(true)
      .onAppear {
          setupAudioSession()
          // 检查当前录音权限状态
          checkRecordingPermission()
      }
      .onDisappear {
          stopRecording()
      }
   }
   
   // MARK: - 音频录制相关方法
   
   /// 设置音频会话（对齐 TaskDetailController）
   private func setupAudioSession() {
       do {
           // 与 TaskDetailController 保持一致：默认模式 + 外放
           try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
           try audioSession.setActive(true)
       } catch {
           print("音频会话设置失败: \(error)")
       }
   }
   
   /// 初始化音频录制器（对齐 TaskDetailController）
   private func setupAudioRecorder() {
       let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
       
       let settings: [String: Any] = [
           AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
           AVSampleRateKey: 44100,
           AVNumberOfChannelsKey: 2,
           AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
       ]
       
       do {
           audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
           audioRecorder?.delegate = nil
           
           // 启用音频计量以监控录制质量
           audioRecorder?.isMeteringEnabled = true
           
           // 预准备录制器
           audioRecorder?.prepareToRecord()
           audioURL = audioFilename.absoluteString
       } catch {
           print("音频录制器初始化失败: \(error)")
       }
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
            showRecordingPermissionSettingsDialog = false
              
            
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
                   
                    self.showRecordingPermissionSettingsDialog = false
                   
                } else {
                    print("❌ 录音权限被拒绝")
                    // 权限被拒绝，显示设置提示对话框
                    self.showRecordingPermissionSettingsDialog = true
                }
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
   
   // 开始录制
   private func startRecording() {
       // 确保音频会话处于活动状态
       do {
           try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
           try audioSession.setActive(true)
       } catch {
           print("激活音频会话失败: \(error)")
           MBProgressHUD.showMessag("无法启动录音，请检查权限设置", to: nil, afterDelay: 2.0)
           return
       }
       
       // 初始化录音器
       setupAudioRecorder()
       
       guard let recorder = audioRecorder else {
           print("❌ 录音器初始化失败")
           MBProgressHUD.showMessag("录音器初始化失败，请重试", to: nil, afterDelay: 2.0)
           return
       }
       
       // 重置状态
       isRecording = true
       recordTime = 0
       isRecorded = false
       duration = 0
       
       // 开始录制
       let success = recorder.record()
       if success {
           print("✅ 开始录制: \(audioURL)")
           
           // 启动计时器
           recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
               DispatchQueue.main.async {
                   recordTime += 1
               }
           }
       } else {
           print("❌ 录制启动失败")
           isRecording = false
           MBProgressHUD.showMessag("录制启动失败，请重试", to: nil, afterDelay: 2.0)
       }
   }
   
   /// 停止录制
   private func stopRecording() {
       guard let recorder = audioRecorder else { return }
       
       isRecording = false
       recorder.stop()
       
       // 停止计时器
       recordingTimer?.invalidate()
       recordingTimer = nil
       
       // 标记录制完成
       if recordTime >= 1 {
           isRecorded = true
           duration = recordTime
       }
   }
   
   /// 处理录音按钮点击
    private func handleRecordButtonTap() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    /// 重新录制
    private func resetRecording() {
        // 停止当前录制（如果正在录制）
        if isRecording {
            stopRecording()
        }
        
        // 停止并清理计时器
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // 停止并清理旧的录音器
        if let recorder = audioRecorder {
            if recorder.isRecording {
                recorder.stop()
            }
            audioRecorder = nil
        }
        
        // 重置音频会话，确保下次录制可以正常开始
        do {
            // 关闭当前会话并让其他音频恢复
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            // 显式切回录音类别，防止上一轮试听将类别改为 .playback
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("重置音频会话失败: \(error)")
        }
        
        // 重置所有状态
        isRecorded = false
        recordTime = 0
        duration = 0
        audioURL = ""
        isRecording = false
        isPlaying = false
    }
    //获取预签名URL
    func getPreSignedURL() {
        guard let fileURL = URL(string: audioURL) else {
            MBProgressHUD.showMessag("音频路径无效", to: nil, afterDelay: 2.0)
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent.isEmpty ? "audio_\(UUID().uuidString).m4a" : fileURL.lastPathComponent
            let fileSize = data.count
            let fileHash = sha256Hex(of: data)

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
                            let item = response.data.first
                            path = item?.path ?? ""
                            print("✅ 预签名获取成功：\(item?.upload_url ?? "")")
                            performAudioUploads(presignedItems:response.data)
                        } else {
                            MBProgressHUD.showMessag(response.msg, to: nil, afterDelay: 2.0)
                        }
                    case .failure(let error):
                        MBProgressHUD.showMessag(error.localizedDescription, to: nil, afterDelay: 2.0)
                    }
                }
            }
        } catch {
            MBProgressHUD.showMessag("读取音频失败：\(error.localizedDescription)", to: nil, afterDelay: 2.0)
        }
    }
    // 计算文件 SHA256 哈希值
    private func sha256Hex(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    // 直传音频到预签名URL
    func performAudioUploads(presignedItems: [PresignedUrlItem]) {
        guard let fileURL = URL(string: audioURL) else {
            print("❌ 音频文件URL为空或无效: \(audioURL)")
            return
        }
        do {
            let audioData = try Data(contentsOf: fileURL)
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

                let task = URLSession.shared.uploadTask(with: request, from: audioData) { _, response, error in
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let success = (200...299).contains(statusCode)
                    Task { @MainActor in
                        if success {
                            print("✅ 音频文件上传成功: \(fileName)")
                            print("🔗 预览URL: \(previewURL)")
                            print("🆔 文件ID: \(fileId)")
                            // 使用 SwiftUI 的 NavigationLink 进行跳转
                            if !navigateToReleasePanel {
                                navigateToReleasePanel = true
                            }
                            
                        } else {
                            print("❌ 音频文件上传失败: \(fileName), 状态码: \(statusCode)")
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
}
