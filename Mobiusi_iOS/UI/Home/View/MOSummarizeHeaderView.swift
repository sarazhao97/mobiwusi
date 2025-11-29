//
//  MOSummarizeHeaderView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit

class MOSummarizeHeaderView: MOView {

	@objc public var didClickFile:((_ index:Int)->Void)?
	var didPreviewClick:(()->Void)?
	var delegate:MOMyVoiceScheduleCellDelegate?
	var avPlayer:AVPlayer?
	var audioPlayer:AVAudioPlayer?
	var  audioDuration:TimeInterval?
	var playerView:MOVoicePlayView?
	var dataModel:MOSummaryDetailModel?
	func configView(model:MOSummaryDetailModel) {
		self.dataModel = model
		guard let result = model.result?.first as? MOGetSummaryListItemResultModel  else {return}
		
		for vi in self.subviews {
			vi.removeFromSuperview()
		}
		
		
		if result.cate == 1 {
			playerView = MOVoicePlayView()
			guard let playerView else {return}
			self.addSubview(playerView)
			playerView.playClick = { [weak self] boolValue in
				if boolValue {
					self?.play()
				} else {
					self?.stop()
				}
			}
			audioDuration = TimeInterval(Int(result.duration))
			playerView.config(withUrl: result.path ?? "", andDuration: result.duration)
			playerView.snp.makeConstraints { make in
				make.left.equalToSuperview().offset(11)
				make.right.equalToSuperview().offset(-12)
				make.top.equalToSuperview().offset(13)
				make.bottom.equalToSuperview().offset(-12)
				make.height.equalTo(65)
			}
		}
		
		
		
		if result.cate == 2 {
			let imageView = UIImageView()
			imageView.isUserInteractionEnabled = true
			let tap = UITapGestureRecognizer(target: self, action: #selector(previewClick))
			imageView.addGestureRecognizer(tap)
			imageView.contentMode = .scaleAspectFill
			imageView.backgroundColor = ColorEDEEF5
			imageView.cornerRadius(QYCornerRadius.all, radius: 10)
			self.addSubview(imageView)
			imageView.snp.makeConstraints { make in
				make.height.equalTo(imageView.snp.width)
				make.width.equalToSuperview().multipliedBy(1.0/3.0).offset(-20.0/3.0)
				make.left.equalToSuperview().offset(11)
				make.top.equalToSuperview().offset(13)
				make.bottom.equalToSuperview().offset(-12)
			}
			
			if let url = URL(string: result.path ?? ""){
				imageView.sd_setImage(with: url)
			}
		}
		
		
		if result.cate == 3 {
			
			let fileItem = MODocFileItemView()
			fileItem.backgroundColor = ColorEDEEF5
			fileItem.fileIconImageView.image = UIImage(namedNoCache: "icon_data_text_doc_34x42")
			fileItem.cornerRadius(QYCornerRadius.all, radius: 10)
			fileItem.fileNameLabel.text = result.file_name
			fileItem.didCilck = {[weak self] in
				guard let self else {return}
				didClickFile?(0)
			}
			self.addSubview(fileItem)
			fileItem.snp.makeConstraints { make in
				make.left.equalToSuperview().offset(11)
				make.right.equalToSuperview().offset(-12)
				make.top.equalToSuperview().offset(13)
				make.bottom.equalToSuperview().offset(-12)
				make.height.equalTo(65)
			}
		}
		
		
		
		
		if result.cate == 4 {
			
			let imageView = UIImageView()
			imageView.isUserInteractionEnabled = true
			let tap = UITapGestureRecognizer(target: self, action: #selector(previewClick))
			imageView.addGestureRecognizer(tap)
			imageView.contentMode = .scaleAspectFill
			imageView.backgroundColor = ColorEDEEF5
			imageView.cornerRadius(QYCornerRadius.all, radius: 10)
			self.addSubview(imageView)
			imageView.snp.makeConstraints { make in
				make.height.equalTo(imageView.snp.width)
				make.width.equalToSuperview().multipliedBy(1.0/3.0).offset(-22.0/3.0)
				make.left.equalToSuperview().offset(11)
				make.top.equalToSuperview().offset(13)
				make.bottom.equalToSuperview().offset(-12)
			}
			
			if let url = URL(string: result.preview_url ?? ""){
				imageView.sd_setImage(with: url,placeholderImage: UIImage(namedNoCache: "icon_video_preview"))
			} else {
				imageView.image = UIImage(namedNoCache: "icon_video_preview");
			}
			let playImageView = UIImageView()
			playImageView.contentMode = .scaleAspectFill
			playImageView.image = UIImage(namedNoCache: "icon_data_video_pause")
			imageView.addSubview(playImageView)
			playImageView.snp.makeConstraints { make in
				make.centerY.equalToSuperview()
				make.centerX.equalToSuperview()
				
			}
		}
	}
	
	
	func play(){
//		delegate?.audioPlayerCellDidRequestPlay(self)
		startPlaying()
	}
	func stop(){
		avPlayer?.pause()
		NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
		do {
			avPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
		}catch{
			DLog(error.localizedDescription)
		}
		avPlayer = nil
		playerView?.playButton.isSelected = false
	}
	
	func startPlaying(){
		
		guard let result = dataModel?.result?.first as? MOGetSummaryListItemResultModel else {return}
		if let tmpPlayer = avPlayer,tmpPlayer.status == .readyToPlay {
			return
		}
		if let url = URL(string: result.path ?? "") {
			avPlayer = AVPlayer.init(url: url)
			avPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: nil)
			avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
				DispatchQueue.main.async {
					self?.updateNetworkAudioProgress()
				}
				
			}
			NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlaying), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
			avPlayer?.play()
			playerView?.playButton.isSelected = true
		}
		
		
	}
	
	func updateNetworkAudioProgress(){
		
		guard let avPlayer,let audioDuration else {return}
		
		if avPlayer.rate > 0,avPlayer.error == nil {
			let playerCurrentTime = avPlayer.currentTime()
			let progress = CMTimeGetSeconds(playerCurrentTime) / (audioDuration/1000.0)
			playerView?.updatePlayProgress(progress, andCurrentTime: Int(CMTimeGetSeconds(playerCurrentTime)))
//			delegate?.audioPlayerCell(self, didUpdateProgress: Float(progress), currentTime: CMTimeGetSeconds(playerCurrentTime))
		}
	}
	
	
	@objc func playerItemDidFinishPlaying(){
		playerView?.endPlay()
		
	}
	
	@objc func previewClick(){
		didPreviewClick?()
	}
	override func addSubViews(inFrame frame: CGRect) {
		
	}

}
