//
//  MOTranslateTextBottomView3.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOTranslateTextBottomView3: MOView {

	var didClickRetakePhotoBtn:(()->Void)?
	var didClickRetranslationBtn:(()->Void)?
	lazy var retakePhotoBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("重拍", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(15))
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
		btn.cornerRadius(QYCornerRadius.all, radius: 40)
		return btn
	}()
	
	lazy var retranslationBtn = {
		let btn = MOButton()
		btn.setTitle("重新翻译", titleColor: WhiteColor!, bgColor: ClearColor, font: MOPingFangSCMediumFont(15))
		btn.setImage(UIImage(namedNoCache: "icon_translate_redo"))
		
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 33)
		btn.cornerRadius(QYCornerRadius.all, radius: 40, borderWidth: 2, borderColor: WhiteColor!)
		btn.fixAlignmentBUG()
		return btn
	}()
	
	
	func setupUI(){
		self.addSubview(retakePhotoBtn)
		self.addSubview(retranslationBtn)
	}
	
	func setupConstraints(){
		retakePhotoBtn.snp.makeConstraints { make in
			make.centerX.equalTo(self.snp.centerX).multipliedBy(0.5)
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
		}
		
		retranslationBtn.snp.makeConstraints { make in
			make.centerX.equalTo(self.snp.centerX).multipliedBy(1.5)
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
		}
	}
	
	func addActions(){
		retakePhotoBtn.addTarget(self, action: #selector(retakePhotoBtnClick), for: UIControl.Event.touchUpInside)
		
		retranslationBtn.addTarget(self, action: #selector(retranslationBtnClick), for: UIControl.Event.touchUpInside)
		
	}
	
	@objc func retakePhotoBtnClick(){
		didClickRetakePhotoBtn?()
	}
	
	@objc func retranslationBtnClick(){
		didClickRetranslationBtn?()
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addActions()
	}
}
