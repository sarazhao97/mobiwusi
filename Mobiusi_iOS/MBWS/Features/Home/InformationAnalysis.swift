//
//  InformationAnalysis.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/4.
//

import SwiftUI
import Foundation
import AVFoundation
import AVKit
import Lottie





struct InformationAnalysis:View {
    var dataItem:IndexItem?
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @State private var isParsing: Bool = false //解析中
    @State private var errorMessage: String? //错误信息
    @State private var parseResult: ParseClipboardData? //解析结果
    @State private var parseComplete: Bool = false
    @State private var loading: Bool = false
    @State private var showImagePreview: Bool = false
    @State private var showVideoPreview: Bool = false
   
  
    


    var body: some View {
          ZStack{
            Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
            VStack(alignment:.leading,spacing:30){
                ZStack(alignment:.topLeading){
                      TextEditor(text: $text)
                        .font(.system(size: 14))
                        .frame(maxWidth:.infinity,maxHeight: 150)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                    if text.isEmpty{
                        Text("请在此输入...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.top, 18)
                     }
                }
                if !parseComplete {
                    HStack{
                            Spacer()
                            Text("开始解析")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            Spacer()    
                        }
                        .padding(.vertical,18)
                        .frame(maxWidth:.infinity)
                        .background(Color(hex: "#9A1E2E"))
                        .cornerRadius(10)
                        .onTapGesture{
                            if text.isEmpty{
                                MBProgressHUD.showMessag("请输入解析内容，文本或者链接", to: nil, afterDelay: 3.0)
                                return
                            }else{
                                // 点击后立即进入加载态：隐藏按钮，显示动画
                                parseResult = nil
                                errorMessage = nil
                                parseComplete = true
                                isParsing = true
                                parseClipboardContent()
                            }
                        }
                }else{
                if !isParsing{
                    if parseResult != nil{
                       HStack{
                        if parseResult?.cate == 3 {
                        HStack{
                            Image("icon_wb@3x_3")
                              .resizable()
                              .frame(width: 30, height: 30)
                            Text(parseResult?.title ?? "")
                             .font(.system(size: 12))
                             .foregroundColor(.black)
                            Spacer()
                       }
                       .padding(.vertical,10)
                       .padding(.horizontal,10)
                       .frame(maxWidth:.infinity)
                       .background(Color(hex:"#EDEEF5"))
                       .cornerRadius(10)
                       }else if (parseResult?.cate == 4){
                        HStack{
                            ZStack{
                             AsyncImage(url: URL(string: parseResult?.preview_url ?? "")) { image in
                               image
                                   .resizable()
                                   .scaledToFill()
                                   .frame(maxWidth: 100, maxHeight: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                           } placeholder: {
                              Image("占位图")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                           }
                           .onTapGesture{
                             showVideoPreview = true                           
                           }
                             Image("icon_data_play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                        }
                            Spacer()
                        }                       
                       }else if (parseResult?.cate == 2){
                            HStack{
                             AsyncImage(url: URL(string: parseResult?.preview_url ?? "")) { image in
                               image
                                   .resizable()
                                   .scaledToFill()
                                   .frame(maxWidth: 100, maxHeight: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                           } placeholder: {
                              Image("占位图")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                           }
                           .onTapGesture{
                             showImagePreview = true
                           }
                            Spacer()
                        }  
                       }else if (parseResult?.cate == 1){
                            HStack{
                                AudioSpectrogram(audioURL: parseResult?.resource_url ?? "")
                           }
                            Spacer()
                        }  
                       }
                       .padding(.vertical,12)
                       .padding(.horizontal,10)
                       .frame(maxWidth:.infinity)
                       .background(Color(hex:"#ffffff"))
                       .cornerRadius(10)

                          HStack(alignment:.center){
                            Spacer()
                            Text("Mobiwusi总结")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Image("四角星_1")
                             .resizable()
                             .frame(width: 20, height: 20)
                            Spacer()    
                        }
                        .padding(.vertical,18)
                        .frame(maxWidth:.infinity)
                        .background(Color(hex: "#9A1E2E"))
                        .cornerRadius(10)
                        .onTapGesture{
                            if parseResult != nil && parseResult?.status == 1  {
                                if  parseResult?.cate == 3 && parseResult?.extract_content != nil{
                                    //先把extract_content保存成txt文件存到本地，然后调上传文件接口，获取返回的相对路径
                                    let fileName = (parseResult?.title ?? "") + ".txt"
                                    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
                                    do {
                                        try parseResult?.extract_content?.write(to: fileURL, atomically: true, encoding: .utf8)
                                        // 调用上传文件接口，上传文件到服务器
                                        uploadFile(fileURL: fileURL)
                                    } catch {
                                        print("写入文件失败: \(error)")
                                    }
                                   
                                }else{
                                    writePasteboardContent()
                                }
                                
                            }else{
                                MBProgressHUD.showMessag("解析失败，请重新解析", to: nil, afterDelay: 3.0)
                            }
                            
                        }

                        HStack{
                            Spacer()
                              Text("什么也不做，去上传")
                                 .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#9A1E2E"))
                            Spacer()
                        }
                        .onTapGesture{
                            uploadFree(isSummarize:0)
                        }


                    }else{
                        HStack{
                            Spacer()
                                VStack(spacing:30){
                                    Image("icon_parse_fail")
                                        .resizable()
                                        .frame(width: 160, height: 160)
                                    Text("链接解析失败")
                                     .font(.system(size: 16))
                                     .foregroundColor(Color(hex:"#626262"))
                                }
                                  
                            Spacer()
                        }
                      
                    }
                }else{
                    if let animation = LottieAnimation.named("link_loading") {
                        HStack {
                            Spacer()
                            LottieView(animation: animation)
                                .playing(loopMode: .loop)
                                .frame(width: 120, height: 120)
                            Spacer()
                        }
                        .padding(.top,30)
                    } else {
                        Text("加载中…")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top,30)
                    }
                }
            }

                Spacer()
              
                   

            }
            .padding(.horizontal,20)
            

            if loading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#9A1E2E")))
                    .scaleEffect(1.5)
            }

            

          }
          .navigationBarTitle("输入文本/URL")
          .navigationBarBackButtonHidden(true)
          .overlay(
            ZStack {
                if showImagePreview {
                    FullScreenImgView(imageURL: parseResult?.resource_url ?? "", isPresented: $showImagePreview)
                }
                if showVideoPreview {
                    FullScreenVideoView(videoURL: parseResult?.resource_url ?? "", isPresented: $showVideoPreview)
                }
            }
        )
          .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
          }
    }

    func uploadFile(fileURL: URL) {
        NetworkManager.shared.uploadFile(fileURL: fileURL, endpoint: APIConstants.Index.uploadFile) { (result: Result<UploadFileResponse, APIError>) in
            switch result {
            case .success(let response):
                if response.code == 1{
                    // 上传成功，返回文件的相对路径
                    let relativePath = response.data?.relative_url ?? ""
                    let fileName = response.data?.original_name ?? ""
                    // 保存相对路径到 UserDefaults
                    UserDefaults.standard.set(relativePath, forKey: "extract_content_path")
                    UserDefaults.standard.set(fileName, forKey: "extract_content_name")
                     //自由传
                    uploadFree(isSummarize:1)
                } else {
                    print("上传文件失败: \(response.msg ?? "未知错误")")
                }
            case .failure(let error):
                print("上传文件失败: \(error.localizedDescription)")
            }
        }
    }

    func parseClipboardContent() {
        // 不要把 parseComplete 置为 false，否则会显示按钮而非 loading
        errorMessage = nil
        var requestBody: [String: Any] = [
               "content": text,
           ]

            // 仅在存在有效 parent_post_id 或 post_id 时添加
           if let parentPostID = dataItem?.parent_post_id, !parentPostID.isEmpty {
               requestBody["parent_post_id"] = parentPostID
           } else if let postID = dataItem?.post_id, !postID.isEmpty {
               requestBody["parent_post_id"] = postID
           }
       
        NetworkManager.shared.post(APIConstants.Index.parseClipboard, 
                                businessParameters: requestBody) { (result: Result<ParseClipboardResponse, APIError>) in
           DispatchQueue.main.async {
               // 结束加载动画
               isParsing = false
               parseComplete = true       
               switch result {
               case .success(let response):
                   if response.code == 1{
                       parseResult = response.data      
                       if parseResult?.extract_content != nil {
                            //parseResult?.extract_content保存本地存储
                            UserDefaults.standard.set(parseResult?.extract_content, forKey: "extract_content")
                       }   
                   } else {
                       parseResult = nil
                       errorMessage = response.msg          

                      MBProgressHUD.showMessag(errorMessage ?? "解析失败", to: nil, afterDelay: 3.0)
                   }
               case .failure(let error):             
                   parseResult = nil
                   errorMessage = error.localizedDescription

                 MBProgressHUD.showMessag(errorMessage ?? "网络错误", to: nil, afterDelay: 3.0)
               }
           }
       }
    
    }

    //MARk： - 总结
    func writePasteboardContent(){
           loading = true
           errorMessage = nil
         let requestBody: [String: Any] = [
                "content_id": parseResult?.id ?? "",
                "is_summarize" : 1
            ]
        
         NetworkManager.shared.post(APIConstants.Index.getNewsSummary, 
                                 businessParameters: requestBody) { (result: Result<WritePasteboardContentResponse, APIError>) in
            DispatchQueue.main.async {
                loading = false      
                switch result {
                case .success(let response):
                    if response.code == 1{
                          MBProgressHUD.showMessag("数据上传成功", to: nil, afterDelay: 3.0)
                            let summarizeSampleVC = MOSummarizeSampleVC()
                            
                            // 设置返回按钮的回调
                            summarizeSampleVC.setBackButtonAction {
                                summarizeSampleVC.dismiss(animated: true)
                            }
                            
                            let navController = UINavigationController(rootViewController: summarizeSampleVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.modalTransitionStyle = .coverVertical
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootVC = window.rootViewController {
                                var topVC = rootVC
                                while let presentedVC = topVC.presentedViewController {
                                    topVC = presentedVC
                                }
                                topVC.present(navController, animated: true)
                            }

                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage ?? "总结失败", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag(errorMessage ?? "网络错误", to: nil, afterDelay: 3.0)
                }
            }
        }
    }

    //MARK: - 自由上传
    func uploadFree(isSummarize: Int){
        loading = true
        errorMessage = nil
        let content = UserDefaults.standard.string(forKey: "extract_content")
        
         var requestBody: [String: Any] = [
               "cate_id": parseResult?.cate,
               "content_id": parseResult?.id ?? 0,
                "is_summarize": isSummarize	
           ]

           if parseResult?.cate == 3 {
                let userDataItem: [String: Any] = [
                    "file_name": UserDefaults.standard.string(forKey: "extract_content_name") ?? "",
                    "url":  UserDefaults.standard.string(forKey: "extract_content_path") ?? ""
                ]
                let userDataArray: [[String: Any]] = [userDataItem]
                if let jsonData = try? JSONSerialization.data(withJSONObject: userDataArray, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    requestBody["user_data"] = jsonString
                } else {
                    requestBody["user_data"] = "[]"
                }
           }else{
             let userDataItem: [String: Any] = [
                    "file_name": parseResult?.title ?? "",
                    "url": parseResult?.resource_url ?? ""
                ]
                let userDataArray: [[String: Any]] = [userDataItem]
                if let jsonData = try? JSONSerialization.data(withJSONObject: userDataArray, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    requestBody["user_data"] = jsonString
                } else {
                    requestBody["user_data"] = "[]"
                }
           }

           // 仅在存在有效 parent_post_id 或 post_id 时添加
           if let parentPostID = dataItem?.parent_post_id, !parentPostID.isEmpty {
               requestBody["parent_post_id"] = parentPostID
           } else if let postID = dataItem?.post_id, !postID.isEmpty {
               requestBody["parent_post_id"] = postID
           }
        
         NetworkManager.shared.post(APIConstants.Scene.freeUploadData, 
                                 businessParameters: requestBody) { (result: Result<FreeUploadDataResponse, APIError>) in
            DispatchQueue.main.async {
                loading = false         
                switch result {
                case .success(let response):
            
                    if response.code == 1{
                         MBProgressHUD.showMessag("数据上传成功", to: nil, afterDelay: 3.0)
                           let summarizeSampleVC = MOSummarizeSampleVC()
                            
                            // 设置返回按钮的回调
                            summarizeSampleVC.setBackButtonAction {
                                summarizeSampleVC.dismiss(animated: true)
                            }
                            
                            let navController = UINavigationController(rootViewController: summarizeSampleVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.modalTransitionStyle = .coverVertical
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootVC = window.rootViewController {
                                var topVC = rootVC
                                while let presentedVC = topVC.presentedViewController {
                                    topVC = presentedVC
                                }
                                topVC.present(navController, animated: true)
                            }

                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                }
            }
        }

    }
}
