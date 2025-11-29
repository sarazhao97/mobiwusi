//
//  MOPersonHeaderView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/9.
//

import UIKit

class MOPersonHeaderView: MOView {
	lazy var nickNameLabel = {
		let lable = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(24))
		return lable
	}()
	
	lazy var momoIDLable = {
		let lable = UILabel(text: "", textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(12))
		return lable
	}()
	
	lazy var avatarImageView = {
		let imageView = UIImageView()
		imageView.cornerRadius(.all, radius: 12)
		imageView.backgroundColor = ColorF2F2F2
		return imageView
	}()
	
	func setupUI(){
		self.addSubview(nickNameLabel)
		self.addSubview(momoIDLable)
		self.addSubview(avatarImageView)
	}
	
	func setupConstraints(){
		nickNameLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(29)
			make.top.equalToSuperview().offset(32)
		}
		
		momoIDLable.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(29)
			make.top.equalTo(nickNameLabel.snp.bottom).offset(11)
		}
		
		avatarImageView.snp.makeConstraints { make in
			make.right.equalToSuperview().offset(-23)
			make.top.equalToSuperview().offset(17)
			make.width.height.equalTo(60)
		}
	}
	
	func configView(dataModel:MOGetSummaryListItemModel) {
		nickNameLabel.text = dataModel.user_name
		momoIDLable.text = "MoID：" + String(dataModel.user_id)
		if let url = URL(string: dataModel.user_avatar ?? "") {
			avatarImageView.sd_setImage(with: url)
		}
		
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
}
