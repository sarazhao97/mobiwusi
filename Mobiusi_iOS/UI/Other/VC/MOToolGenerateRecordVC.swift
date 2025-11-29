//
//  MOToolGenerateRecordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOToolGenerateRecordVC: MOBaseViewController {

	var pageIndex = 1
	var pageSize = 20
	var dataList:[MOTranslateTextRecordItemModel] = []
	@objc public var navigationTitle: String = NSLocalizedString("翻译记录", comment: "")
	public lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = navigationTitle
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
		return navBar
	}();
	@objc public var tableView = {
		let table = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableView.Style.grouped)
		table.showsVerticalScrollIndicator = false
		table.separatorColor = ColorF2F2F2
//        table.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
		table.estimatedRowHeight = 0;
		table.separatorStyle = .none
		table.estimatedSectionHeaderHeight = 0
		table.estimatedSectionFooterHeight = 0
		table.backgroundColor = ColorEDEEF5
		table.sectionIndexColor = ColorAFAFAF
		table.sectionIndexBackgroundColor = ClearColor
		table.sectionIndexTrackingBackgroundColor = ClearColor
		table.register(MOBaseToolRecordCell.self, forCellReuseIdentifier: "MOBaseToolRecordCell")
		table.alwaysBounceVertical = true
		table.bounces = true
		table.delaysContentTouches = false
		table.isDirectionalLockEnabled = true
		if #available(iOS 17.4, *) {
			table.bouncesVertically = true
			table.transfersVerticalScrollingToParent = false
		}
		if #available(iOS 15.0, *) {
			table.sectionHeaderTopPadding = 0
		}
		table.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
		return table
	}()
	
	
	func setupUI(){
		navBar.gobackDidClick = {[weak self] in
			guard let self else {return}
			self.navigationController?.popViewController(animated: true)
//			MOAppDelegate().transition.popViewController(animated: true)
		}
		
		view.addSubview(navBar)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex = 1
			loadRequest()
		});
		tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex =  pageIndex + 1
			loadRequest()
		})
		tableView.mj_footer.isAutomaticallyHidden = true
		tableView.mj_header.beginRefreshing()
		view.addSubview(tableView)
		
	}
	
	
	func stupConstraints(){
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		tableView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBar.snp.bottom)
			make.bottom.equalToSuperview()
		}
	}
	
	func loadRequest(){
		
		
		MONetDataServer.shared().transPictureList(withPage: self.pageIndex, limit: self.pageSize) { dict in
			 
			let list = dict?["list"] as? NSArray
			let newList = NSMutableArray.yy_modelArray(with: MOTranslateTextRecordItemModel.self, json: list as Any) as? [MOTranslateTextRecordItemModel]
			if self.pageIndex == 1 {
				self.dataList.removeAll()
				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
			} else {
				self.tableView.mj_footer.endRefreshing()
			}
			if let newList {
				
				self.dataList.append(contentsOf: newList)
			}
			if newList?.count ?? 0 < self.pageSize {
				self.tableView.mj_footer.endRefreshingWithNoMoreData()
			}
			self.tableView.reloadData()
			
		} failure: { error in
			
			self.showErrorMessage(error?.localizedDescription ?? "")
		} msg: { msg in
			self.showErrorMessage(msg)
		} loginFail: {
			
		}

	}
	
	func previewResult(model:MOTranslateTextRecordItemModel){
		let browseModel = MOBrowseMediumItemModel()
		browseModel.type = MOBrowseMediumItemType.init(rawValue: 0)
		browseModel.url = model.result_url
		let vc = MOBrowseMediumVC.init(dataList: [browseModel], selectedIndex: 0)
		vc.modalTransitionStyle = .crossDissolve
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: true)
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		stupConstraints()
		
	}
}


extension MOToolGenerateRecordVC:UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataList.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return CGFLOAT_MIN
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 219
	}

	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = dataList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOBaseToolRecordCell")
		guard let cell else {
			return MOTranslateTextRecordCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOBaseToolRecordCell")
		}
		
		return cell
	}
	
}
