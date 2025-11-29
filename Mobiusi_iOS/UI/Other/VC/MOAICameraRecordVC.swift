//
//  MOAICameraRecordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOAICameraRecordVC: MOToolGenerateRecordVC {

	var histroyList:[MOGhibliHistoryModel] = []
	override func loadRequest(){
		
		let request = MOGhibliHistoryRequest()
		request.page = self.pageIndex
		request.limit = self.pageSize
		request.startRequest {[weak self] msg, data in
			
			guard let self else {return}
			if let msg {
				
				self.showErrorMessage(msg)
				return
			}
			let dict = data as? [String:Any]
			let list = dict?["list"] as? NSArray
			let newList = NSMutableArray.yy_modelArray(with: MOGhibliHistoryModel.self, json: list as Any) as? [MOGhibliHistoryModel]
			if self.pageIndex == 1 {
				self.histroyList.removeAll()
				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
			} else {
				self.tableView.mj_footer.endRefreshing()
			}
			if let newList {
				
				self.histroyList.append(contentsOf: newList)
			}
			if newList?.count ?? 0 < self.pageSize {
				self.tableView.mj_footer.endRefreshingWithNoMoreData()
			}
			self.tableView.reloadData()
		}

	}
	
	func gopreviewVC(model:MOGhibliHistoryModel){
		
		if model.status != 1 {
			
			return
		}
		
		let vc = MOAIGeneratePreviewImageVC(model: model)
		
		let navVC = MONavigationController(rootViewController: vc)
		navVC.modalTransitionStyle = .coverVertical
		navVC.modalPresentationStyle = .overFullScreen
		self.present(navVC, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		stupConstraints()
		navBar.titleLabel.text = "生成记录"
		tableView.register(MOAICameraGenerateRecordCell.self, forCellReuseIdentifier: "MOAICameraGenerateRecordCell")
	}

}



extension MOAICameraRecordVC {
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return histroyList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = histroyList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOAICameraGenerateRecordCell")
		guard let cell else {
			return MOAICameraGenerateRecordCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOAICameraGenerateRecordCell")
		}
		if let cell1 = cell as? MOAICameraGenerateRecordCell {
			cell1.configCellWithModel(model: model)
			cell1.stateView.didViewClick = {[weak self] in
				guard let self else {return}
				gopreviewVC(model: model)
			}
			cell1.didClickPreview = {[weak self] in
				guard let self else {return}
//				self.previewResult(model: model)
				
			}
			cell1.scheduleVerticalTopView.isHidden = indexPath.row == 0
			cell1.scheduleVerticalBottomView.isHidden = indexPath.row == histroyList.count - 1
		}
		
		return cell
	}
	
}
