//
//  MOSwiftUIWrapperBuilder.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/25.
//

import UIKit
import SwiftUI
class MOSwiftUIWrapperBuilder: NSObject {
	@MainActor @objc public static func createWithCameraView() -> MOSwiftUIViewWrapperVCGeneric {
		let view = MOAiCameraView()
		let vc = MOSwiftUIViewWrapperVCGeneric(rootView: AnyView(view))
		return vc
	}
}
