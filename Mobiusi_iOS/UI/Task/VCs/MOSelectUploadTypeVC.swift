//
//  MOSelectUploadTypeVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/26.
//

import UIKit

class MOSelectUploadTypeVC: MOBaseViewController {

	@objc public var didSelectedIndex:((_ index:Int)->Void)?
	var dataList:[(imageName:String,title:String)] = []
	@objc lazy var tableView = {
		let table = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableView.Style.grouped)
		table.showsVerticalScrollIndicator = false
		table.separatorColor = ColorF2F2F2
		table.estimatedRowHeight = 0;
		table.separatorStyle = .none
		table.estimatedSectionHeaderHeight = 0
		table.estimatedSectionFooterHeight = 0
		table.backgroundColor = WhiteColor
		table.sectionIndexColor = ColorAFAFAF
		table.sectionIndexBackgroundColor = ClearColor
		table.sectionIndexTrackingBackgroundColor = ClearColor
		table.register(MOTranslateTextRecordCell.self, forCellReuseIdentifier: "MOTranslateTextRecordCell")
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
		view.backgroundColor = WhiteColor
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MOSelectUploadTypeCell.self, forCellReuseIdentifier: "MOSelectUploadTypeCell")
		tableView.isScrollEnabled = false
		view?.addSubview(tableView)
	}
	func setupConstraints(){
		tableView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupConstraints()
		self.dataList.append((imageName:"icon_data_audio_24",title:NSLocalizedString("音频", comment: "")))
		self.dataList.append((imageName:"icon_data_image_24",title:NSLocalizedString("图片", comment: "")))
		self.dataList.append((imageName:"icon_data_video_24",title:NSLocalizedString("视频", comment: "")))
		self.dataList.append((imageName:"icon_data_text_24",title:NSLocalizedString("文本", comment: "")))
		
    }
    
}

extension MOSelectUploadTypeVC:UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 4
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40.0
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 10
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 15
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = dataList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOSelectUploadTypeCell")
		if let cell1 = cell as? MOSelectUploadTypeCell {
			cell1.configCell(imageName: model.imageName, title: model.title)
		}
		return cell!
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.dismiss(animated: true)
		didSelectedIndex?(indexPath.row)
	}
	
}
