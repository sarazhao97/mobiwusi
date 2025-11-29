//
//  MOTranslateTextBottomView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/16.
//

import UIKit

class MOTranslateTextBottomView: MOView {
	
	var didClickAlbumBtn:(()->Void)?
	var didClickTakePhotoBtn:(()->Void)?
	var didClickRightBtn:((_ isSelected:Bool)->Void)?
	var offsetBottomHeight = 0.0
	lazy var albumBtn = {
		let btn = MOButton()
		btn.imageView?.contentMode = .scaleAspectFill
		btn.cornerRadius(QYCornerRadius.all, radius: 4)
		btn.backgroundColor = WhiteColor!
		return btn
	}()
	
	lazy var takePhotoBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_take_photo"))
		return btn
	}()
	
	
	lazy var rightBtn = {
		let btn = MOButton()
		btn.imageView?.contentMode = .scaleAspectFill
		btn.setImage(UIImage(namedNoCache: "icon_reverse_camera"), for: UIControl.State.normal)
		btn.setImage(UIImage(namedNoCache: "icon_reverse_camera"), for: UIControl.State.selected)
		return btn
	}()
	
	func setupUI(){
		self.addSubview(albumBtn)
		self.addSubview(takePhotoBtn)
		self.addSubview(rightBtn)
	}
	
	func setupConstraints(){
		albumBtn.snp.makeConstraints { make in
			make.right.equalTo(self.snp.centerX).multipliedBy(0.5)
			make.width.height.equalTo(40)
			make.centerY.equalToSuperview()
		}
		takePhotoBtn.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
			make.bottom.equalToSuperview().offset(offsetBottomHeight)
		}
		
		rightBtn.snp.makeConstraints { make in
			make.left.equalTo(self.snp.centerX).multipliedBy(1.5)
			make.width.height.equalTo(40)
			make.centerY.equalToSuperview()
		}
	}
	
	func addActions(){
		albumBtn.addTarget(self, action: #selector(albumBtnClick), for: UIControl.Event.touchUpInside)
		takePhotoBtn.addTarget(self, action: #selector(takePhotoBtnClick), for: UIControl.Event.touchUpInside)
		rightBtn.addTarget(self, action: #selector(rightBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func albumBtnClick(){
		didClickAlbumBtn?()
	}
	
	@objc func takePhotoBtnClick(){
		didClickTakePhotoBtn?()
	}
	
	@objc func rightBtnClick(){
		rightBtn.isSelected = !rightBtn.isSelected
		didClickRightBtn?(rightBtn.isSelected)
	}
	
	init(offsetBottomHeight:CGFloat = Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20) {
		self.offsetBottomHeight = offsetBottomHeight
		super.init(frame: CGRect())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		addActions()
	}
}
