//
//  MOSummarizeTextInProcessCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
@objcMembers
class MOSummarizeTextInProcessCell: MOBaseSummarizeInProcessCell {

	@objc public var didClickFile:((_ index:Int)->Void)?
    @objc func configFileCell(dataModel:MOGetSummaryListItemModel) {
        
        titleLabel.text = dataModel.title
        timeLabel.text = dataModel.create_time
        dataContentView.msgBtn.isHidden = true
        dataContentView.redDotView.isHidden = true
        for vi in attachmentFilesView.subviews {
            vi.removeFromSuperview()
        }
        let fileItem = MODocFileItemView()
        fileItem.backgroundColor = ColorEDEEF5
        fileItem.cornerRadius(QYCornerRadius.all, radius: 10)
        var model = dataModel.result?.first as? MOGetSummaryListItemResultModel
        DLog("\(model?.file_name)")
        fileItem.fileNameLabel.text = model?.file_name
		fileItem.didCilck = {[weak self] in
			guard let self else {return}
			didClickFile?(0)
		}
        attachmentFilesView.addSubview(fileItem)
        fileItem.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(65)
        }
        
        if dataModel.summarize_status == 1 {
            stateView.showInProcessStyle()
        } else {
            stateView.showProcessFailedStyle()
        }
        
    }
    override func configCell() {
        
    }
}
