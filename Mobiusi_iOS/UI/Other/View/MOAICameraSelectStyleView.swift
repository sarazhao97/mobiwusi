//
//  MOAICameraSelectStyleView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit
import SnapKit

class MOAICameraSelectStyleView: MOView {

	var dataList:[MOCateOptionStyleModel]?
	
	let cellIdentifier = "GIAIImageStyleCell"
	let feedbackGenerator = UIImpactFeedbackGenerator(style:.light)
	var selectedIndex: Int = 0
	lazy var collectionView = {
		
		let layout = GIAIImageStyleFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10
		layout.itemSize = CGSizeMake(40, 40)
		let vi = UICollectionView(frame: .zero, collectionViewLayout: layout)
		vi.translatesAutoresizingMaskIntoConstraints = false
		vi.backgroundColor = .clear
		vi.showsHorizontalScrollIndicator = false
	
		return vi
	}()
	
	lazy var styleNameLable = {
		let lable = UILabel(text: "", textColor: WhiteColor!, font: MOPingFangSCMediumFont(12))
		return lable
	}()
	
	lazy var borderView = {
		let vi = MOView()
		vi.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 5, borderColor: WhiteColor!)
		vi.isUserInteractionEnabled = false
		return vi
	}()
    
	func setupUI(){
		collectionView.delegate = self
		collectionView.dataSource = self
		let itemWidth = 40
		collectionView.contentInset = UIEdgeInsets(top: 0, left: SCREEN_WIDTH/2 - CGFloat(itemWidth/2), bottom: 0, right: SCREEN_WIDTH/2 - CGFloat(itemWidth/2))
		collectionView.register(GIAIImageStyleCell.self, forCellWithReuseIdentifier: cellIdentifier)
		addSubview(collectionView)
		addSubview(styleNameLable)
		addSubview(borderView)
	}
	
	func setupConstraints(){
		collectionView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.height.equalTo(55)
			
        }
		
		borderView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.height.equalTo(40)
			make.width.equalTo(40)
			make.centerY.equalTo(collectionView.snp.centerY)
		}
		
		styleNameLable.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(collectionView.snp.bottom).offset(10)
			make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20 )
		}
	}
	
	
	func configView(dataList:[MOCateOptionStyleModel]) {
		
		self.dataList = dataList
		styleNameLable.text = dataList.first?.name_zh
		collectionView.reloadData()
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
	
}


// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MOAICameraSelectStyleView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataList?.count ?? 0 // Placeholder
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let model = dataList?[indexPath.row]
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
		if let cell1 = cell as? GIAIImageStyleCell {
			if let model {
				cell1.configCell(model: model)
			}
			
		}
		return cell
	}
	
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView is UICollectionView else { return }
		let offset  = scrollView.contentOffset.x + scrollView.contentInset.left
		let index =  Int(_math.round(offset / 50.0))
		let dataListCount = dataList?.count ?? 0
		if selectedIndex != index,index >= 0,index <= dataListCount - 1  {
			guard let collection = scrollView as? UICollectionView else { return }
			let cell = collection.cellForItem(at: IndexPath(item: selectedIndex, section: 0))

			
			selectedIndex = index
			
			let cell2 = collection.cellForItem(at: IndexPath(item: selectedIndex, section: 0))
			
			// 触发震动反馈
			feedbackGenerator.impactOccurred()
			// 再次准备反馈生成器
			feedbackGenerator.prepare()
			let model = dataList?[index]
			styleNameLable.text = model?.name_zh
			
		}
		
	}
}


