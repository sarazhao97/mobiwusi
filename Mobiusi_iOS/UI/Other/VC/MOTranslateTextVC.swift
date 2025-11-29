//
//  MOTranslateTextVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOTranslateTextVC: MOBaseViewController {
	
	init(originalText: String, translateText: String) {
		self.originalText = originalText
		self.translateText = translateText
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var originalText:String
	var translateText:String
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("文本", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
		return navBar
	}();
	
	lazy var scrollView = {
		let scroll = UIScrollView()
		scroll.showsVerticalScrollIndicator = false
		return scroll
	}()
	
	lazy var scrollContentView = {
		let vi = MOView()
		return vi
	}()
	
	lazy var theOriginalView = {
		let vi = MOTaskIntroductionView()
		vi.titleLabel.text = NSLocalizedString("原文", comment: "")
		vi.exampleBtn.setTitle(NSLocalizedString("复制", comment: ""), titleColor: Color9A1E2E!, bgColor: Color9A1E2E!.withAlphaComponent(0.15), font: MOPingFangSCBoldFont(12))
		vi.exampleBtn.setImage(UIImage(namedNoCache: "icon_copy_red"))
		vi.exampleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
		vi.exampleBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 13)
		vi.exampleBtn.cornerRadius(QYCornerRadius.all, radius: 10)
		vi.exampleBtn.fixAlignmentBUG()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 15)
		return vi
	}()
	
	lazy var translationView = {
		let vi = MOTaskIntroductionView()
		vi.titleLabel.text = NSLocalizedString("译文", comment: "")
		vi.titleLabel.textColor = WhiteColor
		vi.textLabel.textColor = WhiteColor
		vi.markView.backgroundColor = WhiteColor
		vi.exampleBtn.setTitle(NSLocalizedString("复制", comment: ""), titleColor: WhiteColor!, bgColor: WhiteColor!.withAlphaComponent(0.15), font: MOPingFangSCBoldFont(12))
		vi.exampleBtn.setImage(UIImage(namedNoCache: "icon_copy_white"))
		vi.exampleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
		vi.exampleBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 13)
		vi.exampleBtn.cornerRadius(QYCornerRadius.all, radius: 10)
		vi.exampleBtn.fixAlignmentBUG()
		vi.backgroundColor = Color9A1E2E
		vi.cornerRadius(QYCornerRadius.all, radius: 15)
		return vi
	}()
	
	func setupUI(){
		navBar.gobackDidClick = {[weak self] in
			guard let  self else {return}
			self.navigationController?.popViewController(animated: true)
			
		}
		view.addSubview(navBar)
		view.addSubview(scrollView)
		scrollView.addSubview(scrollContentView)
		theOriginalView.textLabel.text = originalText
		theOriginalView.didExampleBtnClick = {[weak self] in
			guard let self else {return}
			UIPasteboard.general.string = originalText
			self.showMessage(NSLocalizedString("已复制", comment: ""))
		}
		scrollContentView.addSubview(theOriginalView)
		
		translationView.textLabel.text = translateText
		translationView.didExampleBtnClick = {[weak self] in
			guard let self else {return}
			UIPasteboard.general.string = translateText
			self.showMessage(NSLocalizedString("已复制", comment: ""))
		}
		scrollContentView.addSubview(translationView)
	}
	
	func setupConstraints(){
		
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		scrollView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBar.snp.bottom)
			make.bottom.equalToSuperview()
		}
		
		scrollContentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(SCREEN_WIDTH)
		}
		
		
		theOriginalView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview()
		}
		
		translationView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalTo(theOriginalView.snp.bottom).offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}
		
		
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupConstraints()
    }
    

}


