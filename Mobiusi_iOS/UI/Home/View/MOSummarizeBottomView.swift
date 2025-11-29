//
//  MOSummarizeBottomView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit

class MOSummarizeBottomView: MOView {
	
	var isMine:Bool = false
	var didLetfBtnClick:(()->Void)?
	var didRightBtnClick:(()->Void)?
	var didCenterBtnClick:(()->Void)?
	lazy var contentView = {
		let vi = MOView()
		return  vi
	}()
	
	lazy var letfBtn = {
		let btn = MOButton()
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_summarize_share_22x22"), select: UIImage(namedNoCache: "icon_summarize_share_22x22"))
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		btn.fixAlignmentBUG()
		return btn
	}()
	
	lazy var centerBtn = {
		let btn = MOButton()
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_summarize_like_normal_22x22"), select: UIImage(namedNoCache: "icon_summarize_like_select_22x22"))
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		btn.fixAlignmentBUG()
		return btn
	}()
	
	lazy var rightBtn = {
		let btn = MOButton()
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_summarize_unlike_normal_22x22"), select: UIImage(namedNoCache: "icon_summarize_unlike_select_22x22"))
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		btn.fixAlignmentBUG()
		return btn
	}()
	
	func setupUI(){
		self.shadow(BlackColor.withAlphaComponent(0.05), opacity: 1, radius: 10, offset: .zero)
		self.addSubview(contentView)
		contentView.addSubview(letfBtn)
		contentView.addSubview(centerBtn)
		contentView.addSubview(rightBtn)
		letfBtn.addTarget(self, action: #selector(letfBtnClick), for: UIControl.Event.touchUpInside)
		centerBtn.addTarget(self, action: #selector(centerBtnClick), for: UIControl.Event.touchUpInside)
		rightBtn.addTarget(self, action: #selector(rightBtnClick), for: UIControl.Event.touchUpInside)
		
		
		if isMine {
			rightBtn.setImage(UIImage(namedNoCache: "icon_task_new_msg"), select: UIImage(namedNoCache: "icon_task_new_msg"))
			rightBtn.setTitles(nil)
		}
		
	}
	
	func setupConstraints(){
		
		contentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.height.equalTo(58)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight : -20)
		}
		
		letfBtn.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.right.equalTo(contentView.snp.centerX).multipliedBy(0.4)
		}
		centerBtn.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		rightBtn.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalTo(contentView.snp.centerX).multipliedBy(1.6)
		}
	}
	
	init(isMine: Bool = false) {
		self.isMine = isMine
		super.init(frame: CGRect())
	}
	
	@objc func letfBtnClick(){
		didLetfBtnClick?()
		
	}
	@objc func centerBtnClick(){
		
		didCenterBtnClick?()
	}
	
	@objc func rightBtnClick(){
		didRightBtnClick?()
		
	}
	func configView(model:MOSummaryDetailModel) {
		letfBtn.setTitles(String(model.share_num))
		centerBtn.setTitles(String(model.like_num))
		rightBtn.setTitles(String(model.unlike_num))
		centerBtn.isSelected = model.is_like
		rightBtn.isSelected = model.is_unlike
		isMine = model.is_mine
		if isMine {
			rightBtn.setImage(UIImage(namedNoCache: "icon_sumarize_msg_22x22"), select: UIImage(namedNoCache: "icon_sumarize_msg_22x22"))
			rightBtn.setTitles(nil)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}

}
