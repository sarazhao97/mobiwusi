//
//  SearchResultController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/24.
//

import SwiftUI
import Foundation


struct SearchResultController:View {
    let initialKeyword: String
    @State private var keyword: String = ""
    @State private var errorMessage: String?
    @State private var searchResult: MultiSearchData?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack{
                Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
              VStack(spacing:20){
                     HStack{
                    //返回按钮
                    Button(action:{dismiss()}){
                         Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                        .padding(.trailing,10)
                    
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                   
                    HStack{
                        HStack {
                            TextField("输入关键字/项目ID搜索", text: $keyword)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            // 清除按钮
                            if !keyword.isEmpty {
                                Button(action: {
                                    keyword = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                        Button(action:{
                            if keyword.isEmpty {
                                  MBProgressHUD.showMessag("请输入关键字/项目ID搜索", to: nil, afterDelay: 3.0)
                                return
                            }
                            getSearchResult()
                        }){
                             HStack(alignment:.center){
                            Text("搜索")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background(Color(hex:"#9A1E2E"))
                        .cornerRadius(10)
                        }
                       
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,10)
                    .frame(maxWidth:.infinity, maxHeight: 40)
                    .background(Color.white)
                     .cornerRadius(10)
                   
                    
                }
                .frame(maxWidth: .infinity)

               ScrollView(showsIndicators: false){
                LazyVStack(spacing: 10) {
                    if searchResult?.audio_list.count ?? 0 > 0 {
                        VStack{
                             HStack(alignment:.center){
                                Image("icon_data_yp")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("音频数据")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex:"#333333"))
                                Spacer()
                                }
                                 .padding(.bottom,10)
                                   .padding(.horizontal,12)
                                   .overlay(
                                       Rectangle()
                                           .frame(height: 1)
                                           .foregroundColor(Color(hex: "#E5E5E5"))
                                           .offset(y: 5),
                                       alignment: .bottom
                                   )
                              ForEach(searchResult?.audio_list ?? [], id: \.id) { item in
                                searchResultView(data: item)
                                 .padding(.top,10)
                                   .padding(.horizontal,12)
                            }                      
                        }
                        .padding(.vertical,12)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                   
                   if searchResult?.image_list.count ?? 0 > 0 {
                      VStack{
                            HStack{
                                Image("icon_data_tp@3x_1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("图片数据")
                                .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#333333"))
                                Spacer()
                                }
                               .padding(.bottom,10)
                                   .padding(.horizontal,12)
                                   .overlay(
                                       Rectangle()
                                           .frame(height: 1)
                                           .foregroundColor(Color(hex: "#E5E5E5"))
                                           .offset(y: 5),
                                       alignment: .bottom
                                   )
                               
                             ForEach(searchResult?.image_list ?? [], id: \.id) { item in
                                searchResultView(data: item)
                                  .padding(.top,10)
                                   .padding(.horizontal,12)
                            }
                      }
                       .padding(.vertical,12)
                        .background(Color.white)
                        .cornerRadius(10)
                   }
                   
                   if searchResult?.text_list.count ?? 0 > 0 {
                        VStack{
                             HStack{
                                Image("icon_data_wb")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("文本数据")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex:"#333333"))
                                Spacer()
                                }
                               .padding(.bottom,10)
                                   .padding(.horizontal,12)
                                   .overlay(
                                       Rectangle()
                                           .frame(height: 1)
                                           .foregroundColor(Color(hex: "#E5E5E5"))
                                           .offset(y: 5),
                                       alignment: .bottom
                                   )
                              ForEach(searchResult?.text_list ?? [], id: \.id) { item in
                                    searchResultView(data: item)
                                    .padding(.top,10)
                                    .padding(.horizontal,12)
                              }
                        }
                         .padding(.vertical,12)
                        .background(Color.white)
                        .cornerRadius(10)
                   }

                   if searchResult?.video_list.count ?? 0 > 0 {
                     VStack{
                         HStack{
                                Image("icon_data_sp")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("视频数据")
                                .font(.system(size: 16))
                                 .foregroundColor(Color(hex:"#333333"))
                                Spacer()
                                }
                                 .padding(.bottom,10)
                                   .padding(.horizontal,12)
                                   .overlay(
                                       Rectangle()
                                           .frame(height: 1)
                                           .foregroundColor(Color(hex: "#E5E5E5"))
                                           .offset(y: 5),
                                       alignment: .bottom
                                   )
                        ForEach(searchResult?.video_list ?? [], id: \.id) { item in
                            searchResultView(data: item)
                              .padding(.top,10)
                              .padding(.horizontal,12)
                        }
                     }
                      .padding(.vertical,12)
                        .background(Color.white)
                        .cornerRadius(10)
                   }

                   // 空数据提示：四个列表都为空时显示
                   if (searchResult?.audio_list.isEmpty ?? true)
                        && (searchResult?.image_list.isEmpty ?? true)
                        && (searchResult?.text_list.isEmpty ?? true)
                        && (searchResult?.video_list.isEmpty ?? true) {
                       VStack(spacing: 8) {
                           Image("icon_data_empty")
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 120)
                           Text("无数据")
                               .font(.system(size: 16))
                               .foregroundColor(Color(hex:"#000000"))
                       }
                       .padding(.vertical, 40)
                       .frame(maxWidth: .infinity)
                      
                       
                   }
                   
                }
               }
                Spacer()
              }
              .padding(.horizontal,10)
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .onAppear {
            keyword = initialKeyword
            getSearchResult()
        }
    }

    private func getSearchResult() {
        errorMessage = nil
         let requestBody: [String: Any] = [
                "keyword": keyword
            ]
        NetworkManager.shared.post(APIConstants.Index.searchComposite, 
                                 businessParameters: requestBody) { (result: Result<MultiSearchResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1 {
                        searchResult = response.data
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    //MARK： - 搜索结果视图
    private func searchResultView(data: MultiSearchTaskItem) -> some View {
        HStack(alignment:.center) {
           highlightedText(data.title, keyword: keyword)
           .font(.system(size: 16))
           Spacer()
           Image("Add-one_(添加)")
           .resizable()
           .aspectRatio(contentMode: .fit)
           .frame(width: 20, height: 20)
        }
        .onTapGesture{
             Task { @MainActor in
                let vc = UIHostingController(
                    rootView: TaskDetailController(taskId: data.id, userTaskId: data.user_task_id)
                )
                vc.hidesBottomBarWhenPushed = true
                MOAppDelegate().transition.push(vc, animated: true)
          }
        }
    }
    
    // MARK: - 高亮文本视图
    private func highlightedText(_ text: String, keyword: String) -> some View {
        if keyword.isEmpty {
            return Text(text).foregroundColor(.black)
        }
        
        let parts = text.components(separatedBy: keyword)
        var views: [Text] = []
        
        for (index, part) in parts.enumerated() {
            if !part.isEmpty {
                views.append(Text(part).foregroundColor(.black))
            }
            
            if index < parts.count - 1 {
                views.append(Text(keyword).foregroundColor(Color(hex:"#FF4242")))
            }
        }
        
        return views.reduce(Text(""), +)
    }

  

}