//
//  MOFoodSafetyVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/16.
//

import UIKit
import Photos
import Lottie
import SwiftUI
@objcMembers
class MOFoodSafetyVC: MOBaseViewController {
	
	// 传入首页数据项，用于相机页面上下文（跨 actor 只读，避免隔离报错）
	nonisolated(unsafe) var dataItem: IndexItem?
	nonisolated(unsafe) var analysisResultId:String?
	var captureSession: AVCaptureSession!
	var photoOutput: AVCapturePhotoOutput!
	var videoDataOutput: AVCaptureVideoDataOutput!
	// 新增：闪光灯状态变量，默认关闭
	private var isTorchOn: Bool = false
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
	
	// 新增：闪光灯按钮，使用 Assets 图标
	lazy var flashBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(named: "icon_camera_flash_off"))
		// 图标按比例适配到按钮大小
		btn.imageView?.contentMode = .scaleAspectFit
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
		imageView.image = UIImage(named: "icon_food_safety_officer")
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.size.equalTo(160)
        }   
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
			self.uploadImageAndAnalysis()
			
			
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
		
		// translateSuccessBottomView.didClickShareBtn = {[weak self] in
			
		// 	guard let self else {return}
		// 	if let image =  self.previewImageView.image {
		// 		self.showShareVC()
		// 	}
			
		// }
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
			self.uploadImageAndAnalysis()
			
			
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
		
		// 先添加闪光灯按钮，再添加历史按钮，保证闪光灯在左侧
		navBar.rightItemsView.addArrangedSubview(flashBtn)
		navBar.rightItemsView.addArrangedSubview(historyBtn)
		// 统一按钮尺寸：栈视图等分，按钮宽高一致
		navBar.rightItemsView.alignment = .center
		navBar.rightItemsView.distribution = .fillEqually
		historyBtn.snp.makeConstraints { make in
			make.width.equalTo(38)
			make.height.equalTo(38)
		}
		flashBtn.snp.makeConstraints { make in
			make.width.equalTo(historyBtn.snp.width)
			make.height.equalTo(historyBtn.snp.height)
		}
		
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
	
		// 新增：闪光灯按钮点击事件
		flashBtn.addTarget(self, action: #selector(flashBtnClick), for: .touchUpInside)
	}
	
	func historyBtnClick() {
		
		let vc = MOFoodSafeTextRecordVC()
		self.navigationController?.pushViewController(vc, animated: true)
//		MOAppDelegate().transition.push(vc, animated: true)
	}
	
	
	
	// 新增：打开闪光灯
	@objc func flashBtnClick() {
		if isTorchOn {
			closeTorch()
		} else {
			openTorch()
		}
	}
	
	private func updateFlashButtonUI(on: Bool) {
		DispatchQueue.main.async {
			// 简单状态可视：打开时不透明，关闭时略微降低不透明度
			self.flashBtn.alpha = on ? 1.0 : 0.7
		}
	}
	
	private func openTorch() {
		// 优先使用当前会话的设备
		if let deviceInput = self.captureSession?.inputs.first as? AVCaptureDeviceInput {
			let device = deviceInput.device
			guard device.hasTorch else { updateFlashButtonUI(on: false); return }
			do {
				try device.lockForConfiguration()
				if device.isTorchAvailable {
					// 打开闪光灯，亮度最大
					try device.setTorchModeOn(level: 1.0)
					isTorchOn = true
					updateFlashButtonUI(on: true)
				}
				device.unlockForConfiguration()
			} catch {
				print("Torch could not be used: \(error)")
			}
			return
		}
		// 备用：默认后置广角相机
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), device.hasTorch else {
			updateFlashButtonUI(on: false)
			return
		}
		do {
			try device.lockForConfiguration()
			if device.isTorchAvailable {
				try device.setTorchModeOn(level: 1.0)
				isTorchOn = true
				updateFlashButtonUI(on: true)
			}
			device.unlockForConfiguration()
		} catch {
			print("Torch could not be used: \(error)")
		}
	}
	
	private func closeTorch() {
		// 优先使用当前会话的设备
		if let deviceInput = self.captureSession?.inputs.first as? AVCaptureDeviceInput {
			let device = deviceInput.device
			guard device.hasTorch else { isTorchOn = false; updateFlashButtonUI(on: false); return }
			do {
				try device.lockForConfiguration()
				if device.isTorchAvailable {
					device.torchMode = .off
					isTorchOn = false
					updateFlashButtonUI(on: false)
				}
				device.unlockForConfiguration()
			} catch {
				print("Torch could not be turned off: \(error)")
			}
		} else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), device.hasTorch {
			do {
				try device.lockForConfiguration()
				device.torchMode = .off
				isTorchOn = false
				updateFlashButtonUI(on: false)
				device.unlockForConfiguration()
			} catch {
				print("Torch could not be turned off: \(error)")
			}
		} else {
			isTorchOn = false
			updateFlashButtonUI(on: false)
		}
	}
	func uploadImageAndAnalysis(){
		// 显示加载动画（优先 food_loading，回退 link_loading）
		let animation = LottieAnimation.named("food_loading") ?? LottieAnimation.named("link_loading")
		if let animation {
			let animationView = LottieAnimationView(animation: animation)
			animationView.loopMode = .loop
			animationView.translatesAutoresizingMaskIntoConstraints = false
			
			// 新增：半透明黑色圆角背景容器
			let containerView = UIView()
			containerView.translatesAutoresizingMaskIntoConstraints = false
			containerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
			containerView.layer.cornerRadius = 12
			containerView.clipsToBounds = true
			containerView.tag = 99901 // 便于后续移除
			view.addSubview(containerView)
			
			// 在容器中添加动画视图
			containerView.addSubview(animationView)
			
			// 新增：底部“加载中”文字
			let loadingLabel = UILabel()
			loadingLabel.text = "加载中..."
			loadingLabel.textColor = .white
			loadingLabel.font = UIFont.systemFont(ofSize: 14)
			loadingLabel.textAlignment = .center
			loadingLabel.translatesAutoresizingMaskIntoConstraints = false
			containerView.addSubview(loadingLabel)
			
			// 布局：容器居中、固定宽度，高度由内容撑开
			NSLayoutConstraint.activate([
				containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				containerView.widthAnchor.constraint(equalToConstant: 200),
			
				// 动画视图在容器上方
				animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
				animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
				animationView.widthAnchor.constraint(equalToConstant: 120),
				animationView.heightAnchor.constraint(equalToConstant: 120),
			
				// 文字在动画视图下方，并与容器底部留白
				loadingLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 8),
				loadingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
				loadingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
				loadingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
			])
			
			animationView.play()
				
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
						// self.hidenActivityIndicator()
						Task { @MainActor in
									animationView.stop()
									animationView.removeFromSuperview()
								}
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
						MONetDataServer.shared().analysisFood(withUrl: newRelative_url, parentPostID: parentID) { dict in
							if let m = dict as? [String: Any], let s = m["data"] as? String {
								self.analysisResultId = s
							} else if let s = dict as? String {
								self.analysisResultId = s
							} else {
								self.analysisResultId = ""
							}
							Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
												// let targetID = self.analysisResultId ?? ""
												// if !targetID.isEmpty {
												// 	let hosting = UIHostingController(rootView: MOFoodSafetyAnalysisRecordVC(analysisID: targetID))
												// 	self.navigationController?.pushViewController(hosting, animated: true)
												// }
												let vc = MOFoodSafeTextRecordVC()
                                                self.navigationController?.pushViewController(vc, animated: true)
											}
											taskGroup.leave()
										} failure: { error in
											uploadFail = true
											errorMsg = error?.localizedDescription ?? ""
											Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
											}
											taskGroup.leave()
										} msg: { (msg: String?) in
											uploadFail = true
											errorMsg = msg ?? ""
											Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
											}
											taskGroup.leave()
										} loginFail: {
											DispatchQueue.main.async {
											Task { @MainActor in
													animationView.stop()
													animationView.removeFromSuperview()
												}
											}
											uploadFail = true
											taskGroup.leave()
										}
					} else {
						MONetDataServer.shared().analysisFood(withUrl: newRelative_url, parentPostID: parentID) { dict in
							if let m = dict as? [String: Any], let s = m["data"] as? String {
								self.analysisResultId = s
							} else if let s = dict as? String {
								self.analysisResultId = s
							} else {
								self.analysisResultId = ""
							}
							Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
												// let targetID = self.analysisResultId ?? ""
												// if !targetID.isEmpty {
												// 	let hosting = UIHostingController(rootView: MOFoodSafetyAnalysisRecordVC(analysisID: targetID))
												// 	self.navigationController?.pushViewController(hosting, animated: true)
												// }
												let vc = MOFoodSafeTextRecordVC()
                                                self.navigationController?.pushViewController(vc, animated: true)
											}
											taskGroup.leave()
										} failure: { error in
											uploadFail = true
											errorMsg = error?.localizedDescription ?? ""
											Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
											}
											taskGroup.leave()
										} msg: { (msg: String?) in
											uploadFail = true
											errorMsg = msg ?? ""
											Task { @MainActor in
												animationView.stop()
												animationView.removeFromSuperview()
											}
											taskGroup.leave()
										} loginFail: {
											DispatchQueue.main.async {
												// self.hidenActivityIndicator()
												Task { @MainActor in
													animationView.stop()
													animationView.removeFromSuperview()
												}
											}
											uploadFail = true
											taskGroup.leave()
										}
					}
				}
				
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
		// 页面离开时关闭闪光灯
		closeTorch()
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


extension MOFoodSafetyVC{
	
	// func showShareVC(){
		
	// 	var items:[MOSocialShareModel] = []
	// 	let item1 = MOSocialShareModel(imageName: "icon_save_blue",title: NSLocalizedString("保存到相册", comment: ""))
	// 	items.append(item1)
		
	// 	if WXApi.isWXAppInstalled() {
			
	// 		let item2 = MOSocialShareModel(imageName: "icon_summarize_share_wechat",title: NSLocalizedString("微信", comment: ""))
	// 		items.append(item2)
	// 		let item3 = MOSocialShareModel(imageName: "icon_summarize_share_pyq",title: NSLocalizedString("朋友圈", comment: ""))
	// 		items.append(item3)
	// 	}
		
	// 	// 已隐藏 QQ/QQ空间分享入口
	// 	// if QQApiInterface.isQQInstalled() {
	// 	// 	let item2 = MOSocialShareModel(imageName: "icon_summarize_share_qq",title: "QQ")
	// 	// 	items.append(item2)
	// 	// 	let item3 = MOSocialShareModel(imageName: "icon_summarize_share_qqZone",title: NSLocalizedString("QQ空间", comment: ""))
	// 	// 	items.append(item3)
	// 	// }
		
		
		
	// 	let vc = MOSunmmarizeShareVC.ctrateAlertStyle(items: items)
	// 	vc.didSelectedIndex = {[weak self] index, vc in
			
	// 		guard let self else {return}
	// 		let item = items[index]
	// 		if item.imageName == "icon_save_blue",let image = self.previewImageView.image {
	// 			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
	// 		}
			
		
			
			
			
	// 		vc.dismiss(animated: true)
	// 	}
		
	// 	self.present(vc, animated: true)
		
	// }
	
	
	// func shareToQQ(){
	// 	TencentOAuth.setIsUserAgreedAuthorization(true)
	// 	TencentOAuth.sharedInstance().setupAppId(QQAppId, enableUniveralLink: false, universalLink: "", delegate: self)
		
	// 	let imageUrl = analysisResultId?.result_url ?? ""
	// 	let url = analysisResultId?.share_url ?? ""
	// 	var shareSubTitle = analysisResultId?.translate_text ?? ""
	// 	if shareSubTitle.count > 200 {
	// 		shareSubTitle = String(shareSubTitle.prefix(200))
	// 	}
	// 	guard let urlLink = URL(string: url) else {return}
	// 	var qqshareQQObject:QQApiNewsObject? = nil
	// 	if let imageURL = URL(string: imageUrl) {
	// 		qqshareQQObject = QQApiNewsObject.object(with: urlLink, title: NSLocalizedString("食品安全员", comment: ""), description: shareSubTitle, previewImageURL: imageURL) as? QQApiNewsObject
	// 	}
		
	// 	guard let qqshareQQObject else {return}
		
	// 	let qqShareQrequest =  SendMessageToQQReq.init(content: (qqshareQQObject))
	// 	QQApiInterface.send(qqShareQrequest)
		
		
	// }
	
	
}


extension MOFoodSafetyVC:@preconcurrency WXApiDelegate {
	func onResp(_ resp: BaseResp) {
	}
}

extension MOFoodSafetyVC:TencentSessionDelegate {
	nonisolated func tencentDidLogin() {
		
	}
	
	nonisolated func tencentDidNotLogin(_ cancelled: Bool) {
		
	}
	
	nonisolated func tencentDidNotNetWork() {
		
	}
	
	
}

extension MOFoodSafetyVC:@preconcurrency AVCapturePhotoCaptureDelegate {
	
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
			self.uploadImageAndAnalysis()
		}
		
	}
}


extension MOFoodSafetyVC: AVCaptureVideoDataOutputSampleBufferDelegate {
	
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
