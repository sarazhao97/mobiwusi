//
//  GIAIImageStyleCell.swift
//  GhibliImage
//
//  Created by Mac on 2025/4/21.
//

import Foundation
class GIAIImageStyleCell: UICollectionViewCell {
    
    
    let cacheImage:[UInt:String] = {
        
        let info:[UInt:String] = [
            1:"GhibliStyle",
            2:"3DStyle",
            3:"RealisticStyle",
            4:"PastelBoysStyle",
            5:"CartoonStyle",
            6:"MakotoStyle",
            7:"RevAnimatedStyle",
            8:"BluelineStyle",
            9:"WaterInkStyle",
            10:"NewMonetGarden",
            11:"WaterPaintStyle",
            12:"MonetStyle",
            13:"MarvelStyle",
            14:"CyberFutureStyle",
            15:"KoreanStyle",
            16:"InkArtStyle",
            17:"LightShadowStyle",
            18:"CeramicsDollStyle",
            19:"ChineseRedStyle",
            20:"Clay3DStyle",
            21:"BubbleDollStyle",
            22:"ZEraGameStyle",
            23:"AnimatedMovieStyle",
            24:"ToyDollStyle"
        ]
        
        return info
    }()
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius(QYCornerRadius.all, radius: 12)
        imageView.clipsToBounds = true
        imageView.backgroundColor = ColorB5B5B5
        return imageView
    }()
    
    lazy var titleLabel = {
        let label = UILabel(text: "", textColor: Color34C759!, font: MOPingFangSCBoldFont(16))
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var borderView:MOView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 8)
        vi.backgroundColor = MainSelectColor
        return vi
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
		if #available(iOS 14.0, *) {
			self.backgroundConfiguration = UIBackgroundConfiguration.clear()
		} else {
			self.backgroundColor = ClearColor
			self.backgroundView?.backgroundColor = ClearColor
		};
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	func configCell(model:MOCateOptionStyleModel){
		if let url = URL(string: model.url ?? "") {
			imageView.sd_setImage(with: url)
		}
		
    }
    
    func selectedStyle(){
        titleLabel.textColor = WhiteColor
        borderView.isHidden = false
        imageView.cornerRadius(QYCornerRadius.all, radius: 8, borderWidth: 4, borderColor: MainSelectColor)
        imageView.setNeedsLayout()
    }
    
    func normalStyle(){
//        titleLabel.textColor = Color6B7280
        borderView.isHidden = true
        imageView.cornerRadius(QYCornerRadius.all, radius: 8, borderWidth: 4, borderColor: nil)
        imageView.setNeedsLayout()
        
    }
    
    func setupUI(){
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
//        contentView.addSubview(borderView)
        
    }
    
    func setupConstraints(){
        
        imageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
        }
        
//        titleLabel.snp.makeConstraints { make in
//            
//            make.centerX.equalToSuperview()
//            make.top.equalTo(imageView.snp.bottom).offset(8)
//            make.left.greaterThanOrEqualToSuperview()
//            make.right.lessThanOrEqualToSuperview()
//            make.bottom.equalToSuperview()
//            
//
//        }
    }
    
    func addSubviews(){
        
        setupUI()
        setupConstraints()
    }
}


class GIAIImageStyleFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        let cellWidth = itemSize.width
        let spacing = minimumLineSpacing
        let cellWidthWithSpacing = cellWidth + spacing
        let collectionViewInsetX = collectionView.contentInset.left
        //计算滑动的真实距离
        let proposedContentOffsetX =  proposedContentOffset.x + collectionViewInsetX
        
        // 计算滑动方向
        let isScrollingRight = velocity.x >= 0
        var currentVisibleIndex = 0;
        //四舍五入，找到正确的位置
        if isScrollingRight {
            currentVisibleIndex = Int(round(proposedContentOffsetX / cellWidthWithSpacing))
        } else {
            if (proposedContentOffsetX < 0) {
                return CGPoint(x: proposedContentOffsetX, y: proposedContentOffset.y)
            } else {
                currentVisibleIndex = Int(round(proposedContentOffsetX / cellWidthWithSpacing))
            }
            
        }
        

        // 根据滑动方向计算目标 index
        let targetIndex: Int = currentVisibleIndex
        // 确保目标 index 在有效范围内
        let maxIndex = (collectionView.numberOfItems(inSection: 0) - 1)
        let finalIndex = max(0, min(targetIndex, maxIndex))

        // 计算目标偏移量
        let targetContentOffsetX = CGFloat(finalIndex) * cellWidthWithSpacing - collectionViewInsetX
        return CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
    }
}
