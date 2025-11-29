//
//  MOAICameraVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit
import Photos
@objcMembers
class MOAICameraVC: MOBaseViewController {

	var dataList:[MOCateOptionStyleModel] = []
	// 传入首页数据项，用于相机页面上下文（跨 actor 只读，避免隔离报错）
	nonisolated(unsafe) var dataItem: IndexItem?
	nonisolated(unsafe) var lastTransPictureModel:MOTransPictureModel?
	var captureSession: AVCaptureSession!
	var photoOutput: AVCapturePhotoOutput!
	var videoDataOutput: AVCaptureVideoDataOutput!
	nonisolated(unsafe) var currentCheckUUID:String?
	nonisolated(unsafe) var checkTimer:Timer?
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
		let vi  = MOTranslateTextBottomView(offsetBottomHeight: -10)
		return vi
	}()
	
	private lazy var selectStyleView =  {
		let vi  = MOAICameraSelectStyleView()
		return vi
	}()
//	private lazy var translateSuccessBottomView =  {
//		let vi  = MOTranslateTextBottomView2()
//		return vi
//	}()
	
	private lazy var uploadSuceessView =  {
		let vi  = MOTranslateTextBottomView3()
		vi.retranslationBtn.setImage(UIImage())
		vi.retranslationBtn.setTitle(NSLocalizedString("好了通知我", comment: ""), titleColor: WhiteColor!, bgColor: ClearColor, font: MOPingFangSCHeavyFont(15))
		vi.retranslationBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		vi.retranslationBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		vi.retranslationBtn.fixAlignmentBUG()
		return vi
	}()
	
	lazy var centerTitleImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_camera_title_image")
		return imageView
	}()
	
	
//	nonisolated
	
	func requestLibraryAuthorization(complete: (( _ image:UIImage?)->Void)? = nil){
		
		
		PHPhotoLibrary.requestAuthorization {[weak self] status in
			
			DispatchQueue.global().async {
				
				switch status {
				case .authorized:
					// 已授权，执行获取照片逻辑
					DispatchQueue.main.async {
						if let complete {
							self?.fetchLatestPhoto(complete: complete)
						}
						
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
	
	func fetchLatestPhoto(complete: (( _ image:UIImage?)->Void)? = nil) {
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
		let photoSettings = AVCapturePhotoSettings()
		photoSettings.isAutoVirtualDeviceFusionEnabled = true
		photoSettings.flashMode = .auto
		if captureSession.inputs.first is AVCaptureDeviceInput {
			photoOutput.capturePhoto(with: photoSettings, delegate: self)
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
			let minWidth = 600.0
			let minHeight = 800.0
			let maxSize = 4096.0
			if let image = photos?.first {
				if image.size.width < minWidth || image.size.height < minHeight {
					
					self.showMessage("宽至少在600px以上,高至少800px");
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
			if let image = photos?.first {
				if image.size.width < image.size.height {
					self.previewImageView.contentMode = .scaleAspectFill
				} else {
					self.previewImageView.contentMode = .scaleAspectFit
				}
			}
			
			self.previewImageView.image = photos?.first
			self.previewImageView.setNeedsDisplay()
			self.uploadImageAndGenerate()
			
			
		}
		self.present(imagePickerVC, animated: true)
	}
	
	func setupUI(){
		view.backgroundColor = Color162938
		view.addSubview(previewImageView)
		navBar.gobackDidClick = {[weak self] in
			guard let self else {return}
			if (checkTimer != nil) {
				return
			}
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
		
		view.addSubview(takePhotoView)
		
		takePhotoView.didClickAlbumBtn = {[weak self] in
			guard let self else {return}
			self.pickerPicture()
			
		}
		takePhotoView.didClickTakePhotoBtn = {[weak self] in
			guard let self else {return}
			self.takePhoto()
		}
		
		takePhotoView.didClickRightBtn = {[weak self]_ in
			guard let self else {return}
			self.switchCamera()
		}
		view.addSubview(selectStyleView)
//		view.addSubview(translateSuccessBottomView)
		uploadSuceessView.isHidden = true
		uploadSuceessView.didClickRetakePhotoBtn = {[weak self] in
			guard let self else {return}
			self.stopCheckingResult()
			self.hidenActivityIndicator()
			self.selectStyleView.isHidden = false
			self.uploadSuceessView.isHidden = true
			self.takePhotoView.isHidden = false
//			self.translateSuccessBottomView.isHidden = true
			self.startCaptureSession()
		}
		
		uploadSuceessView.didClickRetranslationBtn = {[weak self] in
			guard let self else {return}
			self.stopCheckingResult()
			self.hidenActivityIndicator()
			self.selectStyleView.isHidden = false
			self.uploadSuceessView.isHidden = true
			self.takePhotoView.isHidden = false
			let vc = MOAICameraRecordVC()
			self.navigationController?.pushViewController(vc, animated: true)
			
		}
		view.addSubview(uploadSuceessView)
		
		
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
		captureSessionQueue.async { [weak session] in
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
		
		takePhotoView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalTo(previewImageView.snp.bottom)
		}
		
		
		selectStyleView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.top.equalTo(previewImageView.snp.bottom).offset(10)
		}
		
//		translateSuccessBottomView.snp.makeConstraints { make in
//			make.edges.equalTo(selectStyleView)
//		}
		
		uploadSuceessView.snp.makeConstraints { make in
			make.edges.equalTo(selectStyleView)
		}
		
		
	}
	
	func addActions(){
		historyBtn.addTarget(self, action: #selector(historyBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	func historyBtnClick() {
		if (checkTimer != nil) {
			return
		}
		let vc = MOAICameraRecordVC()
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func uploadImageAndGenerate(){
		
		
		self.showActivityIndicator()
		let taskGroup = DispatchGroup()
		let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
		let selectedIndex = selectStyleView.selectedIndex
		let stylleId = self.dataList[selectedIndex].model_id
		
		let image = self.previewImageView.image
		var mineType = "image/png"
		var imageData = image?.pngData()
		var fileName = NSUUID().uuidString + ".png"
		let maxSize = 5 * 1024 * 1024
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
		nonisolated(unsafe) var  full_url = ""
		nonisolated(unsafe) var errorMsg = ""
		
		queue.async {
			taskGroup.enter()
			queue.async(group: taskGroup) {
				MONetDataServer.shared().uploadFile(withFileName: safeFileName, fileData: safeImageData, mimeType: safeMineType) {dict in
					relative_url = (dict?["relative_url"] as? String) ?? ""
					full_url = (dict?["url"] as? String) ?? ""
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
			if relative_url.count > 0{
				
				// 预先捕获以避免在 @Sendable 闭包中跨 actor 访问
				let capturedParentPostID = self.dataItem?.parent_post_id ?? ""
				let capturedPostID = self.dataItem?.post_id ?? ""
				taskGroup.enter()
				queue.async(group: taskGroup) {
					
					let request = MOGhibliCreateRequest()
					request.style_id = stylleId
					request.url = newRelative_url
					 // 根据预先捕获的字段追加父帖或子帖 ID（避免跨 actor 访问）
					if !capturedParentPostID.isEmpty {
						request.parent_post_id = capturedParentPostID
					} else if !capturedPostID.isEmpty {
						request.parent_post_id = capturedPostID
					}
					request.startRequest { error, data in
						if let error {
							errorMsg = error
							uploadFail = true
							taskGroup.leave()
							return
						}
						self.currentCheckUUID = data as? String
						taskGroup.leave()
						
					}
				}
				
			}
			
			taskGroup.notify(queue: DispatchQueue.main) {@Sendable [weak self] in
				guard let self else {return}
				
				DispatchQueue.main.async {
					self.hidenActivityIndicator()
					if uploadFail {
						self.showErrorMessage(errorMsg)
						self.selectStyleView.isHidden = false
//						self.translateSuccessBottomView.isHidden = true
						self.uploadSuceessView.isHidden = true
						return
					}
					if let url = URL(string: full_url) {
						self.previewImageView.sd_setImage(with: url)
					}
					self.previewImageView.setNeedsDisplay()
					self.selectStyleView.isHidden = true
					self.takePhotoView.isHidden = true
					self.uploadSuceessView.isHidden = false
					self.startcheckResult()
					
				}
				
				
			}
		}
		
	}
	
	func checkResult(){
		if currentCheckUUID == nil {
			self.hidenActivityIndicator()
			stopCheckingResult()
			return
		}
		let request = MOGhibliGetRestulRequest()
		request.uuid = currentCheckUUID
		request.startRequest { [weak self]errorMsg, data in
			guard let self else {
				self?.hidenActivityIndicator()
				return
			}
			if let dataStr = data as? String,dataStr.count > 0 {
				self.hidenActivityIndicator()
				self.currentCheckUUID = nil
				stopCheckingResult()
				let model = MOGhibliHistoryModel()
				model.image_path = dataStr
				let vc = MOAIGeneratePreviewImageVC(model: model)
				let navVC = MONavigationController(rootViewController: vc)
				navVC.modalTransitionStyle = .coverVertical
				navVC.modalPresentationStyle = .overFullScreen
				self.present(navVC, animated: true)
			}
			
		}
	}
	
	func stopCheckingResult(){
		checkTimer?.invalidate()
		checkTimer = nil
	}
	
	func startcheckResult(){
		stopCheckingResult()
		self.showAllowUserInteractionsActivityIndicator()
		checkTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {[weak self] timer in
			guard let self else {return}
			DispatchQueue.main.async {
				self.checkResult()
			}
			
		}
		checkTimer?.fire()
		
	}
	
	func switchCamera() {
		let deviceInput = self.captureSession.inputs.first as! AVCaptureDeviceInput
		let isFront = deviceInput.device.position == .front
		self.captureSession.beginConfiguration()
		self.captureSession.removeInput(deviceInput)
		
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: isFront ? .back:.front)
		guard let device = discoverySession.devices.first else { return }
		do {
			let input = try AVCaptureDeviceInput(device: device)
			if (self.captureSession.canAddInput(input)) {
				self.captureSession.addInput(input)
			}
			let connection = videoDataOutput.connections.first!
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
			self.captureSession.commitConfiguration()
			
		} catch {
			
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let fromVc = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.from)
		if (fromVc != nil && selectStyleView.isHidden == false) {
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
	func loadRequest(){
		let request  = MOCateOptionStyleRequest()
		self.showActivityIndicator()
		request.startRequest { [weak self] errorMsg, data in
			guard let self else {return}
			self.hidenActivityIndicator()
			if let errorMsg {
				self.showErrorMessage(errorMsg)
				return
			}
			let datalist = data as? [MOCateOptionStyleModel]
			if var datalist {
				
				let firstModel =  MOCateOptionStyleModel()
				firstModel.name_zh = " ";
				let imageName = "icon_camera_nostyle@\(Int(UIScreen.main.scale))x"
				let path = Bundle.main.path(forResource: imageName, ofType: "png")
				if let filePath = path{
					let url = URL(fileURLWithPath: filePath)
					firstModel.url = url.absoluteString
					datalist.insert(firstModel, at: 0)
				}
				self.dataList.append(contentsOf: datalist)
				selectStyleView.configView(dataList: dataList)
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
		loadRequest()
	}

}


extension MOAICameraVC:@preconcurrency AVCapturePhotoCaptureDelegate {
	
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
			self.uploadImageAndGenerate()
		}
		
	}
}


extension MOAICameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
	
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
				let image = UIImage(ciImage: ciImage)
				
				if isFront {
					if let newimage = self.flipImageHorizontally(image:image) {
						self.previewImageView.image = newimage
					}
					
				} else {
					self.previewImageView.image = image
				}
//				self.previewImageView.setNeedsDisplay()
				
			}
		}
	}
}
