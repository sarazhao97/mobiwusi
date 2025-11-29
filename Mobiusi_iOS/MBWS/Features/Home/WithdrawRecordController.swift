import SwiftUI


struct WithdrawRecord: Identifiable {
    var id = UUID()
    var date: String
    var amount: String
    var status: Int
    var StatusText: String {
        switch status {
        case 0:
            return "已打款"
        case 1:
            return "打款中"
        case 2:
            return "审核失败"
        default:
            return "审核中"
        }
    }
}

struct WithdrawRecordRow: View {
    var record: WithdrawRecord
    var body: some View {
        HStack {
            HStack(alignment:.bottom,spacing:0){
                Text("¥")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#A2002D"))
                    .padding(.bottom,2)
                Text(String(format: "%.2f", Double(record.amount) ?? 0.0))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex:"#A2002D"))
            }
            
            Spacer()
            VStack(alignment:.trailing,spacing: 10){
                 Text(record.StatusText)
                    .font(.system(size: 16))
                    .foregroundColor( record.status == 0 ? Color(hex:"#FFAE00") : record.status == 1 ? Color(hex:"#0099FF") : Color(hex:"#FF4D4F"))
                 Text(record.date)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex:"#959998"))
            }
        }
        .padding(20)
        .background(Color.clear)

        Rectangle()
            .fill(Color(hex:"#F7F8FA"))
            .frame(height: 1)
            .padding(.horizontal, 10)
            .padding(.top, 15)
        
    }
}




struct WithdrawRecordController: View {
    @Environment(\.dismiss) var dismiss
    @State var records: [WithdrawRecord] = [
        WithdrawRecord(date: "2023-01-01", amount: "1000", status: 0),
        WithdrawRecord(date: "2023-01-02", amount: "2000", status: 1),
        WithdrawRecord(date: "2023-01-03", amount: "3000", status: 2),
        WithdrawRecord(date: "2023-01-07", amount: "7000", status: 3),
    ]

   

    var body: some View {
        VStack(spacing:0){
            ZStack{
                Color(hex: "#F7F8FA")
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0){
                    VStack(spacing:0){
                        ScrollView(showsIndicators:false){
                            LazyVStack(spacing:0){
                                ForEach(records) { record in
                                    WithdrawRecordRow(record: record)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 10)
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
                Text("提现记录").font(.system(size: 24, weight: .bold)).foregroundColor(.black)
            }
           
        }
    }
}

// MARK: - Preview
#Preview {
    WithdrawRecordController()
}
