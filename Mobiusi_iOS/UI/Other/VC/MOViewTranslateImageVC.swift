//
//  MOViewTranslateImageVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOViewTranslateImageVC: MOBaseViewController {

	
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_close_gray_38"))
		navBar.backBtn.isHidden = true
		return navBar
	}();
	
	lazy var closeBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_history_white_38"))
		return btn
	}()
	
	private lazy var previewImageView = {
		let imageView = UIImageView()
		imageView.backgroundColor = WhiteColor
		imageView.cornerRadius(QYCornerRadius.bottom, radius: 20)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}();
	
	
	lazy var viewPlainTextBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_translate_plain_text"))
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		return btn
	}()
	
	private lazy var bottomView =  {
		let vi  = MOTranslateTextBottomView4()
		return vi
	}()
	
	
	func setupUI(){
		view.backgroundColor = Color162938
		view.addSubview(previewImageView)
		view.addSubview(navBar)
		view.addSubview(viewPlainTextBtn)
		view.addSubview(bottomView)
	}
	
	func setupConstraints(){
		
		navBar.rightItemsView.addArrangedSubview(closeBtn)
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		previewImageView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		viewPlainTextBtn.snp.makeConstraints { make in
			make.right.equalToSuperview().offset(-14)
			make.bottom.equalTo(previewImageView.snp.bottom).offset(-15)
		}
		
		
		bottomView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.top.equalTo(previewImageView.snp.bottom)
		}
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupConstraints()
    }

}
