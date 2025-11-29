//
//  MOBindCellPhoneNumberVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

import Foundation

@objcMembers class MOBindCellPhoneNumberVC: MOBaseViewController {
    
    public  var wXModel:MOUserModel?
    public  var aliPayModel:MOUserModel?
    public var countryCode:Int = 86;
    private lazy var topBGImageView:UIImageView = {
        let bgimageView:UIImageView = UIImageView(image: UIImage.init(namedNoCache: "bg_home_top"))
        bgimageView.contentMode = UIView.ContentMode.scaleAspectFill
        return bgimageView
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = ""
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    
    private lazy var largeTitleLabel:UILabel = {
        let lable:UILabel = UILabel.init(text: NSLocalizedString("绑定手机号", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(25))
        return lable
    }()
    
    private lazy var phoneNumberTFContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    private lazy var countryCodeView:MOCountryCodeView = {
        let cCode:MOCountryCodeView = MOCountryCodeView()
        cCode.codeLable.text = "+86"
        return cCode
    }()
    
    private lazy var phoneNumberTF:UITextField = {
        let textFiledView:UITextField = UITextField()
        textFiledView.backgroundColor = ClearColor
        let placeHolderStr:NSAttributedString = NSAttributedString.create(with: NSLocalizedString("请输入手机号", comment: ""), font: MOPingFangSCMediumFont(17), textColor: ColorAFAFAF!)
        textFiledView.attributedPlaceholder = placeHolderStr
        textFiledView.font = MOPingFangSCMediumFont(17)
        return textFiledView
    }()
    
    private lazy var verifyCodeContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    private lazy var verifyCodeTF:UITextField = {
        let textFiledView:UITextField = UITextField()
        textFiledView.backgroundColor = ClearColor
        let placeHolderStr:NSAttributedString = NSAttributedString.create(with: NSLocalizedString("请输入验证码", comment: ""), font: MOPingFangSCMediumFont(17), textColor: ColorAFAFAF!)
        textFiledView.attributedPlaceholder = placeHolderStr
        textFiledView.font = MOPingFangSCMediumFont(17)
        return textFiledView
    }()
    
    private lazy var getVerifyCodeBtn:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.setTitle(NSLocalizedString("获取验证码", comment: ""), titleColor: MainSelectColor!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
        btn.fixAlignmentBUG()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    private lazy var bindBtn:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.setTitle(NSLocalizedString("立即绑定", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCMediumFont(17))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        return btn
    }()
    
    
    func setupUI() {
        
        view.backgroundColor = WhiteColor
        view.addSubview(topBGImageView)
        topBGImageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        
        view.addSubview(largeTitleLabel)
        largeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(14)
            make.left.equalTo(view.snp.left).offset(23)
        }
        
        let padding:CGFloat = 20
        let textFieldHeight:CGFloat = 50
        let leftMarginTF:CGFloat = 17
        view.addSubview(phoneNumberTFContentView)
        phoneNumberTFContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(largeTitleLabel.snp.bottom).offset(34)
        }
        phoneNumberTFContentView.addSubview(countryCodeView)
        countryCodeView.didClick = {
            
            MOAppDelegate().transition.push(MOAllCountryCodeVC(), animated: true)
        }
        countryCodeView.snp.makeConstraints { make in
            make.left.equalTo(phoneNumberTFContentView.snp.left).offset(leftMarginTF)
            make.top.equalTo(phoneNumberTFContentView.snp.top)
            make.bottom.equalTo(phoneNumberTFContentView.snp.bottom)
        }
        countryCodeView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        countryCodeView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        countryCodeView.codeLable.text = "+\(countryCode)"
        countryCodeView.didClick = { [weak self] in
            
            let vc:MOAllCountryCodeVC = MOAllCountryCodeVC()
            vc.didSelected = { [weak self]( index:Int,countryCode1:Int) in
                self?.countryCodeView.codeLable.text = "+\(countryCode1)"
                self?.countryCode = countryCode1
            }
            MOAppDelegate().transition.push(vc, animated: true)
        }
        
        
        phoneNumberTFContentView.addSubview(phoneNumberTF)
        phoneNumberTF.snp.makeConstraints { make in
            make.left.equalTo(countryCodeView.snp.right).offset(leftMarginTF)
            make.right.equalTo(phoneNumberTFContentView.snp.right).offset(-leftMarginTF)
            make.top.equalTo(phoneNumberTFContentView.snp.top)
            make.bottom.equalTo(phoneNumberTFContentView.snp.bottom)
        }
        phoneNumberTF.setContentHuggingPriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        
        view.addSubview(verifyCodeContentView)
        verifyCodeContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(phoneNumberTFContentView.snp.bottom).offset(padding)
        }
        
        verifyCodeContentView.addSubview(verifyCodeTF)
        verifyCodeTF.snp.makeConstraints { make in
            make.left.equalTo(verifyCodeContentView.snp.left).offset(leftMarginTF)
            make.top.equalTo(verifyCodeContentView.snp.top)
            make.bottom.equalTo(verifyCodeContentView.snp.bottom)
        }
        
        verifyCodeContentView.addSubview(getVerifyCodeBtn)
        getVerifyCodeBtn.addTarget(self, action: #selector(getVerifyCodeBtnClick), for: UIControl.Event.touchUpInside)
        getVerifyCodeBtn.snp.makeConstraints { make in
            make.left.equalTo(verifyCodeTF.snp.right).offset(leftMarginTF)
            make.right.equalTo(verifyCodeContentView.snp.right).offset(-leftMarginTF)
            make.top.equalTo(verifyCodeContentView.snp.top)
            make.bottom.equalTo(verifyCodeContentView.snp.bottom)
        }
        getVerifyCodeBtn.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        view.addSubview(bindBtn)
        bindBtn.addTarget(self, action: #selector(bindBtnCLick), for: UIControl.Event.touchUpInside)
        bindBtn.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(leftMarginTF)
            make.right.equalTo(view.snp.right).offset(-leftMarginTF)
            make.height.equalTo(55)
            make.top.equalTo(verifyCodeContentView.snp.bottom).offset(29)
        }
    }
    
    @objc func bindBtnCLick(){
        
        if phoneNumberTF.text?.count == 0 {
            
            self.showMessage(NSLocalizedString("请输入手机号", comment: ""))
            return
        }
//        if phoneNumberTF.text?.count != 11 {
//            
//            self.showMessage(NSLocalizedString("请输入合法的手机号！", comment: ""))
//            return
//        }
        if verifyCodeTF.text?.count == 0 {
            self.showMessage(NSLocalizedString("请输入验证码", comment: ""))
            return
        }
        
        let phoneNumberStr = phoneNumberTF.text
        let verifyCode = verifyCodeTF.text
        let sex:Int32 = Int32(wXModel?.sex ?? -1)
        self.showActivityIndicator()
        MONetDataServer.shared().login(withMobile: phoneNumberStr, country_code: countryCode, code: verifyCode, account: "", password: "", checkType: 1, name: wXModel?.name, avatar: wXModel?.avatar, sex: sex, unionid: wXModel?.unionid, openid: wXModel?.openid, sub: wXModel?.sub, email: wXModel?.email,alipay_openid:wXModel?.alipay_openid) { (dict:[AnyHashable : Any]?) in
            
            let userModel = MOUserModel.yy_model(withJSON: dict as Any)
            userModel?.archivedUserModel()
            // 切换到新的主TabBar（SwiftUI首页），并确保选中首页
            MOAppDelegate().uMPushSetAlias()
            let tabBarController = MBMainTabBarWrapper.createMainTabBarController()
            if let window = MOAppDelegate().window {
                window.rootViewController = tabBarController
                if let tc = tabBarController as? UITabBarController {
                    tc.selectedIndex = 0
                }
                window.makeKeyAndVisible()
            } else {
                // 兜底：若无法获取window，则以模态方式展示主TabBar
                if let navigationController = self.navigationController {
                    navigationController.setViewControllers([tabBarController], animated: false)
                } else {
                    self.present(tabBarController, animated: true, completion: nil)
                }
            }
            self.hidenActivityIndicator()
            // 已切换到新首页（SwiftUI TabBar），移除旧首页逻辑
        } failure: { ( error:Error?) in
            
        } msg: { (msg:String?) in
			self.hidenActivityIndicator();
        } loginFail: {
			DispatchQueue.main.async {
				self.hidenActivityIndicator()
			}
        }

        
        
    }
    
    @objc func getVerifyCodeBtnClick(){
        
        
        if phoneNumberTF.text?.count == 0 {
            
            self.showMessage(NSLocalizedString("请输入手机号", comment: ""))
            return
        }
        
        
        getVerifyCodeBtn.startCountDown { (btn:UIButton, count:Int) in
            if (count > 60) {
                btn.isEnabled = true
                btn.stopCountDown()
                return NSLocalizedString("获取验证码", comment: "");
            } else {
                btn.isEnabled = false
                return "\(60-count)s"
            }
        }
        
        MONetDataServer.shared().getVerifyCode(withMobile:  phoneNumberTF.text, sms_event: 3, country_code: countryCode, channel_type: 0) { (dict:[AnyHashable : Any]?) in
            
        } failure: { (error:Error?) in
            
        } msg: { (msg:String?) in
            
        } loginFail: {
            
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI();
        
    }
}
