//
//  MOChangePasswordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/8.
//

import Foundation

class MOChangePasswordVC: MOBaseViewController {
    
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
        let lable:UILabel = UILabel.init(text: NSLocalizedString("修改密码", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(25))
        lable.numberOfLines = 0
        return lable
    }()
    
    
    private lazy var tipLabel:UILabel = {
        let lable:UILabel = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(12))
        lable.numberOfLines = 0
        return lable
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
    
    
    private lazy var pwdContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    private lazy var pwdTF:UITextField = {
        let textFiledView:UITextField = UITextField()
        textFiledView.backgroundColor = ClearColor
        let placeHolderStr:NSAttributedString = NSAttributedString.create(with: NSLocalizedString("请输入新密码", comment: ""), font: MOPingFangSCMediumFont(17), textColor: ColorAFAFAF!)
        textFiledView.attributedPlaceholder = placeHolderStr
        textFiledView.font = MOPingFangSCMediumFont(17)
        return textFiledView
    }()
    
    private lazy var pwdSwitch:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.fixAlignmentBUG()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.setImage(UIImage.init(namedNoCache: "icon_register_pwd_view.png"))
        btn.setImage(UIImage.init(namedNoCache: "icon_register_pwd_hidden.png"), for: UIControl.State.selected)
        return btn
    }()
    
    
    private lazy var confirmPwdContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    private lazy var confirmPwdTF:UITextField = {
        let textFiledView:UITextField = UITextField()
        textFiledView.backgroundColor = ClearColor
        let placeHolderStr:NSAttributedString = NSAttributedString.create(with: NSLocalizedString("请再次输入新密码", comment: ""), font: MOPingFangSCMediumFont(17), textColor: ColorAFAFAF!)
        textFiledView.attributedPlaceholder = placeHolderStr
        textFiledView.font = MOPingFangSCMediumFont(17)
        
        return textFiledView
    }()
    
    private lazy var confirmPwdSwitch:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.fixAlignmentBUG()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.setImage(UIImage.init(namedNoCache: "icon_register_pwd_view.png"))
        btn.setImage(UIImage.init(namedNoCache: "icon_register_pwd_hidden.png"), for: UIControl.State.selected)
        return btn
    }()
    
    private lazy var modifyBtn:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.setTitle(NSLocalizedString(NSLocalizedString("立即修改", comment: ""), comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCMediumFont(17))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        return btn
    }()
    
    func setupUI(){
        
        view.backgroundColor = WhiteColor
        view.addSubview(topBGImageView)
        view.addSubview(navBar)
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        
        view.addSubview(largeTitleLabel)
        let userModel:MOUserModel = MOUserModel.unarchive()
        let phoneMaskStr = userModel.mobile.phoneNumberMask()
        tipLabel.text = NSLocalizedString("为了您的账号安全，需要验证您的手机号：", comment: "") + phoneMaskStr
        view.addSubview(tipLabel)
        
        view.addSubview(verifyCodeContentView)
        verifyCodeContentView.addSubview(verifyCodeTF)
        verifyCodeContentView.addSubview(getVerifyCodeBtn)
        
        
        view.addSubview(pwdContentView)
        pwdContentView.addSubview(pwdTF)
        pwdContentView.addSubview(pwdSwitch)
        pwdTF.isSecureTextEntry  = true
        pwdSwitch.isSelected = true
        
        view.addSubview(confirmPwdContentView)
        confirmPwdContentView.addSubview(confirmPwdTF)
        confirmPwdContentView.addSubview(confirmPwdSwitch)
        confirmPwdTF.isSecureTextEntry  = true
        confirmPwdSwitch.isSelected = true
        
        
        view.addSubview(modifyBtn)
        
    }
    
    func setConstraints(){
        
        topBGImageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        largeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(34)
            make.left.equalTo(view.snp.left).offset(23)
        }
        
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(largeTitleLabel.snp.bottom).offset(49)
            make.left.equalTo(view.snp.left).offset(23)
            make.right.equalTo(view.snp.right).offset(-23)
        }
        
        
        let padding:CGFloat = 20
        let textFieldHeight:CGFloat = 50
        let leftMarginTF:CGFloat = 17
        
        
        verifyCodeContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(tipLabel.snp.bottom).offset(29)
        }
        
        verifyCodeTF.snp.makeConstraints { make in
            make.left.equalTo(verifyCodeContentView.snp.left).offset(leftMarginTF)
            make.top.equalTo(verifyCodeContentView.snp.top)
            make.bottom.equalTo(verifyCodeContentView.snp.bottom)
        }
        
        getVerifyCodeBtn.snp.makeConstraints { make in
            make.left.equalTo(verifyCodeTF.snp.right).offset(leftMarginTF)
            make.right.equalTo(verifyCodeContentView.snp.right).offset(-leftMarginTF)
            make.top.equalTo(verifyCodeContentView.snp.top)
            make.bottom.equalTo(verifyCodeContentView.snp.bottom)
        }
        getVerifyCodeBtn.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        pwdContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(verifyCodeContentView.snp.bottom).offset(29)
        }
        
        pwdTF.snp.makeConstraints { make in
            make.left.equalTo(pwdContentView.snp.left).offset(leftMarginTF)
            make.top.equalTo(pwdContentView.snp.top)
            make.bottom.equalTo(pwdContentView.snp.bottom)
        }
        pwdSwitch.snp.makeConstraints { make in
            make.left.equalTo(pwdTF.snp.right).offset(leftMarginTF)
            make.right.equalTo(pwdContentView.snp.right).offset(-leftMarginTF)
            make.top.equalTo(pwdContentView.snp.top)
            make.bottom.equalTo(pwdContentView.snp.bottom)
        }
        pwdSwitch.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        
        confirmPwdContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(pwdContentView.snp.bottom).offset(29)
        }
        
        confirmPwdTF.snp.makeConstraints { make in
            make.left.equalTo(confirmPwdContentView.snp.left).offset(leftMarginTF)
            make.top.equalTo(confirmPwdContentView.snp.top)
            make.bottom.equalTo(confirmPwdContentView.snp.bottom)
        }
        
        confirmPwdSwitch.snp.makeConstraints { make in
            make.left.equalTo(confirmPwdTF.snp.right).offset(leftMarginTF)
            make.right.equalTo(confirmPwdContentView.snp.right).offset(-leftMarginTF)
            make.top.equalTo(confirmPwdContentView.snp.top)
            make.bottom.equalTo(confirmPwdContentView.snp.bottom)
        }
        confirmPwdSwitch.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        modifyBtn.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(confirmPwdContentView.snp.bottom).offset(29)
        }
        
    }
    
    func addActions() {
        
        getVerifyCodeBtn.addTarget(self, action: #selector(sendVerifyCode), for: UIControl.Event.touchUpInside)
        pwdSwitch.addTarget(self, action: #selector(pwdSwitchClick), for: UIControl.Event.touchUpInside)
        confirmPwdSwitch.addTarget(self, action: #selector(confirmPwdSwitchClick), for: UIControl.Event.touchUpInside)
        modifyBtn.addTarget(self, action: #selector(modifyBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func sendVerifyCode(){
        
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
        
        let userMode:MOUserModel = MOUserModel.unarchive()
        MONetDataServer.shared().getVerifyCode(withMobile:  userMode.mobile, sms_event: 5, country_code: userMode.country_code, channel_type: 0) { (dict:[AnyHashable : Any]?) in
            
        } failure: { (error:Error?) in
            
        } msg: { (msg:String?) in
            
        } loginFail: {
			DispatchQueue.main.async {
				self.hidenActivityIndicator()
			}
        }
    }
    
    @objc func pwdSwitchClick(){
        pwdSwitch.isSelected = !pwdSwitch.isSelected
        pwdTF.isSecureTextEntry = pwdSwitch.isSelected
    }
    
    @objc func confirmPwdSwitchClick(){
        confirmPwdSwitch.isSelected = !confirmPwdSwitch.isSelected
        confirmPwdTF.isSecureTextEntry = confirmPwdSwitch.isSelected
    }
    
    @objc func modifyBtnClick(){
        
        if verifyCodeTF.text?.count == 0 {
            self.showMessage(NSLocalizedString("请输入验证码", comment: ""))
            return
        }
        
        if pwdTF.text?.count == 0 {
            self.showMessage(NSLocalizedString("请输入新密码", comment: ""))
            return
        }
        
        
        if ((pwdTF.text?.isRegisterPwd()) == false) {
            
            self.showMessage(NSLocalizedString("密码必须6-16 位，必须包含大小写字母、数字、特殊字符", comment: ""))
            return
        }
        
        if confirmPwdTF.text?.count == 0 {
            self.showMessage(NSLocalizedString("请再次输入新密码", comment: ""))
            return
        }
        
        if pwdTF.text != confirmPwdTF.text {
            self.showMessage(NSLocalizedString("两次输入的密码不一致", comment: ""))
            return
        }
        
        let userMode:MOUserModel = MOUserModel.unarchive()
        self.showActivityIndicator()
        MONetDataServer.shared().resetPassword(withMobile: userMode.mobile, code: verifyCodeTF.text, password: pwdTF.text, country_code: userMode.country_code, second_password: confirmPwdTF.text) { _ in
            
            self.hidenActivityIndicator()
            MOUserModel.remove()
            self.showMessage(NSLocalizedString("修改成功!", comment: ""))
            MOAppDelegate().transition.popToRootViewController(animated: true)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        addActions()
    }
}
