//
//  PersonCenterType3Cell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/31.
//

import Foundation

class PersonCenterType3Cell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding  {
    var didSelectedCell: ((UITableViewCell) -> Void)?
    public var cellHeight:CGFloat = 80
    
    public let leftLabel:UILabel = {
        let label = UILabel.init(text: NSLocalizedString("我的空间", comment: ""), textColor: BlackColor, font:MOPingFangSCFont(15.0))
        return label
    }()
    
    public let rightLabel:UILabel = {
        let label = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCFont(14.0))
        label.textColor = MainSelectColor
        return label
    }()
    
    public var percentage:CGFloat = 0.0{
        didSet{
            progressBarInnerView.snp.remakeConstraints{ make in
                make.left.equalTo(progressBar.snp.left)
                make.top.equalTo(progressBar.snp.top)
                make.bottom.equalTo(progressBar.snp.bottom)
                make.width.equalTo(progressBar.snp.width).multipliedBy(percentage)
            }
        }
    }
    
    
    
    public let progressBar:MOView = {
        
        let progressBar = MOView()
        progressBar.backgroundColor = ColorE6E4F2
        progressBar.cornerRadius(QYCornerRadius.all, radius: 3.5)
        return progressBar
    }()
    
    public let progressBarInnerView:MOView = {
        
        let progressBar = MOView()
        progressBar.backgroundColor = MainSelectColor
        progressBar.cornerRadius(QYCornerRadius.all, radius: 3.5)
        return progressBar
    }()
    
    override func addSubViews() {
        
        self.contentView.addSubview(leftLabel)
        self.contentView.backgroundColor = WhiteColor
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.left).offset(32)
            make.top.equalTo(self.contentView.snp.top).offset(23)
        }
        
        self.contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(self.contentView.snp.right).offset(-25)
            make.centerY.equalTo(leftLabel.snp.centerY)
        }
        
        self.contentView.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.left).offset(32)
            make.right.equalTo(self.contentView.snp.right).offset(-25)
            make.top.equalTo(leftLabel.snp.bottom).offset(13.5)
            make.height.equalTo(7)
            
        }
        progressBar.addSubview(progressBarInnerView)
        progressBarInnerView.snp.makeConstraints { make in
            make.left.equalTo(progressBar.snp.left)
            make.top.equalTo(progressBar.snp.top)
            make.bottom.equalTo(progressBar.snp.bottom)
            make.width.equalTo(progressBar.snp.width).multipliedBy(percentage)
        }
        
        
        
    }
    
}
