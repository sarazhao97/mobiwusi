//
//  MOTranslateTextOnImageVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/16.
//

import UIKit
import Photos
@objcMembers
class MOTranslateTextOnImageVC: MOBaseViewController {
	
	// 传入首页数据项，用于相机页面上下文（跨 actor 只读，避免隔离报错）
	nonisolated(unsafe) var dataItem: IndexItem?
	nonisolated(unsafe) var lastTransPictureModel:MOTransPictureModel?
	var captureSession: AVCaptureSession!
	var photoOutput: AVCapturePhotoOutput!
	var videoDataOutput: AVCaptureVideoDataOutput!
	let captureSessionQueue = dispatch_queue_t(label: "captureSessionQueue",attributes: DispatchQueue.Attributes.concurrent)
	let videoDataOutputQueue = dispatch_queue_t(label: "VideoDataOutputQueue",qos: .userInteractive)
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_close_gray_38"))
		navBar.contentMode = .right
		return navBar
	}();
	
	lazy var historyBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_history_white_38"))
		return btn
	}()
	
	private lazy var previewImageView = {
		let imageView = UIImageView()
		imageView.backgroundColor = WhiteColor
		imageView.cornerRadius(QYCornerRadius.bottom, radius: 20)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}();
	
	private lazy var takePhotoView =  {
		let vi  = MOTranslateTextBottomView()
		vi.rightBtn.isHidden = true
		return vi
	}()
	private lazy var translateSuccessBottomView =  {
		let vi  = MOTranslateTextBottomView2()
		return vi
	}()
	
	private lazy var translateFailBottomView =  {
		let vi  = MOTranslateTextBottomView3()
		return vi
	}()
	
	lazy var viewPlainTextBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_translate_plain_text"))
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		return btn
	}()
	
	lazy var centerTitleImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_translate_title_image")
		return imageView
	}()
	
	nonisolated
	func requestLibraryAuthorization(complete: (( _ image:UIImage?)->Void)? = nil){
		
		
		PHPhotoLibrary.requestAuthorization {[weak self] status in
			
			DispatchQueue.global().async {
				
				switch status {
				case .authorized:
					// 已授权，执行获取照片逻辑
					DispatchQueue.main.async {
						self?.fetchLatestPhoto(complete:complete)
					}
					
					
				case .denied, .restricted:
					DispatchQueue.main.async {
						complete?(nil)
					}
					
				case .notDetermined:
					// 首次请求，系统已弹窗让用户选择，无需额外处理
					break
				case .limited:
					DispatchQueue.main.async {
						self?.fetchLatestPhoto(complete:complete)
					}
					
				@unknown default:
					break
				}
			}
			
		}
		
	}
	
	func fetchLatestPhoto(complete:(( _ image:UIImage?)->Void)? = nil) {
		// 配置查询选项：按创建时间倒序，取最新的 1 张
		let options = PHFetchOptions()
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		options.fetchLimit = 1 // 只取 1 张（最新的）
		
		// 查询所有照片资产（可根据需求限定类型，如只查图片）
		let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
		
		if let latestAsset = fetchResult.firstObject {
			// 将 PHAsset 转为 UIImage（异步加载，避免阻塞主线程）
			let imageManager = PHImageManager.default()
			let targetSize = CGSize(width: latestAsset.pixelWidth, height: latestAsset.pixelHeight)
			let requestOptions = PHImageRequestOptions()
			requestOptions.isSynchronous = false // 异步加载
			
			imageManager.requestImage(for: latestAsset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, info in
				complete?(image)
			}
		}
	}
	
	func flipImageHorizontally(image: UIImage?) -> UIImage? {
		
		guard let image else {return nil}
		UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
		let context = UIGraphicsGetCurrentContext()
		context?.scaleBy(x: -1.0, y: 1.0)
		context?.translateBy(x: -image.size.width, y: 0)
		image.draw(in: CGRect(origin:.zero, size: image.size))
		let flippedImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return flippedImage
	}
	
	private func takePhoto() {
		let tmpSetting = AVCapturePhotoSettings()
		tmpSetting.isAutoVirtualDeviceFusionEnabled = true
		if let deviceInput = captureSession.inputs.first as? AVCaptureDeviceInput {
			photoOutput.capturePhoto(with: tmpSetting, delegate: self)
		}
	}
	
	
	private func pickerPicture(){
		let imagePickerVC = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
		guard let imagePickerVC else {return}
		imagePickerVC.allowPickingVideo = false
		imagePickerVC.isSelectOriginalPhoto = true
		imagePickerVC.showSelectBtn = true
		imagePickerVC.showSelectedIndex = true
		
		imagePickerVC.modalPresentationStyle = .overFullScreen
		imagePickerVC.modalTransitionStyle = .coverVertical
		
		
		imagePickerVC.didFinishPickingPhotosHandle = { [weak self] (photos,assets,isSelectOriginalPhoto) in
			guard let self else {return}
			let minSize = 30.0
			let maxSize = 4096.0
			if let image = photos?.first {
				if image.size.width < minSize || image.size.height < minSize {
					
					self.showMessage("长宽边至少都在30px以上");
					return
				}
				
				if image.size.width > maxSize || image.size.height > maxSize {
					
					self.showMessage("长宽边至少都在4096px以内");
					return
				}
				
				if image.size.height/image.size.width > 3.0 {
					
					self.showMessage("长宽比例要在3:1以内");
					return
				}
			}
			self.captureSession.stopRunning()
			while  self.captureSession.isRunning {
				self.captureSession.stopRunning()
			}
			let image = photos?.first
			if let image = photos?.first {
				if image.size.width < image.size.height {
					self.previewImageView.contentMode = .scaleAspectFill
				} else {
					self.previewImageView.contentMode = .scaleAspectFit
				}
			}
			
			self.previewImageView.image = image
			self.previewImageView.setNeedsDisplay()
			self.uploadImageAndTranslate()
			
			
		}
		self.present(imagePickerVC, animated: true)
	}
	
	func setupUI(){
		view.backgroundColor = Color162938
		view.addSubview(previewImageView)
		navBar.gobackDidClick = {[weak self] in
			guard let self else {return}
			self.dismiss(animated: true)
			
		}
		view.addSubview(navBar)
		navBar.contentView.addSubview(centerTitleImageView)
		centerTitleImageView.snp.makeConstraints { make in
			make.centerX.equalTo(navBar.titleLabel.snp.centerX)
			make.centerY.equalTo(navBar.titleLabel.snp.centerY).offset(3)
		}
		
		
		MOMediaPermissionManager.shared.requestPermission(for: MediaPermissionType.photoLibrary) {[weak self] permissionStatus in
			if permissionStatus == .authorized || permissionStatus == .restricted {
				guard let self else {return}
				self.fetchLatestPhoto {[weak self] image in
					guard let self else {return}
					guard let image else {return}
					self.takePhotoView.albumBtn.setImage(image)
				}
			}
		}
		
		
		
		takePhotoView.didClickAlbumBtn = {[weak self] in
			guard let self else {return}
			self.pickerPicture()
			
		}
		takePhotoView.didClickTakePhotoBtn = {[weak self] in
			guard let self else {return}
			self.takePhoto()
			
		}
		view.addSubview(takePhotoView)
		viewPlainTextBtn.isHidden = true
		view.addSubview(viewPlainTextBtn)
		
		translateSuccessBottomView.isHidden = true
		translateSuccessBottomView.didClickSaveBtn = {[weak self] in
			guard let self else {return}
			
			if let image = self.previewImageView.image {
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
				self.showMessage(NSLocalizedString("保存成功", comment: ""))
			}
			
		}
		
		translateSuccessBottomView.didClickRetakePhotoBtn = {[weak self] in
			guard let self else {return}
			self.takePhotoView.isHidden = false
			self.translateFailBottomView.isHidden = true
			self.translateSuccessBottomView.isHidden = true
			self.viewPlainTextBtn.isHidden = true
			self.startCaptureSession()
		}
		
		translateSuccessBottomView.didClickShareBtn = {[weak self] in
			
			guard let self else {return}
			if let image =  self.previewImageView.image {
				self.showShareVC()
			}
			
		}
		view.addSubview(translateSuccessBottomView)
		translateFailBottomView.isHidden = true
		translateFailBottomView.didClickRetakePhotoBtn = {[weak self] in
			guard let self else {return}
			self.takePhotoView.isHidden = false
			self.translateFailBottomView.isHidden = true
			self.translateSuccessBottomView.isHidden = true
			self.viewPlainTextBtn.isHidden = true
			self.startCaptureSession()
		}
		
		translateFailBottomView.didClickRetranslationBtn = {[weak self] in
			guard let self else {return}
			
//			self.takePhotoView.isHidden = false
//			self.translateFailBottomView.isHidden = true
//			self.translateSuccessBottomView.isHidden = true
//			self.viewPlainTextBtn.isHidden = true
			self.uploadImageAndTranslate()
			
			
		}
		view.addSubview(translateFailBottomView)
		
		
	}
	func setupCamera(){
		captureSession = AVCaptureSession()
		captureSession.sessionPreset = .photo

		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
		guard let device = discoverySession.devices.first else { return }

		do {
			let input = try AVCaptureDeviceInput(device: device)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}

			videoDataOutput = AVCaptureVideoDataOutput()
			videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
			if captureSession.canAddOutput(videoDataOutput) {
				captureSession.addOutput(videoDataOutput)
			}
			// 获取视频连接
			if let connection = videoDataOutput.connection(with:.video) {
				// 根据设备方向设置视频方向
				let orientation = UIDevice.current.orientation
				switch orientation {
				case .portrait:
					connection.videoOrientation = .portrait
				case .portraitUpsideDown:
					connection.videoOrientation = .portraitUpsideDown
				case .landscapeLeft:
					connection.videoOrientation = .landscapeLeft
				case .landscapeRight:
					connection.videoOrientation = .landscapeRight
				default:
					connection.videoOrientation = .portrait
				}
			}
			
			photoOutput = AVCapturePhotoOutput()
			if captureSession.canAddOutput(photoOutput) {
				captureSession.addOutput(photoOutput)
			}
			
			
		} catch {
			print("Error: \(error.localizedDescription)")
		}
		
		
		
		
	}
	
	func startCaptureSession(){
		let session = self.captureSession
		captureSessionQueue.async {[weak session] in
			guard let session else {return}
			session.startRunning()
		}
	}
	func setupConstraints(){
		
		navBar.rightItemsView.addArrangedSubview(historyBtn)
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		previewImageView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		viewPlainTextBtn.snp.makeConstraints { make in
			make.right.equalToSuperview().offset(-14)
			make.bottom.equalTo(previewImageView.snp.bottom).offset(-15)
		}
		
		takePhotoView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.top.equalTo(previewImageView.snp.bottom)
		}
		
		translateSuccessBottomView.snp.makeConstraints { make in
			make.edges.equalTo(takePhotoView)
		}
		
		translateFailBottomView.snp.makeConstraints { make in
			make.edges.equalTo(takePhotoView)
		}
		
		
	}
	
	func addActions(){
		historyBtn.addTarget(self, action: #selector(historyBtnClick), for: UIControl.Event.touchUpInside)
		viewPlainTextBtn.addTarget(self, action: #selector(viewPlainTextBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	func historyBtnClick() {
		
		let vc = MOTranslateTextRecordVC()
		self.navigationController?.pushViewController(vc, animated: true)
//		MOAppDelegate().transition.push(vc, animated: true)
	}
	
	func viewPlainTextBtnClick() {
		
		if let original_text =  self.lastTransPictureModel?.original_text,let translate_text = self.lastTransPictureModel?.translate_text {
			
			let vc = MOTranslateTextVC(originalText: original_text, translateText: translate_text)
			self.navigationController?.pushViewController(vc, animated: true)
//			MOAppDelegate().transition.push(vc, animated: true)
		}
		
	}
	
	func uploadImageAndTranslate(){
		
		
		self.showActivityIndicator()
		let taskGroup = DispatchGroup()
		let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
		
		let image = self.previewImageView.image
		var mineType = "image/png"
		var imageData = image?.pngData()
		var fileName = NSUUID().uuidString + ".png"
		let maxSize = 4 * 1024 * 1024
		if imageData == nil || imageData?.count ?? 0 > maxSize {
			fileName = NSUUID().uuidString + ".jpeg"
			mineType = "image/jpeg"
			imageData = image?.jpegData(compressionQuality: 1.0)
			let size = imageData?.count ?? 1
			if imageData?.count ?? 0 > maxSize {
				let compressionQuality = CGFloat((maxSize - 5 * 1024) / size)
				imageData = image?.jpegData(compressionQuality: compressionQuality)
			}
		}
		let safeFileName = fileName
		let safeMineType = mineType
		let safeImageData = imageData
		nonisolated(unsafe) var uploadFail = false
		nonisolated(unsafe) var  relative_url = ""
		nonisolated(unsafe) var errorMsg = ""
		
		queue.async {
			taskGroup.enter()
			queue.async(group: taskGroup) {
				MONetDataServer.shared().uploadFile(withFileName: safeFileName, fileData: safeImageData, mimeType: safeMineType) {dict in
					relative_url = dict?["relative_url"] as! String
					taskGroup.leave()
					
				} failure: {  error in
					uploadFail = true
					errorMsg = error?.localizedDescription ?? ""
					taskGroup.leave()
				} loginFail: {
					DispatchQueue.main.async {
						self.hidenActivityIndicator()
					}
					uploadFail = true
					taskGroup.leave()
				}
			}
			taskGroup.wait()
			let newRelative_url = relative_url
			let capturedParentPostID = self.dataItem?.parent_post_id ?? ""
			let capturedPostID = self.dataItem?.post_id ?? ""
			if relative_url.count > 0{
				
				taskGroup.enter()
				queue.async(group: taskGroup) {
					let parentID = !capturedParentPostID.isEmpty ? capturedParentPostID : capturedPostID
					if !parentID.isEmpty {
						MONetDataServer.shared().transPicture(withPath: newRelative_url, parentPostID: parentID) { dict in
							let model = MOTransPictureModel.yy_model(withJSON: dict as Any)
							self.lastTransPictureModel = model
							taskGroup.leave()
						} failure: { error in
							uploadFail = true
							errorMsg = error?.localizedDescription ?? ""
							taskGroup.leave()
						} msg: { (msg: String?) in
							uploadFail = true
							errorMsg = msg ?? ""
							taskGroup.leave()
						} loginFail: {
							DispatchQueue.main.async {
								self.hidenActivityIndicator()
							}
							uploadFail = true
							taskGroup.leave()
						}
					} else {
						MONetDataServer.shared().transPicture(withPath: newRelative_url) { dict in
							let model = MOTransPictureModel.yy_model(withJSON: dict as Any)
							self.lastTransPictureModel = model
							taskGroup.leave()
						} failure: { error in
							uploadFail = true
							errorMsg = error?.localizedDescription ?? ""
							taskGroup.leave()
						} msg: { (msg: String?) in
							uploadFail = true
							errorMsg = msg ?? ""
							taskGroup.leave()
						} loginFail: {
							DispatchQueue.main.async {
								self.hidenActivityIndicator()
							}
							uploadFail = true
							taskGroup.leave()
						}
					}
				}
				
			}
			
			taskGroup.notify(queue: DispatchQueue.main) {@Sendable [weak self] in
				guard let self else {return}
				
				DispatchQueue.main.async {
					self.hidenActivityIndicator()
					if uploadFail {
						self.showErrorMessage(errorMsg,image: UIImage(namedNoCache: "icon_translate_error"))
						self.takePhotoView.isHidden = true
						self.translateSuccessBottomView.isHidden = true
						self.translateFailBottomView.isHidden = false
						return
					}
					self.takePhotoView.isHidden = true
					self.translateSuccessBottomView.isHidden = false
					self.translateFailBottomView.isHidden = true
					self.viewPlainTextBtn.isHidden = false
					self.previewImageView.sd_setImage(with: URL(string: self.lastTransPictureModel?.result_url ?? ""))
				}
				
				
			}
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let fromVc = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.from)
		if (fromVc != nil && takePhotoView.isHidden == false) {
			let session = self.captureSession
			captureSessionQueue.async { [weak session] in
				guard let session else {return}
				session.startRunning()
			}

		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		let toVC = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.to)
		if toVC != nil {
			let session = self.captureSession
			captureSessionQueue.async {@Sendable [weak session] in
				guard let session else {return}
				session.stopRunning()
			}
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupConstraints()
		setupCamera()
		startCaptureSession()
		MOMediaPermissionManager.shared.requestPermission(for: MediaPermissionType.camera) {[weak self] permissionStatus in
			guard let self else {return}
			
			if permissionStatus == .denied {
				MOMediaPermissionManager.shared.showPermissionAlert(for: MediaPermissionType.camera, from: self)
			}
		}
		
		addActions()
    }

}


extension MOTranslateTextOnImageVC{
	
	func showShareVC(){
		
		var items:[MOSocialShareModel] = []
		let item1 = MOSocialShareModel(imageName: "icon_save_blue",title: NSLocalizedString("保存到相册", comment: ""))
		items.append(item1)
		
		if WXApi.isWXAppInstalled() {
			
			let item2 = MOSocialShareModel(imageName: "icon_summarize_share_wechat",title: NSLocalizedString("微信", comment: ""))
			items.append(item2)
			let item3 = MOSocialShareModel(imageName: "icon_summarize_share_pyq",title: NSLocalizedString("朋友圈", comment: ""))
			items.append(item3)
		}
		
		// 已隐藏 QQ/QQ空间分享入口
		// if QQApiInterface.isQQInstalled() {
		// 	let item2 = MOSocialShareModel(imageName: "icon_summarize_share_qq",title: "QQ")
		// 	items.append(item2)
		// 	let item3 = MOSocialShareModel(imageName: "icon_summarize_share_qqZone",title: NSLocalizedString("QQ空间", comment: ""))
		// 	items.append(item3)
		// }
		
		
		
		let vc = MOSunmmarizeShareVC.ctrateAlertStyle(items: items)
		vc.didSelectedIndex = {[weak self] index, vc in
			
			guard let self else {return}
			let item = items[index]
			if item.imageName == "icon_save_blue",let image = self.previewImageView.image {
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			}
			
			let qqImageNames = ["icon_summarize_share_qq", "icon_summarize_share_qqZone"]
			if qqImageNames.contains(item.imageName ?? "") {
				shareToQQ()
			}
			
			if item.imageName == "icon_summarize_share_wechat" {
				shareToWeChat(scene: 0)
			}
			
			if item.imageName == "icon_summarize_share_pyq" {
				shareToWeChat(scene: 1)
			}
			
			vc.dismiss(animated: true)
		}
		
		self.present(vc, animated: true)
		
	}
	
	
	func shareToQQ(){
		TencentOAuth.setIsUserAgreedAuthorization(true)
		TencentOAuth.sharedInstance().setupAppId(QQAppId, enableUniveralLink: false, universalLink: "", delegate: self)
		
		let imageUrl = lastTransPictureModel?.result_url ?? ""
		let url = lastTransPictureModel?.share_url ?? ""
		var shareSubTitle = lastTransPictureModel?.translate_text ?? ""
		if shareSubTitle.count > 200 {
			shareSubTitle = String(shareSubTitle.prefix(200))
		}
		guard let urlLink = URL(string: url) else {return}
		var qqshareQQObject:QQApiNewsObject? = nil
		if let imageURL = URL(string: imageUrl) {
			qqshareQQObject = QQApiNewsObject.object(with: urlLink, title: NSLocalizedString("出国翻译官", comment: ""), description: shareSubTitle, previewImageURL: imageURL) as? QQApiNewsObject
		}
		
		guard let qqshareQQObject else {return}
		
		let qqShareQrequest =  SendMessageToQQReq.init(content: (qqshareQQObject))
		QQApiInterface.send(qqShareQrequest)
		
		
	}
	
	func shareToWeChat(scene:Int32 = 0,complete:(()->Void)?=nil) {
		
		
		MOAppDelegate().wxApiDelegate = self
		let webpageObject = WXWebpageObject()
		
		let imageUrl = lastTransPictureModel?.result_url ?? ""
		let url = lastTransPictureModel?.share_url ?? ""
		let shareSubTitle = lastTransPictureModel?.translate_text ?? ""
		webpageObject.webpageUrl = url
		let wexinMsg = WXMediaMessage()
		wexinMsg.title = "出国翻译官"
		wexinMsg.description = shareSubTitle
		wexinMsg.mediaObject = webpageObject
		
		if let imageURL = URL(string: imageUrl) {
			self.showActivityIndicator()
			SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) {[weak self] image, data, error, SDImageCacheType, _, _ in
				guard let self else {return}
				self.hidenActivityIndicator()
				
				if let image {
					let resizedImage = image.resize(CGSize(width: image.size.width/2, height: image.size.height/2))
					wexinMsg.setThumbImage(resizedImage)
				} else {
					wexinMsg.setThumbImage(UIImage(namedNoCache: "icon_appIcon"))
				}
				
				let wexinRequest = SendMessageToWXReq()
				wexinRequest.bText = false
				wexinRequest.scene = scene
				wexinRequest.message = wexinMsg
				WXApi.send(wexinRequest)
				complete?()
			}
		} else {
			wexinMsg.setThumbImage(UIImage(namedNoCache: "icon_appIcon"))
			let wexinRequest = SendMessageToWXReq()
			wexinRequest.bText = false
			wexinRequest.scene = scene
			wexinRequest.message = wexinMsg
			WXApi.send(wexinRequest)
			complete?()
			
		}
		
	}
}


extension MOTranslateTextOnImageVC:@preconcurrency WXApiDelegate {
	func onResp(_ resp: BaseResp) {
	}
}

extension MOTranslateTextOnImageVC:TencentSessionDelegate {
	nonisolated func tencentDidLogin() {
		
	}
	
	nonisolated func tencentDidNotLogin(_ cancelled: Bool) {
		
	}
	
	nonisolated func tencentDidNotNetWork() {
		
	}
	
	
}

extension MOTranslateTextOnImageVC:@preconcurrency AVCapturePhotoCaptureDelegate {
	
	@MainActor
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error = error {
			self.showErrorMessage(error.localizedDescription)
            return
        }
		self.captureSession.stopRunning()
		while  self.captureSession.isRunning {
			self.captureSession.stopRunning()
		}
		if let imageData = photo.fileDataRepresentation() {
			
			let deviceInput = self.captureSession.inputs.first as! AVCaptureDeviceInput
			let isFront = deviceInput.device.position == .front
			var image = UIImage(data: imageData)
			if isFront {
				image = self.flipImageHorizontally(image:image)
			}
			
			guard let image else {return}
			self.previewImageView.image = image
			self.previewImageView.setNeedsDisplay()
			self.uploadImageAndTranslate()
		}
		
	}
}


extension MOTranslateTextOnImageVC: AVCaptureVideoDataOutputSampleBufferDelegate {
	
	nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

		guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		// 创建 CIImage
		let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
		// 在后台线程进行滤镜处理
		// 在闭包外部获取 ciContext
		
		DispatchQueue.global().async {
			// 创建滤镜
			// 在主线程更新预览层
			DispatchQueue.main.async { [weak self] in
				guard let self else {return}
				let deviceInput = self.captureSession.inputs.first as! AVCaptureDeviceInput
				let isFront = deviceInput.device.position == .front
				var image = UIImage(ciImage: ciImage)
				
				if isFront {
					self.previewImageView.image = self.flipImageHorizontally(image:image)
				} else {
					self.previewImageView.image = image
				}
				
				
			}
		}
	}
}
