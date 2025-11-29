//
//  MOPersonCenterVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/27.
//

import Foundation
import SnapKit
import MessageUI
@objc class MOPersonCenterSFVC: MOBaseViewController {

    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("个人中心", comment: "")
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
    
    
    private lazy var cellDataList:Array<Array<MOTableViewCell>> = {
        
        return Array()
    }();
    
    private  func addCellData(){
        
        let userModel:MOUserModel = MOUserModel.unarchive()
        var setcion0:Array<MOTableViewCell> = Array<MOTableViewCell>()
        
        let cell0setcion0:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell0setcion0.leftLabel.text = NSLocalizedString("头像", comment: "")
        cell0setcion0.rightImage.isHidden = true
        cell0setcion0.rightLargeImage.sd_setImage(with: URL(string: userModel.avatar), placeholderImage: UIImage.init(namedNoCache: "icon_user_avatar"))
        cell0setcion0.rightLargeImage.cornerRadius(QYCornerRadius.all, radius: 6)
        cell0setcion0.didSelectedCell = {[weak self] cell in
            self?.showUploadAvatarSheet()
        }
        setcion0.append(cell0setcion0)
        
        
        let cell1setcion0:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell1setcion0.leftLabel.text = NSLocalizedString("昵称", comment: "")
        cell1setcion0.rightLabel.text = (userModel.name.count != 0) ? userModel.name:userModel.mobile
        cell1setcion0.didSelectedCell = { [weak self] cell in
            self?.modiftyuserNiclName()
        }
        setcion0.append(cell1setcion0)
        
        let cell2setcion0:PersonCenterType2Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType2Cell") as! PersonCenterType2Cell
        cell2setcion0.leftLabel.text = NSLocalizedString("账号", comment: "")
        cell2setcion0.rightLabel.text = userModel.moid
        setcion0.append(cell2setcion0)
        
        let cell3setcion0:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell3setcion0.leftLabel.text = NSLocalizedString("登录管理", comment: "")
        cell3setcion0.didSelectedCell = { cell in
            let vc =  MOThirdPartyLoginManagement()
            MOAppDelegate().transition.push(vc, animated: true)
        }
        setcion0.append(cell3setcion0)
        
        cellDataList.append(setcion0)
        
        var setcion1:Array<MOTableViewCell> = Array<MOTableViewCell>()
        
        let cell0setcion1:PersonCenterType3Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType3Cell") as! PersonCenterType3Cell
        cell0setcion1.rightLabel.text = "\(userModel.zone_size_used_txt)/\(userModel.zone_size_total_txt)"
        cell0setcion1.percentage = CGFloat(Double(userModel.zone_size_used) / Double(userModel.zone_size_total))
        setcion1.append(cell0setcion1)
        
        cellDataList.append(setcion1)
        
        var setcion2:Array<MOTableViewCell> = Array<MOTableViewCell>()
        
        let cell0setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell0setcion2.leftLabel.text = NSLocalizedString("消息通知", comment: "")
        cell0setcion2.didSelectedCell = { cell in
			let vc:MOMessageListVC = MOMessageListVC.init(dataId: 0,dataCate:0,userTaskResultId: 0);
            MOAppDelegate().transition.push(vc, animated: true)
        }
        setcion2.append(cell0setcion2)
        
        let cell1setcion2:PersonCenterType2Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType2Cell") as! PersonCenterType2Cell
        cell1setcion2.leftLabel.text = NSLocalizedString("联系我们", comment: "")
        cell1setcion2.rightLabel.text = "contact@mobiwusi.com"
        cell1setcion2.didSelectedCell = {[weak self] cell in
            if MFMailComposeViewController.canSendMail() {
                
                let mailComposeViewController = MFMailComposeViewController()
                mailComposeViewController.mailComposeDelegate = self
                mailComposeViewController.setSubject(NSLocalizedString("mobiwusi用户反馈", comment: ""))
                mailComposeViewController.setToRecipients(["contact@mobiwusi.com"])
                self?.present(mailComposeViewController, animated: true) {
                }
            } else {
            }
        }
        setcion2.append(cell1setcion2)
        
        let cell2setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell2setcion2.leftLabel.text = NSLocalizedString("意见反馈", comment: "")
        cell2setcion2.didSelectedCell = { cell in
            let storyBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let targetVC = storyBoard.instantiateViewController(withIdentifier: "MOFeedbackViewController")
            MOAppDelegate().transition.push(targetVC, animated: true)
        }
        setcion2.append(cell2setcion2)
        
        
        let cell4setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell4setcion2.leftLabel.text = NSLocalizedString("用户协议", comment: "")
        cell4setcion2.didSelectedCell = { cell in
            MOWebViewController.pushServiceAgreementWebVC()
        }
        setcion2.append(cell4setcion2)
        
        let cell5setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell5setcion2.leftLabel.text = NSLocalizedString("隐私政策", comment: "")
        cell5setcion2.didSelectedCell = {cell in
            MOWebViewController.pushPrivacyAgreementWebVC()
        }
        setcion2.append(cell5setcion2)
        
        let cell6setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell6setcion2.leftLabel.text = NSLocalizedString("检测更新", comment: "")
        cell6setcion2.rightLabel.text = AppToken.getAppVersion()
        cell6setcion2.didSelectedCell = { [weak self] cell in
            self?.checkAppVersion()
        }
        setcion2.append(cell6setcion2)
        
        let cell7setcion2:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as! PersonCenterType1Cell
        cell7setcion2.leftLabel.text = NSLocalizedString("清理缓存", comment: "")
        Task {
            let totalSizeStr = await self.calculateCacheSizeWithCompletion()
            cell7setcion2.rightLabel.text = totalSizeStr
        }
        cell7setcion2.didSelectedCell = { [weak self] cell in
            
            Task {
                await self?.clearCache()
                let totalSizeStr = await self?.calculateCacheSizeWithCompletion()
                (cell as! PersonCenterType1Cell).rightLabel.text = totalSizeStr
            }
        }
        setcion2.append(cell7setcion2)
        
        let cell8setcion2:PersonCenterType2Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType2Cell") as! PersonCenterType2Cell
        cell8setcion2.leftLabel.text = NSLocalizedString("APP备案号", comment: "")
        cell8setcion2.rightLabel.text = NSLocalizedString("浙ICP备2024117967号-2A", comment: "");
        setcion2.append(cell8setcion2)
        
        cellDataList.append(setcion2)
        
        var setcion3:Array<MOTableViewCell> = Array<MOTableViewCell>()
        let cell0setcion3:PersonCenterType4Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType4Cell") as! PersonCenterType4Cell
        cell0setcion3.centerTitleLabel.text = NSLocalizedString("退出登录", comment: "")
        cell0setcion3.didSelectedCell = { cell in
            MOMsgAlertView.show(withTitle: NSLocalizedString("温馨提示", comment: ""), andMsg: NSLocalizedString("确定要退出登录吗？", comment: "")) {
                let user:MOUserModel = MOUserModel.unarchive()
                let userAlias = "user_\(user.modelId)"
                UMessage.removeAlias(userAlias, type: "user") { _, _ in
                    
                }
                MOUserModel.remove()
                MOAppDelegate().transition.popToRootViewController(animated: true)
            }
        }
        setcion3.append(cell0setcion3)
        cellDataList.append(setcion3)
        
        var setcion4:Array<MOTableViewCell> = Array<MOTableViewCell>()
        let cell0setcion4:PersonCenterType4Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType4Cell") as! PersonCenterType4Cell
        cell0setcion4.centerTitleLabel.text = NSLocalizedString("注销账户", comment: "")
        cell0setcion4.didSelectedCell = { [weak self]cell in
            
            MOMsgAlertView.show(withTitle: NSLocalizedString("注销账户", comment: ""), andMsg: NSLocalizedString("请确认您的账户下是否有未完成的任务，待领取待提现的收益等，操作完成后可注销用户。", comment: ""), cancelTitle: NSLocalizedString("我再想想", comment: ""), sureTitle: NSLocalizedString("确认注销", comment: "")) {
                MOMsgAlertView.show(withTitle: NSLocalizedString("再次确认注销账户", comment: ""), andMsg: NSLocalizedString("提交账户注销申请60天内，你仍可登录该账户(登录成功将终止注销流程，但你可重新申请注销):若超过60天未登录，你的账户将被注销且不可恢复，请谨慎操作。", comment: ""), cancelTitle: NSLocalizedString("再想想", comment: ""), sureTitle: NSLocalizedString("确认注销", comment: "")) {
                    self?.showUploadAvatarSheet()
                    MONetDataServer.shared().deleteUserSuccess { _ in
                        self?.hidenActivityIndicator()
                        MOUserModel.remove()
                        self?.showMessage(NSLocalizedString("账号已注销", comment: ""))
                    } failure: { (error:Error?) in
                        self?.hidenActivityIndicator()
                        guard let error else {return}
                        self?.showErrorMessage(error.localizedDescription)
                    } msg: { (msg:String?) in
                        self?.hidenActivityIndicator()
                        guard let msg else {return}
                        self?.showErrorMessage(msg)
                    } loginFail: {
                        self?.hidenActivityIndicator()
                    }

                }
                
            }
            
        }
        setcion4.append(cell0setcion4)
        cellDataList.append(setcion4)
    }
    
    private func setupUI() {
        
        
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
        tableView.register(PersonCenterType1Cell.self, forCellReuseIdentifier: "PersonCenterType1Cell")
        tableView.register(PersonCenterType2Cell.self, forCellReuseIdentifier: "PersonCenterType2Cell")
        tableView.register(PersonCenterType3Cell.self, forCellReuseIdentifier: "PersonCenterType3Cell")
        tableView.register(PersonCenterType4Cell.self, forCellReuseIdentifier: "PersonCenterType4Cell")
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.bottom.equalTo(view)
        }
        
    }
    
    private func calculateCacheSizeWithCompletion() async ->String {
        if let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            // 获取临时目录路径
            let tempPath = NSTemporaryDirectory()
            
            // 定义计算文件夹大小的函数
            func folderSize(atPath path: String) -> UInt64 {
                let fileManager = FileManager.default
                var totalSize: UInt64 = 0
                do {
                    if let contents = fileManager.enumerator(atPath: path) {
                        for case let fileContnet as String in contents {
                            let fullPath = (path as NSString).appendingPathComponent(fileContnet)
                            let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                            let fileSize = attributes[.size]
                            totalSize += fileSize as! UInt64
                        }
                    }
                    
                } catch {
                }
                return totalSize
            }
            
            // 计算总大小
            var totalSize: UInt64 = 0
            totalSize += folderSize(atPath: cachePath)
            totalSize += folderSize(atPath: tempPath)
            
            // 转换为可读字符串
            func formatSize(_ size: UInt64) -> String {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useBytes,.useKB,.useMB, .useGB]
                return ByteCountFormatter.string(fromByteCount: Int64(size),countStyle: ByteCountFormatter.CountStyle.binary)
            }
            
            let sizeString = formatSize(totalSize)
            
            return sizeString
        }
        
        return ""
    }
    
    func showUploadAvatarSheet () {
        
        let imagepicker:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
        imagepicker.allowPickingVideo = false
        imagepicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        imagepicker.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        imagepicker.didFinishPickingPhotosHandle = {[weak self](photos:Array<UIImage>?,assets:Array?,isSelectOriginalPhoto:Bool) in
            
            if let image =  photos?.first{
                self?.uploadUserAvatar(image: image)
            }
        }
        self.present(imagepicker, animated: true, completion: nil)
    }
    
    func clearCache() async {
        
        if let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path {
            // 获取临时目录路径
            let tempPath = NSTemporaryDirectory()
            func clearDirectoryAtPath(path:String){
                
                if let contents = FileManager.default.enumerator(atPath: path){
                    
                    for case let fileContnet as String in contents {
                        let fullPath = (path as NSString).appendingPathComponent(fileContnet)
                        do {
                            try FileManager.default.removeItem(atPath: fullPath)
                        } catch {
                            
                        }
                    }
                    
                }
                
            }
            
            clearDirectoryAtPath(path: cachePath)
            clearDirectoryAtPath(path: tempPath)
            
        }
        
        
        
    }
    
    
    func uploadUserAvatar(image:UIImage) {
        
        self.showActivityIndicator()
        MONetDataServer.shared().uploadImage(image) { [weak self](dic:[AnyHashable : Any]?) in
            
            let relateUrl:String?  = dic?["relative_url"] as? String
            let showUrl:String? = dic?["url"] as? String
            
            MONetDataServer.shared().modifyUserInfo(withUserName: "", avatar: relateUrl, sex: 0, mobile: "", describe: "", native_city: "", native_city_code: "", native_province: "", native_province_code: "") { (dict:[AnyHashable : Any]?) in
                
                self?.hidenActivityIndicator()
                self?.showMessage(NSLocalizedString("头像上传成功", comment: ""))
                let cell0setcion0:PersonCenterType1Cell = self?.cellDataList.first?.first as! PersonCenterType1Cell
                cell0setcion0.rightLargeImage.sd_setImage(with: URL.init(string: showUrl ?? ""), placeholderImage: UIImage.init(namedNoCache: "icon_user_avatar"))
                
                
            } failure: { [weak self] ( error:Error?) in
                self?.hidenActivityIndicator()
                guard let error else {return}
                self?.showErrorMessage(error.localizedDescription)
                
            } msg: { [weak self] ( msg:String?) in
                self?.hidenActivityIndicator()
                guard let msg else {return}
                self?.showErrorMessage(msg)
            } loginFail: {[weak self] in
                self?.hidenActivityIndicator()
            }

            
        } failure: {[weak self] ( error:Error?) in
            self?.hidenActivityIndicator()
            guard let error else {return}
            self?.showErrorMessage(error.localizedDescription)
        } loginFail: {[weak self] in
            self?.hidenActivityIndicator()
        }

    }
    
    
    func modiftyuserNiclName() {
        
        let userModel = MOUserModel.unarchive()

        MOInputAlertView.show(withTitle: NSLocalizedString("修改昵称", comment: ""), andMsg: userModel.name, andPlaceHolder: NSLocalizedString("请输入昵称（不超过8个字）", comment: ""), andMaxCount: 8) {[weak self] (nickName:String?) in
            
            if nickName == nil {
                return
            }
            self?.showActivityIndicator()
            MONetDataServer.shared().modifyUserInfo(withUserName: nickName!, avatar: "", sex: 0, mobile: "", describe: "", native_city: "", native_city_code: "", native_province: "", native_province_code: "") { (dict:[AnyHashable : Any]?) in
                self?.hidenActivityIndicator()
                let cell1setcion0:PersonCenterType1Cell = self?.cellDataList.first?[1] as! PersonCenterType1Cell
                cell1setcion0.rightLabel.text = nickName
                
            } failure: { (error:Error?) in
                self?.hidenActivityIndicator()
                guard let error else {return}
                self?.showErrorMessage(error.localizedDescription)
                
            } msg: { (msg:String?) in
                self?.hidenActivityIndicator()
                guard let msg else {return}
                self?.showErrorMessage(msg)
                
            } loginFail: {
                self?.hidenActivityIndicator()
            }

        }
        
    }
    
    func checkAppVersion() {
        
        self.showActivityIndicator()
        
        let appType:UInt32 = 2
        let appId:UInt32 = 1
        
        self.showActivityIndicator()
        MONetDataServer.shared().checkVersion(withAppType: appType, appId: appId) {(dict:[AnyHashable : Any]?) in
            
            self.hidenActivityIndicator()
            let versionModel:MOCheckVersionModel = MOCheckVersionModel.yy_model(withJSON: dict as Any)!
            if versionModel.ver_name.compare(APPVersionString!) == ComparisonResult.orderedDescending {
                MOMsgAlertView.show(withTitle: NSLocalizedString("升级提醒", comment: ""), andMsg: NSLocalizedString("当前App有新版本是否立即升级", comment: "")) {
                    UIApplication.shared.open(URL.init(string: "https://apps.apple.com/cn/app/%E5%A2%A8%E6%AF%94%E4%B9%8C%E6%96%AF-%E6%95%B0%E6%8D%AE%E5%88%9B%E9%80%A0%E4%BB%B7%E5%80%BC-%E5%8F%82%E4%B8%8Eai%E6%9C%AA%E6%9D%A5/id6737462102")!)
                }
            } else {
                
                self.showMessage(NSLocalizedString("当前app已是最新版本", comment: ""))
            }
            
        } failure: {(error:Error?) in
            self.hidenActivityIndicator()
            guard let error else {return}
            self.showErrorMessage(error.localizedDescription)
        } msg: {(msg:String?) in
            self.hidenActivityIndicator()
            guard let msg else {return}
            self.showErrorMessage(msg)
        } loginFail: {
            self.hidenActivityIndicator()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCellData()
    }
}



extension MOPersonCenterSFVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return cellDataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let setcionCells:Array<MOTableViewCell> = cellDataList[section]
        return setcionCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let setcionCells:Array<MOTableViewCell> = cellDataList[indexPath.section]
        if let cell:any PersonCenterTypeCellProviding = setcionCells[indexPath.row] as? PersonCenterTypeCellProviding {
            
            return cell.cellHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == cellDataList.count - 1 {
            
            return Bottom_SafeHeight > 0 ? Bottom_SafeHeight:20
        }
        if section == cellDataList.count - 3 {
            
            return 5
        }
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
        
        let setcionCells:Array<MOTableViewCell> = cellDataList[indexPath.section]
        let cell = setcionCells[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let setcionCells:Array<MOTableViewCell> = cellDataList[indexPath.section]
        
        if let cell = setcionCells[indexPath.row] as? PersonCenterTypeCellProviding {
            if (cell.didSelectedCell != nil) {
                cell.didSelectedCell!(cell as! UITableViewCell)
            }
        }
    }
    
}


extension MOPersonCenterSFVC:@preconcurrency MFMailComposeViewControllerDelegate {
    
     func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        
         controller.dismiss(animated: true, completion: nil)
    }
}

