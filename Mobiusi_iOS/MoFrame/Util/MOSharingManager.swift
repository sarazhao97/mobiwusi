#if canImport(UIKit)
import UIKit

class MOSharingManager: NSObject {

	@MainActor static let shared = MOSharingManager()
	private var complete: ((_ success:Bool)->Void)?
    private var tencentOAuth: TencentOAuth?

    /// 分享选项，用于控制分享菜单中显示保存到相册还是复制链接
    enum ShareOption {
        /// 自动模式：有图片时显示保存到相册，无图片时显示复制链接
        case auto
        /// 强制显示保存到相册选项
        case shareImage
        /// 强制显示复制链接选项
        case shareLink
    }
    
    private enum ShareType {
        case saveToAlbum, wechatSession, wechatTimeline, qqFriend, qqZone, copyLink

        var model: MOSocialShareModel {
            switch self {
            case .saveToAlbum: return .init(imageName: "icon_save_blue", title: NSLocalizedString("保存到相册", comment: ""))
            case .wechatSession: return .init(imageName: "icon_summarize_share_wechat", title: NSLocalizedString("微信", comment: ""))
            case .wechatTimeline: return .init(imageName: "icon_summarize_share_pyq", title: NSLocalizedString("朋友圈", comment: ""))
            case .qqFriend: return .init(imageName: "icon_summarize_share_qq", title: "QQ")
            case .qqZone: return .init(imageName: "icon_summarize_share_qqZone", title: NSLocalizedString("QQ空间", comment: ""))
            case .copyLink: return .init(imageName: "icon_summarize_link", title: NSLocalizedString("复制链接", comment: ""))
            }
        }
    }

	/// 分享内容到各平台
	/// - Parameters:
	///   - title: 分享标题
	///   - description: 分享描述
	///   - imageUrl: 图片URL
	///   - shareURL: 分享链接
	///   - viewController: 展示分享界面的控制器
	///   - shareOption: 分享选项，控制显示保存到相册还是复制链接
	///     - .auto: 自动根据是否有图片决定（有图片显示保存到相册，无图片显示复制链接）
	///     - .saveToAlbum: 强制显示保存到相册选项
	///     - .copyLink: 强制显示复制链接选项
	///   - complete: 分享完成回调
	@MainActor func share(title: String, description: String, imageUrl: String, shareURL: String, from viewController: UIViewController, shareOption: ShareOption = .auto, complete: ((_ success:Bool)->Void)? = nil) {
        let hasImage = !imageUrl.isEmpty && URL(string: imageUrl) != nil
        let availableTypes = availableShareTypes(hasImage: hasImage, shareOption: shareOption)
        let items = availableTypes.map { $0.model }
		self.complete = complete
        let vc = MOSunmmarizeShareVC.ctrateAlertStyle(items: items)
        // 使用弱引用避免循环引用
        let weakSelf = self
        let weakVC = viewController
        // 捕获所需的值，避免对self的强引用
        let capturedTitle = title
        let capturedDesc = description
        let capturedImageUrl = imageUrl
        let capturedShareURL = shareURL
        let capturedTypes = availableTypes
        
        vc.didSelectedIndex = {[weak self,weak viewController] index, presentedVC in
            guard let self, let viewController else { return }
            let selectedType = capturedTypes[index]

            switch selectedType {
            case .saveToAlbum:
				self.saveImageToAlbum(from: capturedImageUrl, in: viewController)
            case .copyLink:
				self.copyLinkToClipboard(shareURL: capturedShareURL, in: viewController)
            case .wechatSession:
				self.shareToWeChat(title: capturedTitle, description: capturedDesc, imageUrl: capturedImageUrl, shareURL: capturedShareURL, scene:WXScene.init(rawValue: 0),shareOption: shareOption, from: viewController)
            case .wechatTimeline:
				self.shareToWeChat(title: capturedTitle, description: capturedDesc, imageUrl: capturedImageUrl, shareURL: capturedShareURL, scene: WXScene.init(rawValue: 1),shareOption: shareOption,from: viewController)
            case .qqFriend, .qqZone:
				self.shareToQQ(title: capturedTitle, description: capturedDesc, imageUrl: capturedImageUrl, shareURL: capturedShareURL, isToZone: selectedType == .qqZone,shareOption: shareOption, from: viewController)
            }
            presentedVC.dismiss(animated: true)
        }
        viewController.present(vc, animated: true)
    }

    /// 获取可用的分享类型
    /// - Parameters:
    ///   - hasImage: 是否有图片
    ///   - shareOption: 分享选项，控制显示保存到相册还是复制链接
    /// - Returns: 可用的分享类型数组
    private func availableShareTypes(hasImage: Bool = true, shareOption: ShareOption = .auto) -> [ShareType] {
        var types: [ShareType] = []
        
        switch shareOption {
        case .auto:
            // 自动根据是否有图片决定显示保存到相册还是复制链接
            if hasImage {
                types.append(.saveToAlbum)
            } else {
                types.append(.copyLink)
            }
        case .shareImage:
            // 强制显示保存到相册
            types.append(.saveToAlbum)
        case .shareLink:
            // 强制显示复制链接
            types.append(.copyLink)
        }
        
        if WXApi.isWXAppInstalled() {
            types.append(.wechatSession)
            types.append(.wechatTimeline)
        }
        // 移除 QQ 平台分享入口
        // if QQApiInterface.isQQInstalled() {
        //     types.append(.qqFriend)
        //     types.append(.qqZone)
        // }
        return types
    }

	@MainActor private func saveImageToAlbum(from imageUrl: String, in viewController: UIViewController) {
        guard let url = URL(string: imageUrl) else { return }
        (viewController as? MOBaseViewController)?.showActivityIndicator()
        SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak viewController] image, _, _, _, _, _ in
            (viewController as? MOBaseViewController)?.hidenActivityIndicator()
            guard let image = image else {
                (viewController as? MOBaseViewController)?.showMessage(NSLocalizedString("图片下载失败", comment: ""))
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            (viewController as? MOBaseViewController)?.showMessage(NSLocalizedString("保存成功", comment: ""))
        }
    }
    
    @MainActor private func copyLinkToClipboard(shareURL: String, in viewController: UIViewController) {
        UIPasteboard.general.string = shareURL
        (viewController as? MOBaseViewController)?.showMessage(NSLocalizedString("链接已复制", comment: ""))
        complete?(true)
    }

	private func shareToQQ(title: String, description: String, imageUrl: String, shareURL: String?, isToZone: Bool,shareOption: ShareOption,from viewController: UIViewController) {
        TencentOAuth.setIsUserAgreedAuthorization(true)
        tencentOAuth = TencentOAuth.sharedInstance()
        guard let tencentOAuth = tencentOAuth, let url = URL(string: shareURL ?? "") else { return }

        tencentOAuth.setupAppId(QQAppId, enableUniveralLink: false, universalLink: "", delegate: self)

        let previewImageURL = URL(string: imageUrl)
		
		nonisolated(unsafe) let  sendRequest = {(newsObject:QQApiObject?) in
			guard let object = newsObject else {
				self.complete?(false)
				return
			}

			let req = SendMessageToQQReq(content: object)
			let ret =  QQApiInterface.send(req)
			self.complete?(Bool(ret.rawValue == 0))
		}
		
		if shareOption == .shareLink {
			let newsObject = QQApiNewsObject.object(with: url, title: title, description: String(description.prefix(200)), previewImageURL: previewImageURL) as? QQApiObject
			if let newsObject {
				sendRequest(newsObject)
			}
			
		}
		
		
		
		if shareOption == .shareImage {
			
			if let url = URL(string: imageUrl) {
				DispatchQueue.main.async {
					(viewController as? MOBaseViewController)?.showActivityIndicator()
				}
				
				SDWebImageManager.shared.loadImage(with: url, progress: nil) { image, _, _, _, _, _ in
					
					let resizedImage = image?.resize(CGSize(width: (image?.size.width ?? 0) / 5, height: (image?.size.height ?? 0) / 5))
					DispatchQueue.main.async {
						(viewController as? MOBaseViewController)?.hidenActivityIndicator()
					}
					let imageObject = QQApiImageObject()
					imageObject.data = resizedImage?.jpegData(compressionQuality: 1)
					sendRequest(imageObject)
					
				}
			}
		}
        
    }

	@MainActor private func shareToWeChat(title: String, description: String, imageUrl: String, shareURL: String, scene: WXScene, shareOption: ShareOption,from viewController: UIViewController) {
        MOAppDelegate().wxApiDelegate = self

        let message = WXMediaMessage()
        // 按微信限制截断：标题约 512 字节，描述最大 1024 字节
        let safeTitle = truncateUTF8(title, to: 512)
        let safeDesc = truncateUTF8(description, to: 1024)
        message.title = safeTitle
        message.description = safeDesc
		
        let sendRequest = { (thumbImage: UIImage?) in
			
			if shareOption == .shareLink {
				let webpageObject = WXWebpageObject()
				webpageObject.webpageUrl = shareURL
				message.mediaObject = webpageObject
				message.setThumbImage(thumbImage ?? UIImage(namedNoCache: "icon_appIcon"))
			}
			if shareOption == .shareImage {
				let imagepageObject = WXImageObject()
				if let data =  thumbImage?.jpegData(compressionQuality: 1.0) {
					imagepageObject.imageData = data
				}
				message.mediaObject = imagepageObject
			}
			
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.scene = Int32(scene.rawValue)
            req.message = message
			WXApi.send(req) {[weak self] sucess in
				guard let self else {return}
				complete?(sucess)
			}
        }

        if let url = URL(string: imageUrl) {
            (viewController as? MOBaseViewController)?.showActivityIndicator()
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak viewController] image, _, _, _, _, _ in
                (viewController as? MOBaseViewController)?.hidenActivityIndicator()
                let resizedImage = image?.resize(CGSize(width: (image?.size.width ?? 0) / 5, height: (image?.size.height ?? 0) / 5))
                sendRequest(resizedImage)
            }
        } else {
            sendRequest(nil)
        }
    }

    // UTF-8 字节截断（不拆分字符）
    private func truncateUTF8(_ text: String, to maxBytes: Int) -> String {
        guard maxBytes > 0 else { return "" }
        var count = 0
        var result = String()
        result.reserveCapacity(min(text.count, maxBytes))
        for ch in text {
            let chBytes = String(ch).utf8.count
            if count + chBytes > maxBytes { break }
            result.append(ch)
            count += chBytes
        }
        return result
    }
}

extension MOSharingManager: WXApiDelegate, TencentSessionDelegate {
    func onResp(_ resp: BaseResp) {
        // 企业微信客服会话回调转发到 SwiftUI
        if let serviceResp = resp as? WXOpenCustomerServiceResp {
            let info: [String: Any] = [
                "errCode": serviceResp.errCode,
                "extMsg": serviceResp.extMsg ?? ""
            ]
            NotificationCenter.default.post(name: Notification.Name("WXOpenCustomerServiceResp"), object: nil, userInfo: info)
            return
        }
        // 其他类型保持原逻辑（目前为空，可按需补充）
    }

    nonisolated func tencentDidLogin() {}
    nonisolated func tencentDidNotLogin(_ cancelled: Bool) {}
    nonisolated func tencentDidNotNetWork() {}
}
#endif
