//
//  MOSummarizeScrollView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOSummarizeScrollView:UIScrollView {
    var dataModel:MOSummaryDetailModel?
    var linkDidClick:(()->Void)?
    lazy var contentView = {
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
	
	lazy var headerView = {
		let vi  = MOSummarizeHeaderView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 15)
		return vi
	}()
    
    lazy var fullTextSummaryView = {
        let vi  = MOTaskIntroductionView()
        vi.titleLabel.text = NSLocalizedString("全文摘要", comment: "")
        
        vi.backgroundColor = WhiteColor
        vi.markView.isHidden = true
        vi.exampleBtn.isHidden = true
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var topologyMapView  = {
        
        let vi  = MOTopologyMapView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var parameterView = {
        let vi  = MOLinkCheckedParameterView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var tagView = {
        let vi  = MOTaskIntroductionView()
        vi.titleLabel.text = NSLocalizedString("标签", comment: "")
        vi.backgroundColor = WhiteColor
        vi.markView.isHidden = true
        vi.exampleBtn.isHidden = true
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var linkSourceView = {
        let vi  = MOTaskIntroductionView()
        vi.titleLabel.text = NSLocalizedString("视频来源/链接", comment: "")
        vi.textLabel.textColor = Color5766E4
        vi.backgroundColor = WhiteColor
        vi.markView.isHidden = true
        vi.exampleBtn.isHidden = true
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    
    func configView(dataModel:MOSummaryDetailModel) {
        
        self.dataModel = dataModel
		
		
		headerView.configView(model: dataModel)
		
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        fullTextSummaryView.textLabel.attributedText =  NSMutableAttributedString.create(with: dataModel.summary ?? "", font: MOPingFangSCMediumFont(14), textColor: BlackColor, paragraphStyle: paragraphStyle)
        
        tagView.textLabel.attributedText = NSMutableAttributedString.create(with: dataModel.tags ?? "", font: MOPingFangSCMediumFont(14), textColor: BlackColor, paragraphStyle: paragraphStyle)
        
        if dataModel.source?.count == 0 {
            linkSourceView.isHidden = true
        } else {
            linkSourceView.textLabel.attributedText = NSMutableAttributedString.create(with: dataModel.source ?? "", font: MOPingFangSCMediumFont(14), textColor: Color5766E4!, paragraphStyle: paragraphStyle)
        }
        parameterView.showDataList(dataList: dataModel.param)
        
        if dataModel.param?.count == 0 {
            parameterView.isHidden = true
            tagView.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(11)
                make.right.equalToSuperview().offset(-11)
                make.top.equalTo(topologyMapView.snp.bottom).offset(10)
            }
            
        }
        
        if let url = URL(string: dataModel.mind_map ?? "") {
            topologyMapView.contentView.imageView.sd_setImage(with: url) { [weak self]image, error, _, _ in
                guard let self else {return}
				topologyMapView.contentView.imageView.setNeedsLayout()
                if let image{
					let maxWidth = SCREEN_WIDTH - 20 - 22
                    let height = image.size.height * maxWidth / image.size.width
                    topologyMapView.contentView.snp.remakeConstraints { make in
                        make.left.equalToSuperview().offset(10)
                        make.right.equalToSuperview().offset(-10)
                        make.width.equalTo(maxWidth)
                        make.height.equalTo(height)
                        make.top.equalTo(topologyMapView.titleLable.snp.bottom).offset(10)
                        make.bottom.equalToSuperview().offset(-10)
                    
                    }
                }
            }
        }
        
        
    }
    
    
    func setupUI(){
        
        self.addSubview(contentView)
		contentView.addSubview(headerView)
        contentView.addSubview(fullTextSummaryView)
        contentView.addSubview(topologyMapView)
        contentView.addSubview(parameterView)
        contentView.addSubview(tagView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        linkSourceView.textLabel.isUserInteractionEnabled = true
        linkSourceView.textLabel.addGestureRecognizer(tap)
        contentView.addSubview(linkSourceView)
        
    }
    
    func setupConstraints(){
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
            
        }
		
		headerView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview().offset(10)
		}
        
        fullTextSummaryView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
			make.top.equalTo(headerView.snp.bottom).offset(10)
        }
        
        topologyMapView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
//            make.height.equalTo(300)
            make.top.equalTo(fullTextSummaryView.snp.bottom).offset(10)
        }
        
        parameterView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.top.equalTo(topologyMapView.snp.bottom).offset(10)
        }
        
        
        tagView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.top.equalTo(parameterView.snp.bottom).offset(10)
        }
        
        linkSourceView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.top.equalTo(tagView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight : -20)
        }
    }
    
    func addSubViews(){
        setupUI()
        setupConstraints()
    }

    @objc func tapClick(){
        linkDidClick?()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
