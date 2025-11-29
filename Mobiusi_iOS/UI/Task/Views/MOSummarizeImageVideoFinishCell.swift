//
//  MOSummarizeImageVideoFinishCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation
@objcMembers
class MOSummarizeImageVideoFinishCell:MOBaseSummarizeProcesFinishsCell {
    
    
    var didPreviewClick:(()->Void)?
	
	func configBaseVideoCell(dataModel:MOGetSummaryListItemModel) {
		let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
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
	}
	
	
	func configBaseImageCell(dataModel:MOGetSummaryListItemModel) {
		let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
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
		
		if let url = URL(string: reslut?.path ?? ""){
			imageView.sd_setImage(with: url)
		}
		
	}
    @objc public func configVideoCell(dataModel:MOGetSummaryListItemModel) {
        
		if dataModel.is_mine {
			configVideoCellIsMine(dataModel: dataModel)
			return
		}
		configBaseCell(dataModel: dataModel)
		configBaseVideoCell(dataModel: dataModel)
    }
	
	@objc public func configVideoCellIsMine(dataModel:MOGetSummaryListItemModel) {
		
		configBaseCellIsMine(dataModel: dataModel)
		configBaseVideoCell(dataModel: dataModel)
		
	}
    
    @objc public func configImageCell(dataModel:MOGetSummaryListItemModel) {
        
		
		if dataModel.is_mine {
			configImageCellIsMine(dataModel: dataModel)
			return
		}
		
		configBaseCell(dataModel: dataModel)
		configBaseImageCell(dataModel: dataModel)
    }
	@objc public func configImageCellIsMine(dataModel:MOGetSummaryListItemModel) {
		
		configBaseCellIsMine(dataModel: dataModel)
		configBaseImageCell(dataModel: dataModel)
	}
    
    @objc func previewClick(){
        didPreviewClick?()
    }
    
}
