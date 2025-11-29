//
//  SharingManager.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/14.
//

import SwiftUI
import Foundation
import UIKit
import Photos

struct ShareItem: Identifiable {
    let id = UUID()
    let image: String?
    let title: String
}
struct SharingManager:View {
    let ImgUrl: String
    let currentItem: ShareStyleItem?
    let onSaveRequest: (@escaping (String?) -> Void) -> Void
    @State private var sharePaths : [ShareItem] = [
        ShareItem(image: "icon_share_save", title: "保存图片"),
        ShareItem(image: "icon_share_wx", title: "微信好友"),
        ShareItem(image: "icon_share_circle", title: "朋友圈"),
        // ShareItem(image: "icon_share_qq", title: "QQ好友"),
        // ShareItem(image: "icon_share_zone", title: "QQ空间"),
    ]
    @State private var isGenerating: Bool = false
    var body: some View {      
            HStack(spacing: 0){
                ForEach(Array(sharePaths.enumerated()), id: \.offset){ index, item in
                    Button(action:{
                        if index == 0{
                            // 保存图片
                            isGenerating = true
                            onSaveRequest { imageUrl in
                                if let imageUrl = imageUrl {
                                    let imageSaveHelper = ImageSaveHelper()
                                    imageSaveHelper.saveImageToAlbum(from: imageUrl)
                                }
                                isGenerating = false
                            }
                        } else if index == 1 {
                             // 保存图片
                            isGenerating = true
                            onSaveRequest { imageUrl in
                                if let imageUrl = imageUrl {
                                      // 微信好友
                                    shareToWeChat(scene: 0,imageUrl:imageUrl)
                                   
                                }
                                isGenerating = false
                            }
                          
                        } else if index == 2 {
                              // 保存图片
                            isGenerating = true
                            onSaveRequest { imageUrl in
                                if let imageUrl = imageUrl {
                                    // 朋友圈
                                    shareToWeChat(scene: 1,imageUrl:imageUrl)
                                }
                                isGenerating = false
                            }
                        }else if index == 3 {
                            //QQ好友
                            isGenerating = true
                            onSaveRequest { imageUrl in
                                if let imageUrl = imageUrl {
                                    shareToQQFriend(imageUrl: imageUrl)
                                }
                                isGenerating = false
                            }
                        }else{
                            //QQ空间
                            isGenerating = true
                            onSaveRequest { imageUrl in
                                if let imageUrl = imageUrl {
                                    shareToQZone(imageUrl: imageUrl)
                                }
                                isGenerating = false
                            }
                        }

                    }){
                        VStack(spacing:10){
                            if let image = item.image{
                                Image(image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            }
                            Text(item.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity) // 等宽分布
                    }    
                }
            }
            .padding(.vertical,10)
            .padding(.horizontal,10)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges:.bottom)
        
    }
    
    // 分享到微信

    @MainActor
    private func shareToWeChat(scene: Int32, imageUrl: String) {
        // 检查微信是否安装与支持 API
        guard WXApi.isWXAppInstalled() else {
            MBProgressHUD.showMessag("未检测到微信，请安装后再试", to: nil, afterDelay: 2.0)
            return
        }
        if !WXApi.isWXAppSupport() {
            MBProgressHUD.showMessag("当前微信版本不支持", to: nil, afterDelay: 2.0)
            return
        }

        // 解析图片 URL
        guard let url = URL(string: imageUrl) else {
            MBProgressHUD.showMessag("图片地址无效", to: nil, afterDelay: 2.0)
            return
        }

        if url.isFileURL {
            // 本地文件路径，直接读取
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                MBProgressHUD.showMessag("读取图片失败", to: nil, afterDelay: 2.0)
                return
            }
            DispatchQueue.main.async {
                sendWeChatImage(image: image, scene: scene)
            }
        } else {
            // 网络地址，下载后分享
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessag("下载图片失败", to: nil, afterDelay: 2.0)
                    }
                    return
                }
                DispatchQueue.main.async {
                    sendWeChatImage(image: image, scene: scene)
                }
            }.resume()
        }
    }

     
  

}





extension SharingManager {

    @MainActor
    private func sendWeChatImage(image: UIImage, scene: Int32) {
        // 构建图片对象
        let imageObject = WXImageObject()
        // 尝试使用 JPEG 数据，若失败则使用 PNG 数据
        let imageData = image.jpegData(compressionQuality: 0.9) ?? image.pngData()
        guard let imageData, imageData.count > 0 else {
            
            MBProgressHUD.showMessag("图片数据无效", to: nil, afterDelay: 2.0)
            return
        }
        imageObject.imageData = imageData
        
        // 构建消息对象
        let message = WXMediaMessage()
        message.mediaObject = imageObject
        
        // 生成不超过 32KB 的缩略图数据
        let maxThumbBytes = 32 * 1024
        let maxThumbEdge: CGFloat = 120
        let size = image.size
        let longestEdge = max(size.width, size.height)
        let scale = longestEdge > maxThumbEdge ? (maxThumbEdge / longestEdge) : 1.0
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var quality: CGFloat = 0.8
        var thumbData = resized?.jpegData(compressionQuality: quality)
        while (thumbData?.count ?? Int.max) > maxThumbBytes && quality > 0.2 {
            quality -= 0.1
            thumbData = resized?.jpegData(compressionQuality: quality)
        }
        // 最后尝试 PNG（某些透明图可能更小）
        if (thumbData?.count ?? Int.max) > maxThumbBytes {
            thumbData = resized?.pngData()
        }
        if let thumbData, thumbData.count <= maxThumbBytes {
            message.thumbData = thumbData
        }
        
        // 构建请求并发送
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = scene

        WXApi.send(req) { success in
            if !success {
                
                MBProgressHUD.showMessag("分享失败，请重试", to: nil, afterDelay: 1.0)

            }
        }
    }



    @MainActor
    private func shareToQQFriend(imageUrl: String) {
        // 检查 QQ 是否安装与支持分享
        guard QQApiInterface.isQQInstalled() else {
            MBProgressHUD.showMessag("未检测到QQ，请安装后再试", to: nil, afterDelay: 2.0)
            return
        }
        guard QQApiInterface.isSupportShareToQQ() else {
            MBProgressHUD.showMessag("当前QQ版本不支持分享", to: nil, afterDelay: 2.0)
            return
        }
        // 处理授权隐私与 AppId
        TencentOAuth.setIsUserAgreedAuthorization(true)
        TencentOAuth.sharedInstance().setupAppId(QQAppId, enableUniveralLink: false, universalLink: "", delegate: QQSessionDelegateProxy.shared)

        guard let url = URL(string: imageUrl) else {
            MBProgressHUD.showMessag("图片地址无效", to: nil, afterDelay: 2.0)
            return
        }

        if url.isFileURL {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                MBProgressHUD.showMessag("读取图片失败", to: nil, afterDelay: 2.0)
                return
            }
            DispatchQueue.main.async {
                self.sendQQImageToFriend(image: image)
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessag("下载图片失败", to: nil, afterDelay: 2.0)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.sendQQImageToFriend(image: image)
                }
            }.resume()
        }
    }

    @MainActor
    private func shareToQZone(imageUrl: String) {
        // 检查 QQ 是否安装与支持空间分享
        guard QQApiInterface.isQQInstalled() else {
            MBProgressHUD.showMessag("未检测到QQ，请安装后再试", to: nil, afterDelay: 2.0)
            return
        }
        guard QQApiInterface.isSupportPushToQZone() else {
            MBProgressHUD.showMessag("当前QQ版本不支持分享到空间", to: nil, afterDelay: 2.0)
            return
        }
        // 处理授权隐私与 AppId
        TencentOAuth.setIsUserAgreedAuthorization(true)
        TencentOAuth.sharedInstance().setupAppId(QQAppId, enableUniveralLink: false, universalLink: "", delegate: QQSessionDelegateProxy.shared)

        guard let url = URL(string: imageUrl) else {
            MBProgressHUD.showMessag("图片地址无效", to: nil, afterDelay: 2.0)
            return
        }

        if url.isFileURL {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                MBProgressHUD.showMessag("读取图片失败", to: nil, afterDelay: 2.0)
                return
            }
            DispatchQueue.main.async {
                self.sendQQImageToQZone(image: image)
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        MBProgressHUD.showMessag("下载图片失败", to: nil, afterDelay: 2.0)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.sendQQImageToQZone(image: image)
                }
            }.resume()
        }
    }

    @MainActor
    private func sendQQImageToFriend(image: UIImage) {
        let maxImageBytes = 5 * 1024 * 1024
        let resizedImage = resizeImageForShare(image)
        guard var data = resizedImage.jpegData(compressionQuality: 0.9) ?? resizedImage.pngData() else {
            MBProgressHUD.showMessag("图片数据无效", to: nil, afterDelay: 2.0)
            return
        }
        var quality: CGFloat = 0.9
        while data.count > maxImageBytes && quality > 0.3 {
            quality -= 0.1
            if let d = resizedImage.jpegData(compressionQuality: quality) { data = d }
        }
        if data.count > maxImageBytes {
            MBProgressHUD.showMessag("图片过大，请更换更小图片", to: nil, afterDelay: 2.0)
            return
        }
        let imageObject = QQApiImageObject()
        imageObject.data = data
        let req = SendMessageToQQReq(content: imageObject)
        let ret = QQApiInterface.send(req)
        if ret.rawValue != 0 {
            MBProgressHUD.showMessag("分享失败(代码: \(ret.rawValue))", to: nil, afterDelay: 2.0)
        }
    }

    @MainActor
    private func sendQQImageToQZone(image: UIImage) {
        let maxImageBytes = 5 * 1024 * 1024
        let resizedImage = resizeImageForShare(image)
        guard var data = resizedImage.jpegData(compressionQuality: 0.9) ?? resizedImage.pngData() else {
            MBProgressHUD.showMessag("图片数据无效", to: nil, afterDelay: 2.0)
            return
        }
        var quality: CGFloat = 0.9
        while data.count > maxImageBytes && quality > 0.3 {
            quality -= 0.1
            if let d = resizedImage.jpegData(compressionQuality: quality) { data = d }
        }
        if data.count > maxImageBytes {
            MBProgressHUD.showMessag("图片过大，请更换更小图片", to: nil, afterDelay: 2.0)
            return
        }
        // 使用空间专用对象写说说路径
        let qzoneObject = QQApiImageArrayForQZoneObject()
        qzoneObject.imageDataArray = [data]
        let req = SendMessageToQQReq(content: qzoneObject)
        let ret = QQApiInterface.sendReq(toQZone: req)
        if ret.rawValue != 0 {
            MBProgressHUD.showMessag("分享失败(代码: \(ret.rawValue))", to: nil, afterDelay: 2.0)
        }
    }

    // 统一缩放逻辑：最长边压到 1200，便于降低体积
    private func resizeImageForShare(_ image: UIImage) -> UIImage {
        let maxEdge: CGFloat = 1200
        let size = image.size
        let longest = max(size.width, size.height)
        let scale = longest > maxEdge ? (maxEdge / longest) : 1.0
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return result
    }

    // 轻量代理：满足 setupAppId 的 delegate 需求
    private class QQSessionDelegateProxy: NSObject, TencentSessionDelegate {
    nonisolated(unsafe) static let shared = QQSessionDelegateProxy()
    func tencentDidLogin() {}
    func tencentDidNotLogin(_ cancelled: Bool) {}
    func tencentDidNotNetWork() {}
}
}


