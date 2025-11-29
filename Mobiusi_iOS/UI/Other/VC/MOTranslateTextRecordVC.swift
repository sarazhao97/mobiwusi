//
//  MOTranslateTextRecordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOTranslateTextRecordVC: MOToolGenerateRecordVC {
	
	override func loadRequest(){
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
	
	func gopreviewTranslateResultVC(model:MOTranslateTextRecordItemModel) {
		let vc = MOPreviewTranslateResultVC(model: model)
		
		let navVC = MONavigationController(rootViewController: vc)
		navVC.modalTransitionStyle = .coverVertical
		navVC.modalPresentationStyle = .overFullScreen
		self.present(navVC, animated: true)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		stupConstraints()
		tableView.register(MOTranslateTextRecordCell.self, forCellReuseIdentifier: "MOTranslateTextRecordCell")
    }
}




extension MOTranslateTextRecordVC {

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = dataList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOTranslateTextRecordCell")
		guard let cell else {
			return MOTranslateTextRecordCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOTranslateTextRecordCell")
		}
		if let cell1 = cell as? MOTranslateTextRecordCell {
			cell1.configCellWithModel(model: model)
			cell1.stateView.didViewClick = {[weak self] in
				guard let self else {return}
				self.gopreviewTranslateResultVC(model: model)
			}
			cell1.didClickPreview = {[weak self] in
				guard let self else {return}
				self.previewResult(model: model)
				
			}
			cell1.scheduleVerticalTopView.isHidden = indexPath.row == 0
			cell1.scheduleVerticalBottomView.isHidden = dataList.count - 1 == indexPath.row
		}
		
		return cell
	}
	
}
