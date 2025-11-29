//
//  ColorDefine.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/27.
//

import Foundation
import UIKit
extension UIColor {
    static func color(fromHex hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// 定义颜色常量
let MainSelectColor = UIColor.color(fromHex: "9A1E2E")
let TabNormalColor = UIColor.color(fromHex: "01070D")
let WhiteColor = UIColor.color(fromHex: "FFFFFF")
let ClearColor = UIColor.clear
let BlackColor = UIColor.black
let Color9B9B9B = UIColor.color(fromHex: "9B9B9B")
let Color606060 = UIColor.color(fromHex: "606060")
let ColorEC0000 = UIColor.color(fromHex: "EC0000")
let Color333333 = UIColor.color(fromHex: "333333")
let Color626262 = UIColor.color(fromHex: "626262")
let ColorF6F7FA = UIColor.color(fromHex: "F6F7FA")
let ColorAFAFAF = UIColor.color(fromHex: "AFAFAF")
let ColorFF4242 = UIColor.color(fromHex: "FF4242")
let Color9A1E2E = UIColor.color(fromHex: "9A1E2E")
let ColorF9ECD7 = UIColor.color(fromHex: "F9ECD7")
let ColorFBF2EA = UIColor.color(fromHex: "FBF2EA")
let ColorE5F2F9 = UIColor.color(fromHex: "E5F2F9")
let ColorD9DAE3 = UIColor.color(fromHex: "D9DAE3")
let ColorFF0000 = UIColor.color(fromHex: "FF0000")
let ColorEDEEF5 = UIColor.color(fromHex: "EDEEF5")
let Color002FA7 = UIColor.color(fromHex: "002FA7")
let Color002FA8 = UIColor.color(fromHex: "002FA8")
let ColorFC9E09 = UIColor.color(fromHex: "FC9E09")
let Color34C759 = UIColor.color(fromHex: "34C759")
let ColorEC6200 = UIColor.color(fromHex: "EC6200")
let ColorECC800 = UIColor.color(fromHex: "ECC800")
let ColorF2F2F2 = UIColor.color(fromHex: "F2F2F2")
let ColorA2002D = UIColor.color(fromHex: "A2002D")
let ColorFFAE00 = UIColor.color(fromHex: "FFAE00")
let ColorFF4A4A = UIColor.color(fromHex: "FF4A4A")
let Color959998 = UIColor.color(fromHex: "959998")
let ColorEDEEF4 = UIColor.color(fromHex: "EDEEF4")
let ColorCCB94C = UIColor.color(fromHex: "CCB94C")
let Color828282 = UIColor.color(fromHex: "828282")
let ColorE6E4F2 = UIColor.color(fromHex: "E6E4F2")
let ColorB5B5B5 = UIColor.color(fromHex: "B5B5B5")
let ColorF5F5F5 = UIColor.color(fromHex: "F5F5F5")
let ColorFF6010 = UIColor.color(fromHex: "FF6010")
let ColorFF9A07 = UIColor.color(fromHex: "FF9A07")
let ColorFF8585 = UIColor.color(fromHex: "FF8585")
let ColorD9D9D9 = UIColor.color(fromHex: "D9D9D9")
let ColorFFE6D4 = UIColor.color(fromHex: "FFE6D4")
let ColorF6A15D = UIColor.color(fromHex: "F6A15D")
let ColorFAC9CF = UIColor.color(fromHex: "FAC9CF")
let ColorF6A361 = UIColor.color(fromHex: "F6A361")
let ColorEFF7FA = UIColor.color(fromHex: "EFF7FA")
let ColorB4B4B4 = UIColor.color(fromHex: "B4B4B4")
let ColorFF445C = UIColor.color(fromHex: "FF445C")
let ColorFFACB7 = UIColor.color(fromHex: "FFACB7")
let ColorEDDEE0 = UIColor.color(fromHex: "EDDEE0")
let ColorCAE2EE = UIColor.color(fromHex: "CAE2EE")
let Color5766E4 = UIColor.color(fromHex: "5766E4")
let ColorDFE1EC = UIColor.color(fromHex: "DFE1EC")
let Color8A8A8A = UIColor.color(fromHex: "8A8A8A")
let Color90ABD3 = UIColor.color(fromHex: "90ABD3")
let Color162938 = UIColor.color(fromHex: "162938")
let ColorFEAEB8 = UIColor.color(fromHex: "FEAEB8")
let Color4F68A7 = UIColor.color(fromHex: "4F68A7")
let ColorE24E66 = UIColor.color(fromHex: "E24E66")
let ColorFF6B6B = UIColor.color(fromHex: "FF6B6B")
let ColorE62941 = UIColor.color(fromHex: "E62941")


