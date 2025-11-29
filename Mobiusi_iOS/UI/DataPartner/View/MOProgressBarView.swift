//
//  MOProgressBarView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MOProgressBarView: MOView {
    
    var progressColor:UIColor?  {
        
        didSet{
            self.progressBarInnerView.backgroundColor = progressColor
        }
    }
    
    public let progressBarInnerView:MOView = {
        
        let progressBar = MOView()
        progressBar.cornerRadius(QYCornerRadius.all, radius: 3.5)
        return progressBar
    }()
    
    public var percentage:CGFloat = 0.0{
        didSet{
            progressBarInnerView.snp.remakeConstraints{ make in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(percentage)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressBarInnerView.cornerRadius(QYCornerRadius.all, radius: self.bounds.height/2)
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        self.addSubview(progressBarInnerView)
    }
    
}
