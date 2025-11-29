//
//  MOBindingVerificationVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/7.
//

import Foundation
class MOBindingVerificationVC: MOBaseViewController {
    
    public var bindType:Int = 1
    public var bindResultCallBack:(()->Void)?
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
        let lable:UILabel = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(25))
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
            // 使用当前视图控制器的导航控制器来返回
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // 如果没有导航控制器，使用 dismiss
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        view.addSubview(largeTitleLabel)
        largeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(34)
            make.left.equalTo(view.snp.left).offset(23)
        }
        
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(largeTitleLabel.snp.bottom).offset(49)
            make.left.equalTo(view.snp.left).offset(23)
            make.right.equalTo(view.snp.right).offset(-23)
        }
        
        let padding:CGFloat = 20
        let textFieldHeight:CGFloat = 50
        let leftMarginTF:CGFloat = 17
        
        
        view.addSubview(verifyCodeContentView)
        verifyCodeContentView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(padding)
            make.right.equalTo(view.snp.right).offset(-padding)
            make.height.equalTo(textFieldHeight)
            make.top.equalTo(tipLabel.snp.bottom).offset(29)
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
    func setupCopywriting(){
        
        let titleDict:[Int:String] = [1:NSLocalizedString("绑定微信", comment: ""),2:NSLocalizedString("绑定支付宝", comment: ""),3:NSLocalizedString("绑定苹果账号", comment: "")]
        largeTitleLabel.text = titleDict[bindType]
        let userModel:MOUserModel = MOUserModel.unarchive()
        let phoneMaskStr = userModel.mobile.phoneNumberMask()
        
        tipLabel.text = NSLocalizedString("为了您的账号安全，需要验证您的手机号：", comment: "") + phoneMaskStr
        
    }
    
    func sendVerifyCodeRequest(){
        
        let userModel:MOUserModel = MOUserModel.unarchive()
        MONetDataServer.shared().getVerifyCode(withMobile:  userModel.mobile, sms_event: 6, country_code: userModel.country_code, channel_type: 0) { (dict:[AnyHashable : Any]?) in
            
        } failure: { (error:Error?) in
            
        } msg: { (msg:String?) in
            
        } loginFail: {
            
        }
    }
    
    
    @objc func getVerifyCodeBtnClick(){
        
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
        
        sendVerifyCodeRequest()
    }
    
    @objc func bindBtnCLick(){
        
        if verifyCodeTF.text?.count == 0 {
            self.showMessage(NSLocalizedString("短信验证码不能为空", comment: ""))
            return
        }
        
        
        if bindType == 1 {
            wxbind()
        }
        
        if bindType == 2 {
            aliPayBind()
        }
        if bindType == 3 {
            
            appleIdBind()
        }
    }
    
    
    func wxbind(){
        
        let wxRequest:SendAuthReq = SendAuthReq()
        wxRequest.scope = "snsapi_userinfo"
        wxRequest.state = "ios"
        MOAppDelegate().wxApiDelegate = self
        WXApi.sendAuthReq(wxRequest, viewController: self, delegate: self) { (success:Bool) in
            
        }
    }
    
    func aliPayBind(){
        let state:String = "\(Int64(Date().timeIntervalSince1970))"
        let url:String  = "https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=2021005132612403&scope=auth_user&state=\(state)"
        let param:[String:Any] = [
            kAFServiceOptionBizParams:["url":url] as! Any,
        kAFServiceOptionCallbackScheme:"alipayAthud",
        kAFServiceOptionNotUseLanding:false
        ]
        
        AFServiceCenter.call(AFService.auth, withParams: param) {[weak self] (response:AFAuthServiceResponse?) in
            guard let response else {return}
            if response.responseCode == AFAuthResCode.success {
                let auth_code:String = response.result["auth_code"] as! String;
                
                self?.showActivityIndicator()
                MONetDataServer.shared().bindAliPay(withCode: auth_code,vercode: self?.verifyCodeTF.text) { _ in
                    self?.hidenActivityIndicator()
                    self?.showMessage(NSLocalizedString("绑定成功！", comment: ""))
                    let userModel:MOUserModel = MOUserModel.unarchive()
                    userModel.alipay_openid = "binded"
                    userModel.archivedUserModel()
                    self?.bindResultCallBack?()
                    // 使用当前视图控制器的导航控制器来返回
                    if let strongSelf = self {
                        if let navigationController = strongSelf.navigationController {
                            navigationController.popViewController(animated: true)
                        } else {
                            
                            // 如果没有导航控制器，使用 dismiss
                            strongSelf.dismiss(animated: true, completion: nil)
                        }
                    }
                    
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
    
    func appleIdBind(){
        let appleIDProvider:ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider();
        let request:ASAuthorizationAppleIDRequest = appleIDProvider.createRequest();
        request.requestedScopes = [ASAuthorization.Scope.fullName, ASAuthorization.Scope.email];

        let authorizationController:ASAuthorizationController = ASAuthorizationController.init(authorizationRequests: [request]);
        authorizationController.delegate = self;
//        authorizationController.presentationContextProvider = self;
        authorizationController.performRequests()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCopywriting()
//        getVerifyCodeBtnClick()
        navBar.gobackDidClick = {
            // 使用当前视图控制器的导航控制器来返回
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // 如果没有导航控制器，使用 dismiss
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


extension MOBindingVerificationVC:@preconcurrency WXApiDelegate {
    
    func onResp(_ resp: BaseResp) {
        let authRes:SendAuthResp = resp as! SendAuthResp;
        if authRes.errCode == 0{
            self.showActivityIndicator()
            MONetDataServer.shared().bindWeChat(withCode: authRes.code,vercode: verifyCodeTF.text) { [weak self]_ in
                self?.hidenActivityIndicator()
                self?.showMessage(NSLocalizedString("绑定成功！", comment: ""))
                let userModel:MOUserModel = MOUserModel.unarchive()
                userModel.openid = "binded"
                userModel.archivedUserModel()
                self?.bindResultCallBack?()
                // 使用当前视图控制器的导航控制器来返回
                if let strongSelf = self {
                    if let navigationController = strongSelf.navigationController {
                        navigationController.popViewController(animated: true)
                    } else {
                        // 如果没有导航控制器，使用 dismiss
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                }
                
            } failure: { (error:Error?) in
                self.hidenActivityIndicator()
            } msg: { (msg:String?) in
                self.hidenActivityIndicator()
            } loginFail: {
                self.hidenActivityIndicator()
            }

        }
    }
}

extension MOBindingVerificationVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if authorization.credential.isKind(of: ASAuthorizationAppleIDCredential.self){
            let appleIDCredential:ASAuthorizationAppleIDCredential = authorization.credential as! ASAuthorizationAppleIDCredential
            let identityToken:String = String.init(data: appleIDCredential.identityToken!, encoding: String.Encoding.utf8)!
            self.showActivityIndicator()
            MONetDataServer.shared().bindApple(withCode: identityToken ,vercode: verifyCodeTF.text) { _ in
                self.hidenActivityIndicator()
                self.showMessage(NSLocalizedString("绑定成功！", comment: ""))
                let userModel:MOUserModel = MOUserModel.unarchive()
                userModel.sub = "binded"
                userModel.archivedUserModel()
                self.bindResultCallBack?()
                // 使用当前视图控制器的导航控制器来返回
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // 如果没有导航控制器，使用 dismiss
                self.dismiss(animated: true, completion: nil)
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
    }
}
