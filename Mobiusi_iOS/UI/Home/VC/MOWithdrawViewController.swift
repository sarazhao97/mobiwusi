//
//  MOWithdrawViewController.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/3.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

class MOWithdrawViewController: MOBaseViewController {
    
    // MARK: - Properties
    @objc public var account_balance:String?
    private var selectedAmountIndex: Int = 0
    private var withdrawMethond: Int = 0
    private var cateOptionModel:MOCateOptionModel?
    private var contentSizeObservation: NSKeyValueObservation?
    private var withdrawalRecordBtn:MOButton = {
        
        let button = MOButton()
        button.setTitle(NSLocalizedString("提现记录", comment: ""), titleColor: MainSelectColor!, bgColor: ClearColor, font: MOPingFangSCHeavyFont(13))
        return button
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("申请提现", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    
    private lazy var amountContentView:MOView = {
        let vi:MOView = MOView();
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    // MARK: - UI Components
    private lazy var amountCollectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 11
        return layout
    }()
    
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false // 显示滚动指示器
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true // 允许垂直弹性滚动
        return scrollView
    }()
    
    private let containerView: MOView = {
        let view = MOView()
        view.backgroundColor = ClearColor
        return view
    }()
    
    private lazy var amountCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: amountCollectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MOCashAmountCell.self, forCellWithReuseIdentifier: "MOCashAmountCell")
        return collectionView
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel.init(text: NSLocalizedString("当前余额 (元)", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(14))
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel.init(text:"0.00", textColor: MainSelectColor!, font: MOPingFangSCBoldFont(31))
        return label
    }()
    
    private let amountLineView: MOView = {
        let view = MOView()
        view.backgroundColor = ColorF2F2F2
        return view
    }()
    
    private let withdrawAmountTitleLabel: UILabel = {
        let label = UILabel.init(text: NSLocalizedString("提现金额", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(14))
        return label
    }()
    
    private let withdrawMethodContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = WhiteColor!
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()

     private let withdrawRulesContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = WhiteColor!
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    private let withdrawMethodTitleLabel:UILabel = {
        let UILabel:UILabel = UILabel(text: NSLocalizedString("提现方式", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(14))
        return UILabel
    }()

     private let withdrawRulesTitleLabel:UILabel = {
        let UILabel:UILabel = UILabel(text: NSLocalizedString("提现规则", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(14))
        return UILabel
    }()
    
    private let withdrawMethodStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical  // 改为垂直布局，每个提现方式独占一行
        stackView.spacing = 12
        stackView.alignment = UIStackView.Alignment.fill
        stackView.distribution = UIStackView.Distribution.fill
        return stackView
    }()

    private let withdrawRulesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    
    // 从接口获取的提现方式列表
    private var withdrawalChannels: [WithdrawalChannelItem] = []
    private var methodItemViews: [WithdrawMethodItemView] = []
    
    private let withdrawButtonContentView: MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
    
    private var withdrawGradientLayer: CAGradientLayer?
    private let withdrawButton: MOButton = {
        let button = MOButton()
        button.setTitle(NSLocalizedString("立即提现", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(17))
        button.cornerRadius(QYCornerRadius.all, radius: 10)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadRequest();
        
        amountCollectionView.observeValue(forKeyPath: "contentSize") {[weak self] (dict:[AnyHashable : Any], object:Any) in
            
            let size:CGSize = dict["new"] as! CGSize
            if size.height != self?.amountCollectionView.bounds.height {
                
                self?.amountCollectionView.snp.remakeConstraints{ make in
                    make.height.equalTo(size.height)
                    make.top.equalTo((self?.withdrawAmountTitleLabel.snp.bottom)!).offset(10)
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.bottom.equalToSuperview().offset(-20)
                }
            }
            
        };
        
    }
    
    deinit {
        contentSizeObservation = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyWithdrawButtonGradient()
    }
    
    private func applyWithdrawButtonGradient() {
        if withdrawGradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [ColorFF6B6B!.cgColor, ColorE62941!.cgColor]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.locations = [0, 1]
            gradient.cornerRadius = withdrawButton.layer.cornerRadius
            withdrawGradientLayer = gradient
            withdrawButton.layer.insertSublayer(gradient, at: 0)
        }
        withdrawGradientLayer?.frame = withdrawButton.bounds
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        
        view.addSubview(navBar)
        navBar.rightItemsView.addArrangedSubview(withdrawalRecordBtn)
        navBar.rightItemsView.alignment = .center
        navBar.rightItemsView.distribution = .equalSpacing
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(amountContentView);
        amountContentView.addSubview(balanceLabel)
        amountContentView.addSubview(amountLabel)
        amountContentView.addSubview(amountLineView)
        amountContentView.addSubview(withdrawAmountTitleLabel)
        
        amountContentView.addSubview(amountCollectionView)
        
        
        
        // 将标题移出容器，放在容器上方
        containerView.addSubview(withdrawMethodTitleLabel)
        containerView.addSubview(withdrawMethodStackView) // 直接添加到 containerView，不再使用 withdrawMethodContentView
      
        containerView.addSubview(withdrawRulesContentView)
        withdrawRulesContentView.addSubview(withdrawRulesTitleLabel) 
        withdrawRulesContentView.addSubview(withdrawRulesStackView)
        
        // 规则文案标签
        let ruleLabel1 = UILabel(text: NSLocalizedString("首次提现用户单笔最低提现金额¥10，以后提现用户单笔最低提现¥50，金额不得超过当前余额。", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(13))
        ruleLabel1.numberOfLines = 0
        let ruleLabel2 = UILabel(text: NSLocalizedString("支持支付宝、银行卡，1-3个工作日到账 （节假日顺延）。", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(13))
        ruleLabel2.numberOfLines = 0
        let ruleLabel3 = UILabel(text: NSLocalizedString("信息错误或提现失败将退回账户余额。", comment: ""), textColor: Color606060 as? UIColor ?? UIColor.gray, font: MOPingFangSCMediumFont(13))
        ruleLabel3.numberOfLines = 0
        
        [ruleLabel1, ruleLabel2, ruleLabel3].forEach { withdrawRulesStackView.addArrangedSubview($0) }
        
          containerView.addSubview(withdrawButtonContentView)
        withdrawButtonContentView.addSubview(withdrawButton)
        
        amountLabel.text = account_balance
        amountLabel.textColor = BlackColor
        
        // 提现方式将从接口获取后动态添加
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
            // 移除固定高度，让 containerView 根据内容自适应高度
        }
        
        amountContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }
        
        amountLineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(104)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }
        
        withdrawAmountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLineView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-16)
        }
        
        amountCollectionView.snp.makeConstraints { make in
            make.top.equalTo(withdrawAmountTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-29)
        }
        
        // 标题放在容器上方，上下间距相等
        withdrawMethodTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountContentView.snp.bottom).offset(20) // 上间距
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        withdrawMethodStackView.snp.makeConstraints { make in
            make.top.equalTo(withdrawMethodTitleLabel.snp.bottom).offset(20) // 下间距，与上间距相等
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
        }

          withdrawRulesContentView.snp.makeConstraints { make in
            make.top.equalTo(withdrawMethodStackView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
        };
         withdrawRulesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        // withdrawMethodStackView 的约束已在上面设置

         withdrawRulesStackView.snp.makeConstraints { make in
            make.top.equalTo(withdrawRulesTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-22)
        }
        
        // 提现方式项的约束将在 setupWithdrawalMethodItems() 中动态设置
        
        withdrawButtonContentView.snp.makeConstraints { make in
            make.top.equalTo(withdrawRulesContentView.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }
        
        
        withdrawButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
             make.bottom.equalToSuperview().offset(-20)
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
        // 提现方式的选择事件将在动态创建时设置
        
        withdrawButton.addTarget(self, action: #selector(withdrawButtonTapped), for: UIControl.Event.touchUpInside)
        
        withdrawalRecordBtn.addTarget(self, action: #selector(WithdrawalRecordClick), for: UIControl.Event.touchUpInside)
    }
    
    private func loadRequest(){
        
        self.showActivityIndicator()
        // 获取分类选项
        MONetDataServer.shared().getCateOptionSuccess { (dict:[AnyHashable : Any]?) in
            self.cateOptionModel = MOCateOptionModel.yy_model(withJSON: dict as Any)
            self.amountCollectionView.reloadData()
        } failure: { (error:Error?) in
            // 忽略错误，继续加载提现通道
        } msg: { (msg:String?) in
            // 忽略错误，继续加载提现通道
        } loginFail: {
            // 忽略错误，继续加载提现通道
        }
        
        // 获取提现通道
        fetchWithdrawalChannels()
    }
    
    private func fetchWithdrawalChannels() {
        NetworkManager.shared.post(APIConstants.Assets.withdrawalChannel,
                                   businessParameters: [:]) { (result: Result<WithdrawalChannelResponse, APIError>) in
            DispatchQueue.main.async {
                self.hidenActivityIndicator()
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        self.withdrawalChannels = response.data ?? []
                        self.setupWithdrawalMethodItems()
                    } else {
                        MBProgressHUD.showMessag(response.msg, to: nil, afterDelay: 2.0)
                    }
                case .failure(let error):
                    MBProgressHUD.showMessag(error.localizedDescription, to: nil, afterDelay: 2.0)
                }
            }
        }
    }
    
    private func setupWithdrawalMethodItems() {
        // 清除现有的提现方式项
        methodItemViews.forEach { $0.removeFromSuperview() }
        methodItemViews.removeAll()
        withdrawMethodStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 根据接口返回的数据创建提现方式项，每个提现方式使用独立的白色容器
        for (index, channel) in withdrawalChannels.enumerated() {
            // 为每个提现方式创建独立的白色容器
            let containerView = MOView()
            containerView.backgroundColor = WhiteColor!
            containerView.cornerRadius(QYCornerRadius.all, radius: 10)
            
            let itemView = WithdrawMethodItemView()
            itemView.titleLable.text = channel.name
            
            // 加载图标
            if let iconUrl = channel.icon, !iconUrl.isEmpty, let url = URL(string: iconUrl) {
                itemView.iconImageView.sd_setImage(with: url, placeholderImage: UIImage(namedNoCache: "icon_Withdraw_method_alipay"), completed: nil)
            } else {
                // 根据类型设置默认图标
                switch channel.type {
                case 1: // 支付宝
                    itemView.iconImageView.image = UIImage(namedNoCache: "icon_Withdraw_method_alipay")
                case 2: // 微信
                    itemView.iconImageView.image = UIImage(named: "icon_share_wx") // 如果没有微信图标，使用默认图标
                case 3: // 银行转账
                    itemView.iconImageView.image = UIImage(namedNoCache: "icon_Withdraw_method_bank")
                default:
                    itemView.iconImageView.image = UIImage(namedNoCache: "icon_Withdraw_method_bank")
                }
            }
            
            // 设置推荐标签 - 只有支付宝（type == 1）显示
            if channel.type == 1 {
                itemView.tagContentView.isHidden = false
            } else {
                itemView.tagContentView.isHidden = true
            }
            
            // 设置默认选中状态
            if channel.isDefault == 1 {
                itemView.selectedSateUI()
                withdrawMethond = index
            } else {
                itemView.normalSateUI()
            }
            
            // 设置点击事件
            itemView.clickEvent = { [weak self] in
                guard let self = self else { return }
                // 取消所有项的选中状态
                self.methodItemViews.forEach { $0.normalSateUI() }
                // 设置当前项为选中状态
                itemView.selectedSateUI()
                self.withdrawMethond = index
            }
            
            // 将 itemView 添加到容器中
            containerView.addSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(60)
            }
            
            methodItemViews.append(itemView)
            withdrawMethodStackView.addArrangedSubview(containerView)
            
            // 设置容器约束
            containerView.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }
    }
    
    func aliPayBind(){
        let vc:MOBindingVerificationVC = MOBindingVerificationVC()
        vc.bindType = 2
        vc.bindResultCallBack = {[weak self] in
            self?.getuserInfo()
        }
        
        // 使用当前视图控制器的导航控制器来推送
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            // 如果没有导航控制器，使用模态展示
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
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
    
    @objc private func withdrawButtonTapped() {
        
        // 检查是否已选择提现方式
        guard withdrawMethond < withdrawalChannels.count else {
            self.showMessage(NSLocalizedString("请选择提现方式", comment: ""))
            return
        }
        
        let selectedChannel = withdrawalChannels[withdrawMethond]
        let userModel:MOUserModel = MOUserModel.unarchive()
        
        // 根据接口返回的 type 字段判断提现方式
        // type: 1=支付宝, 2=微信, 3=银行转账
        if selectedChannel.type == 1 {
            // 支付宝
            if userModel.alipay_openid.count == 0 {
                MOMsgAlertView.show(withTitle: NSLocalizedString("温馨提示", comment: ""), andMsg: NSLocalizedString("你还未绑定支付宝，绑定后才可以提现到支付宝", comment: "")) { [weak self] in
                    self?.aliPayBind()
                }
                return
            }
        }
        
        let model:MOCateOptionItem = cateOptionModel?.withdrawal_money[selectedAmountIndex] as! MOCateOptionItem
        
        let accountBalancel:Float = Float(self.account_balance ?? "") ?? 0
        let amount:Float = Float(model.value) ?? 0
        if accountBalancel < amount {
            self.showMessage(NSLocalizedString("余额不足", comment: ""))
            return
        }
        
        // 根据 type 处理不同的提现方式
        if selectedChannel.type == 1 {
            // 支付宝
            withdrawalSave()
        } else if selectedChannel.type == 3 {
            // 银行转账
            let vc:MOBankWithdrawVC = MOBankWithdrawVC()
            vc.money = model.value
            
            // 使用当前视图控制器的导航控制器来推送
            if let navigationController = self.navigationController {
                navigationController.pushViewController(vc, animated: true)
            } else {
                // 如果没有导航控制器，使用模态展示
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        } else if selectedChannel.type == 2 {
            // 微信（如果将来需要支持）
            self.showMessage(NSLocalizedString("微信提现功能暂未开放", comment: ""))
            return
        }
    }
    
    func withdrawalSave(){
        
        let model:MOCateOptionItem = cateOptionModel?.withdrawal_money[selectedAmountIndex] as! MOCateOptionItem
        self.showActivityIndicator()
        MONetDataServer.shared().userWithdrawalSave(withMoney: model.value, bank_user_name: "", bank_name: "", bank_no: "", type: 0,transferChannel: 1) { _ in
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
        
        // 使用当前视图控制器的导航控制器来推送
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            // 如果没有导航控制器，使用模态展示
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension MOWithdrawViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cateOptionModel?.withdrawal_money.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MOCashAmountCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOCashAmountCell", for: indexPath) as! MOCashAmountCell
        
        let model:MOCateOptionItem = self.cateOptionModel?.withdrawal_money[indexPath.row] as! MOCateOptionItem
        cell.configNormalSateCell(withModel:model)
        if selectedAmountIndex == indexPath.row {
            cell.configSelectedSateCell(withModel: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 11
        let totalWidth = collectionView.bounds.width
        let itemWidth = (totalWidth - spacing * 2) / 3
        let higeht:CGFloat = 70 * itemWidth/113.0;
        return CGSize(width: itemWidth, height: higeht)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == selectedAmountIndex {
            return
        }
        let cellOldSelect:MOCashAmountCell = collectionView.cellForItem(at: IndexPath(row: selectedAmountIndex, section: 0)) as! MOCashAmountCell
        let modelOld:MOCateOptionItem = self.cateOptionModel?.withdrawal_money[selectedAmountIndex] as! MOCateOptionItem
        cellOldSelect.configNormalSateCell(withModel: modelOld);
        
        selectedAmountIndex = indexPath.item
        let modelNew:MOCateOptionItem = self.cateOptionModel?.withdrawal_money[selectedAmountIndex] as! MOCateOptionItem
        let cellNew:MOCashAmountCell = collectionView.cellForItem(at: IndexPath(row: selectedAmountIndex, section: 0)) as! MOCashAmountCell
        cellNew.configSelectedSateCell(withModel: modelNew)
    }
}
