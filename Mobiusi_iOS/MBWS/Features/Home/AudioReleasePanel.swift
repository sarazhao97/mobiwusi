//
//  AudioReleasePanel.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/30.
//

import SwiftUI
import Foundation
import UIKit


struct AudioReleasePanel:View {
    @Environment(\.dismiss) var dismiss
    let audioURL: String
    let duration: Int
    let path: String
      let dataItem: IndexItem?

    init(audioURL: String, duration: Int, path: String, dataItem: IndexItem? = nil) {
        self.audioURL = audioURL
        self.duration = duration
        self.path = path
        self.dataItem = dataItem
    }

    @State private var audioDescription: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var isUploading: Bool = false // 数据上传中
    @State private var cate_id: Int = 1
    @State private var location: String = ""
    @State private var showLocationPicker: Bool = false
    @State private var selectedProvince: String = ""
    @State private var selectedCity: String = ""
    @State private var selectedDistrict: String = ""
    @State private var locationData: [String: [String: [String]]] = [:]
    
    var body: some View {
        ZStack{
              Color(hex: "#f7f8fa")
                    .ignoresSafeArea()
             
             VStack(spacing:15){
                HStack{
                    Button(action:{
                        dismiss()
                    }){
                        Text("取消")
                          .font(.system(size: 16))
                          .foregroundColor(.black)
                    }
                    .contentShape(Rectangle())
                    Spacer()
                    Button(action:{
                        freeUploadData()
                    }){
                        Text("上传")
                         .font(.system(size: 16,weight:.bold))
                         .foregroundColor(.white)
                         .padding(.vertical,5)
                         .padding(.horizontal,20)
                         .background(Color(hex:"#9A1E2E"))
                         .cornerRadius(10)
                         
                    }
                }
                .padding(.horizontal,10)

                VStack(spacing:10){
                       
                         AudioSpectrogram(audioURL: audioURL, backColor:"#EEEDF4")
                    
                    
                     HStack{
                        Text("转文本")
                         .font(.system(size: 14))
                         .foregroundColor(Color(hex:"#9B9B9B"))
                         if isLoading{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex:"#9B9B9B")))
                                .controlSize(.small)
                                .scaleEffect(0.85)
                         }
                        Spacer()
                     }
                     .padding(.horizontal,10)
                     ZStack(alignment: .topLeading) {
                         // 多行文本编辑器
                         TextEditor(text: $audioDescription)
                             .font(.system(size: 14))
                             .foregroundColor(Color(hex:"#333333"))
                             .background(Color.clear)
                             .scrollContentBackground(.hidden)
                             .frame(minHeight: 80, maxHeight: 120)
                             .padding(.leading,5)
                         
                         // 占位符文本 - 精确对齐 TextEditor 的文本位置
                         if audioDescription.isEmpty {
                             Text("这一刻的想法...")
                                 .font(.system(size: 14))
                                 .foregroundColor(Color(hex:"#B3B3B3"))
                                 .padding(.horizontal, 10)
                                 .padding(.vertical, 8)
                                 .allowsHitTesting(false) // 允许点击穿透到 TextEditor
                         }
                     }
                     .background(Color(hex:"#ffffff"))          
                       
                }
                .padding(15)
                .background(Color(hex:"#ffffff"))
                .cornerRadius(15)

                VStack{
                    HStack{
                         Image("icon_free_location")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 25, height: 25)
                     .foregroundColor(Color(hex:"#9B9B9B"))
                     Text(location.isEmpty ? "不显示位置" : location)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#333333"))
                    Spacer()
                    }
                }
                .padding(15)
                .background(Color(hex:"#ffffff"))
                .cornerRadius(15)
                .onTapGesture {
                    if locationData.isEmpty {
                        loadLocationData()
                    }
                    showLocationPicker = true
                }
                   Spacer()
             }
             .padding(.horizontal,10)

             if isUploading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex:"#9B9B9B")))
                    .controlSize(.small)
                    .scaleEffect(0.85)
             }
             
             // 省市区选择器面板
             if showLocationPicker {
                 LocationPickerView(
                     isPresented: $showLocationPicker,
                     locationData: locationData,
                     selectedProvince: $selectedProvince,
                     selectedCity: $selectedCity,
                     selectedDistrict: $selectedDistrict,
                     onConfirm: { province, city, district in
                         let fullLocation = "\(province) \(city) \(district)"
                         location = fullLocation
                         showLocationPicker = false
                     }
                 )
                 .transition(.move(edge: .bottom))
                 .animation(.easeInOut(duration: 0.3), value: showLocationPicker)
             }
        }
        .onAppear{
            loadLocationData()
            transcribeAudio()
             
         }
        

    }

     func loadLocationData() {
        print("[Location] 开始加载省市区数据")
        // 优先从 app bundle 读取
        if let url = Bundle.main.url(forResource: "pca-code", withExtension: "json") {
            print("[Location] 在 Bundle 中找到 pca-code.json: \(url)")
            if let data = try? Data(contentsOf: url), let parsed = parseLocationJSON(data: data) {
                locationData = parsed
                print("[Location] 解析成功，省份数：\(parsed.keys.count)")
                return
            } else {
                print("[Location] 解析 Bundle 中的 pca-code.json 失败")
            }
        } else {
            print("[Location] Bundle 中未找到 pca-code.json")
        }
        
        // 开发环境兜底：如果存在同名资源路径再试一次
        if let devPath = Bundle.main.path(forResource: "pca-code", ofType: "json"),
           FileManager.default.fileExists(atPath: devPath) {
            print("[Location] 使用 path 方式加载：\(devPath)")
            if let data = try? Data(contentsOf: URL(fileURLWithPath: devPath)),
               let parsed = parseLocationJSON(data: data) {
                locationData = parsed
                print("[Location] path 解析成功，省份数：\(parsed.keys.count)")
                return
            } else {
                print("[Location] path 解析失败")
            }
        } else {
            print("[Location] 未找到可用的本地资源路径")
        }
        
        // 最终回退：使用内置示例数据，保证 UI 可用
        let fallback: [String: [String: [String]]] = [
            "北京市": [
                "北京市": ["东城区", "西城区", "朝阳区", "海淀区"]
            ],
            "上海市": [
                "上海市": ["黄浦区", "徐汇区", "浦东新区"]
            ],
            "广东省": [
                "广州市": ["越秀区", "天河区"],
                "深圳市": ["南山区", "福田区"]
            ]
        ]
        locationData = fallback
        print("[Location] 使用示例数据回退，省份数：\(fallback.keys.count)")
    }
    
    func parseLocationJSON(data: Data) -> [String: [String: [String]]]? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("[Location] JSON 解析失败：无法反序列化")
            return nil
        }
        
        // 辅助方法：提取名称和数组（支持多字段）
        func nameFrom(_ dict: [String: Any], keys: [String]) -> String? {
            for key in keys {
                if let v = dict[key] as? String, !v.isEmpty { return v }
            }
            return nil
        }
        func arrayFrom(_ dict: [String: Any], keys: [String]) -> Any? {
            for key in keys {
                if let v = dict[key] { return v }
            }
            return nil
        }
        
        var resultTop: [String: [String: [String]]] = [:]
        
        // Case 1：顶层为数组，元素为省份字典
        if let array = json as? [[String: Any]] {
            for item in array {
                let provinceName = nameFrom(item, keys: ["name", "province", "label", "text"]) ?? ""
                guard !provinceName.isEmpty else { continue }
                
                // 城市列表可能字段：cities / children / city_list / citys
                let citiesAny = arrayFrom(item, keys: ["cities", "children", "city_list", "citys", "city"]) ?? []
                let citiesArr = citiesAny as? [[String: Any]] ?? []
                var cityMap: [String: [String]] = [:]
                for city in citiesArr {
                    let cityName = nameFrom(city, keys: ["name", "city", "label", "text"]) ?? ""
                    guard !cityName.isEmpty else { continue }
                    
                    // 区县可能字段：districts / areas / children / area_list / county_list
                    let districtsAny = arrayFrom(city, keys: ["districts", "areas", "children", "area_list", "county_list"]) ?? []
                    var districts: [String] = []
                    if let arr = districtsAny as? [String] {
                        districts = arr
                    } else if let arrDict = districtsAny as? [[String: Any]] {
                        districts = arrDict.compactMap { nameFrom($0, keys: ["name", "label", "text", "area"]) }
                    } else if let arrAny = districtsAny as? [Any] {
                        districts = arrAny.compactMap { anyItem in
                            if let s = anyItem as? String { return s }
                            if let d = anyItem as? [String: Any] { return nameFrom(d, keys: ["name", "label", "text", "area"]) }
                            return nil
                        }
                    }
                    cityMap[cityName] = districts
                }
                if !cityMap.isEmpty {
                    resultTop[provinceName] = cityMap
                }
            }
            return resultTop.isEmpty ? nil : resultTop
        }
        
        // Case 2：顶层为字典（常见于 code->name 的映射或层级字典）
        if let dict = json as? [String: Any] {
            var resultDict: [String: [String: [String]]] = [:]
            for (provinceName, provinceVal) in dict {
                var cityMap: [String: [String]] = [:]
                if let cityDict = provinceVal as? [String: Any] {
                    // 省级下直接为城市字典
                    for (cityName, distVal) in cityDict {
                        var districts: [String] = []
                        if let arr = distVal as? [String] {
                            districts = arr
                        } else if let arrAny = distVal as? [Any] {
                            districts = arrAny.compactMap { $0 as? String }
                        } else if let arrDict = distVal as? [[String: Any]] {
                            districts = arrDict.compactMap { nameFrom($0, keys: ["name", "label", "text", "area"]) }
                        }
                        cityMap[cityName] = districts
                    }
                } else if let cityArr = provinceVal as? [[String: Any]] {
                    // 省级下为城市数组
                    for city in cityArr {
                        let cityName = nameFrom(city, keys: ["name", "city", "label", "text"]) ?? ""
                        guard !cityName.isEmpty else { continue }
                        var districts: [String] = []
                        if let dArr = city["districts"] as? [String] {
                            districts = dArr
                        } else if let children = city["children"] as? [Any] {
                            districts = children.compactMap { anyItem in
                                if let s = anyItem as? String { return s }
                                if let d = anyItem as? [String: Any] { return nameFrom(d, keys: ["name", "label", "text", "area"]) }
                                return nil
                            }
                        }
                        cityMap[cityName] = districts
                    }
                }
                if !cityMap.isEmpty {
                    resultDict[provinceName] = cityMap
                }
            }
            return resultDict.isEmpty ? nil : resultDict
        }
        
        print("[Location] JSON 结构不支持")
        return nil
    }

   

    func transcribeAudio() {
        guard let audioURL = URL(string: audioURL) else { return }
        let requestBody: [String: Any] = [
            "path": path,
            "start_time": 0, // 毫秒
            "end_time": duration * 1000 // 秒→毫秒
        ]
        
        isLoading = true
        
        NetworkManager.shared.post(APIConstants.Scene.getAudioTranscription, 
                                   businessParameters: requestBody) { (result: Result<AudioTranscriptionResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        audioDescription = response.data ?? ""
                        isLoading = false
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                        isLoading = false
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    //自由上传数据
    func freeUploadData(){
        guard let audioURL = URL(string: audioURL) else { return }

        isUploading = true
        
        // 构造 user_data（数组 JSON 字符串）
        let fileName = audioURL.lastPathComponent
        let fileExtension = audioURL.pathExtension.lowercased()
        let fileData = try? Data(contentsOf: audioURL)
        let size = fileData?.count ?? 0
        let durationMs = duration * 1000
        let audioDict: [String: Any] = [
            "file_name": fileName,
            "duration": durationMs,
            "format": fileExtension.isEmpty ? "m4a" : fileExtension,
            "size": size,
            "url": path,
            "rate": "44100"
        ]
        let userDatas: [Any] = [audioDict]
        let userDataStr: String = {
            if let data = try? JSONSerialization.data(withJSONObject: userDatas, options: []),
               let str = String(data: data, encoding: .utf8) {
                return str
            } else { return "[]" }
        }()
        
        var requestBody: [String: Any] = [
            "cate_id": cate_id,
            "idea": audioDescription, // 毫秒
            "user_data": userDataStr
        ]

        // 根据可选的 dataItem 追加父帖或子帖 ID
        if let item = dataItem {
            let parentPostID = item.parent_post_id
            let postID = item.post_id
            if !parentPostID.isEmpty {
                requestBody["parent_post_id"] = parentPostID
            } else if !postID.isEmpty {
                requestBody["parent_post_id"] = postID
            }
        }

        if !location.isEmpty{
            requestBody["location"] = location
        }

        
        
        NetworkManager.shared.post(APIConstants.Scene.freeUploadData, 
                                 businessParameters: requestBody) { (result: Result<FreeUploadDataResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        audioDescription = response.data ?? ""   
                        isUploading = false
                        MBProgressHUD.showMessag("数据上传成功", to: nil, afterDelay: 3.0)
                         // 稍作延时，避免 HUD 覆盖动画冲突
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                             
                                Task { @MainActor in
                                    // 优先关闭当前页面（兼容可能的模态呈现）
                                    dismiss()
                                    
                                    // 回到根控制器（TabBar），并切换到首页
                                    MOAppDelegate().transition.popToRootViewController(animated: true)
                                    
                                    if let nav = MOAppDelegate().transition.navigationViewController(),
                                       let tab = nav.viewControllers.first as? UITabBarController {
                                        tab.selectedIndex = 0
                                    } else if let root = UIApplication.shared.connectedScenes
                                                    .compactMap({ $0 as? UIWindowScene })
                                                    .flatMap({ $0.windows })
                                                    .first(where: { $0.isKeyWindow })?.rootViewController {
                                        if let tab = root as? UITabBarController {
                                            tab.selectedIndex = 0
                                        } else if let nav = root as? UINavigationController,
                                                  let tab = nav.viewControllers.first as? UITabBarController {
                                            tab.selectedIndex = 0
                                        }
                                    }
                                }
                            }
                    } else {
                         isUploading = false
                        errorMessage = response.msg
                         MBProgressHUD.showMessag(errorMessage, to: nil, afterDelay: 3.0)
                        
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                  
                    isUploading = false
                }
            }
        }
    }
}


// MARK: - LocationPickerView
struct LocationPickerView: View {
    @Binding var isPresented: Bool
    let locationData: [String: [String: [String]]]
    @Binding var selectedProvince: String
    @Binding var selectedCity: String
    @Binding var selectedDistrict: String
    let onConfirm: (String, String, String) -> Void
    
    @State private var provinces: [String] = []
    @State private var cities: [String] = []
    @State private var districts: [String] = []
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    HStack {
                        Button("取消") {
                            isPresented = false
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("选择地区")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button("确定") {
                            onConfirm(selectedProvince, selectedCity, selectedDistrict)
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#9A1E2E"))
                        .disabled(selectedProvince.isEmpty || selectedCity.isEmpty || selectedDistrict.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    
                    Divider()
                    
                    if provinces.isEmpty {
                        VStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex:"#9B9B9B")))
                                .controlSize(.small)
                            Text("省市区数据未加载，请确认 JSON 已加入 Bundle")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                        }
                        .frame(height: 200)
                        .background(Color.white)
                    } else {
                        HStack(spacing: 0) {
                            Picker("省份", selection: $selectedProvince) {
                                ForEach(provinces, id: \.self) { province in
                                    Text(province)
                                        .font(.system(size: 16))
                                        .tag(province)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            .onChange(of: selectedProvince) { newProvince in
                                updateCities(for: newProvince)
                            }
                            
                            Divider()
                            
                            Picker("城市", selection: $selectedCity) {
                                ForEach(cities, id: \.self) { city in
                                    Text(city)
                                        .font(.system(size: 16))
                                        .tag(city)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            .onChange(of: selectedCity) { newCity in
                                updateDistricts(for: selectedProvince, city: newCity)
                            }
                            
                            Divider()
                            
                            Picker("区县", selection: $selectedDistrict) {
                                ForEach(districts, id: \.self) { district in
                                    Text(district)
                                        .font(.system(size: 16))
                                        .tag(district)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 200)
                        .background(Color.white)
                    }
                }
                .background(Color.white)
                .cornerRadius(15, corners: [.topLeft, .topRight])
                
            }
        }
        .onAppear {
            setupInitialData()
        }
        .onChange(of: locationData) { _ in
            setupInitialData()
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func setupInitialData() {
        provinces = Array(locationData.keys).sorted()
        
        // 省份为空：清空所有选择，避免越界
        if provinces.isEmpty {
            selectedProvince = ""
            cities = []
            selectedCity = ""
            districts = []
            selectedDistrict = ""
            return
        }
        
        // 若当前选择不在可选项内，自动修正为首项
        if !provinces.contains(selectedProvince) {
            selectedProvince = provinces.first ?? ""
        }
        
        updateCities(for: selectedProvince)
    }
    
    private func updateCities(for province: String) {
        let cityDict: [String: [String]] = locationData[province] ?? [:]
        cities = Array(cityDict.keys).sorted()
        
        // 城市为空：清空城市与区县选择
        if cities.isEmpty {
            selectedCity = ""
            districts = []
            selectedDistrict = ""
            return
        }
        
        // 若当前城市选择不在选项内，自动修正为首项
        if !cities.contains(selectedCity) {
            selectedCity = cities.first ?? ""
        }
        
        updateDistricts(for: province, city: selectedCity)
    }
    
    private func updateDistricts(for province: String, city: String) {
        districts = Array(locationData[province]?[city] ?? []).sorted()
        
        // 区县为空：清空区县选择
        if districts.isEmpty {
            selectedDistrict = ""
            return
        }
        
        // 若当前区县选择不在选项内，自动修正为首项
        if !districts.contains(selectedDistrict) {
            selectedDistrict = districts.first ?? ""
        }
    }
}



