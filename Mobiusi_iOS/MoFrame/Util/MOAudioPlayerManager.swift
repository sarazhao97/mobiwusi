//
//  MOAudioPlayerManager.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/17.
//

import UIKit

class MOAudioPlayerManager: NSObject {

	nonisolated(unsafe) static let shared = MOAudioPlayerManager()

	private var player: AVPlayer?
	private var timeObserver: Any?
	private var playerItemObserver: NSKeyValueObservation?
	private(set) var isPlaying: Bool = false
		

	// 播放进度回调
	var onProgress: ((Double, Double) -> Void)?  // currentTime, duration
	var onFinish: (() -> Void)?
	var onError: ((Error) -> Void)?

	private override init() {
		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
		try? AVAudioSession.sharedInstance().setActive(true)
	}

	@MainActor func play(url: URL) {
		
		if player != nil {
			onFinish?()
		}
		
		let item = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: item)
		observeTime()
		observeStatus(for: item)
		observeFinish(for: item)
		player?.play()
		isPlaying = true
	}

	@MainActor func pause() {
		player?.pause()
		isPlaying = false
	}

	@MainActor func togglePlayPause() {
		isPlaying ? pause() : player?.play()
		isPlaying.toggle()
	}

	func seek(to seconds: Double) {
		let time = CMTime(seconds: seconds, preferredTimescale: 600)
		player?.seek(to: time)
	}

	var currentTime: Double {
		player?.currentTime().seconds ?? 0
	}
	@MainActor
	var duration: Double {
		player?.currentItem?.asset.duration.seconds ?? 0
	}

	private func observeTime() {
		if let observer = timeObserver {
			player?.removeTimeObserver(observer)
			timeObserver = nil
		}

		timeObserver = player?.addPeriodicTimeObserver(
			forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
			queue: .main
		) { [weak self] time in
			guard let self = self else { return }
			DispatchQueue.main.async {
				let current = time.seconds
				let total = self.duration
				self.onProgress?(current, total)
			}
		}
	}
	
	
	private func observeFinish(for item: AVPlayerItem) {
		   NotificationCenter.default.addObserver(
			   forName: .AVPlayerItemDidPlayToEndTime,
			   object: item,
			   queue: .main
		   ) { [weak self] _ in
			   self?.isPlaying = false
			   self?.onFinish?()
		   }
	   }
	
	private func observeStatus(for item: AVPlayerItem) {
			playerItemObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
				guard let self = self else { return }

				if item.status == .failed {
					self.isPlaying = false
					let error = item.error ?? NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "未知播放错误"])
					self.onError?(error)
				}
			}
		}
	
	private func removePlayerObservers() {
			if let observer = timeObserver {
				player?.removeTimeObserver(observer)
				timeObserver = nil
			}
			NotificationCenter.default.removeObserver(self)
		}
	
}
