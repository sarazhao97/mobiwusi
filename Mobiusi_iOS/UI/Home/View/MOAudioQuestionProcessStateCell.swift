//
//  MOAudioQuestionProcessStateCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/13.
//

import UIKit

class MOAudioQuestionProcessStateCell: MOTableViewCell {

	var didClickGoProcess:(()->Void)?
	lazy var customView = {
		let vi = MOView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 10)
		return vi
	}()
	lazy var titleLabel = {
		let lable = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
		lable.numberOfLines = 0;
		lable.lineBreakMode = .byCharWrapping;
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
	
	
	lazy var lineView = {
		let lineView = MOView()
		lineView.backgroundColor = Color9B9B9B?.withAlphaComponent(0.1)
		return lineView
	}()
	
	lazy var stateView = {
		let vi  = MOAudioProcessStateView()
		vi.backgroundColor = ColorF6F7FA
		vi.cornerRadius(QYCornerRadius.all, radius: 6)
		return vi
	}()
	
	lazy var didLable = {
		let lable = UILabel(text: "", textColor: Color626262!, font: MOPingFangSCMediumFont(10))
		return lable
	}()
	
	lazy var goProcessBtn = {
		
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("去加工", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_ruler_white"))
		btn.cornerRadius(QYCornerRadius.all, radius: 10)
		btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		return btn
	}()
	
	
	func setupUI(){
		contentView.addSubview(customView)
		customView.addSubview(titleLabel)
		customView.addSubview(playView)
		customView.addSubview(audioParameterLabel)
		customView.addSubview(lineView)
		customView.addSubview(stateView)
		customView.addSubview(didLable)
		customView.addSubview(goProcessBtn)
		
	}
	
	func setupConstraints(){
		customView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(10)
			make.right.equalToSuperview().offset(-12)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview().offset(-10)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalToSuperview().offset(9)
		}
		
		playView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(titleLabel.snp.bottom).offset(5)
			make.height.equalTo(35)
		}
		
		audioParameterLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(playView.snp.bottom).offset(5)
		}
		
		lineView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(audioParameterLabel.snp.bottom).offset(11)
			make.height.equalTo(1)
		}
		
		stateView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(lineView.snp.bottom).offset(11)
			make.height.equalTo(30)
		}
		
		goProcessBtn.snp.makeConstraints { make in
			make.top.equalTo(stateView.snp.bottom).offset(6)
			make.right.equalToSuperview().offset(-10)
			make.height.equalTo(26)
			make.bottom.equalToSuperview().offset(-8)
		}
		
		didLable.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.centerY.equalTo(goProcessBtn.snp.centerY)
		}

	}
	
	
	func addAction(){
		goProcessBtn.addTarget(self, action: #selector(goProcessBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func goProcessBtnClick(){
		didClickGoProcess?()
	}
	
	func configCell(questionModel:MOTaskQuestionDataModel,taskTitle:String?) {
		titleLabel.text = taskTitle
		
		if let data_param = questionModel.data_param {
			audioParameterLabel.text = String(format: "音频参数：%@", data_param)
		}
		
		stateView.rightLabel.text = questionModel.status_zh
		if questionModel.status == 0 ||  questionModel.status == 1 {
			stateView.rightLabel.textColor = ColorFC9E09
		}
		if questionModel.status == 2 {
			stateView.rightLabel.textColor = Color34C759
			
		}
		
		goProcessBtn.isHidden = questionModel.status == 2 ||  questionModel.status == 1
		if questionModel.status == 3 {
			goProcessBtn.setTitle("去修改", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCBoldFont(12))
			goProcessBtn.setImage(UIImage(namedNoCache: "icon_ruler"))
			goProcessBtn.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 1, borderColor: ColorAFAFAF)
			
		}else {
			goProcessBtn.setTitle(NSLocalizedString("去加工", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(12))
			goProcessBtn.setImage(UIImage(namedNoCache: "icon_ruler_white"))
			goProcessBtn.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 0, borderColor: ClearColor)
		}
		
		if questionModel.status == 3 {
			stateView.rightLabel.textColor = Color9A1E2E
			
		}
		didLable.text = String(format: "DiD：%d", questionModel.model_id)
		if let path = questionModel.url {
			playView.config(withUrl: path, andDuration: Int(questionModel.duration))
		}
		
	}
	
	override func addSubViews() {
		setupUI()
		setupConstraints()
		addAction()
	}


}
