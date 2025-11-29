//
//  CachedAsyncImage.swift
//  Mobiwusi
//
//  Created by Assistant on 2024/01/16.
//

import SwiftUI
import Foundation

// MARK: - 图片缓存管理器
actor ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // 最多缓存100张图片
        cache.totalCostLimit = 50 * 1024 * 1024 // 最多缓存50MB
    }
    
    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }
    
    func removeImage(for key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - 带缓存的异步图片加载器
@MainActor
class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    let url: URL  // 改为public，以便外部访问
    private let cache = ImageCache.shared
    private var cancellable: URLSessionDataTask?
    
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    private func loadImage() {
        let urlString = url.absoluteString
        
        Task {
            // 首先检查缓存
            if let cachedImage = await cache.getImage(for: urlString) {
                await MainActor.run {
                    self.image = cachedImage
                    self.isLoading = false
                }
                return
            }
            
            // 如果缓存中没有，则开始加载
            await MainActor.run {
                self.isLoading = true
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }
                
                // 缓存图片
                await self.cache.setImage(image, for: urlString)
                
                await MainActor.run {
                    self.image = image
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func reload() {
        cancellable?.cancel()
        image = nil
        loadImage()
    }
}

// MARK: - 带缓存的异步图片组件
@MainActor
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @StateObject private var loader: CachedImageLoader
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        
        // 延迟初始化loader，避免主线程隔离问题
        let loaderURL = url ?? URL(string: "about:blank")!
        self._loader = StateObject(wrappedValue: CachedImageLoader(url: loaderURL))
    }
    
    var body: some View {
        Group {
            if let url = url, let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .onAppear {
            // 如果URL改变了，重新加载
            if let url = url, url != loader.url {
                loader.reload()
            }
        }
    }
}

// MARK: - 便利初始化方法
extension CachedAsyncImage where Content == AnyView, Placeholder == AnyView {
    init(url: URL?, placeholderImage: String = "占位图") {
        self.init(
            url: url,
            content: { image in
                AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            },
            placeholder: {
                AnyView(
                    Image(placeholderImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            }
        )
    }
}

// MARK: - 带loading状态的便利初始化
extension CachedAsyncImage {
    init<LoadingView: View>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder loading: @escaping () -> LoadingView
    ) where Placeholder == AnyView {
        self.init(
            url: url,
            content: content,
            placeholder: {
                AnyView(
                    Group {
                        if url != nil {
                            loading()
                        } else {
                            placeholder()
                        }
                    }
                )
            }
        )
    }
}