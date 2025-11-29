//
//  AudioSpectrogram.swift
//  Mobiwusi
//
//  Created by sarazhao on 2025/1/25.
//

import SwiftUI
import AVFoundation
import Combine



// 音频播放器管理类
class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var spectrogramData: [Float] = []
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private static nonisolated(unsafe) let audioCache = NSMutableDictionary()
    
    func loadAudio(from url: URL, spectrogramCount: Int) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            generateSpectrogramData(count: spectrogramCount)
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func loadAudio(from urlString: String, spectrogramCount: Int) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        // 预先生成波谱数据以提升用户体验
        generateSpectrogramData(count: spectrogramCount)
        
        // 如果是网络URL，需要先下载
        if url.scheme == "http" || url.scheme == "https" {
            // 检查缓存
            if let cachedData = Self.audioCache[urlString] as? Data {
                loadAudioFromData(cachedData, spectrogramCount: spectrogramCount)
                return
            }
            downloadAndLoadAudio(from: url, urlString: urlString, spectrogramCount: spectrogramCount)
        } else {
            loadAudio(from: url, spectrogramCount: spectrogramCount)
        }
    }
    
    private func downloadAndLoadAudio(from url: URL, urlString: String, spectrogramCount: Int) {
        isLoading = true
        loadingProgress = 0
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingProgress = 1.0
                
                guard let data = data, error == nil else {
                    print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // 缓存音频数据
                Self.audioCache[urlString] = data
                self?.loadAudioFromData(data, spectrogramCount: spectrogramCount)
            }
        }
        task.resume()
    }
    
    private func loadAudioFromData(_ data: Data, spectrogramCount: Int) {
        do {
            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            generateSpectrogramData(count: spectrogramCount)
        } catch {
            print("Error creating player from data: \(error)")
        }
    }
    
    func play() {
        // 配置音频会话为播放模式，确保音频有声音
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("❌ 音频会话配置失败: \(error)")
        }
        player?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
        // 恢复音频会话（可选，如果其他功能需要）
        // do {
        //     let audioSession = AVAudioSession.sharedInstance()
        //     try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        // } catch {
        //     print("❌ 音频会话恢复失败: \(error)")
        // }
    }
    
    func stop() {
        player?.stop()
        player?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
            
            if !player.isPlaying {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
     func generateSpectrogramData(count: Int) {
        // 生成模拟的波谱数据（实际项目中可以使用音频分析库）
        spectrogramData = (0..<count).map { _ in
            Float.random(in: 0.2...1.0)
        }
    }
    
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
}

// 音频波谱图组件
struct AudioSpectrogram: View {
    let audioURL: String
    let backColor: String?
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var spectrogramCount: Int = 30 // 默认值，会在 GeometryReader 中更新
    
    // 波谱条的固定尺寸
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 4
    private let buttonWidth: CGFloat = 30
    private let timeLabelWidth: CGFloat = 40
    private let hStackSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 20 // 左右padding总和
    
    // 自定义初始化方法，使 backColor 参数可选
    init(audioURL: String, backColor: String? = nil) {
        self.audioURL = audioURL
        self.backColor = backColor
    }
    
    // 根据可用宽度计算波谱条数量
    private func calculateSpectrogramCount(availableWidth: CGFloat) -> Int {
        // 可用宽度 = 总宽度 - 按钮宽度 - 时长显示宽度 - 间距 - 左右padding
        let usableWidth = availableWidth - buttonWidth - timeLabelWidth - hStackSpacing * 2 - horizontalPadding
        // 每个波谱条占用的宽度 = 条宽度 + 间距
        let barTotalWidth = barWidth + barSpacing
        // 计算可以放置多少个波谱条（至少10个，最多100个）
        let count = max(10, min(100, Int(usableWidth / barTotalWidth)))
        return count
    }
    
    var body: some View {
        GeometryReader { geometry in
            let calculatedCount = calculateSpectrogramCount(availableWidth: geometry.size.width)
            
            HStack(spacing: hStackSpacing) {
                // 播放/停止按钮
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }) {
                    if audioManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: buttonWidth, height: buttonWidth)
                    } else {
                        Image(audioManager.isPlaying ? "icon_record_play" :  "icon_record_pause" )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: buttonWidth, height: buttonWidth)
                    }
                }
                .disabled(audioManager.isLoading)
                
                // 波谱图
                if audioManager.isLoading {
                    HStack(spacing: barSpacing) {
                        ForEach(0..<spectrogramCount, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color(hex: "#E5E5E5"))
                                .frame(width: barWidth, height: 20)
                        }
                    }
                    .frame(height: 34)
                    .overlay(
                        Text("加载中...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    )
                } else {
                    SpectrogramView(
                        spectrogramData: audioManager.spectrogramData,
                        currentTime: audioManager.currentTime,
                        duration: audioManager.duration,
                        barWidth: barWidth,
                        barSpacing: barSpacing
                    )
                    .onTapGesture { location in
                        // 点击波谱图跳转到指定位置
                        let totalWidth = CGFloat(spectrogramCount) * (barWidth + barSpacing) - barSpacing
                        let progress = min(max(location.x / totalWidth, 0), 1)
                        audioManager.seek(to: progress * audioManager.duration)
                    }
                }
                
                // 时长显示
                Text(audioManager.isLoading ? "--:--" : formatTime(audioManager.duration))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(width: timeLabelWidth)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(Color(hex: backColor ?? "#FFFFFF"))
            .cornerRadius(10)
            .onAppear {
                spectrogramCount = calculatedCount
                audioManager.loadAudio(from: audioURL, spectrogramCount: spectrogramCount)
            }
            .onChange(of: calculatedCount) { newCount in
                // 当宽度变化时，更新波谱条数量并重新生成数据
                if spectrogramCount != newCount {
                    spectrogramCount = newCount
                    if !audioManager.isLoading {
                        audioManager.generateSpectrogramData(count: newCount)
                    }
                }
            }
        }
        .frame(height: 54) // 固定高度，避免布局跳动
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// 波谱图视图
struct SpectrogramView: View {
    let spectrogramData: [Float]
    let currentTime: TimeInterval
    let duration: TimeInterval
    let barWidth: CGFloat
    let barSpacing: CGFloat
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<spectrogramData.count, id: \.self) { index in
                let progress = duration > 0 ? currentTime / duration : 0
                let barProgress = Double(index) / Double(spectrogramData.count)
                let isPlayed = barProgress <= progress
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(isPlayed ? Color(hex: "#EA5467") : Color(hex: "#E5E5E5"))
                    .frame(
                        width: barWidth,
                        height: CGFloat(spectrogramData[index]) * 16 + 2
                    )
                    .cornerRadius(3)
                    .animation(.easeInOut(duration: 0.1), value: isPlayed)
            }
        }
        .frame(height: 34)
    }
}

// 预览
//struct AudioSpectrogram_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            AudioSpectrogram(audioURL: "https://example.com/audio.mp3")
//            AudioSpectrogram(audioURL: "https://example.com/audio2.mp3")
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//    }
//}
