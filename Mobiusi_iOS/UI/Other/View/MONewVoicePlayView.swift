//
//  MONewVoicePlayView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/17.
//

import UIKit

class MONewVoicePlayView: MOView {
	
	var didClickPlayBtn:((_ isStartPlay:Bool)->Void)?
	
	var duration:Int = 0
	lazy var playBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_record_my_voice_play"), select: UIImage(namedNoCache: "icon_record_my_voice_pause"))
		btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
		return btn
	}()
	
	lazy var soundWaveBgImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_record_my_voice_playing_g")
		return imageView
	}()
	
	lazy var soundWaveImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_record_my_voice_playing_r")
		return imageView
	}()
	
	lazy var durationLabel = {
		let label = UILabel(text: "00:00", textColor: Color9B9B9B!, font: MOPingFangSCFont(10))
		return label
	}()
	
	func setupUI(){
		playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
		self.cornerRadius(QYCornerRadius.all, radius: 15)
		self.backgroundColor = ColorEDEEF5
		self.addSubview(playBtn)
		self.addSubview(soundWaveBgImageView)
		self.addSubview(soundWaveImageView)
		self.addSubview(durationLabel)
	}
	
	func setupConstraints(){
		
		playBtn.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().offset(14)
			make.width.height.equalTo(22)
		}
		
		durationLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().offset(-14)
		}
		
		durationLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
		durationLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		
		soundWaveBgImageView.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalTo(playBtn.snp.right).offset(10)
			make.right.equalTo(durationLabel.snp.left).offset(-10)
		}
		
		soundWaveImageView.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalTo(soundWaveBgImageView.snp.left)
			make.width.equalTo(0)
		}
	}
	
	func config(duration:Int = 0){
		self.duration = duration
		let minutes = Int(duration / 60)
		let seconds = Int(duration%60)
		durationLabel.text = String(format: "%02d:%02d", minutes,seconds)
	}
	
	@objc func playBtnClick(){
		playBtn.isSelected.toggle()
		didClickPlayBtn?(playBtn.isSelected)
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
}
