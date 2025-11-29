//
//  MOPorcessiongAudioVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/18.
//

import Foundation
class MOPorcessingAudioVC: MOBaseViewController {
	
	nonisolated(unsafe) var detailData:MOAnnotationDetailModel?
	nonisolated(unsafe) var processPropertyList:[MOAudioProcessPropertyModel]?
	nonisolated(unsafe) var bindProperty:[String] = [];
	nonisolated(unsafe) var didSubmitData:(()->Void)?
	nonisolated(unsafe) var result_id:Int
	nonisolated(unsafe) var meta_data_id:Int
	var taskTitle:String
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("加工音频", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        navBar.backgroundColor = WhiteColor
        return navBar
    }();
    
    private lazy var saveBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("存草稿", comment: ""), titleColor: Color9A1E2E!, bgColor: ClearColor, font: MOPingFangSCBoldFont(12))
        btn.fixAlignmentBUG()
        return btn
    }()
    
    private lazy var completeBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("完成", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(14))
        btn.fixAlignmentBUG()
		btn.titleLabel?.adjustsFontSizeToFitWidth = true
		btn.titleLabel?.minimumScaleFactor = 0.5
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
        btn.cornerRadius(QYCornerRadius.all, radius: 6)
        return btn
    }()
    
    private lazy var tableHeaderView = {
        let header = MOProcessingAudioHeader()
        return header
    }()
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.plain)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorColor = ColorF2F2F2
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.backgroundColor = ClearColor
        tableView.sectionIndexColor = ColorAFAFAF
        tableView.sectionIndexBackgroundColor = ClearColor
        tableView.sectionIndexTrackingBackgroundColor = ClearColor
		tableView.keyboardDismissMode = .interactive
		tableView.automaticallyAdjustsScrollIndicatorInsets = true
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
    func setupUI(){
        view.addSubview(tableView)
        tableView.register(MOPorcessingAudioSHView.self, forHeaderFooterViewReuseIdentifier: "MOPorcessingAudioSHView")
        tableView.register(MOPorcessingDataPSHView.self, forHeaderFooterViewReuseIdentifier: "MOPorcessingDataPSHView")
		
		
		tableView.register(MOPorcessingAudioSegmentCell.self, forCellReuseIdentifier: "MOPorcessingAudioSegmentCell")
        tableView.register(MOAudioInvalidCell.self, forCellReuseIdentifier: "MOAudioInvalidCell")
        tableView.register(MOAudioAttributeCell.self, forCellReuseIdentifier: "MOAudioAttributeCell")
        tableView.register(MOAudioToTextCell.self, forCellReuseIdentifier: "MOAudioToTextCell")
        tableView.register(MOProcessingNotesCell.self, forCellReuseIdentifier: "MOProcessingNotesCell")
		tableView.register(MOProcessingAudioinvalidReasonCell.self, forCellReuseIdentifier: "MOProcessingAudioinvalidReasonCell")
        tableView.register(MOPorcessingAudioSHView.self, forHeaderFooterViewReuseIdentifier: "MOPorcessingAudioSHView")
        tableView.register(MOPorcessingDataPSHView.self, forHeaderFooterViewReuseIdentifier: "MOPorcessingDataPSHView")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Bottom_SafeHeight, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupConstraints(){
        
        
        saveBtn.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
        saveBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        completeBtn.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        completeBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
		if self.canEditData() {
			navBar.rightItemsView.addArrangedSubview(saveBtn)
			navBar.rightItemsView.addArrangedSubview(completeBtn)
		}
        
        
		tableHeaderView.configView(taskTitle:taskTitle,datailModel: detailData)
        let size = tableHeaderView.systemLayoutSizeFitting(CGSize(width: SCREEN_WIDTH, height: CGFLOAT_MAX), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        tableHeaderView.snp.makeConstraints { make in
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(size.height)
        }
        
        tableView.tableHeaderView = tableHeaderView
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
	
	func addAtcions(){
		saveBtn.addTarget(self, action: #selector(saveBtnClick), for: UIControl.Event.touchUpInside)
		completeBtn.addTarget(self, action: #selector(completeBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func saveBtnClick(){
		view.endEditing(true)
		requestSaveData(status: 2)
	}
	
	@objc func completeBtnClick(){
		view.endEditing(true)
		requestSaveData()
	}
    
    func addAudioSegmentation(){
		var processPropertyListNew:[MOAudioProcessPropertyModel]? = nil
		if let processPropertyList {
			let newList = NSMutableArray(array: processPropertyList)
			let json = newList.yy_modelToJSONObject()
			let datalist = NSMutableArray.yy_modelArray(with: MOAudioProcessPropertyModel.self, json: json as Any)
			processPropertyListNew = datalist as? [MOAudioProcessPropertyModel]
		}
		let model = MOAudioClipSegmentCustomModel()
		model.audio_property_original = processPropertyListNew
		guard let detailData   else {
			
			return
		}
		
		let vc  = MOAudioSegmentationVC.createAlertStyle(detailModel: detailData, segmentData: model)
		
		vc.willClickSaveBtn = {[weak self] segmentData in
			guard let self else {return false}
			var canSave = true
			if let  audio_slice = detailData.audio_slice {
				for item in audio_slice {
					let gap = min(segmentData.end_time,item.end_time) - max(segmentData.start_time, item.start_time)
					if gap >= 0 {
						canSave = false
						break
					}
				}
			}
			
			return canSave
		}
		
		vc.didClickSaveBtn = {[weak self] segmentData in
			guard let self else {return}
			self.detailData?.audio_slice?.append(segmentData)
			self.tableHeaderView.waveView.updateMaskViews(datetailData: detailData)
			self.tableView.reloadData()
			
		}
        self.present(vc, animated: true) {[weak self] in
            vc.show()
        }
    }
	
    func addAudioTag(index:Int){
        
		if  let audio_slice  = detailData?.audio_slice,audio_slice.count > index {
			let clipSegmentModel = audio_slice[index]
			let vc  = MOAudioTagVC.createAlertStyle(tagList:clipSegmentModel.tags)
			vc.didSaveTags = {[weak self] in
				guard let self else {return}
				clipSegmentModel.tags = $0
				tableView.reloadData()
			}
			self.present(vc, animated: true) {
				vc.show()
			}
		}
		
    }
	
	func addAudioAttribute(index:Int) {
		
		var processPropertyListNew:[MOAudioProcessPropertyModel]? = nil
		if let processPropertyList {
			let newList = NSMutableArray(array: processPropertyList)
			let json = newList.yy_modelToJSONObject()
			let datalist = NSMutableArray.yy_modelArray(with: MOAudioProcessPropertyModel.self, json: json as Any)
			processPropertyListNew = datalist as? [MOAudioProcessPropertyModel]
		}
		if  let audio_slice  = detailData?.audio_slice,audio_slice.count > index {
			let clipSegmentModel = audio_slice[index]
			if clipSegmentModel.audio_property_original == nil {
				clipSegmentModel.audio_property_original = processPropertyListNew
			}
			if let audio_property_original =  clipSegmentModel.audio_property_original {
				let vc = MOAudioAttributeVC.createAlertStyle(processPropertyList: audio_property_original)
				vc.didSaveData = {[weak self] proceesList in
					guard let self else {return}
					clipSegmentModel.audio_property_original = proceesList
					tableView.reloadData()
				}
				self.present(vc, animated: false) {
					vc.show()
				}
			}
			
		}
        
    }
	
	func disassembleAudioAttributes(){
		
		// 提前解包并处理可选值
		guard let audioSlices = self.detailData?.audio_slice else { return }
		guard let processPropertyList = self.processPropertyList else { return }
		for item in audioSlices {
			// 处理音频属性
			guard let audioProperties = item.audio_property else { continue }
			
			// 转换并解析处理属性列表
			let newList = NSMutableArray(array: processPropertyList)
			let json = newList.yy_modelToJSONObject()
			let datalist = NSMutableArray.yy_modelArray(with: MOAudioProcessPropertyModel.self, json: json as Any)
			guard let propertyOriginalModels = datalist as? [MOAudioProcessPropertyModel] else {
				continue
			}
			//设置本地原始属性列表
			item.audio_property_original = propertyOriginalModels
			
			// 匹配并设置选中状态
			for audioProperty in audioProperties {
				for propertyOriginalModel in propertyOriginalModels where audioProperty.name == propertyOriginalModel.cate_alias {
					propertyOriginalModel.isSelected = true
					// 处理值分割 (注意：原代码未使用分割结果)
					if let value = audioProperty.value,let children =  propertyOriginalModel.children {
						MOPorcessingAudioVC.setupChildrenProperty(value: value, children: children)
					}
				}
			}
			
		}
	}
	
    func requestData(){
		
		self.showActivityIndicator()
		let group = DispatchGroup()
		let queue = DispatchQueue(label: "requestData",attributes: DispatchQueue.Attributes.concurrent)
		var errorMsg:String? = nil
		queue.async {
			
			group.enter()
			queue.async(group: group) {[weak self] in
				guard let self else {
					group.leave()
					return
				}

				MONetDataServer.shared().annotationDetail(withResultId: result_id, metaDataId: meta_data_id)  { dict in
					
					self.detailData = MOAnnotationDetailModel.yy_model(withJSON: dict as Any)
					if self.detailData?.audio_slice == nil {
						self.detailData?.audio_slice = []
					}
					group.leave()
					
				} failure: { error in
					errorMsg = error?.localizedDescription
					DispatchQueue.main.async {
						
						self.showErrorMessage(error?.localizedDescription)
					}
					group.leave()
					
				} msg: { msg in
					errorMsg = errorMsg
					DispatchQueue.main.async {
						self.showErrorMessage(msg)
					}
					group.leave()
					
				} loginFail: {
					DispatchQueue.main.async {
						self.hidenActivityIndicator()
					}
					group.leave()
				}
			}
			
			group.enter()
			queue.async(group: group) {[weak self] in
				guard let self else {
					group.leave()
					return
				}
				MONetDataServer.shared().cateOptionProcessProperty { dict in
					let datalist = NSMutableArray.yy_modelArray(with: MOAudioProcessPropertyModel.self, json: dict as Any) as? [MOAudioProcessPropertyModel] ?? []
					
					var bindProperty:[MOAudioProcessPropertyModel] = []
					for item in datalist {
						if let cate_alias =  item.cate_alias, self.bindProperty.contains(cate_alias) {
							bindProperty.append(item)
						}
					}
					self.processPropertyList = bindProperty
					group.leave()
				} failure: { error in
					errorMsg = error?.localizedDescription
					DispatchQueue.main.async {
						self.showErrorMessage(error?.localizedDescription)
					}
					group.leave()
				} msg: { msg in
					errorMsg = msg
					DispatchQueue.main.async {
						self.showErrorMessage(msg)
					}
					group.leave()
				} loginFail: {
					DispatchQueue.main.async {
						self.hidenActivityIndicator()
					}
					group.leave()
				}
				
			}
			
			group.wait()
			group.enter()
			queue.async(group: group) {[weak self] in
				guard let self else {
					group.leave()
					return
				}
				
				if let url = URL(string: self.detailData?.path ?? "") {

					MOAudioDownloader.shared.downloadAudio(from: url) {[weak  self] url1, error in
						self?.detailData?.localCachePath = url1?.absoluteString
						DLog("url:\(String(describing: url1?.absoluteString))")
						group.leave()
					}
					return
				}
				
				group.leave()
				
			}
			
			
			group.wait()
			group.enter()
			queue.async(group: group) {[weak self] in
				guard let self else {
					group.leave()
					return
				}
				
				if let localCachePathUrl = URL(string: detailData?.localCachePath ?? "") {
					MOAudioVolumeAnalyzerOC.shared().getVolumePer10ms(forFilePath: localCachePathUrl) { _ in
						
					} completion: { (dict:[NSNumber : NSNumber], error) in
						DLog("dataList.count :\(dict)")
						let sortedKeys = dict.keys.sorted { $0.intValue < $1.intValue }
						let sortedValues = sortedKeys.map { dict[$0]!.intValue }
						self.detailData?.sound_decibels = sortedValues
						group.leave()
					}
					return
				}
				
				group.leave()
				
			}
			
			group.notify(queue:queue) {[weak self] in
				guard let self else {return}
				DispatchQueue.main.sync {
					self.hidenActivityIndicator()
					if let errorMsg {
						self.showMessage(errorMsg)
						return
					}
					
					if processPropertyList == nil {
						self.showMessage(NSLocalizedString("音频属性配置异常", comment: ""))
						return
					}
					if detailData?.localCachePath == nil {
						self.showMessage(NSLocalizedString("音频文件下载失败", comment: ""))
						return
					}
					
					self.disassembleAudioAttributes()
					self.setupUI()
					self.setupConstraints()
					self.addAtcions()
					self.tableView.reloadData()
				}
				
			}
		}
		
    }
	
	func requestSaveData(status:Int = 1){
		
		
		guard let audio_slice = self.detailData?.audio_slice else {
			
			self.showMessage(NSLocalizedString("请先添加编辑片段", comment: ""))
			return
		}
		
		if audio_slice.count == 0 {
			self.showMessage(NSLocalizedString("请先添加编辑片段", comment: ""))
			return
		}
		
		let modelsArray = NSMutableArray()
		for item in audio_slice {
			let model = NSMutableDictionary()
			model.setValue(item.model_id, forKey: "id")
			model.setValue(item.is_valid, forKey: "is_valid")
			model.setValue(item.start_time, forKey: "start_time")
			model.setValue(item.end_time, forKey: "end_time")
			if item.is_valid {
				model.setValue(item.audio_text, forKey: "audio_text")
				model.setValue(item.audio_property, forKey: "audio_property")
				model.setValue(item.remark, forKey: "remark")
				if let audio_property_original = item.audio_property_original {
					let propertyList = MOPorcessingAudioVC.montagePropertyData(audio_property_original: audio_property_original)
					let ocArray = NSMutableArray(array: propertyList)
					model.setValue(ocArray, forKey: "audio_property")
				}
				
				let tags = NSMutableArray(array: item.tags ?? [])
				model.setValue(tags, forKey: "tags")
			} else {
				model.setValue(item.invalid_reason, forKey: "invalid_reason")
			}
			modelsArray.add(model)
		}
		
		var audioData = modelsArray.yy_modelToJSONString()
		if let data = audioData?.data(using: .utf8) {
			audioData = data.base64EncodedString()
		}
		self.showActivityIndicator()
		MONetDataServer.shared().annotationSave(withResultId: self.result_id, metaDataId: self.meta_data_id, status: status, audioData: audioData) {
			self.hidenActivityIndicator()
			if status == 1 {
				self.showMessage(NSLocalizedString("提交成功", comment: ""))
				self.didSubmitData?()
			} else {
				self.showMessage(NSLocalizedString("保存成功", comment: ""))
			}
			MOAppDelegate().transition.popViewController(animated: true);
			
		} failure: { _ in
			self.hidenActivityIndicator()
		} msg: { msg in
			self.hidenActivityIndicator()
		} loginFail: {
			self.hidenActivityIndicator()
		}

	}
	func requestSpeechToText(segmentData:MOAudioClipSegmentCustomModel) {
		self.showActivityIndicator()
		MONetDataServer.shared().speechToText(withDataId: self.meta_data_id, startTime: Int(segmentData.start_time), endTime: Int(segmentData.end_time)) { text in
			self.hidenActivityIndicator()
			self.showMessage(NSLocalizedString("转译成功", comment: ""))
			segmentData.audio_text = text
			self.tableView.reloadData()
		} failure: { error in
			self.hidenActivityIndicator()
			self.showErrorMessage(error?.localizedDescription)
		} msg: { msg in
			self.hidenActivityIndicator()
			self.showErrorMessage(msg)
		} loginFail: {
			self.hidenActivityIndicator()
		}

	}
	func requestDeleteAudioAnnotation(index:Int) {
		
		guard let model =  detailData?.audio_slice?[index] else {
			self.showMessage(NSLocalizedString("删除失败", comment: ""))
			return
		}
		
		if model.model_id == 0 {
			
			detailData?.audio_slice?.remove(at: index)
			
			if let detailData {
				//耗时严重
//				self.tableHeaderView.configView(taskTitle: taskTitle, datailModel: detailData)
				self.tableHeaderView.waveView.updateMaskViews(datetailData:detailData)
			}
			
			self.tableView.reloadData()
			return
		}
		
		self.showActivityIndicator()
		MONetDataServer.shared().deleteAudioAnnotation(withId: Int(model.model_id)) { _ in
			
			self.hidenActivityIndicator()
			self.detailData?.audio_slice?.remove(at: index)
			self.tableView.reloadData()
			if let detailData =  self.detailData {
				self.tableHeaderView.waveView.updateMaskViews(datetailData:detailData)
			}
			
			self.showMessage(NSLocalizedString("删除成功", comment: ""))
		} failure: { error in
			self.hidenActivityIndicator()
			self.showErrorMessage(error?.localizedDescription)
		} msg: { msg in
			self.hidenActivityIndicator()
			self.showErrorMessage(msg)
		} loginFail: {
			self.hidenActivityIndicator()
		}

	}
	
	init(result_id:Int,meta_data_id:Int,taskTitle:String,property:[String]){
		self.result_id = result_id
		self.meta_data_id = meta_data_id
		self.taskTitle = taskTitle
		self.bindProperty = property
		super.init(nibName: nil, bundle: nil)
	}
	
	func canEditData()->Bool{
		
		return detailData?.status == 0 ||  detailData?.status == 3
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initializationUI(){
		navBar.gobackDidClick = {
			MOAppDelegate().transition.popViewController(animated: true)
		}
		view.addSubview(navBar)
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initializationUI()
        requestData()
    }
}


//MARK: 本地类工具方法
extension MOPorcessingAudioVC {
	
	static func setupChildrenProperty(value: String, children: [MOAudioProcessPropertyModel]) {
		let components = value.split(separator: "-").compactMap { Int($0) }
		
		for itemValue in components {
			// 递归处理所有层级的子元素
			processChildren(children: children, targetId: itemValue)
		}
	}
	static func processChildren(children: [MOAudioProcessPropertyModel], targetId: Int) {
		for child in children {
			if child.value == targetId {
				child.isSelected = true
			}
			
			// 递归处理当前 child 的子元素（如果有）
			if let subChildren = child.children {
				processChildren(children: subChildren, targetId: targetId)
			}
		}
	}
	
	
	static func getPropertySelectData(children:[MOAudioProcessPropertyModel])->[String] {
		
		var selectData:[String] = []
		for item in children {
			if item.isSelected,let name = item.name {
				selectData.append(name)
			}
			if item.isSelected,let childr = item.children {
				selectData.append(contentsOf: MOPorcessingAudioVC.getPropertySelectData(children: childr))
			}
		}
		
		return selectData
	}
	
	static func getPropertySelectValue(children:[MOAudioProcessPropertyModel])->[Int] {
		
		var selectValue:[Int] = []
		for item in children {
			if item.isSelected {
				selectValue.append(item.value)
			}
			if item.isSelected,let childr = item.children {
				selectValue.append(contentsOf: MOPorcessingAudioVC.getPropertySelectValue(children: childr))
			}
		}
		
		return selectValue
	}
	static func montagePropertyData(audio_property_original:[MOAudioProcessPropertyModel])->[NSMutableDictionary] {
		
		var propertyList:[NSMutableDictionary] = []
		for item in audio_property_original {
			if item.isSelected {
				let property = NSMutableDictionary()
				property.setValue(item.cate_alias, forKey: "name")
				let selectData =  MOPorcessingAudioVC.getPropertySelectData(children: item.children ?? [])
				
				property.setValue(selectData.joined(separator: "-"), forKey: "selectData")
				let selectValue = MOPorcessingAudioVC.getPropertySelectValue(children: item.children ?? [])
				let selectValueStr = selectValue.map(String.init).joined(separator: "-")
				property.setValue(selectValueStr, forKey: "value")
				propertyList.append(property)
				
			}
		}
		
		return propertyList
	}
}

extension MOPorcessingAudioVC:UITableViewDataSource,UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
		let dataListCount = detailData?.audio_slice?.count ?? 0
		let showAdd = self.canEditData() ? 1 : 0
		return dataListCount == 0 ? showAdd: dataListCount + showAdd
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if let audio_slice = self.detailData?.audio_slice,section < audio_slice.count, audio_slice.count > 0 {
			let vi = MOView()
			vi.backgroundColor = ClearColor
			return vi
		}
        
        let vi = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MOPorcessingDataPSHView")
        guard let vi = vi as? MOPorcessingDataPSHView  else {
            return vi
        }
        vi.addBtnDidClick = {[weak self] in
            guard let self else {return}
            self.addAudioSegmentation()
        }
        return vi
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
		if let audio_slice = self.detailData?.audio_slice,section < audio_slice.count, audio_slice.count > 0 {
			
			return CGFLOAT_MIN
		}
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
		if let audio_slice = self.detailData?.audio_slice,section < audio_slice.count, audio_slice.count > 0 {
			let segmengData = audio_slice[section]
			if segmengData.isExpand && segmengData.is_valid {
				return 6
			}
			if segmengData.isExpand && !segmengData.is_valid {
				return 3
			}
			
			return 1
		}
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
		let segmengData = self.detailData?.audio_slice?[indexPath.section]
        if indexPath.row == 0 {
            return 60
        }
		if indexPath.row == 1 {
			return 60
		}
		if indexPath.row == 2  {
			
			if segmengData?.is_valid == true {
				return 80
			}
			return segmengData?.invalid_reason_height ?? 199
        }
        if indexPath.row == 3 {
			
			return segmengData?.audio_text_height ?? 100
        }
        
        if indexPath.row == 4 {
            return 80
        }
		return segmengData?.remark_height ?? 100
		
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
		let segmengData = self.detailData?.audio_slice?[indexPath.section]
        var identifier = ""
		
		if indexPath.row == 0 {
			identifier = "MOPorcessingAudioSegmentCell"
		}
		
        if indexPath.row == 1 {
            identifier = "MOAudioInvalidCell"
        }
        
        if indexPath.row == 2 {
            identifier = "MOAudioAttributeCell"
			if let segmengData,!segmengData.is_valid {
				identifier = "MOProcessingAudioinvalidReasonCell"
			}
        }
        if indexPath.row == 3 {
            identifier = "MOAudioToTextCell"
        }
        if indexPath.row == 4 {
            identifier = "MOAudioAttributeCell"
        }
        if indexPath.row == 5 {
            identifier = "MOProcessingNotesCell"
        }
		
		
		
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
		if let cell0 = cell as? MOPorcessingAudioSegmentCell,let segmengData  = segmengData {
			cell0.configCell(segmentData: segmengData, index: indexPath.section)
			cell0.expandBtnDidClick = {[weak self] isExpand in
				guard let self else {return}
				segmengData.isExpand = isExpand
				self.tableView.reloadData()
			}
		}
		
		if indexPath.row > 0 {
			cell?.isUserInteractionEnabled = self.canEditData()
		}
		
		if let cell1 = cell as? MOAudioInvalidCell,let segmengData  = segmengData {
			cell1.rightswitch.isOn = segmengData.is_valid
			cell1.switchValueChanged = {[weak self] in
				guard let self else {return}
				segmengData.is_valid = $0
				self.tableView.reloadData()
				
			}
			
		}
		
		if let cell2 = cell as? MOAudioAttributeCell,indexPath.row == 2,let segmengData {
			cell2.titleLabel.text = NSLocalizedString("音频属性", comment: "")
			cell2.subTitleLabel.text = NSLocalizedString("准确填写音频属性，有机会获得更多加工数据奖励", comment: "")
			cell2.configCellAttibueValue(model: segmengData)
			
		}
		
		
		if let cell2 = cell as? MOProcessingAudioinvalidReasonCell,let segmengData {
			cell2.configCell(textStr: segmengData.invalid_reason)
			cell2.textdidChanged = {
				segmengData.invalid_reason = $0
				
			}
			cell2.textViewHeightdidChanged = {
				segmengData.invalid_reason_height = $0
				UIView.animate(withDuration: 0) {
					tableView.beginUpdates()
					tableView.endUpdates()
				}
				
			}
			
		}
		
		if let cell3 = cell as? MOAudioToTextCell,let segmengData {
			cell3.configCell(textStr: segmengData.audio_text)
			cell3.textdidChanged = {
				segmengData.audio_text = $0
				
			}
			cell3.audioToTextBtnClick = {[weak self] in
				guard let self else {return}
				view.endEditing(true)
				requestSpeechToText(segmentData: segmengData)
			}
			cell3.textViewHeightdidChanged = {
				segmengData.audio_text_height = $0
				UIView.animate(withDuration: 0) {
					tableView.beginUpdates()
					tableView.endUpdates()
				}
				
			}
		}
		
        if let cell4 = cell as? MOAudioAttributeCell,indexPath.row == 4,let segmengData {
			cell4.titleLabel.text = NSLocalizedString("音频标签", comment: "")
			cell4.subTitleLabel.text = NSLocalizedString("准确添加音频标签，有机会获得更多加工数据奖励", comment: "")
			cell4.configCellTagsValue(model: segmengData)
        }
		
		if let cell5 = cell as? MOProcessingNotesCell,let segmengData {
			cell5.configCell(textStr: segmengData.remark)
			cell5.textdidChanged = {
				segmengData.remark = $0
				
			}
			
			cell5.textViewHeightdidChanged = {
				segmengData.remark_height = $0
				UIView.animate(withDuration: 0) {
					tableView.beginUpdates()
					tableView.endUpdates()
				}
			}
			
		}
		
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 4 {
			addAudioTag(index: indexPath.section)
        }
        if indexPath.row == 2 {
			addAudioAttribute(index: indexPath.section)
        }
    }
    
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		if indexPath.row == 0 {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		
		return .delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		requestDeleteAudioAnnotation(index:indexPath.section)
		
	}
}
