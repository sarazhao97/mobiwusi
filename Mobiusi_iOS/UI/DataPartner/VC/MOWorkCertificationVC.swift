//
//  MOWorkCertificationVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/28.
//

import Foundation
class MOWorkCertificationVC: MOBaseViewController {
    
    var didUploadSuccess:(()->Void)?
    var cateOptionModel:MOCateOptionModel?
    var work_type:MOCateOptionItem?
    var work_income:MOCateOptionItem?
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("工作认证", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        return navBar
    }();
    var scrollView:UIScrollView = {
        
        let scrollView = UIScrollView()
        return scrollView;
    }()
    
    var scrollViewContent:MOView = {
        
        let vi = MOView()
        return vi;
    }()
    
    var workTypeLabel:UILabel = {
        let label = UILabel(text: NSLocalizedString("工作类型", comment: ""), textColor: Color959998!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    var workTypeView:MOToChooseVIew = {
        
        let vi = MOToChooseVIew(placeholder: NSLocalizedString("请选择你的工作类型", comment: ""))
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    var workUnitLabel:UILabel = {
        let label = UILabel(text: NSLocalizedString("工作单位", comment: ""), textColor: Color959998!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    var workUnitView:MOOnlyIuputVIew = {
        let vi  = MOOnlyIuputVIew(placeholder: NSLocalizedString("请输入单位名称", comment: ""))
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    var monthlyIncomeRangeLabel:UILabel = {
        let label = UILabel(text: NSLocalizedString("月收入区间", comment: ""), textColor: Color959998!, font: MOPingFangSCMediumFont(12))
        return label
    }()
    
    var monthlyIncomeRangeView:MOToChooseVIew = {
        
        let vi = MOToChooseVIew(placeholder: NSLocalizedString("选填", comment: ""))
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    
    var bottomBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("提交", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(16))
        btn.cornerRadius(QYCornerRadius.all, radius: 14)
        btn.fixAlignmentBUG()
        return btn
    }()
    
    
    func setupUI(){
        
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        view.addSubview(navBar)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContent)
        scrollViewContent.addSubview(workTypeLabel)
        workTypeView.didClick = {[weak self] in
            
            self?.showWorkType()
        }
        scrollViewContent.addSubview(workTypeView)
        scrollViewContent.addSubview(workUnitLabel)
        scrollViewContent.addSubview(workUnitView)
        scrollViewContent.addSubview(monthlyIncomeRangeLabel)
        monthlyIncomeRangeView.didClick = {[weak self] in
            self?.showWorkIncome()
        }
        scrollViewContent.addSubview(monthlyIncomeRangeView)
        
        bottomBtn.addTarget(self, action: #selector(commit), for: UIControl.Event.touchUpInside)
        scrollViewContent.addSubview(bottomBtn)
    }
    
    func setupConstraints(){
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalToSuperview()
            
        }
        
        
        scrollViewContent.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        workTypeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(18)
        }
        
        workTypeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(workTypeLabel.snp.bottom).offset(10)
            make.height.equalTo(55)
        }
        
        
        workUnitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalTo(workTypeView.snp.bottom).offset(18)
        }
        
        workUnitView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(workUnitLabel.snp.bottom).offset(10)
            make.height.equalTo(55)
        }
        
        
        monthlyIncomeRangeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalTo(workUnitView.snp.bottom).offset(18)
        }
        
        monthlyIncomeRangeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(monthlyIncomeRangeLabel.snp.bottom).offset(10)
            make.height.equalTo(55)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(monthlyIncomeRangeView.snp.bottom).offset(18)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(49)
            
        }
        
    }
    
    
    func showWorkType(){
        
        let alertVC = UIAlertController(title: NSLocalizedString("请选择您的工作类型", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cancleAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: UIAlertAction.Style.cancel) { action in
            
        }
        alertVC.addAction(cancleAction)
        
        if let work_type = cateOptionModel?.work_type {
            
            for case let item as MOCateOptionItem in work_type {
                
                let itemAction = UIAlertAction(title: item.name, style: UIAlertAction.Style.default) { action in
                    self.work_type = item
                    self.workTypeView.titleTF.text = item.name
                }
                alertVC.addAction(itemAction)
            }
        }
        
        self.present(alertVC, animated: true)
    }
    
    
    func showWorkIncome(){
        
        let alertVC = UIAlertController(title: NSLocalizedString("请选择您的月收入区间", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cancleAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: UIAlertAction.Style.cancel) { action in
            
        }
        alertVC.addAction(cancleAction)
        
        if let work_income = cateOptionModel?.work_income {
            
            for case let item as MOCateOptionItem in work_income {
                
                let itemAction = UIAlertAction(title: item.name, style: UIAlertAction.Style.default) { action in
                    self.work_income = item
                    self.monthlyIncomeRangeView.titleTF.text = item.name
                }
                alertVC.addAction(itemAction)
            }
        }
        
        self.present(alertVC, animated: true)
    }
    
    func loadRequest(){
        
        self.showActivityIndicator()
        MONetDataServer.shared().getCateOptionSuccess {[weak self] dict in
            guard let self else {return}
            self.hidenActivityIndicator()
            cateOptionModel = MOCateOptionModel.yy_model(withJSON: dict as Any)
        } failure: { error in
            self.hidenActivityIndicator()
            guard let error else {return}
            self.showErrorMessage(error.localizedDescription)
        } msg: { msg in
            self.hidenActivityIndicator()
            guard let msg else {return}
            self.showErrorMessage(msg)
        } loginFail: {
            self.hidenActivityIndicator()
        }

    }
    
    
    @objc func commit(){
        
        guard let work_type else {
            
            showMessage(NSLocalizedString("请选择工作类型", comment: ""))
            return
        }
        
        let work_incomeVaule = work_income?.value ?? ""
//        guard let work_income else {
//            showMessage(NSLocalizedString("请选择月收入区间", comment: ""))
//            return
//        }
        
        let workCompany = workUnitView.inputTF.text
        if workCompany?.count == 0 {
            showMessage(NSLocalizedString("请输入工作单位", comment: ""))
            return
        }
        
        MONetDataServer.shared().saveAuth(withAuthType: 3, identityCardFront: nil, identityCardBack: nil, driverLicenceMain: nil, driverLicenceDeputy: nil, workCompany: workCompany, workIncome: Int(work_incomeVaule) ?? 0, educationImage: nil, workType: Int(work_type.value) ?? 0) { dic in
            self.hidenActivityIndicator()
            self.showMessage(NSLocalizedString("提交成功", comment: ""))
            self.didUploadSuccess?()
            MOAppDelegate().transition.popViewController(animated: true)
            
        } failure: { error in
            self.hidenActivityIndicator()
            guard let error else {return}
            self.showErrorMessage(error.localizedDescription)
        } msg: { msg in
            
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
        setupConstraints()
        loadRequest()
        
    }
}
