//
//  MOSummaryAssistantAbilityView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/12.
//

import UIKit

class MOSummaryAssistantAbilityView: MOView {
	
	lazy var iconImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	lazy var titleLabel = {
		
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(12))
		return label
	}()
	
	lazy var subtitleLabel = {
		
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(10))
		label.numberOfLines = 0
		label.lineBreakMode = .byCharWrapping
		return label
	}()
	
	func setupUI(){
		self.addSubview(iconImageView)
		self.addSubview(titleLabel)
		self.addSubview(subtitleLabel)
	}
	
	func setupConstraints(){
		iconImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(14)
			make.top.equalToSuperview().offset(11)
		}
		iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalTo(iconImageView.snp.right).offset(7)
			make.right.equalToSuperview().offset(-14)
			make.top.equalTo(iconImageView.snp.top)
		}
		
		titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
		titleLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
		
		subtitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(14)
			make.right.equalToSuperview().offset(-14)
			make.top.equalTo(titleLabel.snp.bottom).offset(3)
			make.bottom.equalToSuperview().offset(-10)
		}
	}
	
	func configView(iconName:String,title:String,subTile:String) {
		
		let image = UIImage(namedNoCache: iconName)
		iconImageView.image = image
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 3
		paragraphStyle.lineBreakMode = .byCharWrapping
		let subTileA = NSMutableAttributedString.create(with: subTile, font: MOPingFangSCMediumFont(10), textColor: BlackColor, paragraphStyle: paragraphStyle)
		titleLabel.text = title
		subtitleLabel.attributedText = subTileA
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		
		setupUI()
		setupConstraints()
	}

}
