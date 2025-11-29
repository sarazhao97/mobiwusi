//
//  MOSummarizeTextProcesFinishsCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOSummarizeTextProcesFinishsCell:MOBaseSummarizeProcesFinishsCell {
    
	@objc public var didClickFile:((_ index:Int)->Void)?
    @objc func configFileCell(dataModel:MOGetSummaryListItemModel) {
		
		if dataModel.is_mine {
			configFileCellIsMine(dataModel: dataModel)
			return
		}
        
		configBaseCell(dataModel: dataModel)
        
        let fileItem = MODocFileItemView()
        fileItem.backgroundColor = ColorEDEEF5
		fileItem.fileIconImageView.image = UIImage(namedNoCache: "icon_data_text_doc_34x42")
        fileItem.cornerRadius(QYCornerRadius.all, radius: 10)
        let model = dataModel.result?.first as? MOGetSummaryListItemResultModel
        fileItem.fileNameLabel.text = model?.file_name
		fileItem.didCilck = {[weak self] in
			guard let self else {return}
			didClickFile?(0)
		}
        attachmentFilesView.addSubview(fileItem)
        fileItem.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(65)
        }
		
        
    }
	@objc func configFileCellIsMine(dataModel:MOGetSummaryListItemModel) {
		
		configBaseCellIsMine(dataModel: dataModel)
		let reslut = dataModel.result?.first as? MOGetSummaryListItemResultModel
		dataContentView.redDotView.isHidden = true
		for vi in attachmentFilesView.subviews {
			vi.removeFromSuperview()
		}
		
		
		let fileItem = MODocFileItemView()
		fileItem.backgroundColor = ColorEDEEF5
		fileItem.fileIconImageView.image = UIImage(namedNoCache: "icon_data_text_doc_34x42")
		fileItem.cornerRadius(QYCornerRadius.all, radius: 10)
		let model = dataModel.result?.first as? MOGetSummaryListItemResultModel
		fileItem.fileNameLabel.text = model?.file_name
		fileItem.didCilck = {[weak self] in
			guard let self else {return}
			didClickFile?(0)
		}
		attachmentFilesView.addSubview(fileItem)
		fileItem.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(65)
		}
		
		
	}
    
}
