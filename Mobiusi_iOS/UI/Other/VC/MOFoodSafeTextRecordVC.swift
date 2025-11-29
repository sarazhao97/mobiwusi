//
//  MOFoodSafeTextRecordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit
import SwiftUI

class MOFoodSafeTextRecordVC: MOToolGenerateRecordVC {
	
	// 独立的食品安全记录数据源，避免与父类 dataList 类型冲突
	var foodSafeDataList: [MOFoodSafeRecordItemModel] = []
	
	override func loadRequest(){
		MONetDataServer.shared().foodSafeHistoryList(withPage: self.pageIndex, limit: self.pageSize) { dict in
			 
			let list = dict?["list"] as? NSArray
			let newList = NSMutableArray.yy_modelArray(with: MOFoodSafeRecordItemModel.self, json: list as Any) as? [MOFoodSafeRecordItemModel]
			if self.pageIndex == 1 {
				self.foodSafeDataList.removeAll()
				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
			} else {
				self.tableView.mj_footer.endRefreshing()
			}
			if let newList {
				self.foodSafeDataList.append(contentsOf: newList)
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

	func gopreviewTranslateResultVC(model:MOFoodSafeRecordItemModel) {
		// UIKit → SwiftUI：无参构造，详情页内部自处理加载逻辑
		let detailView = MOFoodSafetyAnalysisDetail(recordItem: model)
		let hosting = UIHostingController(rootView: detailView)
		hosting.modalTransitionStyle = UIModalTransitionStyle.coverVertical
		hosting.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
		let navVC = MONavigationController(rootViewController: hosting)
		navVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
		navVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
		self.present(navVC, animated: true)
	}

	override func viewDidLoad() {
		navigationTitle = NSLocalizedString("分析记录", comment: "")
		super.viewDidLoad()
		tableView.register(MOFoodSafeRecordCell.self, forCellReuseIdentifier: "MOFoodSafeRecordCell")
	}
	
	// 预览当前食品安全记录的图片/结果
	func previewFoodSafeResult(model: MOFoodSafeRecordItemModel){
		let browseModel = MOBrowseMediumItemModel()
		browseModel.type = MOBrowseMediumItemType.init(rawValue: 0)
		browseModel.url = model.image_url
		let vc = MOBrowseMediumVC.init(dataList: [browseModel], selectedIndex: 0)
		vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
		vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
		self.present(vc, animated: true)
	}
}


extension MOFoodSafeTextRecordVC {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foodSafeDataList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = foodSafeDataList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOFoodSafeRecordCell")
		guard let cell else {
			return MOFoodSafeRecordCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOFoodSafeRecordCell")
		}
		if let cell1 = cell as? MOFoodSafeRecordCell {
			cell1.configCellWithModel(model: model)
			cell1.stateView.didViewClick = {[weak self] in
				guard let self else {return}
				// 如需跳详情页，这里替换为真正的详情跳转
				self.gopreviewTranslateResultVC(model: model)
			}
			cell1.didClickPreview = {[weak self] in
				guard let self else {return}
				self.previewFoodSafeResult(model: model)
				
			}
			cell1.scheduleVerticalTopView.isHidden = indexPath.row == 0
			cell1.scheduleVerticalBottomView.isHidden = foodSafeDataList.count - 1 == indexPath.row
		}
		
		return cell
	}
	
}
