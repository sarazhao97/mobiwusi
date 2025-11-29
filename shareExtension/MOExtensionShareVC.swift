//
//  MOExtensionShareVC.swift
//  shareExtension
//
//  Created by Mac on 2025/5/28.
//

import Foundation
import UIKit
import SnapKit
import CoreServices
import AVFoundation

@available(iOSApplicationExtension, unavailable)
class MOExtensionShareVC: UIViewController {
    var content:String?
//    0 URL  1 text  2 file
    var contentType:Int = 0
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.extensionContext?.open(URL(string: "mobisuwiShare://open-file?path")!)
    }
    lazy var navBar = {
        let bar  = UIView()
        return bar
    }()
    lazy var lineView = {
        let vi  = UIView()
        vi.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return vi
    }()
    
    lazy var closeBtn = {
        let btn  = UIButton()
        btn.setTitle(NSLocalizedString("取消", comment: ""), for: UIControl.State.normal)
        btn.setTitle(NSLocalizedString("取消", comment: ""), for: UIControl.State.highlighted)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.setTitleColor(UIColor.black, for: UIControl.State.selected)
        return btn
    }()
    
    lazy var titleLable = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.text = "Mobiwusi"
        return label
    }()
    
    lazy var displayImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var fileNameTitle = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 10
        label.textAlignment = .center
        return label
    }()
    
    lazy var sendBtn = {
        let btn  = UIButton()
        btn.setTitle(NSLocalizedString("发送", comment: ""), for: UIControl.State.normal)
        btn.setTitle(NSLocalizedString("发送", comment: ""), for: UIControl.State.highlighted)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.selected)
        btn.backgroundColor = MainSelectColor
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        return btn
    }()
    
    func setupUI(){
        view.addSubview(navBar)
        navBar.addSubview(closeBtn)
        navBar.addSubview(titleLable)
        view.addSubview(lineView)
        view.addSubview(displayImageView)
        
        view.addSubview(fileNameTitle)
        view.addSubview(sendBtn)
        
    }
    
    func setupConstraints(){
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(64)
            
        }
        titleLable.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            
        }
        
        closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        
        displayImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        fileNameTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        
        sendBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(fileNameTitle.snp.bottom).offset(10)
            make.height.equalTo(55)
        }
        
    }
    
    func addAction(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendBtnClick), for: UIControl.Event.touchUpInside)
        

    }
    
    @objc func closeBtnClick(){
        
        self.extensionContext?.completeRequest(returningItems: nil)
    }
    @objc func sendBtnClick(){
        
        guard let  content  else {
            return
        }
        let encodeData = content.data(using: .utf8)
        let encodeStr = encodeData?.base64EncodedString()
        let urlString = String(format: "mobisuwishare://openfile?data=%@&type=%d", encodeStr ?? "",contentType)
        if let url = URL(string: urlString) {
            print("\(extensionContext.debugDescription)")
//            extensionContext?.open(url) { boolValue in
//                print("\(boolValue)")
//                self.extensionContext?.completeRequest(returningItems: nil)
//            }
            UIApplication.shared.open(url, options: [:]) { _ in
                self.extensionContext?.completeRequest(returningItems: nil)
            }
        }
    }
    
    func getSelectedFile(){
        
        let data = extensionContext?.inputItems.first as? NSExtensionItem
        let itemProvider = data?.attachments?.first
        guard let itemProvider else {return}
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url") {dict,error in
                let url = dict as? URL
                if  let url {
                    if url.isFileURL {
                        let destinationURL = self.copyFile(origURl: url)
                        if let destinationURL {
                            self.showNewFileUI(fileUrl: destinationURL)
                        }
                        return
                    }
                }
                self.content = url?.absoluteString
                self.fileNameTitle.text = url?.absoluteString
                self.contentType = 0
            }
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.text") {
            itemProvider.loadItem(forTypeIdentifier: "public.text") {dict,error in
                let plianText = dict as? String
                self.content = plianText
                self.contentType = 1
                DispatchQueue.main.async {
                    self.fileNameTitle.text = plianText
                }
            }
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
            itemProvider.loadItem(forTypeIdentifier: "public.image") {dict,error in
				let imagePath =  dict as? URL
				var image = UIImage(contentsOfFile: imagePath?.relativePath ?? "")
				if image == nil {
					image = dict as? UIImage
				}
                let fileName = "\(UUID().uuidString).jpg"
                
                guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.mobiwusi.mobiwusi") else {
                    print("无法访问共享容器")
                    return
                }
                var destinationURL = containerURL.appendingPathComponent("Library/Caches")
                destinationURL = destinationURL.appendingPathComponent(fileName)
                let fileData = image?.jpegData(compressionQuality: 1.0)
                try? fileData?.write(to: destinationURL)
                self.content = destinationURL.absoluteString
                self.contentType = 2
                DispatchQueue.main.async {
                    self.displayImageView.image = image
                }
            }
            return
        }

        itemProvider.loadFileRepresentation(forTypeIdentifier: kUTTypeItem as String) { url, error in
            if error == nil,let url {
                let destinationURL = self.copyFile(origURl: url)
                if let destinationURL {
                    self.showNewFileUI(fileUrl: destinationURL)
                }
                
            }
        }
        
    }
    
    func showNewFileUI(fileUrl:URL){
        let destinationURL = fileUrl
        
        self.contentType = 2
        self.content = destinationURL.absoluteString
        DispatchQueue.main.async {
            let path = destinationURL.path
            let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif", "webp"]
            let videoExtensions: Set<String> = ["mp4", "mov", "avi", "mkv", "flv", "wmv", "mpeg", "3gp", "webm"]
//            let audioExtensions: Set<String> = ["mp3", "wav", "flac", "aac", "m4a", "oog", "wma", "amr"]
            if imageExtensions.contains(destinationURL.pathExtension.lowercased()) {
                self.displayImageView.image = UIImage.init(contentsOfFile: path)
            }
            if videoExtensions.contains(destinationURL.pathExtension.lowercased()) {
                let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: false]
                let urlAsset = AVURLAsset(url: destinationURL, options: opts)
                let imageGenerator = AVAssetImageGenerator(asset: urlAsset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let time = CMTime(seconds: 0.0, preferredTimescale: 600)
                var actualTime = CMTime.zero
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
                    self.displayImageView.image = UIImage(cgImage: cgImage)
                } catch let error as NSError {
                    print("生成缩略图时出错: \(error.localizedDescription)")
                }
            }
            if self.displayImageView.image == nil {
                self.fileNameTitle.text = destinationURL.lastPathComponent
            }
            
            
        }
    }
    
    func copyFile(origURl:URL)->URL? {
        
        
        let fileName = origURl.lastPathComponent
        
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.mobiwusi.mobiwusi") else {
            print("无法访问共享容器")
            return nil
        }
        var destinationURL = containerURL.appendingPathComponent("Library/Caches")
        destinationURL = destinationURL.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(atPath: destinationURL.path)
            }
            
        }catch {
            print("删除文件失败: \(error.localizedDescription)")
        }
        
        do{
            try FileManager.default.copyItem(at: origURl, to: destinationURL)
        }catch {
            print("保存文件失败: \(error.localizedDescription)")
        }
        
        return destinationURL
    }
    
    
    deinit{
        print("MOExtensionShareVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupUI()
        setupConstraints()
        addAction()
        getSelectedFile()
        
    }
}
