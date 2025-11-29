//
//  MOAudioProcessRecordCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/3.
//

import Foundation
class MOAudioProcessRecordCell: MOBaseScheduleCell {
	lazy var titleLabel = {
		let lable = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
		lable.numberOfLines = 0
		return lable
	}()
	
	lazy var playView = {
		let vi  = MOVoicePlayView()
		return vi
	}()
	
	lazy var audioParameterLabel = {
		let lable = UILabel(text: "", textColor: Color828282!, font: MOPingFangSCMediumFont(11))
		return lable
	}()
	
	lazy var audioTagTitleLabel = {
		let lable = UILabel(text: "", textColor: Color828282!, font: MOPingFangSCMediumFont(11))
		return lable
	}()
	
	lazy var audioTagsLabel = {
		let lable = YYLabel()
		lable.numberOfLines = 0
		return lable
	}()
	
	lazy var lineView = {
		let lineView = MOView()
		lineView.backgroundColor = ColorF6F7FA
		return lineView
	}()
	
	lazy var stateView = {
		let vi = MOAudioProcessStateView()
		vi.backgroundColor = ColorF6F7FA
		vi.cornerRadius(QYCornerRadius.all, radius: 6)
		return vi
	}()
	
	func setupUI(){
		
//        let attutedStr222222 = NSMutableAttributedString()
//        let label1 = UILabel(text: "  音频标签1  ", textColor: Color9A1E2E!, font: MOPingFangSCMediumFont(10))
//        label1.cornerRadius(QYCornerRadius.all, radius: 2)
//        label1.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
//        label1.frame = CGRect(x: 0, y: 0, width: 56, height: 16)
//        let attutedStr21 = NSMutableAttributedString.yy_attachmentString(withContent: label1, contentMode: UIView.ContentMode.scaleAspectFit, attachmentSize: CGSize(width: 56, height: 16), alignTo: MOPingFangSCMediumFont(11), alignment: YYTextVerticalAlignment.center)
//        attutedStr222222.append(attutedStr21)
//        attutedStr222222.append(NSMutableAttributedString.create(with: " ", font: MOPingFangSCMediumFont(10), textColor: ClearColor))
//        let label2 = UILabel(text: "  音频标签2  ", textColor: Color9A1E2E!, font: MOPingFangSCMediumFont(10))
//        label2.cornerRadius(QYCornerRadius.all, radius: 2)
//        label2.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
//        label2.frame = CGRect(x: 0, y: 0, width: 56, height: 16)
//        let attutedStr22 = NSMutableAttributedString.yy_attachmentString(withContent: label2, contentMode: UIView.ContentMode.scaleAspectFit, attachmentSize: CGSize(width: 56, height: 16), alignTo: MOPingFangSCMediumFont(11), alignment: YYTextVerticalAlignment.center)
//
//        attutedStr222222.append(attutedStr22)
//        audioTagsLabel.attributedText = attutedStr222222
		
		audioTagTitleLabel.isHidden = true
		audioTagsLabel.isHidden = true
		dataContentView.locationBtn.isHidden = true
		
		dataContentView.didTageLabel.isHidden = false
		dataContentView.redDotView.isHidden = true
		dataContentView.msgBtn.setImage(UIImage(namedNoCache: "icon_ruler"))
		
		dataContentView.categoryDataView.addSubview(titleLabel)
		dataContentView.categoryDataView.addSubview(playView)
		dataContentView.categoryDataView.addSubview(audioParameterLabel)
		dataContentView.categoryDataView.addSubview(audioTagTitleLabel)
		dataContentView.categoryDataView.addSubview(audioTagsLabel)
		dataContentView.categoryDataView.addSubview(lineView)
		dataContentView.categoryDataView.addSubview(stateView)
	}
	
	
	func setupConstraints(){
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(9)
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-13)
		}
		
		playView.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(5)
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-13)
			make.height.equalTo(35)
		}
		
		audioParameterLabel.snp.makeConstraints { make in
			make.top.equalTo(playView.snp.bottom).offset(5)
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-13)
		}
		
		audioTagTitleLabel.snp.makeConstraints { make in
			make.top.equalTo(audioParameterLabel.snp.bottom).offset(5)
			make.left.equalToSuperview().offset(13)
		}
		audioTagsLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 13 - 10 - 34 - 13;
		audioTagsLabel.snp.makeConstraints { make in
			make.left.equalTo(audioTagTitleLabel.snp.right)
			make.top.equalTo(audioTagTitleLabel.snp.top)
			make.right.equalToSuperview().offset(-13)
		}
		
		lineView.snp.makeConstraints { make in
			make.top.equalTo(audioParameterLabel.snp.bottom).offset(10)
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-13)
			make.height.equalTo(1)
		}
		
		stateView.snp.makeConstraints { make in
			make.top.equalTo(lineView.snp.bottom).offset(6)
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-13)
			make.height.equalTo(30)
			make.bottom.equalToSuperview().offset(-10)
		}
	}
	
	func configCellWithModel(model:MOAudioAnnotationItemModel) {
		titleLabel.text = model.task_title
		timeLabel.text = model.create_time
		
		if let data_param = model.data_param {
			let audiaoParamStr = String(format:NSLocalizedString("音频参数：%@", comment: ""),data_param)
			audioParameterLabel.text = audiaoParamStr
		}
		
		dataContentView.didTageLabel.text = String(format: "DID:%d", model.meta_data_id)
		
		if let path = model.path {
			playView.config(withUrl: path, andDuration: Int(model.duration))
		}
		stateView.rightLabel.text = model.status_zh ?? ""
		if model.status == 0 {
			stateView.showInProcessStyle()
		}
		if model.status == 1 {
			stateView.showPendingApprovalStyle()
		}
		
		if model.status == 2 {
			stateView.showPassedStyle()
		}
		if model.status == 3 {
			stateView.showFailStyle()
		}
		
		if model.status == 3 {
			stateView.showFailStyle()
		}
		
		if model.status == 4 {
			stateView.showRecycledStyle()
		}
		
	}
	
	
	
	
	
	override func addSubViews() {
		super.addSubViews()
		setupUI()
		setupConstraints()
		
	}
}
