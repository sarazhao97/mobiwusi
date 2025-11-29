//
//  MOLinkCheckedParameterView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOLinkCheckedParameterView: MOView {
    
    var dataList:[MOSummaryParamModel]?
    lazy var titleLabel = {
        let label = UILabel(text: NSLocalizedString("参数", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(15))
        return label
    }()
    lazy var collectionView = {
        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.minimumLineSpacing = 0
        let collection  = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), collectionViewLayout: flowLayout)
        return collection
    }()
    
    func showDataList(dataList:[MOSummaryParamModel]?) {
        self.dataList = dataList
        collectionView.reloadData()
    }
    
    func setupUI(){
        self.addSubview(titleLabel)
        self.addSubview(collectionView)
        collectionView.register(MOLinkCheckedParameterCell.self, forCellWithReuseIdentifier: "MOLinkCheckedParameterCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.observeValue(forKeyPath: "contentSize") {[weak self] dict, object in
            let size:CGSize = dict["new"] as! CGSize
            guard let self else {return}
            if size.height != self.collectionView.bounds.height {
                
                self.collectionView.snp.remakeConstraints{ make in
                    make.height.equalTo(size.height)
                    make.left.equalToSuperview().offset(21)
                    make.right.equalToSuperview().offset(-21)
                    make.top.equalTo(titleLabel.snp.bottom).offset(5)
                    make.bottom.equalToSuperview().offset(-19)
                }
            }
        }
    }
    
    func setupConstraints(){
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(10)
        }
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-19)
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        
    }
}

extension MOLinkCheckedParameterView:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isleft = indexPath.row%2 == 0
        let percent = isleft ? 4 : 3
        let width =  CGFloat(percent) * collectionView.bounds.width/7.0
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOLinkCheckedParameterCell", for: indexPath)
        
        if let cell1 = cell as? MOLinkCheckedParameterCell,let model = self.dataList?[indexPath.row] {
            cell1.nameLabel.text = model.name
            cell1.valueLabel.text = model.value
        }
        return cell
    }
    
    
    
}

class MOLinkCheckedParameterCell:UICollectionViewCell {
    
    lazy var nameLabel = {
        let label = UILabel(text: "", textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(10))
        
        return label
    }()
    
    lazy var valueLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(12))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        return label
    }()
    
    func setupUI(){
        contentView.clipsToBounds = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(valueLabel)
    }
    
    func setupConstraints(){
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            
        }
    }
    
    func addSubviews(){
        setupUI()
        setupConstraints()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
