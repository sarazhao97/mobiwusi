//
//  MODataSummarizeStateView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MODataSummarizeStateView:MOView {
    
    @objc public var didViewClick:(()->Void)?
    lazy var leftImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_colorful_four_pointed_star")
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    lazy var titleLabel = {
        let label = UILabel(text: NSLocalizedString("资讯分析师", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(13))
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var stateLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(12))
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var rightImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_black_arrow_r")
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    func setupUI(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewClick))
        self.addGestureRecognizer(tap)
        
        self.addSubview(leftImageView)
        self.addSubview(titleLabel)
        self.addSubview(stateLabel)
        self.addSubview(rightImageView)
    }
    
    func setupConstraints(){
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        leftImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftImageView.snp.right).offset(7)
            make.centerY.equalToSuperview()
        }
        
        stateLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(7)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { make in
            make.left.equalTo(stateLabel.snp.right)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
        
    }
    
    @objc func viewClick(){
        didViewClick?()
    }
    
    func showInProcessStyle(){
        self.stateLabel.text = NSLocalizedString("处理中...", comment: "")
        self.stateLabel.textColor = ColorFC9E09
    }
    
    func showProcessFailedStyle(){
        self.stateLabel.text = NSLocalizedString("处理失败", comment: "")
        self.stateLabel.textColor = ColorFC9E09
    }
    
    func showProcessCompleteStyle(){
        self.stateLabel.text = NSLocalizedString("已完成", comment: "")
        self.stateLabel.textColor = Color34C759
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
    }
}
