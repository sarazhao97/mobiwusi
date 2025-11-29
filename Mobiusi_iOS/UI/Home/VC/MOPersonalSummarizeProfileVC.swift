//
//  MOPersonalSummarizeProfileVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/9.
//

import UIKit

class MOPersonalSummarizeProfileVC: MOBaseViewController {

	var summarySquareVC:MOSummarySquareVC?
	var mySummaryVC:MOMySummaryVC?
	var isMine:Bool = false
	var currentUserId:Int
	lazy var bgView = {
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}()
	lazy var bgImageView = {
		let vi = UIImageView()
		vi.image = UIImage(namedNoCache: "icon_summary_bg_short")
		return vi
	}()
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString(NSLocalizedString("资讯分析师", comment: ""), comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
		return navBar
	}()
	
	func initializationUI(){
		
		navBar.gobackDidClick = {
			MOAppDelegate().transition.popViewController(animated: true)
		}
		view.addSubview(bgView)
		bgView.addSubview(bgImageView)
		
		view.addSubview(navBar)
		if isMine {
			mySummaryVC = MOMySummaryVC(showHeader: true)
			mySummaryVC?.view.backgroundColor = ClearColor
			if let mySummaryVC {
				view.addSubview(mySummaryVC.view)
				
			}
			mySummaryVC?.manuallyRefresh()
			return
		}
		summarySquareVC = MOSummarySquareVC(showHeader: true,currentUserId: currentUserId)
		summarySquareVC?.view.backgroundColor = ClearColor
		if let summarySquareVC {
			view.addSubview(summarySquareVC.view)
			
		}
		summarySquareVC?.manuallyRefresh()
		
	}
	
	func setupConstraints(){
		bgView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		bgImageView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.height.equalTo(244)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		if let mySummaryVC {
			mySummaryVC.view.snp.makeConstraints { make in
				make.left.equalToSuperview()
				make.right.equalToSuperview()
				make.top.equalTo(navBar.snp.bottom)
				make.bottom.equalToSuperview()
			}
		}
		
		if let summarySquareVC {
			summarySquareVC.view.snp.makeConstraints { make in
				make.left.equalToSuperview()
				make.right.equalToSuperview()
				make.top.equalTo(navBar.snp.bottom)
				make.bottom.equalToSuperview()
			}
		}
		
	}
	
	init(isMine: Bool, currentUserId: Int) {
		self.isMine = isMine
		self.currentUserId = currentUserId
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initializationUI()
		setupConstraints()
		
	}
	
}
