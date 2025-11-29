//
//  MOSummarizeAvatarView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/9.
//

import UIKit

class MOSummarizeAvatarView: MOView {
	
	var didClick:(()->Void)?
	
	var avatarImageView = {
		let imageView = UIImageView()
		imageView.cornerRadius(.all, radius: 4)
		imageView.backgroundColor = ColorF2F2F2
		return imageView
	}()
	
	var nickNameLabel = {
		let label = UILabel(text: "", textColor: Color333333!, font: MOPingFangSCMediumFont(12))
		return label
	}()
	
	func setupUI(){
		self.addSubview(avatarImageView)
		self.addSubview(nickNameLabel)
	}
	
	func setupConstraints(){
		avatarImageView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(avatarImageView.snp.height)
			
		}
		
		nickNameLabel.snp.makeConstraints { make in
			make.left.equalTo(avatarImageView.snp.right).offset(5)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
		}
	}
	
	func addActions(){
		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
		singleTapGesture.numberOfTapsRequired = 1 // 单点
		singleTapGesture.numberOfTouchesRequired = 1 // 单指
		self.addGestureRecognizer(singleTapGesture)
	}
	
	@objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
		didClick?()
		
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addActions()
		
	}

}
