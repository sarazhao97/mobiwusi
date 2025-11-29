//
//  MOSumarizeMessageListVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit

class MOSumarizeMessageListVC: MOMessageListVC {
	var userPasteBoardId:Int = 0
	var messageList:[MOSummarizeMessageItemModel] = []
	init(presentationCustomStyle userPasteBoardId:Int) {
		self.userPasteBoardId = userPasteBoardId
		super.init(nibName: nil, bundle: nil)
		self.modalTransitionStyle = .crossDissolve
		self.modalPresentationStyle = .custom
		self.transitioningDelegate = self.myTransitionDelegate
		self.isPresented = true
		showCloseBtn()
		hiddenBackBtn()
	}
	
	override func loadRequest() {
		let request = MOGetSummaryMessageRequest()
		request.page = self.page
		request.limit = self.limit
		request.user_paste_board_id = self.userPasteBoardId
		request.startRequest {[weak self] errorMsg, data in
			guard let self else {return}
			if let errorMsg {
				self.showErrorMessage(errorMsg)
				return
			}
			let dict = data as? [String:Any]
			let list = dict?["list"]
			let dataModel =  NSArray.yy_modelArray(with: MOSummarizeMessageItemModel.self, json: list as Any) as? [MOSummarizeMessageItemModel] ?? []
			
			if page == 1 {
				self.messageList.removeAll()
//				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
//				self.tableView.fd_indexPathHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
				self.tableView.mj_footer.endRefreshingWithNoMoreData()
			}
			
			if page > 1 {
				if dataModel.count < page {
					self.tableView.mj_footer.endRefreshingWithNoMoreData()
				}
				
			}
			self.messageList.append(contentsOf: dataModel)
			self.tableView.reloadData()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(MOSummarizeMessageListCell.self, forCellReuseIdentifier: "MOSummarizeMessageListCell")
    }

}

extension MOSumarizeMessageListVC:UITableViewDelegate,UITableViewDataSource {
	
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		return messageList.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 1
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 95.0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = messageList[indexPath.section]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOSummarizeMessageListCell") ?? MOSummarizeMessageListCell(frame: CGRect())
		if let cell1 = cell as? MOSummarizeMessageListCell {
			cell1.config(model: model)
		}
		return cell
	}
}
