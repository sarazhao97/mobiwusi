//
//  MOTranslateTextBottomView2.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOTranslateTextBottomView2: MOView {
	
	
	var didClickSaveBtn:(()->Void)?
	var didClickRetakePhotoBtn:(()->Void)?
	var didClickShareBtn:(()->Void)?
	lazy var saveBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("保存", comment: ""), titleColor: WhiteColor!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_save_white"))
		return btn
	}()
	
	lazy var retakePhotoBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("重拍", comment: ""),titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(15))
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
		btn.cornerRadius(QYCornerRadius.all, radius: 40)
		return btn
	}()
	
	lazy var shareBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("分享", comment: ""), titleColor: WhiteColor!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_share_white"))
		return btn
	}()
	
	
	func setupUI(){
		self.addSubview(saveBtn)
		self.addSubview(retakePhotoBtn)
		self.addSubview(shareBtn)
	}
	
	func setupConstraints(){
		saveBtn.snp.makeConstraints { make in
			make.right.equalTo(self.snp.centerX).multipliedBy(0.5)
			make.centerY.equalToSuperview()
		}
		saveBtn.centerImage(aboveTitle: 6)
		retakePhotoBtn.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
//			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
		}
		
		shareBtn.snp.makeConstraints { make in
			make.left.equalTo(self.snp.centerX).multipliedBy(1.5)
			make.centerY.equalToSuperview()
		}
		shareBtn.centerImage(aboveTitle: 6)
	}
	
	func addActions(){
		saveBtn.addTarget(self, action: #selector(saveBtnClick), for: UIControl.Event.touchUpInside)
		retakePhotoBtn.addTarget(self, action: #selector(retakePhotoBtnClick), for: UIControl.Event.touchUpInside)
		
		shareBtn.addTarget(self, action: #selector(shareBtnClick), for: UIControl.Event.touchUpInside)
		
	}
	
	@objc func saveBtnClick(){
		didClickSaveBtn?()
	}
	
	@objc func retakePhotoBtnClick(){
		didClickRetakePhotoBtn?()
	}
	
	@objc func shareBtnClick(){
		didClickShareBtn?()
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addActions()
	}
}
