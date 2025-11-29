//
//  MOSummaryDatailBriefIntroductionView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit

class MOSummaryDatailBriefIntroductionView: MOView {
	
	var didViewDetailBtnClick:(()->Void)?
	lazy var iconImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_colorful_four_pointed_star")
		return imageView
	}()
	
	lazy var titleLabel = {
		let label = UILabel(text: NSLocalizedString("资讯分析师", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(13))
		label.isUserInteractionEnabled = false
		return label
	}()
	
	lazy var detailBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("详情", comment: ""), titleColor: Color4F68A7!, bgColor: WhiteColor!, font: MOPingFangSCMediumFont(10))
		btn.setImage(UIImage(namedNoCache: "icon_other_triangle"))
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 10)
		btn.semanticContentAttribute = .forceRightToLeft
		btn.cornerRadius(QYCornerRadius.all, radius: 40)
		btn.fixAlignmentBUG()
		return btn
	}()
	
	lazy var subTitleLabel = {
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(12))
		label.isUserInteractionEnabled = false
		label.numberOfLines = 2
		return label
	}()
	
	func setupUI(){
		
		
		self.backgroundColor = ColorF6F7FA
		self.addSubview(iconImageView)
		self.addSubview(titleLabel)
		self.addSubview(detailBtn)
		self.addSubview(subTitleLabel)
		detailBtn.addTarget(self, action: #selector(detailBtnClick), for: UIControl.Event.touchUpInside)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detailBtnClick))
		self.addGestureRecognizer(tapGesture)
	}
	
	func setupConstraints(){
		
		iconImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(9)
			make.top.equalToSuperview().offset(10)
			
		}
		iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalTo(iconImageView.snp.right).offset(4)
			make.centerY.equalTo(iconImageView.snp.centerY)
		}
		
		detailBtn.snp.makeConstraints { make in
			make.left.greaterThanOrEqualTo(titleLabel.snp.right)
			make.right.equalToSuperview().offset(-9)
			make.centerY.equalTo(iconImageView.snp.centerY)
			make.height.equalTo(20)
		}
		detailBtn.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		subTitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalTo(titleLabel.snp.bottom).offset(12)
			make.bottom.equalToSuperview().offset(-13)
		}
	}
	
	@objc func detailBtnClick(){
		didViewDetailBtnClick?()
	}
	
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
	
}
