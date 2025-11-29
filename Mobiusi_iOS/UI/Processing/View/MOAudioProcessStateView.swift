//
//  MOAudioProcessStateView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/3.
//

import Foundation
class MOAudioProcessStateView: MOView {
	
	var didClick:(()->Void)?
	
	lazy var letfLabel = {
		let lable = UILabel(text: NSLocalizedString("加工详情", comment: ""), textColor: Color8A8A8A!, font: MOPingFangSCMediumFont(13))
		return lable
	}()
	
	lazy var rightLabel = {
		let lable = UILabel(text: "", textColor: ColorFC9E09!, font: MOPingFangSCMediumFont(12))
		lable.textAlignment = .right
		return lable
	}()
	
	lazy var rightImageView = {
		let vi = UIImageView()
		vi.image = UIImage(namedNoCache: "icon_black_arrow_r")
		return vi
	}()
	
	func setupUI(){
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
		self.addGestureRecognizer(tap)
		self.addSubview(letfLabel)
		self.addSubview(rightLabel)
		self.addSubview(rightImageView)
	}
	
	func setupConstraints(){
		letfLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(10)
			make.centerY.equalToSuperview()
		}
		
		rightImageView.snp.makeConstraints { make in
			make.right.equalToSuperview().offset(-10)
			make.centerY.equalToSuperview()
		}
		rightImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		rightLabel.snp.makeConstraints { make in
			make.left.equalTo(letfLabel.snp.right).offset(10)
			make.right.equalTo(rightImageView.snp.left).offset(-2)
			make.centerY.equalToSuperview()
		}
	}
	
	func showInProcessStyle(){
//		rightLabel.text = NSLocalizedString("加工中", comment: "")
		rightLabel.textColor = ColorFC9E09
		
	}
	
	func showFailStyle(){
//		rightLabel.text = NSLocalizedString("未通过", comment: "")
		rightLabel.textColor = Color9A1E2E
		
	}
	
	func showRecycledStyle(){
//		rightLabel.text = NSLocalizedString("已回收", comment: "")
		rightLabel.textColor = Color9B9B9B
		
	}
	
	func showPassedStyle(){
//		rightLabel.text = NSLocalizedString("已完成", comment: "")
		rightLabel.textColor = Color34C759
		
	}
	
	func showPendingApprovalStyle(){
//		rightLabel.text = NSLocalizedString("待审核", comment: "")
		rightLabel.textColor = ColorFC9E09
		
	}
	
	@objc func tapClick(){
		didClick?()
	}
	
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
}
