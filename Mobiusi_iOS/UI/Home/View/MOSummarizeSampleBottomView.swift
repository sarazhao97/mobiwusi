//
//  MOSummarizeSampleBottomView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/27.
//

import UIKit

class MOSummarizeSampleBottomView: MOView {
	
	var didClickUploadBtn:(()->Void)?
	var didClickTextBtn:(()->Void)?
	lazy var uploadBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("本地上传", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(13))
		btn.setImage(UIImage(namedNoCache: "icon_upload_white"))
		btn.cornerRadius(QYCornerRadius.all, radius: 14)
		return btn
	}()
	
	lazy var textBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("输入文本/URL", comment: ""), titleColor: Color9A1E2E!, bgColor: WhiteColor!, font: MOPingFangSCHeavyFont(13))
		btn.cornerRadius(QYCornerRadius.all, radius: 14, borderWidth: 4, borderColor: Color9A1E2E)
		return btn
	}()
	
	lazy var bottomGradientView:MOHorizontalGradientView = {
		
		let vi = MOHorizontalGradientView(colors: [WhiteColor!.withAlphaComponent(0),WhiteColor!],startPoint: CGPoint(x: 1, y: 0),endPoint: CGPoint(x: 1, y: 0.5))
		return vi
	}()
	
	func setupUI(){
		self.addSubview(bottomGradientView)
		self.addSubview(uploadBtn)
		self.addSubview(textBtn)
		
		
	}
	
	func setupConstraints(){
		
		
		textBtn.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(17)
			make.top.equalToSuperview()
			make.height.equalTo(55)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20 )
		}
		
		uploadBtn.snp.makeConstraints { make in
			make.left.equalTo(textBtn.snp.right).offset(10)
			make.right.equalToSuperview().offset(-12)
			make.top.equalToSuperview()
			make.height.equalTo(55)
			make.width.equalTo(textBtn.snp.width)
		}
		
		bottomGradientView.snp.makeConstraints { make in
			make.top.equalTo(uploadBtn.snp.top)
			make.bottom.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
	}
	
	func addActions(){
		uploadBtn.addTarget(self, action: #selector(uploadBtnClick), for: UIControl.Event.touchUpInside)
		textBtn.addTarget(self, action: #selector(textBtnClick), for: UIControl.Event.touchUpInside)
		
	}
	
	@objc func uploadBtnClick(){
		didClickUploadBtn?()
	}
	
	@objc func textBtnClick(){
		didClickTextBtn?()
	}
	
	@objc override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addActions()
	}
}
