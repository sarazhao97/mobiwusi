//
//  MOAudioDownloader.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/11.
//

import Foundation
import CryptoKit

class MOAudioDownloader:NSObject {
	// 单例模式
	nonisolated(unsafe) static let shared = MOAudioDownloader()
	
	// 本地缓存目录
	private var cacheDirectory: URL
	private let fileManager = FileManager.default
	private let session: URLSession
	
	override init() {
		// 获取应用缓存目录
		
		cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ProcessingAudioCache")
		
		// 创建缓存目录（如果不存在）
		do {
			try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
		} catch {
			print("Failed to create cache directory: \(error)")
		}
		
		// 配置URLSession
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .useProtocolCachePolicy
		session = URLSession(configuration: config)
		super.init()
	}
	
	func getFileName(url:URL)->String?{
		
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			return nil
		}
		components.query = nil
		let str = components.url?.absoluteString
		let fileExtension = components.url?.pathExtension
		guard let data = str?.data(using: String.Encoding.utf8) else {
			return nil
		}
		
		// SHA-256 哈希
		let hashedData = SHA256.hash(data: data)
		let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
		return hashString + "." + (fileExtension ?? "")
	}
	
	/// 下载音频文件并保存到本地
	func downloadAudio(from url: URL,
					   completion: @escaping (URL?, Error?) -> Void) {
		// 生成缓存文件名（使用URL的哈希值）
		guard let fileName = getFileName(url: url) else { return} // 根据实际格式修改扩展名
		let localURL = cacheDirectory.appendingPathComponent(fileName)
		
		// 检查文件是否已缓存
		if fileManager.fileExists(atPath: localURL.path) {
			print("音频已缓存: \(localURL)")
			completion(localURL, nil)
			return
		}
		
		// 创建下载任务
		let task = session.downloadTask(with: url) { [weak self] location, response, error in
			guard let self = self,
				  let location = location,
				  error == nil else {
					DispatchQueue.main.async {
						completion(nil, error)
					}
				return
			}
			
			// 移动临时文件到缓存目录
			do {
				try self.fileManager.moveItem(at: location, to: localURL)
				DispatchQueue.main.async {
					completion(localURL, nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		
		task.taskDescription = "AudioDownload-\(url.lastPathComponent)"
		task.resume()
	}
	
	/// 获取缓存的音频文件路径
	func cachedAudioPath(for url: URL) -> URL? {
		let fileName = "\(url.absoluteString.hash).mp3"
		let localURL = cacheDirectory.appendingPathComponent(fileName)
		
		return fileManager.fileExists(atPath: localURL.path) ? localURL : nil
	}
	
	/// 清理缓存
	func clearCache(completion: (() -> Void)? = nil) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else { return }
			
			do {
				let files = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil)
				for file in files {
					try self.fileManager.removeItem(at: file)
				}
				DispatchQueue.main.async {
					completion?()
				}
			} catch {
				print("Failed to clear cache: \(error)")
				DispatchQueue.main.async {
					completion?()
				}
			}
		}
	}
}
