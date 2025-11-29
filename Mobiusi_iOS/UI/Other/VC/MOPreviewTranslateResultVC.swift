//
//  MOPreviewTranslateResultVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

#if canImport(UIKit)
import UIKit
import SnapKit
import SDWebImage

class MOPreviewTranslateResultVC: MOBaseToolPreviewImageVC {
	
	private let dataModel: MOTranslateTextRecordItemModel
	
	private lazy var viewPlainTextBtn: MOButton = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_translate_plain_text"))
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.addTarget(self, action: #selector(viewPlainTextButtonTapped), for: .touchUpInside)
		return btn
	}()
	
	// MARK: - Initialization
	init(model: MOTranslateTextRecordItemModel) {
		self.dataModel = model
		super.init(nibName: nil, bundle: nil)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	@objc func viewPlainTextButtonTapped() {
		guard let originalText = dataModel.original_text, let translatedText = dataModel.translate_text else {
			return
		}
		let vc = MOTranslateTextVC(originalText: originalText, translateText: translatedText)
		navigationController?.pushViewController(vc, animated: true)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(viewPlainTextBtn)
		if let imageUrl = URL(string: dataModel.result_url ?? "") {
			previewImageView.sd_setImage(with: imageUrl) {[weak self]image, _, _, _ in
				guard let self else {return}
				if let image {
					if image.size.width > image.size.height {
						previewImageView.contentMode = .scaleAspectFit
					} else {
						previewImageView.contentMode = .scaleAspectFill
					}
				}
			}
		}
		
		viewPlainTextBtn.snp.makeConstraints {
			$0.trailing.equalToSuperview().offset(-14)
			$0.bottom.equalTo(scrollView.snp.bottom).offset(-15)
		}
    }
    
    // MARK: - 重写关闭方法
    override func closeButtonTapped() {
        // 先发送关闭通知，通知 SwiftUI 更新状态
        NotificationCenter.default.post(name: NSNotification.Name("TranslationPreviewDismissed"), object: nil)
        // 然后执行关闭动画
        super.closeButtonTapped()
    }
}


// MARK: - Sharing Logic
extension MOPreviewTranslateResultVC {
	override func showShareSheet() {
        let title = NSLocalizedString("出国翻译官", comment: "")
        let description = dataModel.translate_text ?? ""
        let imageUrl = dataModel.result_url ?? ""
        let shareURL = dataModel.share_url ?? ""
		MOSharingManager.shared.share(title: title, description: description, imageUrl: imageUrl, shareURL: shareURL, from: self,shareOption: .shareImage)
    }
}
#endif
