//
//  MOSignInAlertVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/4.
//

import Foundation
class MOSignInAlertVC: MOBaseViewController {
    var points:Int = 0
    
    lazy var contentView:MOView = {
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
    
    lazy var topHeader:MOHorizontalGradientView = {
        
        let vi = MOHorizontalGradientView(colors: [Color9A1E2E!,ColorFF445C!],startPoint:  CGPoint(x: 0, y: 1),endPoint:  CGPoint(x: 1, y: 1))
        vi.cornerRadius(QYCornerRadius.top, radius: 20)
        return vi
    }()
    
    lazy var topHeaderTitleLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("恭喜您！", comment: ""), textColor: WhiteColor!, font: MOPingFangSCHeavyFont(30))
        return label
    }()
    
    lazy var topHeaderSubtitleLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("签到成功", comment: ""), textColor: WhiteColor!, font: MOPingFangSCHeavyFont(14))
        return label
    }()
    
    lazy var bottomView:MOView = {
        
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
    
    lazy var bottomViewBGImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_ProfitReminder_bottomBg")
        return imageView
    }()
    
    lazy var pointsLabel:UILabel = {
        
        let label = UILabel(text: "", textColor: Color9A1E2E!, font: MOPingFangSCBoldFont(40))
        return label
    }()
    
    lazy var pointsIcon:UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_points_24x24")
        return imageView
    }()
    
    
    lazy var bottomTitleLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("恭喜您获得", comment: ""), textColor: BlackColor, font: MOPingFangSCBoldFont(18))
        return label
    }()
    
    
    lazy var bottomCloseBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("明天再来", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(17))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        return btn
    }()
    
    
    lazy var calendarSiginImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_calendar_sigin")
        return imageView
    }()
    
    lazy var closeBtn:MOButton = {
        
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_ProfitReminder_close_white"))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(contentView)
        view.addSubview(closeBtn)
        view.addSubview(calendarSiginImageView)
        contentView.addSubview(topHeader)
        topHeader.addSubview(topHeaderTitleLabel)
        topHeader.addSubview(topHeaderSubtitleLabel)
        contentView.addSubview(bottomView)
        bottomView.addSubview(bottomViewBGImageView)
        pointsLabel.text = "+\(points)"
        bottomView.addSubview(pointsLabel)
        bottomView.addSubview(pointsIcon)
        bottomView.addSubview(bottomTitleLabel)
        bottomView.addSubview(bottomCloseBtn)
    }
    
    func setupConstraints(){
        
        contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        topHeader.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(104)
        }
        
        topHeaderTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(21)
        }
        
        topHeaderSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topHeaderTitleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(21)
        }
        
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topHeader.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
//            make.height.equalTo(50)
        }
        
        bottomViewBGImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pointsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        pointsIcon.snp.makeConstraints { make in
            make.left.equalTo(pointsLabel.snp.right).offset(7)
            make.centerY.equalTo(pointsLabel.snp.centerY)
        }
        
        bottomTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(pointsLabel.snp.top).offset(-42)
        }
        
        bottomCloseBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-26)
            make.height.equalTo(55)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomView.snp.bottom).offset(20)
        }
        calendarSiginImageView.snp.makeConstraints { make in
            make.right.equalTo(topHeader.snp.right)
            make.top.equalTo(topHeader.snp.top).offset(-15)
        }
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
        
        bottomCloseBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
        
        self.dismiss(animated: true)
    }
    
    class func createAlertVC(points:Int)->MOSignInAlertVC{
        let vc =  MOSignInAlertVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.points = points
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
    }
}
