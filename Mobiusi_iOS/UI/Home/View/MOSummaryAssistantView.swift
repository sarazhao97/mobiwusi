//
//  MOSummaryAssistantView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/12.
//

@_exported import UIKit

class MOSummaryAssistantView: MOView {

	lazy var customView = {
		let vi = MOView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 20)
		return vi
	}()
	
	lazy var bottomContentView = {
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}()
	
	lazy var iconImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_mobiwusi_48x48")
		return imageView
	}()
	
	lazy var titleLabel = {
		
		let label = UILabel(text: NSLocalizedString("你好！我是资讯分析师小助手", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(16))
		label.numberOfLines = 0
		label.lineBreakMode = .byCharWrapping
		return label
	}()
	
	lazy var toggleButton: UIButton = {
		let button = MOButton()
		button.setImage(UIImage(named: "icon_black_arrow_d"), for: .normal)
		let upArrow = UIImage(named: "icon_black_arrow_u")
		button.setImage(upArrow, for: .selected)
		button.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
		button.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		return button
	}()
	
	
	
	lazy var subtitleLabel = {
		
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(16))
		label.numberOfLines = 0
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 3
		let subTile =  NSMutableAttributedString.create(with: NSLocalizedString("我能为你快速总结各种音频、图片、视频、文件中的关键信息，提取主要观点和摘要以及思维导图。", comment: ""), font: MOPingFangSCMediumFont(10), textColor: BlackColor, paragraphStyle: paragraphStyle)
		label.attributedText = subTile
		return label
	}()
	
	lazy var leftSector = {
		let vi = MOSummaryAssistantAbilityView()
		vi.configView(iconName: "icon_summarize_magnifier", title: NSLocalizedString("摘要总结", comment: ""), subTile: NSLocalizedString("帮你快速总结数据核心，生成总结摘要", comment: ""))
		vi.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 1, borderColor: ColorF2F2F2)
		return vi
	}()
	
	lazy var rightSector = {
		let vi = MOSummaryAssistantAbilityView()
		vi.configView(iconName: "icon_summarize_map", title: NSLocalizedString("导图生成", comment: ""), subTile: NSLocalizedString("直观呈现思维脉络，生成结构化思维导图", comment: ""))
		vi.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 1, borderColor: ColorF2F2F2)
		return vi
	}()
	
	func setupUI(){
		
		self.addSubview(customView)
		customView.addSubview(iconImageView)
		customView.addSubview(titleLabel)
		customView.addSubview(bottomContentView)
		customView.addSubview(toggleButton)
		bottomContentView.addSubview(subtitleLabel)
		bottomContentView.addSubview(leftSector)
		bottomContentView.addSubview(rightSector)
		
		// 默认状态为收起
		subtitleLabel.isHidden = true
		leftSector.isHidden = true
		rightSector.isHidden = true
		bottomContentView.isHidden = true
	}
	
	func setupConstraints(){
		
		customView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview().offset(40)
			// 默认收起状态
			make.bottom.equalToSuperview()
			make.bottom.equalTo(titleLabel.snp.bottom).offset(19)
		}
		
		iconImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(19)
			make.top.equalToSuperview().offset(19)
		}
		iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalTo(iconImageView.snp.right).offset(7)
			make.top.equalTo(iconImageView.snp.top).offset(3)
			make.right.equalTo(toggleButton.snp.left).offset(-10)
		}
		
		toggleButton.snp.makeConstraints { make in
			make.centerY.equalTo(titleLabel.snp.centerY)
			make.right.equalToSuperview().offset(-19)
			make.width.height.equalTo(24)
		}
		
		bottomContentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(titleLabel.snp.bottom)
		}
		
		subtitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(19)
			make.right.equalToSuperview().offset(-19)
			make.top.equalTo(bottomContentView.snp.top).offset(11)
		}
		
		
		leftSector.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(19)
			make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
			make.height.equalTo(80)
			make.bottom.equalToSuperview().offset(-18)
		}
		
		rightSector.snp.makeConstraints { make in
			make.left.equalTo(leftSector.snp.right).offset(15)
			make.right.equalToSuperview().offset(-19)
			make.centerY.equalTo(leftSector.snp.centerY)
			make.width.equalTo(leftSector.snp.width)
			make.height.equalTo(80)
		}
		
	}
	
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
	
	@objc func toggleButtonTapped() {
		toggleButton.isSelected.toggle()
		let isExpanded = toggleButton.isSelected
		
		// 显示或隐藏内容
		subtitleLabel.isHidden = !isExpanded
		leftSector.isHidden = !isExpanded
		rightSector.isHidden = !isExpanded
		bottomContentView.isHidden = !isExpanded
		
		// 更新视图高度
		UIView.animate(withDuration: 0.5) {
			
			self.customView.snp.remakeConstraints { make in
				make.left.equalToSuperview().offset(11)
				make.right.equalToSuperview().offset(-11)
				make.top.equalToSuperview().offset(40)
				make.bottom.equalToSuperview()
				// 默认收起状态
				if isExpanded {
					make.bottom.equalTo(self.bottomContentView.snp.bottom)
				} else {
					make.bottom.equalTo(self.titleLabel.snp.bottom).offset(19)
				}
			}
			self.customView.layoutIfNeeded()
		}
	}
}
