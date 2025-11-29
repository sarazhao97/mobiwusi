//
//  MOBaseSummarizeInProcessCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation
class MOBaseSummarizeInProcessCell:MOBaseScheduleCell{
    
    lazy var titleLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
        label.numberOfLines = 0
		label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    lazy var attachmentFilesView = {
        let vi = MOView()
        return vi
    }()
    
    lazy var stateView = {
        let vi = MODataSummarizeStateView()
        vi.cornerRadius(QYCornerRadius.all, radius: 6)
        vi.backgroundColor = ColorF6F7FA
        return vi
    }()
    
    func setupUI(){
		self.scheduleVerticalTopView.backgroundColor = BlackColor.withAlphaComponent(0.05)
		self.scheduleVerticalBottomView.backgroundColor = BlackColor.withAlphaComponent(0.05)
        self.dataContentView.categoryDataView.addSubview(titleLabel)
        self.dataContentView.categoryDataView.addSubview(attachmentFilesView)
        self.dataContentView.categoryDataView.addSubview(stateView)
		self.dataContentView.editBtn.removeFromSuperview()
		self.dataContentView.msgBtn.removeFromSuperview()
		self.dataContentView.locationBtn.removeFromSuperview()
		self.dataContentView.didTageLabel.removeFromSuperview()
        stateView.showInProcessStyle()
    }
    
    func setupConstraints(){
		
		dataContentView.mas_updateConstraints({ make in
			make?.right.equalTo()(contentView.mas_right)?.offset()(-14)
		})
		dataContentView.categoryDataView.mas_remakeConstraints { make in
			make?.left.equalTo()(dataContentView.mas_left)
			make?.right.equalTo()(dataContentView.mas_right)
			make?.top.equalTo()(dataContentView.mas_top)
			make?.bottom.equalTo()(dataContentView.mas_bottom)?.offset()(-11)
		}
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(9)
        }
        
        attachmentFilesView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        
        stateView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(attachmentFilesView.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    
    
    public func configCell(){
        
    }
    
    override func addSubViews() {
        super.addSubViews()
        setupUI()
        setupConstraints()
        configCell()
		dataContentView.locationBtn.isHidden = true
		
    }
}
