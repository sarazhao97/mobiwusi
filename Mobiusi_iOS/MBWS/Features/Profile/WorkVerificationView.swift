//
//  WorkVerificationView.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/12.
//

import SwiftUI
import UIKit
import Foundation

struct WorkVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedWorkType = "1"
    @State private var selectedWorkTypeName: String = ""
    @State private var errorMessage = ""
    @State private var workTypes: [CategoryType] = []
    @State private var workIncome = ""
    //收入水平区间集合
    @State private var workIncomeRange: [CategoryType] = []
    @State private var workUnit = ""
    @State private var showWorkTypePicker = false
    @State private var showIncomePicker = false
    @State private var isFetchingOptions = false
    @State private var selectedWorkIncome = ""
    @State private var selectedWorkIncomeName: String = ""
    private var isWorkTypeReady: Bool { !workTypes.isEmpty }

    func fetchCategoryTypes(){

        errorMessage = ""
        isFetchingOptions = true
        
         NetworkManager.shared.post(APIConstants.Profile.getCategoryOptions, 
                                 businessParameters: [:]) { (result: Result<CategoryOptionResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                        workTypes = response.data?.work_type ?? []
                        workIncomeRange = response.data?.work_income ?? []
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
                isFetchingOptions = false
            }
        }
    }

    func WorkTypePickerView(workTypes: [CategoryType]) -> some View {
        VStack{
            HStack{
                Spacer()
                Text("选择工作类型")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(hex:"#000000"))
                 Spacer()
                Image("icon_search_close")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .onTapGesture{
                        showWorkTypePicker = false
                    }
            }
            ScrollView(showsIndicators: false) {
                ForEach(workTypes, id: \.value) { workType in
                    HStack{
                        Text(workType.name)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex:"#000000"))  
                            Spacer()
                    }
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    //下边框
               .overlay(alignment: .bottom) {
                   Rectangle()
                       .frame(height: 1)
                       .foregroundColor(Color(hex:"#f4f4f4"))
               }
               .onTapGesture {
                   selectedWorkType = workType.value
                   selectedWorkTypeName = workType.name
                   showWorkTypePicker = false
                 
               }
            }
            }
        }
        .padding(.vertical,16)
        .padding(.horizontal,30)
    }

    func IncomeRangePickerView(workIncomeRange: [CategoryType]) -> some View{
           VStack{
            HStack{
                Spacer()
                Text("选择月收入区间")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(hex:"#000000"))
                 Spacer()
                Image("icon_search_close")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .onTapGesture{
                        showIncomePicker = false
                    }
            }
            ScrollView(showsIndicators: false) {
                ForEach(workIncomeRange, id: \.value) { workIncome in
                    HStack{
                        Text(workIncome.name)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex:"#000000"))  
                            Spacer()
                    }
                    .padding(.vertical,16)
                    .contentShape(Rectangle())
                    //下边框
               .overlay(alignment: .bottom) {
                   Rectangle()
                       .frame(height: 1)
                       .foregroundColor(Color(hex:"#f4f4f4"))
               }
               .onTapGesture {
                   selectedWorkIncome = workIncome.value
                   selectedWorkIncomeName = workIncome.name
                   showIncomePicker = false
                 
               }
            }
            }
        }
        .padding(.vertical,16)
        .padding(.horizontal,30)
    }

    func submitVerification(){
       errorMessage = ""
       let incomeInt = Int(selectedWorkIncome) // 选填：未选择则为 nil
       let typeInt = Int(selectedWorkType)     // 必填：字符串转整型
       var requestBody: [String: Any?] = [
           "auth_type": "3",
           "work_income": incomeInt,
           "work_type": typeInt,
       ]
       if !workUnit.isEmpty {
          requestBody["work_company"] = workUnit
       }
       NetworkManager.shared.post(APIConstants.Profile.applyVerification, 
                                 businessParameters: requestBody) { (result: Result<ApplyVerificationResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                         MBProgressHUD.showMessag("认证申请已提交，等待审核", to: nil, afterDelay: 3.0)
                         dismiss()
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
    
  

    var body: some View {
          ZStack{
              Color(hex: "#f7f8fa")
               .ignoresSafeArea()
              VStack(alignment:.leading,spacing:10){
                HStack{
                    Text("工作类型")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#959998"))
                    Spacer()
                }
                .padding(.top,30)
               HStack{
                if selectedWorkTypeName.isEmpty{
                  Text("请选择")
                     .font(.system(size: 18))
                     .foregroundColor(Color(hex:"#959998"))  
                } else{
                    Text(selectedWorkTypeName)
                     .font(.system(size: 18))
                     .foregroundColor(Color(hex:"#000000"))  
                    
                }
                     Spacer()
                  Image("Arrow___Caret_Down_MD 1")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 18, height: 18)
               
                  
               }
               .padding(.vertical,16)
               .padding(.horizontal,16)
               .frame(maxWidth: .infinity)
               .background(Color.white)
               .cornerRadius(10)
               .overlay(alignment: .trailing) {
                   if isFetchingOptions {
                       ProgressView()
                           .scaleEffect(0.9)
                           .padding(.trailing, 8)
                   }
               }
               .onTapGesture{
                   if isWorkTypeReady {
                       showWorkTypePicker = true
                   } else {
                       MBProgressHUD.showMessag("正在加载选项，请稍候", to: nil, afterDelay: 2.0)
                       if !isFetchingOptions {
                           fetchCategoryTypes()
                       }
                   }
               }

                HStack{
                    Text("工作单位")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#959998"))
                    Spacer()
                }
                .padding(.top,30)
               HStack{
                  TextField("请输入", text: $workUnit)
                  Spacer()
                  
               }
               .padding(.vertical,16)
               .padding(.horizontal,16)
               .frame(maxWidth: .infinity)
               .background(Color.white)
               .cornerRadius(10)

                 HStack{
                    Text("月收入区间")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex:"#959998"))
                    Spacer()
                }
                .padding(.top,30)
               HStack{

                if selectedWorkIncomeName.isEmpty{
                  Text("选填")
                     .font(.system(size: 18))
                     .foregroundColor(Color(hex:"#959998"))  
                     Spacer()
                }else{
                    Text(selectedWorkIncomeName)
                     .font(.system(size: 18))
                     .foregroundColor(Color(hex:"#000000"))  
                     Spacer()
                }
                  Image("Arrow___Caret_Down_MD 1")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 18, height: 18)
                  
               }
               .padding(.vertical,16)
               .padding(.horizontal,16)
               .frame(maxWidth: .infinity)
               .background(Color.white)
               .cornerRadius(10)
                .onTapGesture{
                 showIncomePicker = true
               }

               Button(action:{
                  if selectedWorkTypeName.isEmpty {
                    errorMessage = "请选择工作类型"
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 0.6)
                  }else if workUnit.isEmpty {
                    errorMessage = "请输入工作单位"
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 0.6)
                  }else {
                    submitVerification()
                  }
               }){
                Text("提交")
                .padding(.vertical,16)
               .padding(.horizontal,16)
               .frame(maxWidth: .infinity)
               .background(Color(hex:"#9A1E2E"))
               .cornerRadius(10)
               .foregroundColor(.white)
               .padding(.top,30)
               }

               
                

                Spacer()
              }
              
            .padding(.horizontal,10)
          }
       
           .onAppear { fetchCategoryTypes() }
            .navigationTitle("职业认证")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 处理返回按钮点击事件
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showWorkTypePicker) {
                if #available(iOS 17.0, *) {
                    WorkTypePickerView(workTypes: workTypes)
                         .presentationDetents([.fraction(0.6)]) // 45% 高度，可上拉至全屏
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(20)
                } else if #available(iOS 16.0, *) {
                    WorkTypePickerView(workTypes: workTypes)
                        .presentationDetents([.fraction(0.6)]) // 45% 高度，可上拉至全屏
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(20)
                } else {
                    // iOS 15 及以下不支持 SwiftUI 的 detents，可保持默认样式
                    WorkTypePickerView(workTypes: workTypes)
                }
            }

             .sheet(isPresented: $showIncomePicker) {
                if #available(iOS 17.0, *) {
                    IncomeRangePickerView(workIncomeRange: workIncomeRange)
                         .presentationDetents([.fraction(0.6)]) // 45% 高度，可上拉至全屏
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(20)
                } else if #available(iOS 16.0, *) {
                    IncomeRangePickerView(workIncomeRange: workIncomeRange)
                        .presentationDetents([.fraction(0.6)]) // 45% 高度，可上拉至全屏
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(20)
                } else {
                    // iOS 15 及以下不支持 SwiftUI 的 detents，可保持默认样式
                    IncomeRangePickerView(workIncomeRange: workIncomeRange)
                }
            }

    }
}

