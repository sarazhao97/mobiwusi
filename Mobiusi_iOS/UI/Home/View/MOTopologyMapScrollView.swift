//
//  MOTopologyMapScrollView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import UIKit
class MOTopologyMapScrollView: MOView {
    
	
	var xAxisView = {
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}()
	var yAxisView = {
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}()
	var scorllView = {
		let vi = UIScrollView()
		vi.backgroundColor = ClearColor
		vi.showsVerticalScrollIndicator = false
		vi.showsHorizontalScrollIndicator = false
		return vi
	}()
	
	
	
    var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    func setupUI(){
		
		
		self.addSubview(xAxisView)
		self.addSubview(yAxisView)
		self.addSubview(scorllView)
		scorllView.minimumZoomScale = 0.2
		scorllView.maximumZoomScale = 10
		scorllView.delegate = self
		scorllView.contentInsetAdjustmentBehavior = .never
		scorllView.automaticallyAdjustsScrollIndicatorInsets = false
		
		scorllView.addSubview(imageView)
        
    }
    
    func setupConstraints(){
		
		yAxisView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.width.equalTo(0.5);
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		xAxisView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(0.5);
			make.top.equalToSuperview()
		}
		
		scorllView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
        imageView.snp.makeConstraints { make in
			make.width.equalTo(xAxisView.snp.width)
			make.height.equalTo(yAxisView.snp.height)
			make.left.greaterThanOrEqualToSuperview()
			make.right.lessThanOrEqualToSuperview()
			make.top.greaterThanOrEqualToSuperview()
			make.bottom.lessThanOrEqualToSuperview()
        }
		imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
		imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
    }
    func addSubViews(){
        setupUI()
        setupConstraints()
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MOTopologyMapScrollView:UIScrollViewDelegate {
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let scrollViewSize = scrollView.bounds.size
		let containerSize = scrollView.contentSize

		let horizontalInset = max((scrollViewSize.width - containerSize.width ) / 2, 0)
		let verticalInset = max((scrollViewSize.height - containerSize.height) / 2, 0)

		scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
		self.setNeedsLayout()
		imageView.setNeedsLayout()
    }
}
