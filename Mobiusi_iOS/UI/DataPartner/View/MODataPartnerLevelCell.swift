//
//  MODataPartnerLevelCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MODataPartnerLevelCell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
    var didSelectedCell: ((UITableViewCell) -> Void)?
    var cellHeight:CGFloat = 200
    var levelTitle:UILabel = {
        let label = UILabel(text: NSLocalizedString("当前等级", comment: ""), textColor: BlackColor, font: MOPingFangSCFont(12))
        return label
    }()
    
    var leveImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_level_1_M")
        return imageView
    }()
    
    var pointsBtn:MOButton = {
        let btn = MOButton()
        btn.fixAlignmentBUG()
        btn.setTitle("", titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCFont(12))
        btn.setImage(UIImage(namedNoCache: "icon_points"))
        return btn
    }()
    
    var progressBar:MOProgressBarView = {
        
        let bar = MOProgressBarView()
        bar.progressColor = MainSelectColor
        bar.backgroundColor = ColorD9D9D9
        bar.cornerRadius(QYCornerRadius.all, radius: 2.5)
        return bar
    }()
    
    var bottomBgImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_integral_base")
        return imageView
    }()
    
    var pointsImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_level_1_L")
        return imageView
    }()
    
    
    func configCell(model:MOLevelInfoResModel){
        let mobiPoints = String(format: NSLocalizedString("  Mobi分：%d/%d", comment: ""),model.mobi_point,model.level_point);
        pointsBtn.setTitles(mobiPoints)
        var level = model.level
        if level <= 0 {
            level = 1
        }
        leveImageView.image = UIImage(namedNoCache: "icon_level_\(level)_M")
        pointsImageView.image = UIImage(namedNoCache: "icon_level_\(level)_L")
        
        if model.level_point == 0 {
            progressBar.percentage = 0
        } else {
            progressBar.percentage = CGFloat(Double(model.mobi_point)/Double(model.level_point))
        }
        
    }
    
    
    func setupUI(){
        
        self.addSubview(bottomBgImage)
        self.addSubview(pointsImageView)
        
        self.addSubview(levelTitle)
        self.addSubview(leveImageView)
        self.addSubview(pointsBtn)
        self.addSubview(progressBar)
    }
    
    func setupConstraints(){
        
        bottomBgImage.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        pointsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            
        }
        
        levelTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(15)
            
        }
        
        leveImageView.snp.makeConstraints { make in
            make.top.equalTo(levelTitle.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            
        }
        
        pointsBtn.snp.makeConstraints { make in
            make.top.equalTo(leveImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(pointsBtn.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(self.snp.centerX)
            make.height.equalTo(5)
            
        }
    }
    
    override func addSubViews() {
        setupUI()
        setupConstraints()
    }
}
