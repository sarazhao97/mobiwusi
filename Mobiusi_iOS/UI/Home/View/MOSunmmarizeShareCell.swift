//
//  MOSunmmarizeShareCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/9.
//

import Foundation
class MOSunmmarizeShareCell: UICollectionViewCell {
	
	lazy var topImageView = {
		let imageView = UIImageView()
		return imageView
	}()
	
	lazy var bottomTitleLable = {
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(12))
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		return label
	}()
	
	
	func setupUI(){
		contentView.addSubview(topImageView)
		contentView.addSubview(bottomTitleLable)
	}
	
	func setupConstraints(){
		
		topImageView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.left.greaterThanOrEqualToSuperview()
			make.right.lessThanOrEqualToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalTo(32)
			make.height.equalTo(32)
		}
		
		bottomTitleLable.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(topImageView.snp.bottom).offset(10)
		}
	}
	
	func configCell(imageIcon:String,title:String) {
		topImageView.image = UIImage(namedNoCache: imageIcon)
		bottomTitleLable.text = title
	}
	
	func addSubviews() {
		setupUI()
		setupConstraints()
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubviews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
