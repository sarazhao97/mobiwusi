//
//  MODataPartnerVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MODataPartnerVC: MOBaseViewController {
    
    var dataModel:MOLevelInfoResModel?
    var pointdRuleBtn:MOButton = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("积分规则", comment: ""), titleColor: MainSelectColor!, bgColor: ClearColor, font: MOPingFangSCBoldFont(12))
        btn.fixAlignmentBUG()
        return btn
    }()
    var cellDataList:[[MOTableViewCell]] = []
    private lazy var topBGImageView:MOHorizontalGradientView = {
        let imageView = MOHorizontalGradientView(colors: [Color9A1E2E!,ColorFF8585!.withAlphaComponent(0)])
        return imageView
    }();
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("数据合伙人", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        return navBar
    }();
    
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
        tableView.register(MODataPartnerLevelCell.self, forCellReuseIdentifier: "MODataPartnerLevelCell")
        tableView.register(MODataPartnerSignInCell.self, forCellReuseIdentifier: "MODataPartnerSignInCell")
        tableView.register(MODataPartnerTaskCell.self, forCellReuseIdentifier: "MODataPartnerTaskCell")
        
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
    func setupUI(){
        view.addSubview(topBGImageView)
        navBar.gobackDidClick = {
            
            MOAppDelegate().transition.popViewController(animated: true)
        }
        navBar.rightItemsView.addArrangedSubview(pointdRuleBtn)
        view.addSubview(navBar)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupConstraints(){
        topBGImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(210)
            
        }
        
        navBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func addCellDataList(){
        
        var section0:[MOTableViewCell] = []
        let section0Cell0 = tableView.dequeueReusableCell(withIdentifier: "MODataPartnerLevelCell") as! MODataPartnerLevelCell
        if  let model = dataModel {
            section0Cell0.configCell(model: model)
        }
        
        section0.append(section0Cell0 as MOTableViewCell)
        
        let section0Cell1 = tableView.dequeueReusableCell(withIdentifier: "MODataPartnerSignInCell") as! MODataPartnerSignInCell
        section0Cell1.didSelectedDate = {[weak self] (index,isToday,isYesterday)in
            guard let self else { return}
            if !isToday && !isYesterday {
                return
            }
            if let weekModel = self.dataModel?.week_data?[index],weekModel.status == 0 {
                self.signIn(weekModel: weekModel)
            }
        }
        
        if  let model = dataModel {
            section0Cell1.configCell(model: model)
        }
        
        section0.append(section0Cell1 as MOTableViewCell)
        
        cellDataList.append(section0)
        
        var section1:[MOTableViewCell] = []
        let section1Cell0 = tableView.dequeueReusableCell(withIdentifier: "MODataPartnerTaskCell") as! MODataPartnerTaskCell
        section1Cell0.configCell(imageName: "icon_daily_tasks", taskTitle: NSLocalizedString("每日任务：数据任务", comment: ""), tagName: "文本", pointsFormatValue: "+5")
        section1Cell0.didCickDoBtn = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        section1.append(section1Cell0 as MOTableViewCell)
        cellDataList.append(section1)
        
        var section2:[MOTableViewCell] = []
        
        if let taskData = dataModel?.taskdata {
            for taskModel in taskData {
                let section2Cell = tableView.dequeueReusableCell(withIdentifier: "MODataPartnerTaskCell") as! MODataPartnerTaskCell
                
                section2Cell.configCell(taskModel: taskModel)
                section2Cell.didCickDoBtn = {[weak self,taskModel] in
                    guard let self else {return}
                    authenticationTask(taskModel: taskModel)
                }
                section2.append(section2Cell as MOTableViewCell)
            }
        }
        
        cellDataList.append(section2)
    }
    
    func addActions(){
        pointdRuleBtn.addTarget(self, action: #selector(pointdRuleBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func pointdRuleBtnClick(){
        
        MOWebViewController.pushPointsRuleWebVC()
    }
    
    func authenticationTask(taskModel:MOLevelTaskDataModel){
        
        if taskModel.key == "education_auth" {
            let vc = MOEducationCertificationVC()
            vc.didUploadSuccess = {[weak self] in
                taskModel.status = 1
                guard let self else {return}
                cellDataList.removeAll()
                addCellDataList()
                tableView.reloadData()
            }
            MOAppDelegate().transition.push(vc, animated: true)
            return
        }
        
        if taskModel.key == "work_auth" {
            let vc = MOWorkCertificationVC()
            vc.didUploadSuccess = {[weak self] in
                taskModel.status = 1
                guard let self else {return}
                cellDataList.removeAll()
                addCellDataList()
                tableView.reloadData()
            }
            MOAppDelegate().transition.push(vc, animated: true)
            return
        }
        
        if taskModel.key == "driver_auth" {
            let vc = MODriversLicenseCertificationVC()
            vc.didUploadSuccess = {[weak self] in
                taskModel.status = 1
                guard let self else {return}
                cellDataList.removeAll()
                addCellDataList()
                tableView.reloadData()
            }
            MOAppDelegate().transition.push(vc, animated: true)
            return
        }
        
        if taskModel.key == "identity_auth" {
            let vc = GIRealNameAuthenticationVC()
            vc.didUploadSuccess = {[weak self] in
                taskModel.status = 1
                guard let self else {return}
                cellDataList.removeAll()
                addCellDataList()
                tableView.reloadData()
            }
            MOAppDelegate().transition.push(vc, animated: true)
            return
        }
        
    }
    
    func signIn(weekModel:MOLevelWeekDataModel){
        
        self.showActivityIndicator()
        MONetDataServer.shared().signIn(withDate: weekModel.date) {[weak self] dict in
            guard let self else {return}
            self.hidenActivityIndicator()
            let value = (dict?["value"] as? Int) ?? 0
            let continuous_days = dict?["continuous_days"] ?? 0
            weekModel.status = 1
            if let dataModel {
                dataModel.continuous_days = continuous_days as! Int
                dataModel.mobi_point = dataModel.mobi_point + value
                let levelCount = dataModel.levels?.count ?? 0
                if dataModel.mobi_point > dataModel.level_point, levelCount > 0 {
                    if dataModel.level < levelCount - 1 {
                        if let nextLevel = dataModel.levels?[dataModel.level] {
                            dataModel.mobi_point = dataModel.mobi_point - dataModel.level_point
                            dataModel.level = nextLevel.level
                            dataModel.level_point = nextLevel.point
                        }
                    }
                    
                }
            }
            cellDataList.removeAll()
            addCellDataList()
            tableView.reloadData()
            
            let vc = MOSignInAlertVC.createAlertVC(points: value)
            self.present(vc, animated: true)
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
    
    func loadReqeust(){
        self.showActivityIndicator()
        MONetDataServer.shared().getlevelInfo {[weak self] dict in
            guard let self  else { return}
            self.hidenActivityIndicator()
            dataModel = MOLevelInfoResModel.yy_model(withJSON: dict as Any)
            DLog("\(String(describing: dataModel))")
            
            addCellDataList()
            tableView.reloadData()
            
        } failure: { error in
            
        } msg: { msg in
            
        } loginFail: {
            
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
//        tableView.reloadData()
        loadReqeust()
    }
}


extension MODataPartnerVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return cellDataList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArray = cellDataList[section]
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sectionArray = cellDataList[indexPath.section]
        let cell = sectionArray[indexPath.row]
        
        if let cell1 = cell as? MODataPartnerLevelCell {
            
            return cell1.cellHeight
        }
        
        if let cell2 = cell as? MODataPartnerSignInCell {
            
            return cell2.cellHeight
        }
        
        if let cell3 = cell as? MODataPartnerTaskCell {
            
            return cell3.cellHeight
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let sectionArray = cellDataList[indexPath.section]
        return sectionArray[indexPath.row] as UITableViewCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let vc = MOWorkCertificationVC()
//        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    
}
