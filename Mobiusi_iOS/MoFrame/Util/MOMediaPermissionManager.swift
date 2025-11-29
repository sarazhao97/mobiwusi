import AVFoundation
import Photos
import UIKit

/// 媒体权限类型
public enum MediaPermissionType {
	case camera     // 相机权限
	case photoLibrary // 相册权限
}

/// 权限状态
public enum PermissionStatus : Sendable{
	case authorized    // 已授权
	case denied        // 已拒绝
	case restricted    // 受限制（如家长控制）
	case notDetermined // 未决定
	case unknown       // 未知状态
}

/// 权限请求错误
public enum PermissionError: Error {
	case authorizationFailed(status: PermissionStatus)
	case unknownError
}

/// 媒体权限管理器
public class MOMediaPermissionManager {
	
	// MARK: - 单例
	@MainActor public static let shared = MOMediaPermissionManager()
	private init() {}
	
	// MARK: - 权限状态查询
	
	/// 查询权限状态
	public func checkPermissionStatus(for type: MediaPermissionType) -> PermissionStatus {
		switch type {
		case .camera:
			let status = AVCaptureDevice.authorizationStatus(for: .video)
			return convertAVAuthorizationStatus(status)
			
		case .photoLibrary:
			let status: PHAuthorizationStatus
			
			if #available(iOS 14, *) {
				status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			} else {
				status = PHPhotoLibrary.authorizationStatus()
			}
			
			return convertPHAuthorizationStatus(status)
		}
	}
	
	// MARK: - 异步权限请求
	
	/// 异步请求权限
	public func requestPermissionAsync(for type: MediaPermissionType) async throws -> PermissionStatus {
		// 先检查当前状态
		let currentStatus = checkPermissionStatus(for: type)
		
		// 如果已经授权，直接返回
		if currentStatus == .authorized {
			return .authorized
		}
		
		// 如果未决定，请求权限
		if currentStatus == .notDetermined {
			return try await withCheckedThrowingContinuation { continuation in
				requestPermission(for: type) { status in
					switch status {
					case .authorized:
						continuation.resume(returning: .authorized)
					case .denied, .restricted:
						continuation.resume(returning: status)
					default:
						continuation.resume(throwing: PermissionError.unknownError)
					}
				}
			}
		}
		
		// 其他状态（拒绝、受限）直接返回
		return currentStatus
	}
	
	// MARK: - 传统回调权限请求
	
	/// 请求权限（传统回调方式）
	/// nonisolated
	nonisolated
	public func requestPermission(for type: MediaPermissionType,
								 completion: @escaping (PermissionStatus) -> Void) {
		
		// 先检查当前状态
		let currentStatus = checkPermissionStatus(for: type)
		
		guard currentStatus == .notDetermined else {
			completion(currentStatus)
			return
		}
		
		// 请求权限
		switch type {
		case .camera:
			AVCaptureDevice.requestAccess(for: .video) {@Sendable [weak self] _ in
				DispatchQueue.main.async {
					// 重新检查当前状态，而不是直接使用 granted 参数
					let updatedStatus = AVCaptureDevice.authorizationStatus(for: .video)
					let permissionStatus = self?.convertAVAuthorizationStatus(updatedStatus) ?? .unknown
					completion(permissionStatus)
				}
			}
			
		case .photoLibrary:
			if #available(iOS 14, *) {
				PHPhotoLibrary.requestAuthorization(for: .readWrite) {@Sendable [weak self] status in
					DispatchQueue.main.async {
						let convertedStatus = self?.convertPHAuthorizationStatus(status) ?? .unknown
						completion(convertedStatus)
					}
				}
			} else {
				PHPhotoLibrary.requestAuthorization {@Sendable [weak self] status in
					DispatchQueue.main.async {
						guard let self else {return}
						let convertedStatus = self.convertPHAuthorizationStatus(status)
						completion(convertedStatus)
					}
				}
			}
		}
	}
	
	// MARK: - 权限设置引导
	
	/// 显示权限设置提示
	@MainActor public func showPermissionAlert(
		for type: MediaPermissionType,
		from viewController: UIViewController,
		title: String? = nil,
		message: String? = nil,
		completion: (() -> Void)? = nil
	) {
		let alertTitle = title ?? defaultAlertTitle(for: type)
		let alertMessage = message ?? defaultAlertMessage(for: type)
		
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { _ in
			completion?()
		})
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("去设置", comment: ""), style: .default) { _ in
			self.openSettings()
			completion?()
		})
		
		viewController.present(alert, animated: true)
	}
	
	/// 打开系统设置
	@MainActor public func openSettings() {
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	// MARK: - 私有方法
	nonisolated
	private func convertAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
		switch status {
		case .authorized: return .authorized
		case .denied: return .denied
		case .restricted: return .restricted
		case .notDetermined: return .notDetermined
		@unknown default: return .unknown
		}
	}
	
	private func convertPHAuthorizationStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
		switch status {
		case .authorized: return .authorized
		case .denied: return .denied
		case .restricted: return .restricted
		case .notDetermined: return .notDetermined
		case .limited: return .authorized // iOS 14+ 的有限访问视为授权
		@unknown default: return .unknown
		}
	}
	
	private func defaultAlertTitle(for type: MediaPermissionType) -> String {
		switch type {
		case .camera: return NSLocalizedString("请在\"设置－Mobiwusi\"中打开相机权限", comment: "")
		case .photoLibrary: return NSLocalizedString("请在\"设置－Mobiwusi\"中打开相册权限", comment: "")
		}
	}
	
	private func defaultAlertMessage(for type: MediaPermissionType) -> String {
		switch type {
		case .camera: return ""
		case .photoLibrary: return ""
		}
	}
}
