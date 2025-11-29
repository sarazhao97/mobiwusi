//
//  MOBaseSummarizeProcesFinishsCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation
class MOBaseSummarizeProcesFinishsCell:MOBaseScheduleCell {
    
	
	var didChangeOpenState:(()->Void)?
	
	var unlikeBtnDidClick:(()->Void)?
	
	var likeBtnDidClick:(()->Void)?
	var shareBtnDidClick:(()->Void)?
	
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
    
    lazy var paramLabel = {
        let label = UILabel(text: "", textColor: Color828282!, font: MOPingFangSCMediumFont(13))
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tagTitleLabel = {
        let label = UILabel(text: "标签：", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tagsLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        return label
    }()
    
    @objc public lazy var briefIntroductionView = {
        let vi = MOSummaryDatailBriefIntroductionView()
        vi.cornerRadius(QYCornerRadius.all, radius: 6)
        vi.backgroundColor = ColorF6F7FA
        return vi
    }()
	
	lazy var likeBtn = {
		let btn = MOButton()
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		btn.setImage(UIImage(namedNoCache: "icon_summarize_linke_nomal"), select: UIImage(namedNoCache: "icon_summarize_linke_selected"))
		btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		btn.contentHorizontalAlignment = .left
		btn.fixAlignmentBUG()
		return btn
	}()
	
	lazy var avatarView = {
		let vi = MOSummarizeAvatarView()
		return vi
	}()
	
	
    
    func setupUI(){
		self.scheduleVerticalTopView.backgroundColor = BlackColor.withAlphaComponent(0.05)
		self.scheduleVerticalBottomView.backgroundColor = BlackColor.withAlphaComponent(0.05)
        self.dataContentView.categoryDataView.addSubview(titleLabel)
        self.dataContentView.categoryDataView.addSubview(attachmentFilesView)
        self.dataContentView.categoryDataView.addSubview(paramLabel)
        
        self.dataContentView.categoryDataView.addSubview(tagTitleLabel)
        self.dataContentView.categoryDataView.addSubview(tagsLabel)
		
        self.dataContentView.categoryDataView.addSubview(briefIntroductionView)
		likeBtn.addTarget(self, action: #selector(likeBtnClick), for: UIControl.Event.touchUpInside)
		self.dataContentView.addSubview(likeBtn)
		self.dataContentView.addSubview(avatarView)
        tagTitleLabel.isHidden = true
        tagsLabel.isHidden = true
		
		self.dataContentView.locationBtn.isHidden = true
		self.dataContentView.locationBtn.addTarget(self, action: #selector(locationBtnClick), for: UIControl.Event.touchUpInside)
		self.dataContentView.editBtn.isHidden = false
		self.dataContentView.editBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		self.dataContentView.editBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		self.dataContentView.editBtn.setImage(UIImage(namedNoCache: "icon_summarize_unlinke_nomal"),select:UIImage(namedNoCache: "icon_summarize_unlinke_selected"))
		self.dataContentView.editBtn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		self.dataContentView.editBtn.fixAlignmentBUG()
		self.didEditBtnClick = {[weak self] in
			guard let self else {return}
			unlikeBtnDidClick?()
		}
//
		self.dataContentView.msgBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		self.dataContentView.msgBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		self.dataContentView.msgBtn.setImage(UIImage(namedNoCache: "icon_other_14x14"), select: UIImage(namedNoCache: "icon_other_14x14"))
		self.dataContentView.msgBtn.setTitle("0", titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
		self.dataContentView.msgBtn.fixAlignmentBUG()
		self.didMsgBtnClick = {[weak self] in
			guard let self else {return}
			shareBtnDidClick?()
		}
        
    }
    
    func setupConstraints(){
        
		dataContentView.mas_updateConstraints({ make in
			make?.right.equalTo()(contentView.mas_right)?.offset()(-14)
		})
		
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
        
        paramLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(attachmentFilesView.snp.bottom).offset(5)
        }
        
        tagTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(paramLabel.snp.bottom).offset(5)
        }
        
        tagsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(attachmentFilesView.snp.bottom).offset(5)
        }
	
        
//        lineView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(13)
//            make.right.equalToSuperview().offset(-10)
//            make.top.equalTo(paramLabel.snp.bottom).offset(10)
//            make.height.equalTo(0.5)
//        }
        
		briefIntroductionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(paramLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
		
		likeBtn.snp.makeConstraints { make in
			make.centerY.equalTo(dataContentView.msgBtn.snp.centerY)
			make.right.equalTo(dataContentView.editBtn.snp.left).offset(-5)
			make.width.greaterThanOrEqualTo(50)
		}
		
		avatarView.snp.makeConstraints { make in
			make.centerY.equalTo(dataContentView.editBtn.snp.centerY)
			make.left.equalToSuperview().offset(21)
			make.right.lessThanOrEqualTo(likeBtn.snp.left).offset(-5)
			make.height.equalTo(18)
		}
    }
	
	@objc public func configBaseCell(dataModel:MOGetSummaryListItemModel) {
		
		self.didEditBtnClick = {[weak self] in
			guard let self else {return}
			unlikeBtnDidClick?()
			
		}
		
		self.didEditBtnClick = {[weak self] in
			guard let self else {return}
			unlikeBtnDidClick?()
			
		}
		
		self.didMsgBtnClick = {[weak self] in
			guard let self else {return}
			shareBtnDidClick?()
			
		}
		
		timeLabel.text = dataModel.create_time
		titleLabel.text = dataModel.title
		timeLabel.text = dataModel.create_time
		let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
		paramLabel.text = String(format: "参数：%@", reslut?.data_param ?? "")
		
		if let user_avatar = URL(string: dataModel.user_avatar ?? ""){
			self.avatarView.avatarImageView.sd_setImage(with: user_avatar)
		}
		self.avatarView.isHidden = false
		self.dataContentView.locationBtn.isHidden = true
		self.avatarView.nickNameLabel.text = dataModel.user_name ?? ""
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 5
		paragraphStyle.lineBreakMode = .byTruncatingTail
		let attrt1 = NSAttributedString.create(with: dataModel.summary ?? "", font: MOPingFangSCMediumFont(12), textColor: BlackColor, paragraphStyle: paragraphStyle)
		self.briefIntroductionView.subTitleLabel.attributedText = attrt1
		
		self.likeBtn.isSelected = dataModel.is_like
		self.likeBtn.setTitles(String(dataModel.like_num))
		
		self.dataContentView.editBtn.isSelected =  dataModel.is_unlike
		self.dataContentView.editBtn.setTitles(String(dataModel.unlike_num))
		self.dataContentView.editBtn.setImage(UIImage(namedNoCache: "icon_summarize_unlinke_nomal"),select:UIImage(namedNoCache: "icon_summarize_unlinke_selected"))
		self.dataContentView.editBtn.contentHorizontalAlignment = .left
		
		
		self.dataContentView.msgBtn.setTitles(String(dataModel.share_num))
		self.dataContentView.msgBtn.setImage(UIImage(namedNoCache: "icon_other_14x14"), select: UIImage(namedNoCache: "icon_other_14x14"))
		self.dataContentView.msgBtn.contentHorizontalAlignment = .left
		
		dataContentView.redDotView.isHidden = true
	}
	
	@objc public func configBaseCellIsMine(dataModel:MOGetSummaryListItemModel) {
		let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
		timeLabel.text = dataModel.create_time
		titleLabel.text = dataModel.title
		paramLabel.text = String(format: "参数：%@", reslut?.data_param ?? "")
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 5
		paragraphStyle.lineBreakMode = .byTruncatingTail
		let attrt1 = NSAttributedString.create(with: dataModel.summary ?? "", font: MOPingFangSCMediumFont(12), textColor: BlackColor, paragraphStyle: paragraphStyle)
		self.briefIntroductionView.subTitleLabel.attributedText = attrt1
		
		self.avatarView.isHidden = true
		self.dataContentView.locationBtn.isHidden = true
		self.dataContentView.locationBtn.setImage(UIImage(namedNoCache: "icon_summarize_open"), select: UIImage(namedNoCache: "icon_summarize_close"))
		self.dataContentView.locationBtn.cornerRadius(QYCornerRadius.all, radius: 11)
		self.dataContentView.locationBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
		self.dataContentView.locationBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 9)
		self.dataContentView.locationBtn.fixAlignmentBUG()
		self.dataContentView.locationBtn.isSelected = !dataModel.is_open
		self.dataContentView.locationBtn.setTitle(dataModel.is_open ? "公开":"私密", titleColor: Color626262!, bgColor: ColorF6F7FA!, font: MOPingFangSCMediumFont(11))
		
		self.likeBtn.setImage(UIImage(namedNoCache: "icon_summarize_linke_nomal"), select: UIImage(namedNoCache: "icon_summarize_linke_selected"))
		self.likeBtn.setTitles(String(dataModel.like_num))
		self.likeBtn.isSelected = dataModel.is_like
		
		self.dataContentView.editBtn.setImage(UIImage(namedNoCache: "icon_other_14x14"),select:UIImage(namedNoCache: "icon_other_14x14"))
		self.dataContentView.editBtn.setTitle(nil, for: UIControl.State.normal)
		self.dataContentView.editBtn.setTitles(String(dataModel.share_num))
		self.dataContentView.editBtn.contentHorizontalAlignment = .left
		self.didEditBtnClick = {[weak self] in
			guard let self else {return}
			shareBtnDidClick?()
			
		}
		
		self.dataContentView.msgBtn.setImage(UIImage(namedNoCache: "icon_task_new_msg"),select:UIImage(namedNoCache: "icon_task_new_msg"))
		self.dataContentView.msgBtn.setTitles(nil)
		self.dataContentView.msgBtn.contentHorizontalAlignment = .center
		
		dataContentView.redDotView.isHidden = true
		
	}
    
	@objc func likeBtnClick(){
		likeBtnDidClick?()
	}
	
	@objc func locationBtnClick(){
		didChangeOpenState?()
	}
	
	func configCell() {
	}
    override func addSubViews() {
        super.addSubViews()
        setupUI()
        setupConstraints()
		configCell()
    }
}
