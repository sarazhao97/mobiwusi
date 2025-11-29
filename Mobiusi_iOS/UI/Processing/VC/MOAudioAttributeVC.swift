//
//  MOAudioAttributeVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioAttributeVC:MOBaseViewController {
	var processPropertyList:[MOAudioProcessPropertyModel]
	var  didSaveData:((_ processPropertyList:[MOAudioProcessPropertyModel])->Void)?
	
    lazy var customView = {
        let vi  = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.top, radius: 16)
        return vi
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("标签", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        navBar.backBtn.isHidden = true
        navBar.customStatusBarheight(20)
        return navBar
    }();
    lazy var closeBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_nav_close"))
        return btn
    }()
    
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.insetGrouped)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorColor = ColorF2F2F2
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.backgroundColor = ClearColor
        tableView.sectionIndexColor = ColorAFAFAF
        tableView.sectionIndexBackgroundColor = ClearColor
        tableView.sectionIndexTrackingBackgroundColor = ClearColor
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
    
    
    lazy var bottomView = {
        let vi = MOBottomBtnView()
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    func setBottomBtnNormalStyle(){
        bottomView.bottomBtn.setTitle(NSLocalizedString("保存", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!,font: MOPingFangSCBoldFont(16))
        bottomView.bottomBtn.cornerRadius(QYCornerRadius.all, radius: 14)
    }
    
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(customView)
        navBar.rightItemsView.addArrangedSubview(closeBtn)
        customView.addSubview(navBar)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PersonCenterType1Cell.self, forCellReuseIdentifier: "PersonCenterType1Cell");
        customView.addSubview(tableView)
        customView.addSubview(bottomView)
        setBottomBtnNormalStyle()
		bottomView.didClick = {[weak self] in
			guard let self else {return}
			self.hidden {
				self.didSaveData?(self.processPropertyList)
				self.dismiss(animated: false)
			}
			
		}
		
		tableView.observeValue(forKeyPath: "contentSize") { [weak self] (dict:[AnyHashable : Any], object:Any) in
			guard let self else {return}
			let size:CGSize = dict["new"] as! CGSize
			if size.height != self.tableView.bounds.height {
				tableView.snp.remakeConstraints { make in
					make.left.equalToSuperview()
					make.right.equalToSuperview()
					make.top.equalTo(navBar.snp.bottom)
					make.height.equalTo(size.height + tableView.contentInset.top + tableView.contentInset.bottom).priority(800)
				}
			}
		}
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(finalChoiced), name: NSNotification.Name.MOProcessAttributeFinalChoiced, object: nil)
        
    }
    
    
    func setupConstraints(){
        
        customView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        navBar.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        closeBtn.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }
        bottomView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        bottomView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
		
        self.hidden {
            self.dismiss(animated: true)
        }
    }
    
    func hidden(complete:(()->Void)?){
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            complete?()
        }
        
    }
    
    
    func show(){
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview().offset(STATUS_BAR_Height_CODE())
                make.bottom.equalToSuperview()
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            
        }
    }
	
	
	@objc func finalChoiced(){
		
		self.view.isHidden = false
		self.show()
		self.tableView.reloadData()
		self.dismiss(animated: false)
		
	}
	
	func FormatResult(model:MOAudioProcessPropertyModel)->String? {
		
		
		let resultStr = ""
		var nameList:[String] = []
		if let children = model.children {
			for item in children {
				for item1 in MOAudioAttributeVC.getAllSelectedItems(model: item) {
					nameList.append(item1.name ?? "")
				}
			}
		}
		if nameList.count > 0 {
			return nameList.joined(separator: "-")
		}
		
		return nil
		
		
	}
	
	static func getAllSelectedItems(model:MOAudioProcessPropertyModel) -> [MOAudioProcessPropertyModel] {
		var result: [MOAudioProcessPropertyModel] = []
		// 如果当前节点被选中，加入结果集
		if model.isSelected {
			result.append(model)
		}
			// 递归处理子节点
		if let children = model.children {
			for child in children {
				result.append(contentsOf: MOAudioAttributeVC.getAllSelectedItems(model: child))
			}
		}
			
		return result
	}
    
    
    class func createAlertStyle(processPropertyList:[MOAudioProcessPropertyModel])->MOAudioAttributeVC{
		let vc = MOAudioAttributeVC(processPropertyList:processPropertyList)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
	
	init(processPropertyList:[MOAudioProcessPropertyModel]) {
		self.processPropertyList = processPropertyList
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
    }
    
}


extension MOAudioAttributeVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return processPropertyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		let subList = processPropertyList[indexPath.row]
		let subTitle = FormatResult(model: subList)
		if subTitle != nil {
			subList.isSelected = true
		}
		let cell = PersonCenterType1Cell.dequeueReusableCell(tableView: tableView, identifier: "PersonCenterType1Cell", title: subList.name ?? "", subTitle: subTitle ?? "请选择")
		guard let cell  else{
			return PersonCenterType1Cell.init(style: .default, reuseIdentifier: "PersonCenterType1Cell")
		}
		return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
		let subList = processPropertyList[indexPath.row]
		if let children = subList.children {
			
			let vc = MOSelecAudioAttributeValueVC.createAlertStyle(title: subList.name ?? "",dataList: children)
			vc.didClose = {[weak self] in
				guard let self else {return}
				self.view.isHidden = false
				self.show()
				
			}
			self.hidden {[weak self] in
				guard let self else {return}
				self.view.isHidden = true
				self.present(vc, animated: false) {
					vc.show()
				}
			}
		}
		
        
    }
    
}
