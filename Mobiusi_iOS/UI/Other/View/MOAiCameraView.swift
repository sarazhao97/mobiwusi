//
//  MOAiCameraView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/25.
//

import SwiftUI



struct MOAiCameraView: View {
    @Environment(\.presentationMode) var presentationMode
	@State var dataList:[MOTranslateTextRecordItemModel] = []
    var body: some View {
		VStack{
			MOSFNavBarView(
				leftBtnTitle: "返回",
				title: "标题",
				rightViews: [
					AnyView(Button(action: { print("按钮1") }) {
						Image(systemName: "bell")
					}),
					AnyView(Button(action: { print("按钮2") }) {
						Text("设置")
					}),
					
				],
				leftBtnAction: {
					self.presentationMode.wrappedValue.dismiss()
				}
			)
			List {
				
				ForEach(dataList, id: \.path) { item in
					
					cell(dataModel: item)
						.background(Color.clear)
						.listRowBackground(Color.clear.opacity(0))
				}
			}
			.listStyle(.plain)


		}
		.edgesIgnoringSafeArea(.top)
		.onAppear(){
			MONetDataServer.shared().transPictureList(withPage: 1, limit: 20) { dict in
				 
				let list = dict?["list"] as? NSArray
				let newList = NSMutableArray.yy_modelArray(with: MOTranslateTextRecordItemModel.self, json: list as Any) as? [MOTranslateTextRecordItemModel]
				if let newList {
					dataList.append(contentsOf: newList)
				}
			} failure: { error in
				
			} msg: { msg in
			} loginFail: {
				
			}
		}
        

    }
}




struct cell:View {
	var dataModel:MOTranslateTextRecordItemModel
	var body: some View {
		HStack {
			VStack {
				Image(systemName: "sun.max.fill")
					.resizable()
					.frame(width: 50, height: 50)
					.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
				Spacer()
				Text(dataModel.status_text ?? "")
			}
			.padding(.leading,50)
			.cornerRadius(20)
			.background(Color.white)
			.frame(maxWidth: .infinity,alignment: .leading)
			Spacer()
		}
		.background(Color.clear)
		.frame(maxWidth: .infinity,alignment: .leading)
	}
}


#Preview {
    MOAiCameraView()
}
