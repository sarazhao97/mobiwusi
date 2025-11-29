//
//  DataPartnerController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/10.
//

import SwiftUI
import UIKit
import Foundation
import SafariServices
import WebKit


struct SlantedTopPanel: Shape {
    var slant: CGFloat = 20
    var bottomRadius: CGFloat = 15
    var topRadius: CGFloat = 12
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let s = max(0, min(slant, h))
        let r = max(0, min(bottomRadius, min(w, h) / 2))
        let tr = max(0, min(topRadius, min(w, h) / 3))

        // 顶部斜边：左低右高
        p.move(to: CGPoint(x: 0, y: s))
        p.addLine(to: CGPoint(x: w, y: 0))
        // 右上角：斜边 → 右侧 的圆角过渡
        p.addArc(tangent1End: CGPoint(x: w, y: 0),
                 tangent2End: CGPoint(x: w, y: h),
                 radius: tr)
        // 右侧到右下角前
        p.addLine(to: CGPoint(x: w, y: h - r))
        // 右下角圆弧
        p.addArc(center: CGPoint(x: w - r, y: h - r),
                 radius: r,
                 startAngle: .degrees(0),
                 endAngle: .degrees(90),
                 clockwise: false)
        // 底边到左下角前
        p.addLine(to: CGPoint(x: r, y: h))
        // 左下角圆弧
        p.addArc(center: CGPoint(x: r, y: h - r),
                 radius: r,
                 startAngle: .degrees(90),
                 endAngle: .degrees(180),
                 clockwise: false)
        // 左侧向上到斜切处
        p.addLine(to: CGPoint(x: 0, y: s))
        // 左上角：左侧 → 斜边 的圆角过渡
        p.addArc(tangent1End: CGPoint(x: 0, y: s),
                 tangent2End: CGPoint(x: w, y: 0),
                 radius: tr)
        p.closeSubpath()
        return p
    }
}

struct DataPartnerController:View {
    @Environment(\.dismiss) var dismiss

    struct MenuItem: Identifiable {
       let id: String // 使用后端 key 作为唯一标识
       let title: String
       let icon: String // 保存接口返回的 icon URL 字符串
       let point: Int
       let status: Int
     }

    @State private var menus: [MenuItem] = []
    @State private var showSignSuccessPanel = false
    @State private var errorMessage: String? = nil
    @State private var mobiPointsInfo: MobiPointsInfoData? = nil
    @State private var signInAwardValue: Int = 0
    @State private var navigateToMyProject = false
    @State private var navigateToEducation = false
    @State private var navigateToWork = false
    @State private var navigateToDriver = false
    @State private var navigateToIdentity = false
    let maxWidth = UIScreen.main.bounds.width - 40
   

    // 第一种颜色所占比例（0.0~1.0），例如 0.3 表示占 30%
    private let firstColorRatio: CGFloat = 0.001
    // 若希望平滑过渡，可设置过渡带宽度（0.0~1.0），例如 0.05 表示 5% 区间渐变
    private let blendSpan: CGFloat = 0.35 // 设为 0 则为硬切分

    @State private var signedIndices: Set<Int> = []

    // 辅助：以周一为一周起点的日历
    private static var mondayCal: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "zh_CN")
        cal.timeZone = TimeZone.current
        cal.firstWeekday = 2 // 周一为一周起点
        cal.minimumDaysInFirstWeek = 1
        return cal
    }()

    // 辅助：日期格式化 M/d
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale(identifier: "zh_CN")
        f.timeZone = TimeZone.current
        return f
    }()

    // 辅助：计算当前周（周一到周日）的日期数组
    fileprivate static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        f.timeZone = TimeZone.current
        return f
    }()
    private func formatWeekDate(_ s: String) -> String {
        if let d = Self.apiDateFormatter.date(from: s) {
            return Self.dateFormatter.string(from: d)
        }
        return s
    }

    // 辅助：获取今天在本周的索引（0~6，周一为0）
    private static func weekdayIndex(reference date: Date = Date()) -> Int {
        var cal = mondayCal
        let weekday = cal.component(.weekday, from: date)
        return (weekday + 7 - cal.firstWeekday) % 7
    }

    // 辅助：中文星期标题
    private static let weekdayTitles = ["周一","周二","周三","周四","周五","周六","周日"]
    
    // 辅助：生成签到按钮视图
    @ViewBuilder
    private func signButtonView(item: MobiWeekItem, idx: Int) -> some View {
        let isToday = (item.is_today == 1)
        let didSign = (item.status == 1)
        let isMakeup = (item.is_yesterday == 1) && !didSign
        let isYesterday = (item.is_yesterday == 1)
        let isPastUnSigned = computePastUnSigned(item: item, isToday: isToday, didSign: didSign, isYesterday: isYesterday)
        
        let fillGradient = signButtonFillGradient(isMakeup: isMakeup, didSign: didSign, isPastUnSigned: isPastUnSigned)
        let borderGradient = signButtonBorderGradient(isMakeup: isMakeup)
        
        VStack(spacing: 6) {
            if didSign {
                Image("Group_77 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(.bottom,6)
            } else {
                Text("+\(item.val)")
                    .font(.system(size: 12))
                   .foregroundColor(Color(hex:(isPastUnSigned || didSign) ? "#9B9B9B" : "#000000"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    // .fixedSize(horizontal: true, vertical: false)
                    .padding(.bottom,6)
            }
            Text(isToday ? "今天" : (isMakeup ? "补签" : item.week_day))
                .font(.system(size: 14))
                .foregroundColor(Color(hex:(isPastUnSigned || didSign) ? "#9B9B9B" : "#000000"))
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                // .fixedSize(horizontal: true, vertical: false)
            Text(formatWeekDate(item.date))
                .font(.system(size: 12))
                .foregroundColor(Color(hex:(isPastUnSigned || didSign) ? "#9B9B9B" : "#000000"))
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                // .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 6)
        .background(fillGradient)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(
                strokeStyle(isToday: isToday, didSign: didSign, isMakeup: isMakeup, borderGradient: borderGradient),
                lineWidth: (isToday || isMakeup) ? 2 : 0
            )
        )
        .onTapGesture{
            if didSign {
                MBProgressHUD.showMessag("您已签到", to: nil, afterDelay: 1.5)
            }else{
                if isToday || isMakeup {
                     // 发起签到，日期按 yyyy-MM-dd，默认当天
                signIn(date: item.date)
                }
               
            }
            
        }
    }
    
    private func signButtonFillGradient(isMakeup: Bool, didSign: Bool, isPastUnSigned: Bool) -> LinearGradient {
        if isMakeup {
            return LinearGradient(
                colors: [
                    Color(hex: "#FFE6D4"),
                    Color(hex: "#ffffff")
                ],
                startPoint: .top, endPoint: .bottom
            )
        } else {
            if didSign || isPastUnSigned {
                return LinearGradient(
                    colors: [Color(hex: "#EDEEF5"), Color(hex: "#EDEEF5")],
                    startPoint: .top, endPoint: .bottom
                )
            } else {
                return LinearGradient(
                    colors: [Color(hex: "#F3AAB3"), Color(hex: "#ffffff")],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
    }
    
    private func signButtonBorderGradient(isMakeup: Bool) -> LinearGradient {
        if isMakeup {
            return LinearGradient(
                colors: [
                    Color(hex: "#F6A15D"),
                    Color(hex: "#ffffff")
                ],
                startPoint: .top, endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "#D05F6D"), Color(hex: "#ffffff")],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
    
    private func strokeStyle(isToday: Bool, didSign: Bool, isMakeup: Bool, borderGradient: LinearGradient) -> LinearGradient {
        if isToday && didSign {
            return LinearGradient(
                colors: [Color(hex: "#EDEEF5"), Color(hex: "#EDEEF5")],
                startPoint: .top,
                endPoint: .bottom
            )
        } else if isToday || isMakeup {
            return borderGradient
        } else {
            return LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
        }
    }
    
    // 辅助：处理菜单项导航
    private func handleMenuNavigation(menuId: String) {
        switch menuId {
        case "education_auth":
            navigateToEducation = true
        case "work_auth":
            navigateToWork = true
        case "driver_auth":
            navigateToDriver = true
        case "identity_auth":
            navigateToIdentity = true
        default:
            break
        }
    }
    
    // 辅助：生成菜单项视图
    @ViewBuilder
    private func menuItemView(menu: MenuItem, idx: Int) -> some View {
        HStack(alignment:.center,spacing:5){
            AsyncImage(url: URL(string: menu.icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } placeholder: {
                Image("占位图")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            VStack(alignment:.leading,spacing:6){
                Text(menu.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#000000"))
                HStack{
                    Text("Mobi分")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#AFAFAF"))
                    Text("+\(menu.point)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex:"#9A1E2E"))
                    Spacer()
                }
            }
            Spacer()
            Button(action:{
                if menu.status == 0 || menu.status == 3{
                    handleMenuNavigation(menuId: menu.id)
                }else{
                    MBProgressHUD.showMessag("\(menu.status == 1 ? "审核中" : "已完成")", to: nil, afterDelay: 1.0)
                }
                
            }){
                Text(menu.status == 0 ? "去完成" : menu.status == 1 ? "审核中" : menu.status == 2 ? "已完成" : "未通过")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#ffffff"))
                    .padding(.vertical,10)
                    .padding(.horizontal,15)
                    .background(
                        Capsule().fill(Color(hex:"#9A1E2E"))
                    )
            }
        }
        .padding(.vertical, idx == 1 ? 20 : 0)
        .padding(.bottom, idx == 2 ? 20 : 0)
    }

    //签到成功提示面板
    @ViewBuilder
    private func signSuccessPanel() -> some View {
       ZStack(alignment:.top){
        VStack{
                ZStack(alignment:.topTrailing){
                    HStack{
                        VStack(alignment:.leading,spacing:10){
                            Text("恭喜您！")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex:"#FFFFFF"))
                            Text("签到成功")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex:"#FFFFFF"))
                        }
                        Spacer()
                    }
                   Image("image_9")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .padding(.top,-65)
                    .padding(.trailing,-50)
                }
                }
                .padding(.horizontal,15)
                .padding(.top,15)
                .padding(.bottom,50)
                .frame(width: UIScreen.main.bounds.width * 0.76)        
                .background(
                    RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FF445C"),
                                    Color(hex: "#9A1E2E")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            
            ZStack(alignment:.center){
                Image("Rectangle_197 1")
                 .resizable()
                 .scaledToFit()
                 .frame(width: UIScreen.main.bounds.width * 0.9)
                 VStack{
                Text("恭喜您获得")
                 .font(.system(size: 24))
                 .foregroundColor(Color(hex:"#000000"))
                 .fontWeight(.bold)
                 .padding(.top,30)
                 HStack(alignment:.center){
                    Spacer()
                    Text("+\(signInAwardValue)")
                        .font(.system(size: 45))
                        .foregroundColor(Color(hex:"#9A1E2E"))
                        .fontWeight(.bold)
                    Image("图3_2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                    Spacer()
                 }
                 .padding(.top,30)
                 .padding(.bottom,60)
                 Button(action:{
                     showSignSuccessPanel = false
                 }){
                    Text("开心收下")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex:"#FFFFFF"))
                        .fontWeight(.bold)
                        .padding(.vertical,14)
                        .padding(.horizontal,12)
                        .frame(width: UIScreen.main.bounds.width * 0.76)
                        .background(Color(hex:"#9A1E2E"))
                        .cornerRadius(10)
                 }
                
            }
            }
            .padding(.top,89)

           

             
           

           
       }
    }

    //MARK： - 获取墨比积分信息
    func fetchMobiPointsInfo(){
         NetworkManager.shared.post(APIConstants.Profile.getMobiPointsInfo, 
                                 businessParameters: [:]) { (result: Result<MobiPointsInfoResponse, APIError>) in
            DispatchQueue.main.async {        
                switch result {
                case .success(let response):
                    if response.code == 1{
                        mobiPointsInfo = response.data
                        if let tasks = response.data?.task_data {
                            menus = tasks.map { t in
                                MenuItem(id: t.key, title: t.title, icon: t.icon, point: t.point, status: t.status)
                            }
                        }
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
            }
        }
    }
    
    
    
    private var levelImageName: String {
        let level = mobiPointsInfo?.level ?? 1
        switch level {
        case 1: return "icon_level1"
        case 2: return "icon_level2"
        case 3: return "icon_level3"
        case 4: return "icon_level4"
        case 5: return "icon_level5"
        default: return "icon_level1"
        }
    }
    
    private var progressRatio: CGFloat {
        let mobiPoints = Double(mobiPointsInfo?.mobi_point ?? 0)
        let levelPoints = Double(max(mobiPointsInfo?.level_point ?? 1, 1))
        return CGFloat(min(max(mobiPoints / levelPoints, 0), 1))
    }
    
    private var progressWidth: CGFloat {
        return CGFloat(150) * progressRatio
    }
    
    private var gradientStops: [Gradient.Stop] {
        let r1 = max(CGFloat(0.0), firstColorRatio)
        let r2 = max(CGFloat(0.0), min(CGFloat(1.0), firstColorRatio + blendSpan))
        return [
            .init(color: Color(hex: "#BA5763"), location: 0.0),
            .init(color: Color(hex: "#BA5763"), location: r1),
            .init(color: Color(hex: "#EDEEF5"), location: r2),
            .init(color: Color(hex: "#EDEEF5"), location: 1.0),
        ]
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: gradientStops),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
       ZStack{
            backgroundGradient
            .ignoresSafeArea()
           
            VStack{
                ScrollView(.vertical,showsIndicators: false){
                HStack(alignment:.center,spacing:10){
                   VStack(alignment:.leading,spacing:15){
                        Text("当前等级")
                           .font(.system(size: 14))
                           .foregroundColor(Color(hex:"#000000"))
                        Image(levelIconName)
                          .resizable()
                          .scaledToFill()
                          .frame(width: maxWidth * 0.12, height: maxWidth * 0.12)
                          .padding(.leading,20)
                        HStack(alignment:.center,spacing:5){
                            Image("图3_1")
                                 .resizable()
                                 .scaledToFill()
                                 .frame(width: 15, height: 15)
                            Text("Mobi分： \((mobiPointsInfo?.mobi_point ?? 0))/\((mobiPointsInfo?.level_point ?? 1))")
                                 .font(.system(size: 14))
                                 .foregroundColor(Color(hex:"#000000"))
                            Spacer()
                        }
                        .padding(.top,10)
                        VStack{
                             ZStack(alignment:.leading){
                              Rectangle()
                                 .fill(Color(hex:"#D9D9D9"))
                                 .frame(width: maxWidth * 0.4, height: 4)
                                 .cornerRadius(2)
                              Rectangle()
                                 .fill(Color(hex:"#9A1E2E"))
                                 .frame(width: progressWidth, height: 4)
                                 .cornerRadius(2)
                            }
                        }
                        
                   }
                   .padding(.leading,10)
                VStack(alignment:.center,spacing:10){
                    Image(levelImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width:maxWidth * 0.3)
                        .padding(.leading,30)    
                    Image("image")
                        .resizable()
                        .scaledToFit()
                        .frame(width:maxWidth * 0.3)
                }
                    
                      
                   
                                  
                }
                .padding(.top,10)

                VStack{
                     HStack(alignment:.center,spacing:10){
                    Text("签到赚积分")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#000000"))
                    Text("已连续签到\((mobiPointsInfo?.continuous_days ?? 0))天")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#AFAFAF"))
                    Spacer()
                   }
                   .padding(.bottom,20)

                   // 七个签到按钮：周一到周日
                   HStack(alignment: .center, spacing: 12) {
                       if let weekData = mobiPointsInfo?.week_data, !weekData.isEmpty {
                           ForEach(Array(weekData.enumerated()), id: \.offset) { idx, item in
                               signButtonView(item: item, idx: idx)
                           }
                       } else {
                           ForEach(0..<7, id: \.self) { _ in
                               VStack(spacing: 6) {
                                   Text("+0")
                                       .font(.system(size: 12))
                                       .foregroundColor(Color(hex: "#9A1E2E"))
                                       .lineLimit(1)
                                       .truncationMode(.tail)
                                       .minimumScaleFactor(0.7)
                                        .allowsTightening(true)
                                    //    .fixedSize(horizontal: true, vertical: false)
                                       .padding(.bottom,6)
                                   Text("-")
                                       .font(.system(size: 14))
                                       .foregroundColor(Color(hex: "#000000"))
                                       .lineLimit(1)
                                       .truncationMode(.tail)
                                       .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                                    //    .fixedSize(horizontal: true, vertical: false)
                                   Text("--/--")
                                       .font(.system(size: 12))
                                       .foregroundColor(Color(hex: "#000000"))
                                       .lineLimit(1)
                                       .truncationMode(.tail)
                                       .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                                    //    .fixedSize(horizontal: true, vertical: false)
                               }
                               .padding(.vertical, 20)
                               .padding(.horizontal, 6)
                               .background(LinearGradient(colors: [Color(hex: "#F3AAB3"), Color(hex: "#ffffff")], startPoint: .top, endPoint: .bottom))
                               .clipShape(Capsule())
                           }
                       }
                   }

                }
                .padding(.vertical,14)
                .padding(.horizontal,10)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(hex:"#ffffff"))
                )

                HStack(alignment:.center,spacing:5){
                        Image("Group_78")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 50, height: 50)
                        VStack(alignment:.leading,spacing:6){
                            Text("每日任务：数据任务")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex:"#000000"))
                                HStack{
                                     Text("Mobi分")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex:"#AFAFAF"))
                                    Text("+5")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex:"#9A1E2E"))
                                    Spacer()
                                }
                           
                        }
                        Spacer()
                    Button(action:{
                        navigateToMyProject = true
                    }){
                        Text("去完成")
                           .font(.system(size: 16))
                           .foregroundColor(Color(hex:"#ffffff"))
                           .padding(.vertical,10)
                           .padding(.horizontal,15)
                           .background(
                               Capsule().fill(Color(hex:"#9A1E2E"))
                           )
                    }
                }
                 .padding(.vertical,20)
                .padding(.horizontal,20)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(hex:"#ffffff"))
                )
                 VStack{
                    ForEach(Array(menus.enumerated()), id: \.element.id) { idx, menu in
                        menuItemView(menu: menu, idx: idx)
                    }
                }
                 .padding(.vertical,20)
                .padding(.horizontal,20)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(hex:"#ffffff"))
                )
              
               
            
               
                Spacer()
            }
             .padding(.horizontal,20)
            }

            if showSignSuccessPanel {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                       
                    VStack(spacing: 16) {
                        signSuccessPanel()
                        Button(action: {
                            showSignSuccessPanel = false
                        }) {
                            Image("Close-one_(关闭)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(2)
               
                    
                }
                .transition(.opacity)
                .zIndex(1)
            }

            NavigationLink(destination: MyProjectController(initialSelectedTab:0), isActive: $navigateToMyProject) {
                                EmptyView()
                            }
            NavigationLink(destination: EducationVerificationView(), isActive: $navigateToEducation) {
                                EmptyView()
                            }
             NavigationLink(destination: WorkVerificationView(), isActive: $navigateToWork) {
                                EmptyView()
                            }
             NavigationLink(destination: DriverVerificationView(), isActive: $navigateToDriver) {
                                EmptyView()
                            }
             NavigationLink(destination: IdentityVerificationView(), isActive: $navigateToIdentity) {
                                EmptyView()
                            }

        }
        .refreshable {
            fetchMobiPointsInfo()
        }
        .onAppear{
            fetchMobiPointsInfo()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                //返回图标
             Button(action:{
                dismiss()
             }){
                 Image(systemName: "chevron.left")
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .medium))
             }
            }

            ToolbarItem(placement: .principal){
                Text("数据合伙人")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex:"#000000"))
            }

            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink{
                        TutorialWebViewPage(urlString: "https://m.mobiwusi.com/user/rule",title: "积分规则")

                }label:{
                 Text("积分规则")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#9A1E2E"))
            }
            }
        }
         
       


     }
 
    // 规范化日期字符串（yyyy-MM-dd），为空或不合法时默认当天
    private func normalizedDateString(_ date: String?) -> String {
        if let s = date, !s.isEmpty {
            // 简单校验格式是否满足 yyyy-MM-dd
            let pattern = "^\\d{4}-\\d{2}-\\d{2}$"
            if s.range(of: pattern, options: .regularExpression) != nil {
                return s
            }
        }
        return Self.apiDateFormatter.string(from: Date())
    }

    //MARK： - 签到
    func signIn(date: String? = nil){
         let dateStr = normalizedDateString(date)
         let requestBody: [String: Any] = [
                "date": dateStr,
            ]
        
         NetworkManager.shared.post(APIConstants.Profile.signIn, 
                                 businessParameters: requestBody) { (result: Result<MobiSignInResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        // 显示积分值，并刷新数据
                        signInAwardValue = response.data?.value ?? 0
                        showSignSuccessPanel = true
                        fetchMobiPointsInfo()
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
            }
        }
    }

    
    
    // 辅助计算属性
    private var levelIconName: String {
        let level = mobiPointsInfo?.level ?? 1
        switch level {
        case 1: return "icon_level_one"
        case 2: return "icon_level_two"
        case 3: return "icon_level_three"
        case 4: return "icon_level_four"
        case 5: return "icon_level_five"
        default: return "icon_level_one"
        }
    }
 }


@MainActor
private func computePastUnSigned(item: MobiWeekItem, isToday: Bool, didSign: Bool, isYesterday: Bool) -> Bool {
    guard let d = DataPartnerController.apiDateFormatter.date(from: item.date) else { return false }
    let todayStart = Calendar.current.startOfDay(for: Date())
    return d < todayStart && !isToday && !isYesterday && !didSign
}

