//
//  MOSunmmarizeShareVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/9.
//

import Foundation
class MOSunmmarizeShareVC: MOBaseViewController {
	
	var didSelectedIndex:((_ index:Int,_ vc:MOSunmmarizeShareVC)->Void)?
	var items:[MOSocialShareModel]
	lazy var customView = {
		let vi  = MOView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.top, radius: 20)
		return vi
	}()
	
	lazy var closeBtn = {
		let btn  = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_pop_alert_close"))
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		return btn
	}()
	
	lazy var customTitleLabel = {
		let label = UILabel(text: NSLocalizedString("分享", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(18))
		
		return label
	}()
	
	lazy var collectonView = {
		
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.scrollDirection = .horizontal
		flowLayout.minimumInteritemSpacing = 0
		flowLayout.minimumLineSpacing = 0
		let collectoin = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
		collectoin.showsHorizontalScrollIndicator = false
		return collectoin
	}()
	
	func setupUI(){
		
		view.backgroundColor = BlackColor.withAlphaComponent(0.6)
		view.addSubview(customView)
		customView.addSubview(customTitleLabel)
		customView.addSubview(closeBtn)
		collectonView.register(MOSunmmarizeShareCell.self, forCellWithReuseIdentifier: "MOSunmmarizeShareCell")
		collectonView.delegate = self
		collectonView.dataSource = self
		customView.addSubview(collectonView)
	}
	
	func setupConstraints(){
		customView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		customTitleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.centerX.equalToSuperview()
		}
		
		closeBtn.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
		}
		
		collectonView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(10)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(customTitleLabel.snp.bottom).offset(30)
			make.height.equalTo(100)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
		}
	}
	
	
	func addActions(){
		closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func closeBtnClick(){
		
		self.dismiss(animated: true)
	}
	
	
	public class func ctrateAlertStyle(items:[MOSocialShareModel])->MOSunmmarizeShareVC {
		
		let vc = MOSunmmarizeShareVC(items:items)
		vc.modalTransitionStyle = .crossDissolve
		vc.modalPresentationStyle = .overFullScreen
		return vc
	}
	
	init(items:[MOSocialShareModel]) {
		self.items = items
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		DLog("MOSunmmarizeShareVC deinit")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupConstraints()
		addActions()
	}
}

extension MOSunmmarizeShareVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// 等宽平均分布：根据当前可见宽度与项目数计算
		let totalWidth = collectionView.bounds.width
		let count = max(items.count, 1)
		let itemWidth = floor(totalWidth / CGFloat(count))
		return CGSize(width: itemWidth, height: 100)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOSunmmarizeShareCell", for: indexPath)
		if let cell1 = cell as? MOSunmmarizeShareCell {
			
			let model = items[indexPath.row]
			let imageName = model.imageName ?? ""
			let title = model.title ?? ""
			cell1.configCell(imageIcon: imageName, title: title)
		}
		return cell
		
	}
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		
		didSelectedIndex?(indexPath.row,self)
		
	}
	
	
}

extension MOSunmmarizeShareVC:TencentSessionDelegate {
	nonisolated func tencentDidLogin() {
		
	}
	
	nonisolated func tencentDidNotLogin(_ cancelled: Bool) {
		
	}
	
	nonisolated func tencentDidNotNetWork() {
		
	}
	
	
}
