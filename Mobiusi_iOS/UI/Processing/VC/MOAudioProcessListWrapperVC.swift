//
//  MOPorcessiongAudioWrapperVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/3.
//

import Foundation
class MOAudioProcessListWrapperVC: MOBaseViewController {
	
	weak var dataVC:MOAudioProcessListVC?
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("加工音频", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
		navBar.backgroundColor = WhiteColor
		return navBar
	}();
	
	private lazy var processingRecordsBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("加工记录", comment: ""), titleColor: Color9A1E2E!, bgColor: Color9A1E2E!.withAlphaComponent(0.1), font: MOPingFangSCBoldFont(12))
		btn.fixAlignmentBUG()
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
		btn.cornerRadius(QYCornerRadius.all, radius: 10)
		return btn
	}()
	
	func setupUI(){
		navBar.gobackDidClick = {
			
			MOAppDelegate().transition.popViewController(animated: true)
		}
		
		view.addSubview(navBar)
		let vc = MOAudioProcessListVC()
		dataVC = vc
		self.addChild(vc)
		vc.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
		self.view.addSubview(vc.view)
		
		
	}
	
	func stupConstraints(){
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		processingRecordsBtn.snp.makeConstraints { make in
			make.height.equalTo(26)
		}
		processingRecordsBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		navBar.rightItemsView.addArrangedSubview(processingRecordsBtn)
		dataVC?.view.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBar.snp.bottom)
			make.bottom.equalToSuperview()
		}
	
	}
	
	func addActions(){
		processingRecordsBtn.addTarget(self, action: #selector(processingRecordsBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func processingRecordsBtnClick(){
		
		let vc = MOAudioProcessingRecordVC()
		MOAppDelegate().transition.push(vc, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		stupConstraints()
		addActions()
		dataVC?.manualLoadingIfLoad()
	}
}
