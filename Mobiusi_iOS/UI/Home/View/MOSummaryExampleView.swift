//
//  MOSummaryExampleView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/13.
//

import UIKit

class MOSummaryExampleView: MOView {
	
	
	lazy var exampleTitleLabel = {
		
		let label = UILabel(text: NSLocalizedString("总结示例", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(16))
		return label
	}()
	
	lazy var customView = {
		let vi = MOView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 20)
		return vi
	}()
	
	lazy var videoImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = ColorEDEEF5
		imageView.cornerRadius(QYCornerRadius.all, radius: 10)
		return imageView
	}()
	
	lazy var playImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_data_video_pause")
		return imageView
	}()
	
	lazy var paramLabel = {
		let label = UILabel(text: " ", textColor: Color828282!, font: MOPingFangSCMediumFont(13))
		label.numberOfLines = 0
		return label
	}()
	
	lazy var tagTitleLabel = {
		let label = UILabel(text: NSLocalizedString("标签：", comment: ""), textColor: Color828282!, font: MOPingFangSCMediumFont(13))
		return label
	}()
	
	lazy var tagLable = {
		let label = YYLabel()
		label.numberOfLines = 0
		return label
	}()
		
	lazy var lineView = {
		let vi = MOView()
		vi.backgroundColor = ColorF2F2F2
		return vi
	}()
	
	@objc public lazy var stateView = {
		let vi = MODataSummarizeStateView()
		vi.cornerRadius(QYCornerRadius.all, radius: 6)
		vi.backgroundColor = ColorF6F7FA
		vi.stateLabel.text = NSLocalizedString("查看示例", comment: "")
		vi.stateLabel.textColor = Color34C759
		return vi
	}()
	
	func setupUI(){
		self.addSubview(exampleTitleLabel)
		self.addSubview(customView)
		customView.addSubview(videoImageView)
		videoImageView.addSubview(playImageView)
		customView.addSubview(paramLabel)
		customView.addSubview(tagTitleLabel)
		customView.addSubview(tagLable)
		customView.addSubview(lineView)
		customView.addSubview(stateView)
	}
	
	func setupConstraints(){
		
		
		exampleTitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview().offset(35)
		}
		
		customView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalTo(exampleTitleLabel.snp.bottom).offset(17)
			make.bottom.equalToSuperview()
		}
		
		videoImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.top.equalToSuperview().offset(14)
			make.height.equalTo(115)
			make.width.equalTo(115)
		}
		
		playImageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		paramLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(15)
			make.top.equalTo(videoImageView.snp.bottom).offset(5)
			make.right.equalToSuperview().offset(-15)
		}
		
		tagTitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(15)
			make.top.equalTo(paramLabel.snp.bottom).offset(5)
			make.width.equalTo(39)
		}
		tagTitleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		tagLable.snp.makeConstraints { make in
			make.left.equalTo(tagTitleLabel.snp.right).offset(3)
			make.right.equalToSuperview().offset(-15)
			make.top.equalTo(tagTitleLabel.snp.top)
		}
		
		
		
		lineView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(15)
			make.top.equalTo(tagLable.snp.bottom).offset(8)
			make.right.equalToSuperview().offset(-15)
			make.height.equalTo(1)
		}
		stateView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(15)
			make.top.equalTo(lineView.snp.bottom).offset(10)
			make.right.equalToSuperview().offset(-15)
			make.height.equalTo(30)
			make.bottom.equalToSuperview().offset(-12)
		}
		
	}
	
	
	func configView(sampleData:MOSummarizeSampleModel) {
		self.layoutIfNeeded()
		if let url = URL(string: sampleData.preview_url ?? "") {
			videoImageView.sd_setImage(with: url)
		}
		paramLabel.text = NSLocalizedString("参数：", comment: "") + (sampleData.data_param ?? "")
		var tasWitoutZeroWidthCharacter:[String] = []
		if let tags = sampleData.tags?.split(separator: "#") {
			for item in tags {
				if item.count > 0 {
					tasWitoutZeroWidthCharacter.append(String(item))
				}
					
			}
		}
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 4
		let attutedStr = NSMutableAttributedString(string: "", attributes: [.paragraphStyle:paragraphStyle])
		for (index,item) in tasWitoutZeroWidthCharacter.enumerated() {
			let tagStr = String(format: "%@", item)
			DLog(tagStr)
			let label1 = UILabel(text: tagStr, textColor: Color9A1E2E!, font: MOPingFangSCMediumFont(10))
			label1.textInsets = UIEdgeInsets(top: 3, left: 2, bottom: 3, right: 2)
			label1.textAlignment = .center
			label1.cornerRadius(QYCornerRadius.all, radius: 2)
			label1.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
			
			let height = 16.0
			let size  = label1.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: height))
			label1.frame = CGRect(x: 0, y: 0, width: size.width, height: height)
			let attutedStr1 = NSMutableAttributedString.yy_attachmentString(withContent: label1, contentMode: UIView.ContentMode.center, attachmentSize: CGSize(width: size.width, height: height), alignTo: MOPingFangSCMediumFont(13), alignment: YYTextVerticalAlignment.center)
			attutedStr.append(attutedStr1)
			if index != tasWitoutZeroWidthCharacter.count - 1{
				attutedStr.append(NSMutableAttributedString.create(with: " ", font: MOPingFangSCMediumFont(13), textColor: ClearColor))
			}
		}
		DLog("preferredMaxLayoutWidth:\(self.tagLable.preferredMaxLayoutWidth)")
		tagLable.font = MOPingFangSCMediumFont(11)
		tagLable.attributedText = attutedStr
	}
	
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.tagLable.preferredMaxLayoutWidth = self.tagLable.bounds.width
		DLog("preferredMaxLayoutWidth:\(self.tagLable.preferredMaxLayoutWidth)")
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
	
}
