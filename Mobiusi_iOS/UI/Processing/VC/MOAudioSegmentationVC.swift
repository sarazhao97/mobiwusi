//
//  MOAudioSegmentationVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOAudioSegmentationVC: MOBaseViewController {
    
	var detailModel:MOAnnotationDetailModel
	var segmentData:MOAudioClipSegmentCustomModel
	private var player: AVPlayer?
	private var playerItem: AVPlayerItem?
	var duration:Int64 = 0
	var startTimeStamp:Int64 = -1
	var endTimeStamp:Int64 = -1
	var didClickSaveBtn:((_ segmentData:MOAudioClipSegmentCustomModel)->Void)?
	var willClickSaveBtn:((_ segmentData:MOAudioClipSegmentCustomModel)->Bool)?
    lazy var customView = {
        let vi  = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.top, radius: 16)
        return vi
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("加工音频", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        navBar.backBtn.isHidden = true
        navBar.customStatusBarheight(20)
        return navBar
    }();
    lazy var closeBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_nav_close"))
        return btn
    }()
    
    lazy var leftTitleLable = {
        let label = UILabel(text: NSLocalizedString("开始时间", comment: ""), textColor: Color626262!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    lazy var centerTitleLable = {
        let label = UILabel(text: NSLocalizedString("已选时间", comment: ""), textColor: Color626262!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    lazy var rightTitleLable = {
        let label = UILabel(text: NSLocalizedString("结束时间", comment: ""), textColor: Color626262!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    lazy var startTimeLable = {
        let label = UILabel(text: "00:00.000", textColor: BlackColor, font: MOPingFangSCHeavyFont(15))
        return label
    }()
    
    lazy var durationLable = {
        let label = UILabel(text: "00:00.000", textColor: BlackColor, font: MOPingFangSCHeavyFont(15))
        return label
    }()
    
    lazy var endTimeLable = {
        let label = UILabel(text: "00:00.000", textColor: BlackColor, font: MOPingFangSCHeavyFont(15))
        return label
    }()
    
    lazy var segmentationView = {
		let vi = MOAudioSegmentationView(timeStamp: duration, detailModel:detailModel,segmentData: segmentData)
        vi.backgroundColor = BlackColor
        return vi
    }()
    
    lazy var playBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_record_my_voice_play"))
		btn.setImage(UIImage(namedNoCache: "icon_record_my_voice_pause"), for: UIControl.State.selected)
        return btn
    }()
    
    lazy var bottomView = {
        let vi = MOBottomBtnView()
        return vi
    }()
    
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(customView)
        customView.addSubview(navBar)
        navBar.rightItemsView.addArrangedSubview(closeBtn)
        customView.addSubview(leftTitleLable)
        customView.addSubview(centerTitleLable)
        customView.addSubview(rightTitleLable)
        customView.addSubview(startTimeLable)
        customView.addSubview(durationLable)
        customView.addSubview(endTimeLable)
		
		segmentationView.didSetStartTime = { [weak self] timeValue,initEndTime in
			
			guard let self else {return}
			self.startTimeStamp = Int64(timeValue)
			let time =  timeValue/1000
			let minutes = Int(time / 60)
			let seconds = Double(time).truncatingRemainder(dividingBy: 60)
			self.startTimeLable.text = String(format: "%02d:%.03f", minutes,seconds)
			if initEndTime {
				self.endTimeStamp = -1
			}
			
			
		}
		segmentationView.didSetEndTime = {[weak self] timeValue in
			guard let self else {return}
			self.endTimeStamp = Int64(timeValue)
			let time =  timeValue/1000
			let minutes = Int(time / 60)
			let seconds = Double(time).truncatingRemainder(dividingBy: 60)
			self.endTimeLable.text = String(format: "%02d:%.03f", minutes,seconds)
			
			let captureDuration = self.endTimeStamp - self.startTimeStamp
			let captureTime =  Double(captureDuration)/1000
			let captureMinutes = Int(captureTime / 60)
			let captureSeconds = captureTime.truncatingRemainder(dividingBy: 60)
			self.durationLable.text = String(format: "%02d:%.03f", captureMinutes,captureSeconds)
			
		}
		
		segmentationView.didSetTimeError =  {[weak self] msg in
			guard let self else {return}
			self.showMessage(msg)
		}
		segmentationView.scrollView.delegate = self
        customView.addSubview(segmentationView)
        customView.addSubview(playBtn)
        customView.addSubview(bottomView)
		bottomView.didClick = {[weak self] in
			guard let self else {return}
			
			
			if self.startTimeStamp == -1 {
				self.showMessage(NSLocalizedString("请设置开始时间", comment: ""))
				return
			}
			
			if self.endTimeStamp == -1 {
				self.showMessage(NSLocalizedString("请设置结束时间", comment: ""))
				return
			}
			if self.segmentData.end_time - self.segmentData.start_time == 0 {
				self.showMessage(NSLocalizedString("截取时长不能为0", comment: ""))
				return
			}
			
			let canSave = willClickSaveBtn?(self.segmentData)
			if canSave == false {
				self.showMessage(NSLocalizedString("与已保存的音频区间有重合", comment: ""))
				return
			}
			
			didClickSaveBtn?(self.segmentData)
			self.hidden {
				self.dismiss(animated: true)
			}
		}
        setBottomBtnNormalStyle()
        
        
    }
    
    func setupConstraints(){
        
        customView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
//            make.bottom.equalToSuperview()
        }
        
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        closeBtn.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        leftTitleLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.top.equalTo(navBar.snp.bottom).offset(20)
        }
        
        centerTitleLable.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(leftTitleLable.snp.centerY)
        }
        
        rightTitleLable.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-19)
            make.centerY.equalTo(leftTitleLable.snp.centerY)
        }
        
        startTimeLable.snp.makeConstraints { make in
            make.left.equalTo(leftTitleLable.snp.left)
            make.top.equalTo(leftTitleLable.snp.bottom)
        }
        
        
        durationLable.snp.makeConstraints { make in
            make.centerX.equalTo(centerTitleLable.snp.centerX)
            make.top.equalTo(centerTitleLable.snp.bottom)
        }
        
        
        endTimeLable.snp.makeConstraints { make in
            make.right.equalTo(rightTitleLable.snp.right)
            make.top.equalTo(rightTitleLable.snp.bottom)
        }
        
        segmentationView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(startTimeLable.snp.bottom).offset(18)
            make.height.equalTo(240)
        }
        
        playBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentationView.snp.bottom).offset(19)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(playBtn.snp.bottom).offset(50)
        }
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
		playBtn.addTarget(self, action: #selector(playBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
        self.hidden {
            self.dismiss(animated: true)
        }
    }
    
	@objc func playBtnClick(){
		playBtn.isSelected = !playBtn.isSelected
		if playBtn.isSelected {
			
			DLog("\(segmentationView.scrollView.contentOffset.x)")
			var progress = (segmentationView.scrollView.contentOffset.x + segmentationView.scrollView.contentInset.left)/segmentationView.scrollView.contentSize.width
			
			
			if segmentData.start_time > 0 && segmentData.end_time > 0 {
				let star = CMTime(value: CMTimeValue(Int64(segmentData.start_time)), timescale: CMTimeScale(1000))
				playerItem?.seek(to: star)
				player?.play()
				return
			}
			
			if progress == 1.0 {
				playerItem?.seek(to: CMTime.zero)
				player?.play()
				return
			}
			
			let timeValue = progress * CGFloat(self.duration)
			let currentTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
			DLog("timeValue:\(timeValue),currentTime:\(currentTime * 1000)")
			let star = CMTime(value: CMTimeValue(Int64(timeValue)), timescale: CMTimeScale(1000))
			playerItem?.seek(to: star)
			
			player?.play()
		}else {
			player?.pause()
		}
	}
    
    
	class func createAlertStyle(detailModel:MOAnnotationDetailModel,segmentData:MOAudioClipSegmentCustomModel)->MOAudioSegmentationVC{
		let vc = MOAudioSegmentationVC(detailModel: detailModel,segmentData: segmentData)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    func setBottomBtnNormalStyle(){
        bottomView.bottomBtn.setTitle(NSLocalizedString("保存片段", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!,font: MOPingFangSCBoldFont(16))
        bottomView.bottomBtn.cornerRadius(QYCornerRadius.all, radius: 14)
    }
    
    
    func setBottomBtnDisableStyle(){
		
    }
    
    func show(){
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview()
                make.bottom.equalToSuperview()
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            
        }
        
    }
    
    func hidden(complete:(()->Void)?){
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            complete?()
        }
        
    }
	
	
	init(detailModel:MOAnnotationDetailModel,segmentData:MOAudioClipSegmentCustomModel){
		self.detailModel = detailModel
		self.segmentData = segmentData
		super.init(nibName: nil, bundle: nil)
		let url = detailModel.localCachePath ?? ""
		let duration = Int64(detailModel.duration)
		self.duration = duration
		if let url = URL(string: url) {
			playerItem = AVPlayerItem(url: url)
			player = AVPlayer(playerItem: playerItem)
			observePlayerStatus()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
    }
}


extension MOAudioSegmentationVC{
	
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
		
		var totalDuration = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.zero)
		totalDuration = Float64(duration)
		if totalDuration.isNaN {
			return
		}
		if totalDuration == 0 {
			return
		}
		let currentTime = CMTimeGetSeconds(self.playerItem?.currentTime() ?? CMTime.zero) * 1000
		var progress = Float64(currentTime) / (totalDuration)
//		progress = progress
		DLog("currentTime:\(currentTime)  progress:\(progress)")
		if progress > 1.0 {
			return
		}
		
		if segmentData.start_time > 0 && segmentData.end_time > 0 {
			if Int64(currentTime) >= segmentData.end_time {
				player?.pause()
				playBtn.isSelected = false
				progress = Float64(segmentData.end_time) / (totalDuration)
			}
		}
		
		let offsetX = progress * segmentationView.scrollView.contentSize.width - segmentationView.scrollView.contentInset.left
		DLog("offsetX:\(offsetX)")
		UIView.animate(withDuration: 0.1, delay: 0,options:[UIView.AnimationOptions.curveLinear,UIView.AnimationOptions.allowUserInteraction]) {
			self.segmentationView.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
		}
		
	}
	
	@objc func playerItemDidReachEnd(_ notification: Notification) {
		playBtn.isSelected = false
		
	}
}


extension MOAudioSegmentationVC:UIScrollViewDelegate {
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
		
		var progress = (segmentationView.scrollView.contentOffset.x + segmentationView.scrollView.contentInset.left)/segmentationView.scrollView.contentSize.width
		if progress.isNaN {
			
			return
		}
		if progress < 0 {
			return
		}
		if progress > 1.0 {
			return
		}
//		progress = floor(progress * 1000) / 1000
//		let timeValue = progress * CGFloat(self.duration)
//		let time =  timeValue/1000
//		let minutes = Int(time / 60)
//		let seconds = Int(Double(time).truncatingRemainder(dividingBy: 60))
//		currentTimeLabel.text = String(format: "%02d:%02d", Int(minutes),Int(seconds))
		
		segmentationView.updateWaveViews(contentOffsetX: segmentationView.scrollView.contentOffset.x + segmentationView.scrollView.contentInset.left)
	}
}
