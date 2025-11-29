//
//  MOThirdPartyLoginManagement.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/1.
//

import Foundation
@objc class MOThirdPartyLoginManagement: MOBaseViewController {
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("登录管理", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.insetGrouped)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.backgroundColor = ClearColor
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
    private lazy var celllDataList:Array<[MOTableViewCell]> = {
        
        return Array()
    }()
    
    
    func wxbind(){
        
        let vc:MOBindingVerificationVC = MOBindingVerificationVC()
        vc.bindType = 1
        vc.bindResultCallBack = {[weak self] in
            self?.refresh()
            self?.getuserInfo{[weak self] in
                self?.refresh()
            }
        }
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    func aliPayBind(){
        
        let vc:MOBindingVerificationVC = MOBindingVerificationVC()
        vc.bindType = 2
        
        vc.bindResultCallBack = {[weak self] in
            self?.refresh()
            self?.getuserInfo{[weak self] in
                self?.refresh()
            }
        }
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    func appleIdBind(){
        
        let vc:MOBindingVerificationVC = MOBindingVerificationVC()
        vc.bindType = 3
        vc.bindResultCallBack = {[weak self] in
            self?.refresh()
            self?.getuserInfo{[weak self] in
                self?.refresh()
            }
        }
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    func getuserInfo(complate:( () -> Void)? = nil) {
        MONetDataServer.shared().getUserInfoSuccess { (dict:[AnyHashable : Any]?) in
            let userModel:MOUserModel = MOUserModel.yy_model(withJSON: dict as Any)!
            userModel.archivedUserModel()
            complate?()
        } failure: { (error:Error?) in
            complate?()
        } msg: { (msg:String?) in
            complate?()
        } loginFail: {
            complate?()
        }

    }
    
    func addCellData() {
        
        var dataList = Array<MOThirdPartyLoginManagementCell>()
        
        let userModel:MOUserModel = MOUserModel.unarchive()
        let cell0:MOThirdPartyLoginManagementCell = tableView.dequeueReusableCell(withIdentifier: "MOThirdPartyLoginManagementCell") as! MOThirdPartyLoginManagementCell
        cell0.iconImageView.image = UIImage.init(namedNoCache: "icon_wx_small")
        cell0.leftLabel.text = NSLocalizedString("微信", comment: "")
        cell0.rightLabel.text = userModel.openid.count > 0 ?NSLocalizedString("已绑定", comment: ""):NSLocalizedString("去绑定", comment: "")
        cell0.rightLabel.textColor = userModel.openid.count > 0 ?ColorAFAFAF:MainSelectColor
        cell0.didSelectedCell  = { [weak self]cell in
            
            if  userModel.openid.count > 0 {
                
                let alerTipVC = MOUnbindAlertTipVC.showAlert(title: NSLocalizedString("确定要解除绑定吗？", comment: ""), text: NSLocalizedString("解绑后将无法继续使用该微信登录本账号", comment: "")) { alertVC in
                    self?.unbindThirdPartyPlatform(1)
                }
                
                self?.present(alerTipVC, animated: true)
                return
            }
            
            self?.wxbind()
        }
        dataList.append(cell0)
        
        let cell1:MOThirdPartyLoginManagementCell = tableView.dequeueReusableCell(withIdentifier: "MOThirdPartyLoginManagementCell") as! MOThirdPartyLoginManagementCell
        cell1.iconImageView.image = UIImage.init(namedNoCache: "icon_alipay_small")
        cell1.leftLabel.text = NSLocalizedString("支付宝", comment: "")
        cell1.rightLabel.text = userModel.alipay_openid.count > 0 ?NSLocalizedString("已绑定", comment: ""):NSLocalizedString("去绑定", comment: "")
        cell1.rightLabel.textColor = userModel.alipay_openid.count > 0 ?ColorAFAFAF:MainSelectColor
        cell1.didSelectedCell  = {[weak self] cell in
            
            if  userModel.alipay_openid.count > 0 {
                
                let alerTipVC = MOUnbindAlertTipVC.showAlert(title: NSLocalizedString("确定要解除绑定吗？", comment: ""), text: NSLocalizedString("解绑后将无法继续使用该支付宝登录本账号", comment: "")) { alertVC in
                    self?.unbindThirdPartyPlatform(2)
                }
                
                self?.present(alerTipVC, animated: true)
                return
            }
            self?.aliPayBind()
        }
        dataList.append(cell1)
        
        let cell2:MOThirdPartyLoginManagementCell = tableView.dequeueReusableCell(withIdentifier: "MOThirdPartyLoginManagementCell") as! MOThirdPartyLoginManagementCell
        cell2.iconImageView.image = UIImage.init(namedNoCache: "icon_apple_small")
        cell2.leftLabel.text = NSLocalizedString("苹果账号", comment: "")
        cell2.rightLabel.text = userModel.sub.count > 0 ?NSLocalizedString("已绑定", comment: ""):NSLocalizedString("去绑定", comment: "")
        cell2.rightLabel.textColor = userModel.sub.count > 0 ?ColorAFAFAF:MainSelectColor
        cell2.didSelectedCell  = {[weak self] cell in
            
            if  userModel.sub.count > 0 {
                
                let alerTipVC = MOUnbindAlertTipVC.showAlert(title: NSLocalizedString("确定要解除绑定吗？", comment: ""), text: NSLocalizedString("解绑后将无法继续使用该苹果账户登录本账号", comment: "")) { alertVC in
                    self?.unbindThirdPartyPlatform(3)
                }
                
                self?.present(alerTipVC, animated: true)
                return
            }
            self?.appleIdBind()
        }
        dataList.append(cell2)
        self.celllDataList.append(dataList)
        
        
        var dataList2 = Array<MOThirdPartyLoginManagementCell2>()
        let modifyPwdCell:MOThirdPartyLoginManagementCell2 = tableView.dequeueReusableCell(withIdentifier: "MOThirdPartyLoginManagementCell2") as! MOThirdPartyLoginManagementCell2
        modifyPwdCell.leftLabel.text = NSLocalizedString("修改密码", comment: "")
        modifyPwdCell.rightLabel.text = ""
        modifyPwdCell.rightLabel.textColor = userModel.alipay_openid.count > 0 ?ColorAFAFAF:MainSelectColor
        modifyPwdCell.didSelectedCell  = { cell in
            
            MOAppDelegate().transition.push(MOChangePasswordVC(), animated: true)
        }
        dataList2.append(modifyPwdCell)
        self.celllDataList.append(dataList2)
    }
    
    func refresh(){
        
        self.celllDataList.removeAll()
        addCellData()
        tableView.reloadData()
    }
    
    func unbindThirdPartyPlatform(_ type:Int) {
        
        self.showActivityIndicator()
        MONetDataServer.shared().unbindThirdAccount(withAccountType: type) { _ in
            self.hidenActivityIndicator()
            self.showMessage(NSLocalizedString("解绑成功！", comment: ""))
            let userModel:MOUserModel = MOUserModel.unarchive()
            if type == 1 {
                userModel.openid = ""
            }
            if type == 2 {
                userModel.alipay_openid = ""
            }
            if type == 3 {
                userModel.sub = ""
            }
            
            userModel.archivedUserModel()
            self.refresh()
            self.getuserInfo {[weak self] in
                self?.refresh()
            }
        } failure: { (error:Error?) in
            self.hidenActivityIndicator()
            guard let error else {return}
            self.showErrorMessage(error.localizedDescription)
            
        } msg: { (msg:String?) in
            self.hidenActivityIndicator()
            guard let msg else {return}
            self.showErrorMessage(msg)
        } loginFail: {
            self.hidenActivityIndicator()
        }

    }
    
    func setupUI() {
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MOThirdPartyLoginManagementCell.self, forCellReuseIdentifier: "MOThirdPartyLoginManagementCell")
        tableView.register(MOThirdPartyLoginManagementCell2.self, forCellReuseIdentifier: "MOThirdPartyLoginManagementCell2")
        
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.bottom.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCellData()
    }
    
}


extension MOThirdPartyLoginManagement: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return celllDataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let setctionArray:[MOTableViewCell] = celllDataList[section];
        return setctionArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
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
            
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi:MOView = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let setctionArray:[MOTableViewCell] = celllDataList[indexPath.section];
        let cell = setctionArray[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let setctionArray:[MOTableViewCell] = celllDataList[indexPath.section]
        if let cell1 = setctionArray[indexPath.row] as? MOThirdPartyLoginManagementCell {
            
            if cell1.didSelectedCell != nil {
                cell1.didSelectedCell!(cell1)
            }
        }
        
        if let cell2 = setctionArray[indexPath.row] as? MOThirdPartyLoginManagementCell2 {
            
            if cell2.didSelectedCell != nil {
                cell2.didSelectedCell!(cell2)
            }
        }
        
    }
    
}


