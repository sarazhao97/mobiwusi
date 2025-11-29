import SwiftUI

// MARK: - Model
struct Country: Identifiable, Codable, Hashable {
    let id = UUID()
    let en: String
    let cn: String
    let code: String
    let pinYinInitial: String  // 直接读取 JSON 的首字母

    var dialCode: Int {
        Int(code.replacingOccurrences(of: "+", with: "")) ?? 0
    }
    
    var displayName: String {
        cn.isEmpty ? en : cn
    }
    
    var firstLetter: String {
        pinYinInitial.uppercased()
    }
}

// MARK: - JSON 数据加载
func loadCountriesFromJSON() -> [Country] {
    guard let url = Bundle.main.url(forResource: "country-code", withExtension: "json") else {
        print("找不到 country-code.json")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        let countries = try JSONDecoder().decode([Country].self, from: data)
        return countries
    } catch {
        print("解析 JSON 失败：\(error)")
        return []
    }
}

// MARK: - 数据缓存
class CountryStore: ObservableObject {
    @Published var countries: [Country] = []

    private static nonisolated(unsafe) let cachedCountries = NSMutableArray()

    func loadData(completion: @escaping () -> Void) {
        if Self.cachedCountries.count > 0 {
            self.countries = Self.cachedCountries.compactMap { $0 as? Country }
            completion()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = loadCountriesFromJSON().sorted { $0.firstLetter < $1.firstLetter }

            Self.cachedCountries.removeAllObjects()
            Self.cachedCountries.addObjects(from: loaded)

            DispatchQueue.main.async {
                self.countries = loaded
                completion()
            }
        }
    }
}

// MARK: - Row
struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    var body: some View {
        HStack {
            Text(country.displayName)
                .foregroundColor(.black)
            Spacer()
            Text(country.code)
                .foregroundColor(.gray)
                .padding(.trailing, 2) 
        }
        .padding(.vertical, 6)
         .frame(maxWidth: .infinity, alignment: .leading) // 让按钮宽度填满整行
                                            .contentShape(Rectangle()) // 整个行可点击
        
        
    }
}

// MARK: - Picker
struct CountryCodePicker: View {
    @Binding var selectedCode: Int
    var onDone: () -> Void = {} // 默认空闭包
    @Environment(\.dismiss) private var dismiss

    @StateObject private var store = CountryStore()
    @State private var scrollTarget: String? = nil
    @State private var isLoading = true

    private var groupedCountries: [String: [Country]] {
        Dictionary(grouping: store.countries) { $0.firstLetter }
    }

    private var sortedKeys: [String] {
        groupedCountries.keys.sorted()
    }

    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("加载中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                        .font(.system(size: 15, weight: .medium))
                } else {
                    ZStack(alignment: .trailing) {
                        HStack{
                        ScrollViewReader { proxy in
                            List {
                                ForEach(sortedKeys, id: \.self) { key in
                                    Section(header: 
                                     // 使用 ZStack 或者 HStack 包裹 Text 来设置背景
                                        ZStack {
                                            Color.white // 你想要的背景色
                                            Text(key)
                                                .font(.headline)
                                                .foregroundColor(.black) // 字体颜色可调
                                                .padding(.leading) // 内边距
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .listRowInsets(EdgeInsets()) // 去掉默认内边距
                                        .frame(height: 30) // 调整 header 高度
                                     ) {
                                        ForEach(groupedCountries[key] ?? []) { country in
                                            Button {
                                                selectedCode = country.dialCode
                                                 onDone()  // 调用闭包关闭页面
                                            } label: {
                                                CountryRow(
                                                    country: country,
                                                    isSelected: selectedCode == country.dialCode
                                                )
                                                .listRowBackground(Color.clear)
                                            }
                                           
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .id(key)
                                    
                                }
                            }
                            .listStyle(.plain)
                            .onAppear {
                                // 隐藏分割线
                                UITableView.appearance().separatorStyle = .none
                               
                            }
                            .onDisappear {
                                // 恢复默认样式，避免影响其他列表
                                UITableView.appearance().separatorStyle = .singleLine
                            }
                            .onChange(of: scrollTarget) { target in
                                if let t = target {
                                    withAnimation {
                                        proxy.scrollTo(t, anchor: .top)
                                    }
                                }
                            }
                        }
                         
                     Spacer()

                        // 右侧字母索引
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                ForEach(sortedKeys, id: \.self) { key in
                                    Text(key)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .frame(width: 40, height: geometry.size.height / CGFloat(sortedKeys.count))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            scrollTarget = key
                                        }
                                }
                            }
                        }
                        .frame(width: 40)
                        .padding(.trailing, 4)
                        }
                    }
                }
            }
           
            .navigationTitle("选择国家和地区")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.loadData {
                    isLoading = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {  // 注意这里是 placement，不是方法
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            
        }
        .navigationBarBackButtonHidden(true) 
          
        
    }
}

// MARK: - Preview
struct CountryCodePicker_Previews: PreviewProvider {
    static var previews: some View {
        CountryCodePicker(selectedCode: .constant(86))
    }
}
