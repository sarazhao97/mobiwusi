//
//  AccountManageController.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/10/27.
//

import SwiftUI
import Foundation


struct AccountManageController:View {
    @Environment(\.dismiss) private var dismiss
    var mobile:String
    var openid:String
    var alipay_openid:String

    func customNavigationBar() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("账户管理")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    var body: some View {
                ZStack{
                    Color(hex: "#F7F8FA").ignoresSafeArea()
                    VStack{
                        customNavigationBar()
                       VStack(alignment:.leading,spacing:10){
                          VStack(alignment:.center,spacing:30){
                        //     HStack{
                        //         HStack{
                        //             Image("icon_share_wx")
                        //             .resizable()
                        //             .scaledToFit()
                        //             .frame(width: 26, height: 26)
                        //             Text("微信")
                        //                 .font(.system(size: 18))
                        //                 .foregroundColor(.black)
                        //         }
                        //         Spacer()
                        //         HStack{
                        //             Text(openid.isEmpty ? "去绑定" : "已绑定")
                        //                .font(.system(size: 15))
                        //                .foregroundColor(Color(hex:"#B2B2B2"))
                        //             Image(systemName: "chevron.right")
                        //                 .font(.system(size: 15))
                        //                 .foregroundColor(Color.black)
                        //         }
                        //    }
                        //    .onTapGesture{
                        //     if openid.isEmpty{
                        //         // 去绑定微信
                        //     }else{
                        //         // 去解绑微信
                        //     }
                        //    }
                        //      HStack{
                        //         HStack{
                        //             Image("alipay")
                        //             .resizable()
                        //             .scaledToFit()
                        //             .frame(width: 26, height: 26)
                        //             Text( "支付宝")
                        //                 .font(.system(size: 18))
                        //                 .foregroundColor(.black)
                        //         }
                        //         Spacer()
                        //         HStack{
                        //             Text(alipay_openid.isEmpty ? "去绑定" : "已绑定")
                        //                .font(.system(size: 15))
                        //                .foregroundColor(Color(hex:"#B2B2B2"))
                        //             Image(systemName: "chevron.right")
                        //                 .font(.system(size: 15))
                        //                 .foregroundColor(Color.black)
                        //         }
                        //    }
                        //    .onTapGesture{
                        //     if alipay_openid.isEmpty{
                        //         // 去绑定支付宝
                        //     }else{
                        //         // 去解绑支付宝
                        //     }
                        //    }
                        //   }
                        //   .padding(20)
                        //     .frame(maxWidth: .infinity)
                        //     .background(Color.white)
                        //     .cornerRadius(10)
                        //      .contentShape(Rectangle())

                            HStack{
                                Text("修改密码")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                             .contentShape(Rectangle())
                            .onTapGesture{
                                    Task { @MainActor in
                                        let vc = UIHostingController(
                                            rootView: EditPwdController(mobile: mobile)
                                            .toolbarColorScheme(.dark)
                                                )
                                                vc.hidesBottomBarWhenPushed = true
                                                MOAppDelegate().transition.push(vc, animated: true)
                                }

                            }
                           
                       }
                        
                        .padding(.horizontal,10)
                        Spacer()
                    }
                }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .toolbar(.hidden, for: .tabBar)
              
    }
}
