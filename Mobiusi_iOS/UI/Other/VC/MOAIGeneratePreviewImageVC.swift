//
//  MOAIGeneratePreviewImageVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit
import SDWebImage

class MOAIGeneratePreviewImageVC: MOBaseToolPreviewImageVC {

	var dataModel:MOGhibliHistoryModel
	init(model: MOGhibliHistoryModel) {
		self.dataModel = model
		super.init(nibName: nil, bundle: nil)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    override func viewDidLoad() {
        super.viewDidLoad()
        // 改为通过 v2.ghibli/detail 接口使用 id 获取 result_url 展示预览图
        let requestBody: [String: Any] = [
            "id": dataModel.id
        ]
        // 在闭包外缓存 fallback，避免在 Sendable 闭包里访问 MainActor 隔离属性
        let fallbackImagePath = dataModel.image_path
        NetworkManager.shared.post(APIConstants.Index.getVariationPhotographerDetail,
                                   businessParameters: requestBody) { (result: Result<GhibliDetailResponse, APIError>) in
            // 计算最终展示的 URL 字符串（在闭包内不直接触碰 UI）
            var finalURLString: String? = nil
            switch result {
            case .success(let response):
                if response.code == 1, let urlStr = response.data?.result_url, !urlStr.isEmpty {
                    finalURLString = urlStr
                } else {
                    finalURLString = fallbackImagePath
                }
            case .failure:
                finalURLString = fallbackImagePath
            }
            // 将 UI 更新封装到 MainActor 上，避免隔离冲突
            Task { @MainActor in
                if let s = finalURLString, let url = URL(string: s) {
                    self.previewImageView.sd_setImage(with: url)
                }
            }
        }
        
    }

}


// MARK: - Sharing Logic
extension MOAIGeneratePreviewImageVC {
    override func showShareSheet() {
        let title = NSLocalizedString("多变摄影师", comment: "")
        let description =  "多变摄影师"
        let imageUrl = dataModel.image_path ?? ""
        let shareURL = dataModel.share_url ?? ""
        MOSharingManager.shared.share(title: title, description: description, imageUrl: imageUrl, shareURL: shareURL, from: self,shareOption: .shareImage)
    }
}
