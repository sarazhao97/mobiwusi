//
//  MOSwiftUIViewWrapperVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2024/7/25.
//

import SwiftUI
import UIKit


// 1. A non-generic base class that can be referenced from Objective-C
@objc(MOSwiftUIViewWrapperVC)
open class MOSwiftUIViewWrapperVC: MOBaseViewController {
    // This class can be empty or contain non-generic properties/methods
}

// 2. A generic subclass for use in Swift
open class MOSwiftUIViewWrapperVCGeneric: MOSwiftUIViewWrapperVC {
    private var hostingController: UIHostingController<AnyView>?

    public init(rootView: AnyView) {
        super.init(nibName: nil, bundle: nil)
        self.hostingController = UIHostingController(rootView: rootView)
    }

    @objc required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let hostingController = hostingController else { return }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        hostingController.view.backgroundColor = .clear
    }
}
