//
//  MOProcessingAudioHeader.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/19.
//

import Foundation
class MOProcessingAudioHeader: MOView {
	
	
	private var player: AVPlayer?
	private var playerItem: AVPlayerItem?
	var duration:Int64 = 0
    lazy var topBGView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    lazy var titleHeader = {
        let vi = MOProcessTitleHeaderView()
        return vi
    }()
    
    lazy var durationLabel = {
        let label = UILabel(text: "", textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(10))
        return label
    }()
    
    lazy var currentTimeLabel = {
        let label = UILabel(text: "00:00", textColor: BlackColor, font: MOPingFangSCMediumFont(10))
        return label
    }()
    
    lazy var playBtn = {
        let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_play_triangle"))
//		icon_pause_new
		btn.setImage(UIImage(namedNoCache: "icon_pause_new"), for: UIControl.State.selected)
		btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var waveView = {
        let vi  = MOAudioTimeChartView()
        return vi
    }()
    
    func setupUI(){
        self.addSubview(topBGView)
        topBGView.addSubview(titleHeader)
        topBGView.addSubview(currentTimeLabel)
        topBGView.addSubview(durationLabel)
        topBGView.addSubview(playBtn)
		waveView.scrollView.delegate = self
        self.addSubview(waveView)
        
        titleHeader.titleLabel.text = ""
        titleHeader.subTitleLabel.text = ""
        durationLabel.text = ""
		
        
    }
    
    func setupConstraints(){
        topBGView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        titleHeader.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(titleHeader.snp.bottom).offset(10)
			make.bottom.equalToSuperview().offset(-10)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(currentTimeLabel.snp.right)
            make.centerY.equalTo(currentTimeLabel.snp.centerY)
        }
        playBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(currentTimeLabel.snp.centerY)
        }
        
        waveView.snp.makeConstraints { make in
            make.top.equalTo(topBGView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(146)
        }
    }
	
	func addActions(){
		playBtn.addTarget(self, action: #selector(playBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func playBtnClick(){
		playBtn.isSelected = !playBtn.isSelected
		if playBtn.isSelected {
			
			DLog("\(waveView.scrollView.contentOffset.x)")
			var progress = (waveView.scrollView.contentOffset.x + waveView.scrollView.contentInset.left)/waveView.scrollView.contentSize.width
			
			if progress == 1.0 {
				playerItem?.seek(to: CMTime.zero)
				
			} else {
				
				let timeValue = progress * CGFloat(self.duration)
				let currentTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
				DLog("timeValue:\(timeValue),currentTime:\(currentTime * 1000)")
				let star = CMTime(value: CMTimeValue(Int64(timeValue)), timescale: CMTimeScale(1000))
				playerItem?.seek(to: star)
			}
			
			player?.play()
		}else {
			player?.pause()
		}
		
	}
	
	
	func configView(taskTitle:String,datailModel:MOAnnotationDetailModel?){
		let url = datailModel?.localCachePath ?? ""
		let duration = Int64(datailModel?.duration ?? 0)
		self.duration = duration
		let timeDuration = Float(duration)/1000
		let minutes = Int(timeDuration / 60)
		let seconds = (Double(timeDuration).truncatingRemainder(dividingBy: 60))
		currentTimeLabel.text = "00:00"
		durationLabel.text = String(format: "/%02d:%02d", Int(minutes),Int(seconds))
		titleHeader.titleLabel.text = taskTitle
		titleHeader.subTitleLabel.text = String(format: "TID:%d", datailModel?.task_id ?? 0)
		if let url = URL(string: url) {
			playerItem = AVPlayerItem(url: url)
			player = AVPlayer(playerItem: playerItem)
			observePlayerStatus()
			waveView.timeStamp = duration;
			if let datailModel {
				waveView.updateMaskViews(datetailData: datailModel)
			}
			
		}
	}
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
		addActions()
    }
}

extension MOProcessingAudioHeader {
	func observePlayerStatus() {
			guard let playerItem = playerItem else { return }
			
			// 监听状态变化
		let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			guard let self else {return}
			DispatchQueue.main.async {
				self.startUpdatingCurrentTime()
			}
		}
			// 监听播放结束
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
	}
	
	func startUpdatingCurrentTime(){
		// 计算缓冲进度
//		guard let timeRanges = self.playerItem?.loadedTimeRanges,
//			  let firstTimeRange = timeRanges.first as? CMTimeRange else { return }
		var totalDuration = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.zero)
		//以前是网络音频依赖后台给的时长，有时候后台返回的毫秒级是不正确的，现在本地化音频
		totalDuration = Float64(duration)
		if totalDuration.isNaN {
			return
		}
		if totalDuration == 0 {
			return
		}
		let totalDurationTimeStamp = Int(totalDuration)
		let currentTime = Int(CMTimeGetSeconds(self.playerItem?.currentTime() ?? CMTime.zero) * 1000)
		let progress = Float(currentTime) / Float(totalDurationTimeStamp)
		DLog("currentTime:\(currentTime)  totalDuration:\(totalDuration)")
		if currentTime > totalDurationTimeStamp {
			return
		}
		
		let offsetX = CGFloat(progress) * waveView.scrollView.contentSize.width - waveView.scrollView.contentInset.left
		DLog("offsetX:\(offsetX)")
		UIView.animate(withDuration: 0.1, delay: 0,options:[UIView.AnimationOptions.curveLinear,UIView.AnimationOptions.allowUserInteraction]) {
			self.waveView.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
		}
		
	}
	
	@objc func playerItemDidReachEnd(_ notification: Notification) {
		playBtn.isSelected = false
		
	}
}


extension MOProcessingAudioHeader:UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		player?.pause()
		playBtn.isSelected = false
		playBtn.isEnabled = false
	}
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		playBtn.isEnabled = true
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			playBtn.isEnabled = true
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		DLog("contentOffset :\(waveView.scrollView.contentOffset.x) ===")
		var progress = (waveView.scrollView.contentOffset.x + waveView.scrollView.contentInset.left)/waveView.scrollView.contentSize.width
		if progress.isNaN {
			
			return
		}
		if progress < 0 {
			return
		}
		if progress > 1.0 {
			return
		}
		progress = floor(progress * 1000) / 1000
		let timeValue = progress * CGFloat(self.duration)
		let time =  timeValue/1000
		let minutes = Int(time / 60)
		let seconds = Int(Double(time).truncatingRemainder(dividingBy: 60))
		currentTimeLabel.text = String(format: "%02d:%02d", Int(minutes),Int(seconds))
		waveView.updateWaveViews(contentOffsetX: waveView.scrollView.contentOffset.x + waveView.scrollView.contentInset.left)
		
	}
}
