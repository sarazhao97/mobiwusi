//
//  MOLinkRecognitionInputView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/16.
//

import UIKit

class MOLinkRecognitionInputView: MOView {

	
	var didClickStartRecognitionBtn:(()->Void)?
	lazy var contentView = {
		let vi = MOView()
		vi.cornerRadius(QYCornerRadius.all, radius: 20)
		vi.backgroundColor = WhiteColor
		return vi
	}()
	
	
	
	lazy var textView = {
		let tv = UITextView()
		tv.font = MOPingFangSCMediumFont(14)
		tv.showsVerticalScrollIndicator = false
		return tv
	}()
	
	lazy var summarizeBtn = {
		let btn = MOButton()
		btn.semanticContentAttribute = .forceRightToLeft
		btn.setTitle(NSLocalizedString("开始识别", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(13))
		btn.cornerRadius(QYCornerRadius.all, radius: 14)
		return btn
	}()
	
	func setupUI(){
		self.addSubview(contentView)
		textView.zw_placeHolder = NSLocalizedString("请在此输入...", comment: "")
		textView.observeValue(forKeyPath: "contentSize") { dict, object in
			let size:CGSize = dict["new"] as! CGSize
			let newSize = size.height < 59 ? 59 : size.height
			
			self.textView.snp.remakeConstraints{ make in
				make.left.equalToSuperview().offset(21)
				make.right.equalToSuperview().offset(-21)
				make.top.equalToSuperview().offset(14)
				make.height.equalTo(newSize)
				make.bottom.equalToSuperview().offset(-14)
			}
			
		}
		contentView.addSubview(textView)
		self.addSubview(summarizeBtn)
	}
	
	func setupConstraints(){
		contentView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview()
			
		}
		
		textView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(21)
			make.right.equalToSuperview().offset(-21)
			make.top.equalToSuperview().offset(14)
			make.height.equalTo(59)
			make.bottom.equalToSuperview().offset(-14)
		}
		
		summarizeBtn.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(19)
			make.right.equalToSuperview().offset(-19)
			make.height.equalTo(55)
			make.top.equalTo(contentView.snp.bottom).offset(33)
			make.bottom.equalToSuperview()
		}
		
		
	}
	
	func addAtcions(){
		
		summarizeBtn.addTarget(self, action: #selector(summarizeBtnClick), for: UIControl.Event.touchUpInside)
	}

	@objc func summarizeBtnClick(){
		
		didClickStartRecognitionBtn?()
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addAtcions()
	}
}
