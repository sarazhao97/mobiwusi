import SwiftUI

struct BankWithdrawController: View {
     @Environment(\.dismiss) var dismiss
     @State private var name = ""
     @State private var cardNumber = ""
     @State private var bankName = ""
    var body: some View {
        ZStack{
            Color(hex: "#F7F8FA")
                .edgesIgnoringSafeArea(.all)
        
            VStack(spacing:10){
                HStack{
                    Text("收款人姓名")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#626262"))
                    Spacer()
                }
                .padding(.vertical,10)
                HStack{
                    TextField("请输入收款人姓名", text: $name)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex:"#626262"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom,20)
                HStack{
                    Text("开户行名称")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#626262"))
                    Spacer()
                }
                .padding(.vertical,10)
                HStack{
                    TextField("请输入开户行名称", text: $bankName)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex:"#626262"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom,20)
                HStack{
                    Text("银行卡号")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex:"#626262"))
                    Spacer()
                }
                .padding(.vertical,10)
                HStack{
                    TextField("请输入银行卡号", text: $cardNumber)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex:"#626262"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom,20)

                HStack{
                    Text("提交申请")
                        .font(.system(size: 18))
                        .foregroundColor(Color.white)
                        .padding(.vertical,20)
                        .padding(.horizontal,20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#9A1E2E"))
                        .cornerRadius(10)
                        .padding(.top,40)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal,20)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading){
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left").foregroundColor(.black).imageScale(.large)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("银行卡提现").font(.system(size: 24, weight: .bold)).foregroundColor(.black)
                }
            
            }
        }

    }
}

#Preview {
    BankWithdrawController()
}