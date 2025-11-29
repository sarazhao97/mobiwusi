//
//  MOSelectUploadTypeCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/26.
//

import UIKit

class MOSelectUploadTypeCell: MOTableViewCell {
	
	lazy var typleImageView = {
		let imageView = UIImageView()
		return imageView
	}()
	
	lazy var typleNameLabel = {
		let label = UILabel(text: NSLocalizedString("当前等级", comment: ""), textColor: BlackColor, font: MOPingFangSCBoldFont(13))
		return label
	}()
	
	func setupUI(){
		contentView.addSubview(typleImageView)
		contentView.addSubview(typleNameLabel)
	}
	
	func setupConstraints(){
		typleImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(30)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(24)
		}
		
		typleNameLabel.snp.makeConstraints { make in
			make.left.equalTo(typleImageView.snp.right).offset(3)
			make.centerY.equalToSuperview()
		}
	}
	
	func configCell(imageName:String,title:String) {
		typleImageView.image = UIImage(namedNoCache: imageName)
		typleNameLabel.text = title
	}
	
	
	override func addSubViews() {
		setupUI()
		setupConstraints()
	}

}
