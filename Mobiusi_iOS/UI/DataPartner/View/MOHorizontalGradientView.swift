//
//  MOHorizontalGradientView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
enum MOGradientDirection {
    case horizontal
    case vertical
    
}
class MOHorizontalGradientView: MOView {
    var gradientLayer:CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0,1]
        return layer
    }()
    
	init(colors:[UIColor],startPoint:CGPoint = CGPoint(x: 0.5, y: 0),endPoint:CGPoint = CGPoint(x: 0.5, y: 1),locations:[NSNumber] = [0,1]) {
        
        var colorNew:[Any] = []
        for color in colors {
            colorNew.append(color.cgColor)
        }
        self.gradientLayer.colors = colorNew
		gradientLayer.startPoint = startPoint
		gradientLayer.endPoint = endPoint
		gradientLayer.locations = locations
        super.init(frame: CGRect())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientLayer.frame.size.width != self.bounds.width ||  gradientLayer.frame.size.height != self.bounds.height {
            
            gradientLayer.frame = self.bounds
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func addSubViews(inFrame frame: CGRect) {
        
        self.layer.insertSublayer(self.gradientLayer, at: 0)
    }
}
