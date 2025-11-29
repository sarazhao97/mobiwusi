//
//  MOSummarizeImageVideoInprocrssCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation
@objcMembers
class MOSummarizeImageVideoInProcessCell:MOBaseSummarizeInProcessCell {
    
    var didPreviewClick:(()->Void)?
    @objc public func configVideoCell(dataModel:MOGetSummaryListItemModel) {
        
        timeLabel.text = dataModel.create_time
        dataContentView.redDotView.isHidden = true
        for vi in attachmentFilesView.subviews {
            vi.removeFromSuperview()
        }
        
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewClick))
        imageView.addGestureRecognizer(tap)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = ColorEDEEF5
        imageView.cornerRadius(QYCornerRadius.all, radius: 10)
        attachmentFilesView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.snp.width)
            make.width.equalToSuperview().multipliedBy(1.0/3.0).offset(-20.0/3.0)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        let reslut = dataModel.result?.first as? MOUserTaskDataResultModel
        if let url = URL(string: reslut?.preview_url ?? ""){
            imageView.sd_setImage(with: url,placeholderImage: UIImage(namedNoCache: "icon_video_preview"))
        } else {
            imageView.image = UIImage(namedNoCache: "icon_video_preview");
        }
        let playImageView = UIImageView()
        playImageView.contentMode = .scaleAspectFill
        playImageView.image = UIImage(namedNoCache: "icon_data_video_pause")
        imageView.addSubview(playImageView)
        playImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            
        }
        
        if dataModel.summarize_status == 1 {
            stateView.showInProcessStyle()
        } else {
            stateView.showProcessFailedStyle()
        }
        
    }
    
    @objc public func configImageCell(dataModel:MOGetSummaryListItemModel) {
        
        titleLabel.text = dataModel.title
        timeLabel.text = dataModel.create_time
        dataContentView.msgBtn.isHidden = true
        dataContentView.redDotView.isHidden = true
        for vi in attachmentFilesView.subviews {
            vi.removeFromSuperview()
        }
        
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewClick))
        imageView.addGestureRecognizer(tap)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = ColorEDEEF5
        imageView.cornerRadius(QYCornerRadius.all, radius: 10)
        attachmentFilesView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.snp.width)
            make.width.equalToSuperview().multipliedBy(1.0/3.0).offset(-20.0/3.0)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
        if let url = URL(string: reslut?.path ?? ""){
            imageView.sd_setImage(with: url)
        }
        
        if dataModel.summarize_status == 1 {
            stateView.showInProcessStyle()
        } else {
            stateView.showProcessFailedStyle()
        }
        
        
    }
    
    @objc func previewClick(){
        didPreviewClick?()
    }
    
    override func configCell() {
        
    }
}
