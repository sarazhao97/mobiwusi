//
//  MOTranslateTextBottomView4.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOTranslateTextBottomView4: MOView {

	var didClickSaveBtn:(()->Void)?
	var didClickShareBtn:(()->Void)?
	lazy var saveBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("保存", comment: ""), titleColor: WhiteColor!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_save_white"))
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
		self.addSubview(shareBtn)
	}
	
	func setupConstraints(){
		saveBtn.snp.makeConstraints { make in
			make.centerX.equalTo(self.snp.centerX).multipliedBy(0.5)
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
		}
		saveBtn.centerImage(aboveTitle: 6)
		shareBtn.snp.makeConstraints { make in
			make.centerX.equalTo(self.snp.centerX).multipliedBy(1.5)
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
		}
		shareBtn.centerImage(aboveTitle: 6)
	}
	
	func addActions(){
		saveBtn.addTarget(self, action: #selector(saveBtnClick), for: UIControl.Event.touchUpInside)
		
		shareBtn.addTarget(self, action: #selector(shareBtnClick), for: UIControl.Event.touchUpInside)
		
	}
	
	@objc func saveBtnClick(){
		didClickSaveBtn?()
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
