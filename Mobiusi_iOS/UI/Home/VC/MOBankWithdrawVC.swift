//
//  MOBankWithdrawVCswift.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/7.
//

import Foundation

class MOBankWithdrawVC: MOBaseViewController {
    
    public var money:String?
    private var withdrawalRecordBtn:MOButton = {
        
        let button = MOButton()
        button.setTitle(NSLocalizedString("提现记录", comment: ""), titleColor: MainSelectColor!, bgColor: ClearColor, font: MOPingFangSCHeavyFont(13))
        return button
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("银行卡提现", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        return scrollView
    }()
    
    private let containerView: MOView = {
        let view = MOView()
        view.backgroundColor = ClearColor
        return view
    }()
    
    private let nameView:MOBankWithdrawItemView = {
        
        let vi:MOBankWithdrawItemView = MOBankWithdrawItemView()
        vi.titleLabel.text = "收款人姓名"
        vi.textFiled.placeholder = "请输入收款人姓名"
        return vi
        
    }()
    
    private let bankNameView:MOBankWithdrawItemView = {
        
        let vi:MOBankWithdrawItemView = MOBankWithdrawItemView()
        vi.titleLabel.text = "开户行名称"
        vi.textFiled.placeholder = "请输入收款人姓名"
        return vi
        
    }()
    
    private let bankNumberView:MOBankWithdrawItemView = {
        
        let vi:MOBankWithdrawItemView = MOBankWithdrawItemView()
        vi.titleLabel.text = "银行卡号"
        vi.textFiled.placeholder = "请输入银行卡号"
        return vi
        
    }()
    
    
    private let withdrawButtonContentView: MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
    
    private let withdrawButton: MOButton = {
        let button = MOButton()
        button.setTitle(NSLocalizedString("立即提现", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(17))
        button.cornerRadius(QYCornerRadius.all, radius: 10)
        return button
    }()
    
    
    private func setupUI() {
        
        view.addSubview(navBar)
        navBar.rightItemsView.addArrangedSubview(withdrawalRecordBtn)
        navBar.rightItemsView.alignment = .center
        navBar.rightItemsView.distribution = .equalSpacing
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(nameView)
        containerView.addSubview(bankNameView)
        containerView.addSubview(bankNumberView)
        containerView.addSubview(withdrawButtonContentView)
        withdrawButtonContentView.addSubview(withdrawButton)
        
    }
    
    
    private func setupConstraints() {
        
        navBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        withdrawalRecordBtn.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
        
        nameView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(20)
        }
        
        bankNameView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(nameView.snp.bottom).offset(21.5)
        }
        
        bankNumberView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(bankNameView.snp.bottom).offset(21.5)
        }
        
        withdrawButtonContentView.snp.makeConstraints { make in
            make.top.equalTo(bankNumberView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(containerView.snp.bottom).offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight: -20)
        }
        
        
        withdrawButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(55)
        }
    }
    
    
    private func setupActions() {
        
        navBar.gobackDidClick = {
            // 使用当前视图控制器的导航控制器来返回
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // 如果没有导航控制器，使用 dismiss
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        withdrawButton.addTarget(self, action: #selector(withdrawButtonTapped), for: UIControl.Event.touchUpInside)
        
        withdrawalRecordBtn.addTarget(self, action: #selector(WithdrawalRecordClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc private func withdrawButtonTapped() {
        
        if nameView.textFiled.text?.count == 0 {
            self.showMessage(NSLocalizedString("请填写银行卡卡号", comment: ""))
            return
        }
        
        if bankNameView.textFiled.text?.count == 0 {
            self.showMessage(NSLocalizedString("请填写开户行", comment: ""))
            return
        }
        
        if bankNumberView.textFiled.text?.count == 0 {
            self.showMessage(NSLocalizedString("请填写银行卡卡号", comment: ""))
            return
        }
        
        self.showActivityIndicator()
        MONetDataServer.shared().userWithdrawalSave(withMoney: money, bank_user_name: nameView.textFiled.text!, bank_name: bankNameView.textFiled.text!, bank_no: bankNumberView.textFiled.text!, type: 0,transferChannel: 3) { _ in
            self.hidenActivityIndicator()
            self.showMessage(NSLocalizedString("申请成功！", comment: ""))
            NotificationCenter.default.post(name: .ApplyForWithdrawalSucess, object: nil)
            
            
        } failure: { (error:Error?) in
            self.hidenActivityIndicator()
            guard let error else {return}
            self.showMessage(error.localizedDescription)
        } msg: { (msg:String?) in
            self.hidenActivityIndicator()
            guard let msg else {return}
            self.showMessage(msg)
        } loginFail: {
            self.hidenActivityIndicator()
        }

        
    }
    
    @objc private func WithdrawalRecordClick() {
        let vc:MOWithdrawalRecordVC = MOWithdrawalRecordVC()
        MOAppDelegate().transition.push(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        
    }
}
