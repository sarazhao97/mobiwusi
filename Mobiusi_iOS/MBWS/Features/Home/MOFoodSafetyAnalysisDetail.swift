//
//  MOFoodSafetyAnalysisDetail.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/9/28.
//

import SwiftUI
import UIKit



struct DetailItem {
    let name: String
    let describe: String
}

struct MOFoodSafetyAnalysisDetail: View {
    let item: IndexItem?
    let recordItem: MOFoodSafeRecordItemModel?
    @State private var analysisData: FoodAnalysisResultData?
    @State private var isLoading = true
    @State private var hasData = false
    @State private var errorMessage: String?
    @State private var showFullScreen = false
  
    
    // 展开状态
    @State private var showAllSafeIngredient = false
    @State private var showAllAlertIngredient = false
    @State private var showAllRiskIngredient = false
    @State private var showAllNutrition = false
    @Environment(\.dismiss) var dismiss

    private func dismissView() {
        // 优先尝试 SwiftUI 的 dismiss
        dismiss()
        // 兜底：使用 UIKit 关闭当前模态控制器
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }),
           var top = window.rootViewController {
            while let presented = top.presentedViewController {
                top = presented
            }
            top.dismiss(animated: true)
        }
    }

    private func makeNavBarSeamless() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

     private func createWeChatCompatibleShareContent(_ jsonString: String?) -> String {
        // 创建微信兼容的分享内容 - 使用简洁的文本格式
        let shareData = formatShareJSON(jsonString)
        
        var shareText = ""
        
        // 添加标题（如果有）
        if !shareData.title.isEmpty {
            shareText += shareData.title
        }
        
        // 添加描述或简介（如果有且与标题不同）
        let description = shareData.brief.isEmpty ? shareData.description : shareData.brief
        if !description.isEmpty && description != shareData.title {
            if !shareText.isEmpty {
                shareText += "\n"
            }
            shareText += description
        }
        
        // 添加链接
        var shareUrl = ""
        if !(analysisData?.share_url.isEmpty ?? true) {
            shareUrl = analysisData?.share_url ?? ""
        } else if !(analysisData?.share_sharejson.isEmpty ?? true) {
            shareUrl = analysisData?.share_sharejson ?? ""
        } else {
            shareUrl = "https://www.mobiwusi.com"
        }
        
        if !shareText.isEmpty {
            shareText += "\n"
        }
        shareText += shareUrl
        
        return shareText
    }

      private func formatShareJSON(_ jsonString: String?) -> (title: String, description: String, brief: String, url:String) {
        guard let jsonString = jsonString,
              !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            return (title: "分享内容", description: "", brief: "", url:"")
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let title = jsonObject["title"] as? String ?? 
                           jsonObject["name"] as? String ?? 
                           jsonObject["subject"] as? String ?? 
                           "分享内容"
                
                let description = jsonObject["description"] as? String ?? 
                                jsonObject["desc"] as? String ?? 
                                jsonObject["content"] as? String ?? 
                                jsonObject["message"] as? String ?? 
                                ""
                
                let brief = jsonObject["brief"] as? String ?? 
                           jsonObject["summary"] as? String ?? 
                           jsonObject["abstract"] as? String ?? 
                           jsonObject["preview"] as? String ?? 
                           ""
                
                let url = jsonObject["url"] as? String ?? ""
                
                return (title: title, description: description, brief: brief, url:url)
            }
        } catch {
            print("JSON解析错误: \(error.localizedDescription)")
        }
        
        // 如果JSON解析失败，尝试直接使用字符串作为标题
        let fallbackText = jsonString.count > 50 ? String(jsonString.prefix(50)) + "..." : jsonString
        return (title: fallbackText, description: "", brief: fallbackText, url:"")
    }


    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "B9E9AB"), location: 0.0),
                    .init(color: Color(hex: "F7F8FA"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if hasData, let data = analysisData {
                ScrollView {
                    VStack(spacing: 10) {
                        // 简介和配图 - 添加顶部间距避免被导航栏遮挡
                        analysisIntroSection(data)
                            
                        
                        // 配料分析
                        ingredientAnalysisSection(data)
                        
                        // 营养成分
                        if !data.nutrient_percent.isEmpty {


                            nutritionAnalysisSection(data)
                        }
                        
                        // 健康建议
                        if !data.suggested_crowd.isEmpty || !data.unsuggested_crowd.isEmpty {
                            healthAdviceSection(data)
                        }
                        
                        // 详细说明
                        if !createDetailDescFromResponse(data).isEmpty {
                            detailDescriptionSection(data)
                        }
                    }
                    .padding(.bottom, 32)
                }
            } else {
                // 无数据状态
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("分享已过期")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 返回按钮动作
                    dismissView()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                 Button(action:{
                        let title = "食品安全员"
                        let description = "食品安全员"
                        let imageUrl = analysisData?.image_url ?? ""
                        let shareURL = analysisData?.share_url ?? ""
                        // 获取当前的UIViewController
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        
                        var currentVC = rootViewController
                        while let presentedVC = currentVC.presentedViewController {
                            currentVC = presentedVC
                        }

                       MOSharingManager.shared.share(
                            title: title,
                            description: description,
                            imageUrl: imageUrl,
                            shareURL: shareURL,
                            from: currentVC,
                            shareOption: .shareLink
                        ) { success in
                            // 只有分享成功才调用统计接口
                            if success {
                              
                            }
                        }
                       }
                 }) {
                   Image("分享_1")
                    .resizable()
                    .frame(width: 24, height: 24)
                    
                }
            }
        }
       
        .onAppear {
            loadAnalysisData()
            makeNavBarSeamless()
        }
        .toolbarBackground(Color(hex: "B9E9AB"), for: .navigationBar)
        // .toolbarBackground(.visible, for: .navigationBar)
        
    }
    
    // MARK: - 简介部分
    @ViewBuilder
    private func analysisIntroSection(_ data: FoodAnalysisResultData) -> some View {
        ZStack {     
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    // 评分
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(data.score)")
                            .font(.custom("PingFangSC-Heavy", size: 42))
                        Text("分")
                            .font(.custom("PingFangSC-Heavy", size: 16))
                            .padding(.top,8)
                    }
                    
                    // 进度条
                    progressBarView(score: data.score)
                    
                    Text(data.score_describe.isEmpty ? "暂无描述" : data.score_describe)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 24)
                
                Spacer()
                
                // 图片
                AsyncImage(url: URL(string: data.image_url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 144, height: 144)
                .cornerRadius(10)
                .padding(.trailing, 24)
                 .onTapGesture {
                    showFullScreen.toggle()
                }
                .fullScreenCover(isPresented: $showFullScreen) {
                        fullScreenView(data.image_url)
        }
            }
        }
    }

      // 全屏视图
    @ViewBuilder
    private func fullScreenView(_ imgUrl: String) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AsyncImage(url: URL(string: imgUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            } placeholder: {
                ProgressView()
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        // 关闭所有全屏视图
                        showFullScreen = false
                       
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
    
    // MARK: - 进度条
    @ViewBuilder
    private func progressBarView(score: Int) -> some View {
        VStack(spacing: 8) {
            // 指针
            Image("Vector_3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 8, height: 6)
                .offset(x: CGFloat(score - 50) * 0.96) // 根据分数调整位置
            
            HStack(spacing: 2) {
                Rectangle()
                    .fill(Color(hex: "FF0032"))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color(hex: "FF6000"))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color(hex: "20B37B"))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
            .frame(width: 96)
        }
    }
    
    // MARK: - 配料分析
    @ViewBuilder
    private func ingredientAnalysisSection(_ data: FoodAnalysisResultData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image("筛选_1")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 24, height: 24)
                Text("配料分析")
                    .font(.system(size: 18, weight: .heavy))
            }
            
            // 安全配料
            if !data.safe_level.isEmpty {
                safeIngredientSection(data.safe_level)
            }
            
            // 警示配料
            if !data.warn_level.isEmpty {
                warnIngredientSection(data.warn_level)
            }
            
            // 风险配料
            if !data.danger_level.isEmpty {
                dangerIngredientSection(data.danger_level)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        // .offset(y: -50) // 调整重叠效果
    }
    
    // MARK: - 安全配料
    @ViewBuilder
    private func safeIngredientSection(_ ingredients: [SafeLevelItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image("image_35")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 24, height: 24)
                    Text("安全配料 (\(ingredients.count))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                if ingredients.count > 1 {
                    Button(action: {
                        showAllSafeIngredient.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(showAllSafeIngredient ? "收起" : "展开")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(Array(ingredients.prefix(showAllSafeIngredient ? ingredients.count : 4).enumerated()), id: \.offset) { index, ingredient in
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 16)
                        
                        Text(ingredient.name)
                            .font(.system(size: 12))
                            .fixedSize(horizontal: true, vertical: false)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "F0FDF4"))
        .cornerRadius(10)
    }
    
    // MARK: - 警示配料
    @ViewBuilder
    private func warnIngredientSection(_ ingredients: [WarnLevelItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image("image_33")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("警示配料 (\(ingredients.count))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                if ingredients.count > 1 {
                    Button(action: {
                        showAllAlertIngredient.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(showAllAlertIngredient ? "收起" : "展开")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array((showAllAlertIngredient || ingredients.count <= 2 ? ingredients : Array(ingredients.prefix(2))).enumerated()), id: \.offset) { index, ingredient in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ingredient.name)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("适量食用")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(hex: "FFEFE6"))
                                .cornerRadius(6)
                        }
                        
                        Text(ingredient.intro ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "FEFCE8"))
        .cornerRadius(10)
    }
    
    // MARK: - 风险配料
    @ViewBuilder
    private func dangerIngredientSection(_ ingredients: [DangerLevelItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image("image_34")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                       
                    Text("风险配料 (\(ingredients.count))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                if ingredients.count > 1 {
                    Button(action: {
                        showAllRiskIngredient.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(showAllRiskIngredient ? "收起" : "展开")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array((showAllRiskIngredient || ingredients.count <= 1 ? ingredients : Array(ingredients.prefix(1))).enumerated()), id: \.offset) { index, ingredient in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ingredient.name)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("不建议食用")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        Text(ingredient.describe ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if !ingredient.reason.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                                    Text("主要风险")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.red)
                                }
                                
                                ForEach(ingredient.reason, id: \.self) { reason in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 6, height: 6)
                                        Text(reason)
                                            .font(.system(size: 12))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "FEF2F2"))
        .cornerRadius(10)
    }
    
    // MARK: - 营养成分
    @ViewBuilder
    private func nutritionAnalysisSection(_ data: FoodAnalysisResultData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack {
                    Image("数据_1")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 24, height: 24)
                    Text("营养成分")
                        .font(.system(size: 18, weight: .heavy))
                }
                
                Spacer()
                
                if data.nutrient_percent.count > 1 {
                    Button(action: {
                        showAllNutrition.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(showAllNutrition ? "收起" : "展开")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                ForEach(Array((showAllNutrition || data.nutrient_percent.count <= 4 ? data.nutrient_percent : Array(data.nutrient_percent.prefix(4))).enumerated()), id: \.offset) { index, nutrient in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(nutrient.name)
                            .font(.system(size: 12))
                        
                        Text(nutrient.weight)
                            .font(.system(size: 14, weight: .bold))
                        
                        ProgressView(value: Double(nutrient.percent) ?? 0.0, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "26C186")))
                            .scaleEffect(y: 0.5)
                    }
                    .padding(12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "F2F2F2"), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    // MARK: - 健康建议
    @ViewBuilder
    private func healthAdviceSection(_ data: FoodAnalysisResultData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image("灯泡_(1) 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text("健康建议")
                    .font(.system(size: 18, weight: .heavy))
            }
            
            VStack(spacing: 16) {
                // 适宜人群
                if !data.suggested_crowd.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("适宜人群")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(data.suggested_crowd, id: \.self) { crowd in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .font(.system(size: 12))
                                        .frame(width: 16, height: 16)
                                    
                                        Text(crowd)
                                            .font(.system(size: 12))
                                            .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "F0FDF4"))
                    .cornerRadius(10)
                }
                
                // 不适宜人群
                if !data.unsuggested_crowd.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image("Forbid_(禁止)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            Text("不适宜人群")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(data.unsuggested_crowd, id: \.self) { crowd in
                                HStack {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                                        .frame(width: 16, height: 16)
                                    
                                        Text(crowd)
                                            .font(.system(size: 12))
                                            .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "FEF2F2"))
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    // MARK: - 详细说明
    @ViewBuilder
    private func detailDescriptionSection(_ data: FoodAnalysisResultData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image("file-text-line")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text("详细说明")
                    .font(.system(size: 18, weight: .heavy))
            }
            
            VStack(spacing: 12) {
                ForEach(Array(createDetailDescFromResponse(data).enumerated()), id: \.offset) { index, detail in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(detail.name)
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(detail.describe)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "F2F2F2"), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    // MARK: - 数据加载
    private func loadAnalysisData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 这里应该调用实际的API
               isLoading = true
               errorMessage = nil

            var requestBody: [String: Any] = [:]
            if let id = item?.id, id != 0 {
                requestBody["id"] = id
            } else if let uuid = recordItem?.uuid, !uuid.isEmpty {
                requestBody["uuid"] = uuid
            } else {
                isLoading = false
                hasData = false
                return
            }     

             NetworkManager.shared.post(APIConstants.Index.foodSafetyAnalysisDetail, 
                                 businessParameters: requestBody) { (result: Result<FoodAnalysisResultResponse, APIError>) in
             DispatchQueue.main.async {
                isLoading = false         
                switch result {
                case .success(let response):
                    if response.code == 1 {
                       
                        if let data = response.data {
                            self.analysisData = data
                        }
                        self.hasData = true
                    } else {
                        errorMessage = response.msg
                    }
                case .failure(let error):
                     
                        errorMessage = error.localizedDescription
                }
            }
            
          
        }
    }
    }
    
   
    
    // MARK: - 创建详细说明
    private func createDetailDescFromResponse(_ responseData: FoodAnalysisResultData) -> [DetailItem] {
        var detailItems: [DetailItem] = []
        
        // 从风险配料中提取描述
        for dangerItem in responseData.danger_level {
            if !dangerItem.describe.isEmpty {
                detailItems.append(DetailItem(name: dangerItem.name, describe: dangerItem.describe))
            }
        }
        
        // 从警示配料中提取介绍
        for warnItem in responseData.warn_level {
            if !warnItem.intro.isEmpty {
                detailItems.append(DetailItem(name: warnItem.name, describe: warnItem.intro))
            }
        }
        
        return detailItems
    }
    
}

// 在结构体定义处添加显式初始化器
extension MOFoodSafetyAnalysisDetail {
    init(item: IndexItem? = nil, recordItem: MOFoodSafeRecordItemModel? = nil) {
        self.item = item
        self.recordItem = recordItem
    }
}