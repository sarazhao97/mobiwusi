import SwiftUI

// MARK: - 数据模型
struct PayMethod: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let isRecommend: Bool
    let value: Int
}

// MARK: - 子组件：提现金额按钮
struct DquotaButton: View {
    let dquota: Int
    @Binding var selected: Int
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0){
            Text("¥")
                .font(.system(size: 15))
                .foregroundColor(selected == dquota ? Color(hex:"#E64E62") : Color(hex:"#D9D9D9"))
            Text("\(dquota)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(selected == dquota ? Color(hex:"#E64E62") : Color(hex:"#D9D9D9"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(selected == dquota ? Color(hex:"#E64E62").opacity(0.15) : Color(hex:"#F7F8FA"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected == dquota ? Color(hex:"#E64E62") : Color.clear, lineWidth: 3)
        )
        .cornerRadius(10)
        .onTapGesture {
            selected = dquota
        }
    }
}

// MARK: - 子组件：推荐标签
struct RecommendBadge: View {
    var body: some View {
        Text("推荐")
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex:"#FC9E09"))
            .cornerRadius(6)
    }
}

// MARK: - 子组件：支付方式行
struct PayMethodRow: View {
    let method: PayMethod
    @Binding var selectedMethod: Int
    
    var body: some View {
        HStack(spacing: 10){
            Image(method.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
            Text(method.title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            if method.isRecommend {
                RecommendBadge()
            }
            
            Spacer()
            
            Button(action: {
                selectedMethod = method.value
            }) {
                Image(selectedMethod == method.value ? "icon_withdrawal_select" : "icon_withdrawal_normal")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
}


//绑定支付宝提示窗口
struct BindAccountAlert: View {
    @Binding var openAlert: Bool
    var body: some View {
        VStack(spacing: 20){
            HStack{
                Spacer()
                Text("温馨提示")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.black)
                Spacer()
            }
            HStack{
                Text("您还未绑定支付宝，绑定后才可以提现到支付宝")
                .font(.system(size: 16))
                .foregroundColor(Color(hex:"#333333"))
            }
            .padding(.vertical,10)
            HStack{
                Button{
                openAlert = false
            } label: {
                HStack{
                    Spacer()
                    Text("取消").font(.system(size: 16)).foregroundColor(Color(hex:"#A2002D"))
                    Spacer()
                }
            }
            Button{
                openAlert = false
            } label: {
                HStack{
                    Spacer()
                    Text("去绑定").font(.system(size: 16)).foregroundColor(Color(hex:"#A2002D"))
                    Spacer()
                }
            }
            }
            
        }
        .padding(20)
        .frame(maxWidth:.infinity)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal,40)
    }
}

// MARK: - 主视图
struct WithdrawalRequestController: View {
    @Environment(\.dismiss) var dismiss
    @State private var isBindAccount: Bool = false
    @State private var openAlert: Bool = false
    @State private var navigateToBankWithdraw: Bool = false
    @State private var selecteDquota = 50
    @State private var selectedMethod = 1
    @State private var dquotas = [50, 100, 200]
    @State private var payMethods = [
        PayMethod(title: "支付宝", icon: "Vector", isRecommend: true, value: 1),
        PayMethod(title: "银行卡", icon: "image_125", isRecommend: false, value: 2)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(hex: "#F7F8FA")
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 当前余额 & 提现金额
                    VStack(spacing: 20) {
                        HStack { Text("当前余额（元）").font(.system(size: 14)).foregroundColor(Color(hex:"#626262")); Spacer() }
                        HStack { Text("98.96").font(.system(size: 28, weight: .bold)).foregroundColor(.black); Spacer() }
                        
                        Rectangle()
                            .fill(Color(hex:"#F7F8FA"))
                            .frame(height: 1)
                            .padding(.horizontal, 10)
                            .padding(.top, 15)
                        
                        HStack { Text("提现金额").font(.system(size: 14)).foregroundColor(Color(hex:"#626262")); Spacer() }
                        
                        HStack(spacing: 20) {
                            ForEach(dquotas, id: \.self) { dquota in
                                DquotaButton(dquota: dquota, selected: $selecteDquota)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 10)
                    .padding(.top, -30)
                    
                    // 提现方式
                    Text("提现方式")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#626262"))
                        .padding(20)
                    
                    ForEach(payMethods) { method in
                        PayMethodRow(method: method, selectedMethod: $selectedMethod)
                    }
                    
                    // 提现规则
                    VStack(alignment: .leading, spacing: 10) {
                        Text("提现规则").font(.system(size: 14)).foregroundColor(Color(hex:"#626262"))
                        Text("· 单笔最低提现 ¥50，金额不得超过当前余额。").font(.system(size: 14)).foregroundColor(.black)
                        Text("· 支持支付宝、银行卡，1～3个工作日到账（节假日顺延）。").font(.system(size: 14)).foregroundColor(.black)
                        Text("· 信息错误或提现失败将退回账户余额。").font(.system(size: 14)).foregroundColor(.black)
                    }
                    .padding(.horizontal,10)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
                    
                    // 提现按钮
                    HStack {
                        Spacer()
                        Text("立即提现").font(.system(size: 18)).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red:1.0, green:0.42, blue:0.42), Color(red:0.902, green:0.161, blue:0.255)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .onTapGesture{
                        if selectedMethod == 1 && !isBindAccount {
                            openAlert = true
                        } else if selectedMethod == 2 {
                            navigateToBankWithdraw = true
                        }
                    }
                    .navigationDestination(isPresented: $navigateToBankWithdraw) {
                        BankWithdrawController()
                    }
                    
                    Spacer()
                }
               if openAlert {
                   ZStack {
                       Color.black.opacity(0.4)
                           .ignoresSafeArea()
                           .onTapGesture {
                               openAlert = false
                           }
                       
                       BindAccountAlert(openAlert: $openAlert)
                   }
               }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").foregroundColor(.black).imageScale(.large)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("申请提现").font(.system(size: 24, weight: .bold)).foregroundColor(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: WithdrawRecordController()) {
                    Text("提现记录")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex:"#9A1E2E"))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WithdrawalRequestController()
}