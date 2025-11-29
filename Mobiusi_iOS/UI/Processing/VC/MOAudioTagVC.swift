//
//  MOAudioTagVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioTagVC:MOBaseViewController {
    
	var tagList:[String]
	var didSaveTags:((_ tags:[String])->Void)?
    lazy var customView = {
        let vi  = MOView()
        vi.backgroundColor = ColorEDEEF5
        vi.cornerRadius(QYCornerRadius.top, radius: 16)
        return vi
    }()
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("标签", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        navBar.backBtn.isHidden = true
        navBar.customStatusBarheight(20)
        return navBar
    }();
    lazy var closeBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_nav_close"))
        return btn
    }()
    
    lazy var tagCollectionView = {
        let fllowLayout = UICollectionViewFlowLayout()
        fllowLayout.scrollDirection = .vertical
        fllowLayout.minimumLineSpacing = 10.0
        fllowLayout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: fllowLayout)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.backgroundColor = ClearColor
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    
    lazy var bottomView = {
        let vi = MOBottomBtnView()
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    func setBottomBtnNormalStyle(){
        bottomView.bottomBtn.setTitle(NSLocalizedString("保存", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!,font: MOPingFangSCBoldFont(16))
        bottomView.bottomBtn.cornerRadius(QYCornerRadius.all, radius: 14)
    }
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(customView)
        navBar.rightItemsView.addArrangedSubview(closeBtn)
        customView.addSubview(navBar)
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.register(MOAudioTagCell.self, forCellWithReuseIdentifier: "MOAudioTagCell")
        tagCollectionView.register(MOAudioAddCustomTagCell.self, forCellWithReuseIdentifier: "MOAudioAddCustomTagCell")
        
        tagCollectionView.register(MOAudioTagSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MOAudioTagSectionHeader")
        customView.addSubview(tagCollectionView)
        customView.addSubview(bottomView)
		bottomView.didClick = {[weak self] in
			guard let self  else {return}
			didSaveTags?(tagList)
			self.hidden {
				self.dismiss(animated: false)
			}
		}
        setBottomBtnNormalStyle()
        
        tagCollectionView.observeValue(forKeyPath: "contentSize") { [weak self] (dict:[AnyHashable : Any], object:Any) in
            guard let self else {return}
            let size:CGSize = dict["new"] as! CGSize
            if size.height != self.tagCollectionView.bounds.height {
                tagCollectionView.snp.remakeConstraints { make in
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalTo(navBar.snp.bottom).offset(20)
                    make.height.equalTo(size.height + tagCollectionView.contentInset.top + tagCollectionView.contentInset.bottom).priority(800)
                }
            }
        }
    }
    
    
    func setupConstraints(){
        
        customView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        navBar.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        closeBtn.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.height.equalTo(100)
        }
        tagCollectionView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        
        bottomView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
			make.top.equalTo(tagCollectionView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        bottomView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
        
        
        self.hidden {
            self.dismiss(animated: true)
        }
    }
    
    func hidden(complete:(()->Void)?){
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            complete?()
        }
        
    }
    
    
    func show(){
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            customView.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview().offset(STATUS_BAR_Height_CODE())
                make.bottom.equalToSuperview()
            }
            customView.layoutIfNeeded()
            view.layoutIfNeeded()
            
        } completion: { _ in
            
        }
    }
    
    
    class func createAlertStyle(tagList: [String]? = nil)->MOAudioTagVC{
		let vc = MOAudioTagVC(tagList:tagList)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
	init(tagList: [String]? = nil) {
		
		if let tagList {
			self.tagList = tagList
		} else {
			self.tagList = []
		}
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
    }
    
}

extension MOAudioTagVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let count  = tagList.count
        return 1 + count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: (collectionView.bounds.width - 50)/4, height: 36)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        DLog("kind:\(kind)")
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MOAudioTagSectionHeader", for: indexPath)
            if let header1 = header as?  MOAudioTagSectionHeader{
                
//                header1.titleLable.text = "系统推荐"
				header1.titleLable.text = "自定义"
//                if indexPath.section == 1 {
//                    header1.titleLable.text = "自定义"
//                }
                
            }
            return header
        }
        
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
		if  tagList.count > indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOAudioTagCell", for: indexPath)
			let tag = tagList[indexPath.row]
			if let cell1 = cell as? MOAudioTagCell {
				cell1.titleLabel.text = tag
				cell1.showCanDeleteStyle()
				cell1.didClickDelete = {[weak self] in
					guard let self else {return}
					self.tagList.remove(at: indexPath.row)
					self.tagCollectionView.reloadData()
				}
			}
            return cell
		}
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOAudioAddCustomTagCell", for: indexPath)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row >= tagList.count {
            let alertVC = UIAlertController(title: "请填写自定义标签", message: nil, preferredStyle: UIAlertController.Style.alert)
            let cancleAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { action in
                
            }
            let sureAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { [weak self]action in
				guard let self else {return}
				if let text = alertVC.textFields?.first?.text {
					self.tagList.append(text)
					self.tagCollectionView.reloadData()
				}
				
                
            }
            alertVC.addTextField { tf in
                
            }
            alertVC.addAction(cancleAction)
            alertVC.addAction(sureAction)
            self.present(alertVC, animated: true)
        }
        
    }
    
    
}
