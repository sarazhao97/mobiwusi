//
//  MOUploadTextFileVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/8.
//

import Foundation

@objc public class MOUploadAlbumVC: MOBaseViewController {
    
    lazy var nextBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("下一步", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(12))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        btn.fixAlignmentBUG()
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return btn
    }()
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("", comment: "")
        
        navBar.backBtn.fixAlignmentBUG()
        navBar.backBtn.setImage(UIImage())
        navBar.backBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        navBar.backBtn.setTitle(NSLocalizedString("取消", comment: ""), titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))

        return navBar
    }();
    
    lazy var topContentView:MOView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    lazy var textView:UITextView = {
        let tv = UITextView()
        tv.textColor = BlackColor
        tv.font = MOPingFangSCMediumFont(12)
        tv.zw_placeHolder = NSLocalizedString("这一刻的想法...", comment: "")
        return tv
    }()
    
    lazy var albumCollectionView:UICollectionView = {
        let fllowLayout = UICollectionViewFlowLayout()
        fllowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView.init(frame: CGRect(), collectionViewLayout: fllowLayout)
        collectionView.register(MOPictureVideoStep2PlaceholderCell.self, forCellWithReuseIdentifier: "MOPictureVideoStep2PlaceholderCell")
        collectionView.register(MOFillTaskVideoCell.self, forCellWithReuseIdentifier: "MOFillTaskVideoCell")
        return collectionView
    }()
    
    lazy var locateView:MOPositionInformationView = {
        let vi = MOPositionInformationView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    
    func setupUI(){
        navBar.gobackDidClick = {[weak self] in
            guard let self else {return}
            self.dismiss(animated: true)
        }
        navBar.rightItemsView.addArrangedSubview(self.nextBtn)
        view.addSubview(navBar)
        view.addSubview(topContentView)
        topContentView.addSubview(textView)
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        topContentView.addSubview(albumCollectionView)
        view.addSubview(locateView)
    }
    
    func setupConstraints(){
        
        self.nextBtn.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        topContentView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(289)
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.top.equalToSuperview().offset(12)
        }
        
        albumCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.top.equalTo(textView.snp.bottom).offset(-10)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(114)
        }
        
        
        locateView.snp.makeConstraints { make in
            make.top.equalTo(topContentView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(55)
        }
    }
    
    func addActions(){
        
        self.nextBtn.addTarget(self, action: #selector(nextBtnClick), for: UIControl.Event.touchUpInside)
    }
    @objc func nextBtnClick(){
        
    }
    
    @objc public class func createAlertStyle() ->MOUploadAlbumVC{
        let vc = MOUploadAlbumVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    public override func viewDidLoad() {
    super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
        
    }
}

extension MOUploadAlbumVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 114, height: 114)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOPictureVideoStep2PlaceholderCell", for: indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

