//
//  MOAllCountryCode.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

import Foundation

@objcMembers class MOAllCountryCodeVC: MOBaseViewController {
    
    private lazy var dataList:NSArray? = nil
    public var didSelected:((_ index:Int,_ countryCode:Int)->Void)?
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("选择国家和地区", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.plain)
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
    
    func setupUI(){
        view.addSubview(navBar)
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MOCountryCodeCell.self, forCellReuseIdentifier: "MOCountryCodeCell")
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.bottom.equalTo(view)
        }
    }
    
    func loadRequest(){
        
        self.showActivityIndicator()
        MONetDataServer.shared().getCountryCode { (dict:[Any]?) in
            self.hidenActivityIndicator()
            let list:NSArray =  NSArray.yy_modelArray(with: MOCountryCodeModel.self, json: dict as Any)! as  NSArray
            let sectionTitles:NSMutableArray = NSMutableArray()
            for _ in UILocalizedIndexedCollation.current().sectionTitles {
                sectionTitles.add(NSMutableArray())
            }
            for model  in list  {
                let tmpModel:MOCountryCodeModel = model as! MOCountryCodeModel
                let sectionIndex:Int = UILocalizedIndexedCollation.current().section(for: tmpModel, collationStringSelector: #selector(getter: MOCountryCodeModel.name))
                let subArr:NSMutableArray = sectionTitles[sectionIndex] as! NSMutableArray
                subArr.add(model)
            }
            
            for subArr in sectionTitles {
                let tmpSubArr = subArr as! NSMutableArray
                let sorArr:NSArray = UILocalizedIndexedCollation.current().sortedArray(from: tmpSubArr as! [Any], collationStringSelector: #selector(getter: MOCountryCodeModel.name)) as NSArray
                tmpSubArr.removeAllObjects()
                tmpSubArr.addObjects(from: sorArr as! [Any])
            }
            
            self.dataList = sectionTitles
            self.tableView.reloadData()
        } failure: { (error:Error?) in
            self.hidenActivityIndicator()
        } msg: { (msg:String?) in
            self.hidenActivityIndicator()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI();
        loadRequest()
    }
}


extension MOAllCountryCodeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let setcion:NSMutableArray = dataList?[section] as! NSMutableArray
        return setcion.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let vi:MOView = MOView()
        vi.backgroundColor = ClearColor
        
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi:MOView = MOView()
        vi.backgroundColor = WhiteColor
        let title =  UILocalizedIndexedCollation.current().sectionTitles[section]
        let lable:UILabel = UILabel.init(text: title, textColor: MainSelectColor!, font: MOPingFangSCHeavyFont(15))
        lable.frame = CGRect(x: 10, y: 0, width: SCREEN_WIDTH, height: 20)
        vi.addSubview(lable)
        return vi
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MOCountryCodeCell = tableView.dequeueReusableCell(withIdentifier: "MOCountryCodeCell")! as! MOCountryCodeCell
        
        let setcionArray:NSMutableArray = self.dataList![indexPath.section] as! NSMutableArray
        let model:MOCountryCodeModel = setcionArray[indexPath.row] as! MOCountryCodeModel
        cell.leftLabel.text = model.name
        cell.rightLabel.text = "+\(model.value)"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let setcionArray:NSMutableArray = self.dataList![indexPath.section] as! NSMutableArray
        let model:MOCountryCodeModel = setcionArray[indexPath.row] as! MOCountryCodeModel
        if didSelected != nil {
            didSelected!(indexPath.row,model.value)
        }
        MOAppDelegate().transition.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) ->[String]? {
        
        return UILocalizedIndexedCollation.current().sectionTitles
    }
    
}
