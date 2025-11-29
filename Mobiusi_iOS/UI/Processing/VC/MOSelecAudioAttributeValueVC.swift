//
//  MOSelecAudioAttributeValueVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOSelecAudioAttributeValueVC:MOBaseViewController {
	var dataList:[MOAudioProcessPropertyModel]
	//点击右上角返回上一个页面
    var didClose:(()->Void)?
	//最后一个页面选中是，递归关闭所有页面
	var onFinalChoicedDismiss: (() -> Void)?
	var selectdeIndex:Int = -1
    lazy var customView = {
        let vi  = MOView()
        vi.backgroundColor = WhiteColor
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
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.plain)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorColor = ColorF2F2F2
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.backgroundColor = ClearColor
        tableView.sectionIndexColor = ColorAFAFAF
        tableView.sectionIndexBackgroundColor = ClearColor
        tableView.sectionIndexTrackingBackgroundColor = ClearColor
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Bottom_SafeHeight, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
	
	
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(customView)
        navBar.rightItemsView.addArrangedSubview(closeBtn)
        customView.addSubview(navBar)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MOAudioAttributeOptionValueCell.self, forCellReuseIdentifier: "MOAudioAttributeOptionValueCell");
        customView.addSubview(tableView)
        tableView.observeValue(forKeyPath: "contentSize") { [weak self] (dict:[AnyHashable : Any], object:Any) in
            guard let self else {return}
            let size:CGSize = dict["new"] as! CGSize
            if size.height != self.tableView.bounds.height {
                tableView.snp.remakeConstraints { make in
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalTo(navBar.snp.bottom)
                    make.height.equalTo(size.height + tableView.contentInset.top + tableView.contentInset.bottom).priority(800)
					make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
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
            make.height.equalTo(398)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
        }
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
        
        
        self.hidden {
            self.didClose?()
            self.dismiss(animated: false) {
                
            }
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
	
	
	static func setunSelectValue(model:MOAudioProcessPropertyModel){
		
		model.isSelected = false
		if let children = model.children {
			for item in children {
				MOSelecAudioAttributeValueVC.setunSelectValue(model: item)
			}
		}
	}
	
	
	@objc func finalChoiced(){
		
		for (index,subModel) in dataList.enumerated() {
			if index != selectdeIndex {
				MOSelecAudioAttributeValueVC.setunSelectValue(model: subModel)
			}
			
		}
		let model = dataList[selectdeIndex]
		model.isSelected = true
		
	}
    
    
	class func createAlertStyle(title:String,dataList:[MOAudioProcessPropertyModel])->MOSelecAudioAttributeValueVC{
        let vc = MOSelecAudioAttributeValueVC(title: title,dataList: dataList)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    init(title:String,dataList:[MOAudioProcessPropertyModel]) {
		self.dataList = dataList
        super.init(nibName: nil, bundle: nil)
        self.navBar.titleLabel.text = title
		
		for (index,item) in dataList.enumerated() {
			if item.isSelected {
				self.selectdeIndex = index
			}
		}
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


extension MOSelecAudioAttributeValueVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		let subModel = dataList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MOAudioAttributeOptionValueCell")
        if let cell1 = cell as? MOAudioAttributeOptionValueCell {
			cell1.titleLabel.text = subModel.name
			if selectdeIndex == indexPath.row {
				cell1.showSelected()
			} else {
				cell1.showNormal()
			}
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		selectdeIndex = indexPath.row
		
		let subModel = dataList[indexPath.row]
		let cell = tableView.cellForRow(at: indexPath)
		if let cell1 = cell as? MOAudioAttributeOptionValueCell {
			cell1.rightImageView.isHidden = false
		}
		if let children =  subModel.children,children.count > 0 {
			let vc = MOSelecAudioAttributeValueVC.createAlertStyle(title: subModel.name ?? "",dataList: children)
			vc.didClose = {[weak self] in
				guard let self else {return}
				self.view.isHidden = false
				self.show()
				
			}
			
			vc.onFinalChoicedDismiss = {[weak self] in
				guard let self else {return}
				self.dismiss(animated: false)
			}
			
			self.hidden {[weak self] in
				guard let self else {return}
				self.view.isHidden = true
				self.present(vc, animated: false) {
					vc.show()
				}
			}
		} else {
			self.hidden {
				NotificationCenter.default.post(name: NSNotification.Name.MOProcessAttributeFinalChoiced, object: nil)
				self.dismiss(animated: false)
				self.onFinalChoicedDismiss?()
			}
			
		}
		
    }

}

extension NSNotification.Name {
	static let MOProcessAttributeFinalChoiced = Notification.Name("MOProcessAttributeFinalChoiced")
}
