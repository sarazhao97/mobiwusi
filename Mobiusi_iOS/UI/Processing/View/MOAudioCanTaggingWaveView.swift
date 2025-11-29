//
//  MOAudioCanTaggingWaveView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/6.
//

import Foundation
class MOAudioCanTaggingWaveView:MOView {
	var waveColor:UIColor?
	var layerOffset:CGFloat = 0
	var layerWidth:CGFloat = 0
	var soundDecibels:[Int] = []
//	var currentSegmentModel:MOAudioClipSegmentCustomModel
	lazy var waveView = {
		var wvView = MOAudioWaveView(waveColor: self.waveColor, layerOffset: self.layerOffset, soundDecibels: self.soundDecibels)
		return wvView
	}()
	lazy var mkView  = {
		let vi = MOView()
		return vi
	}()
	lazy var segmentLable  = {
		let label = UILabel(text: "", textColor: WhiteColor!, font: MOPingFangSCMediumFont(10))
		label.backgroundColor = BlackColor.withAlphaComponent(0.3)
		label.cornerRadius(QYCornerRadius.all, radius: 2)
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		return label
	}()
	
	init(waveColor: UIColor? = nil, layerOffset: CGFloat = 0,layerWidth:CGFloat,soundDecibels:[Int]?) {
		self.waveColor = waveColor
		self.layerOffset = layerOffset
		self.layerWidth = layerWidth
		if let soundDecibels {
			self.soundDecibels.append(contentsOf: soundDecibels)
		}
		super.init(frame: CGRect())
	}
	
	func setupUI(){
		self.addSubview(waveView)
		self.addSubview(mkView)
		mkView.addSubview(segmentLable)
	}
	
	func setupConstraints(){
		waveView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		mkView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		segmentLable.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(-2)
			make.left.equalToSuperview().offset(2)
			make.right.lessThanOrEqualToSuperview()
		}
		
	}
	
	func configView(data:MOAudioClipSegmentCustomModel) {
		
		mkView.isHidden = data.localIndex == -1
		mkView.backgroundColor = WhiteColor!.withAlphaComponent(0.7)
		segmentLable.text = String(format: NSLocalizedString(" 片段%d ", comment: ""), data.localIndex + 1)
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
