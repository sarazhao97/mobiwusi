//
//  MOGradientBorderView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MOGradientBorderView: MOView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientColors:[UIColor]
    
    var innerView:MOView = MOView()
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
	
//	lazy var maskLayer:CAShapeLayer = {
//		let layer = CAShapeLayer()
//		layer.path = UIBezierPath(roundedRect: .zero, cornerRadius: cornerRadius).cgPath
//		layer.lineWidth = 2.0
//		layer.fillColor = UIColor.clear.cgColor
//		layer.strokeColor = UIColor.black.cgColor  // 实际颜色不重要
//		return layer
//	}()
    
    init(gradientColors: [UIColor]) {
        self.gradientColors = gradientColors
        super.init(frame: CGRect())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        // 设置渐变颜色
        var newColors:[Any] = []
        for color in gradientColors {
            newColors.append(color.cgColor)
        }
        gradientLayer.colors = newColors
        // 设置渐变方向，从左到右
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.25,1]
        innerView.backgroundColor = WhiteColor
        layer.addSublayer(innerView.layer)
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        if innerView.layer.frame.width != self.bounds.width - 4 ||
            innerView.layer.frame.height != self.bounds.height - 4 {
            innerView.frame = CGRect(x: 2, y: 2, width: self.bounds.width - 4, height: self.bounds.height - 4)
            innerView.cornerRadius(QYCornerRadius.all, radius: innerView.layer.frame.width/2)
            
        }
    }
}
