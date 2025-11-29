//
//  MOTopologyMapVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/10.
//

import Foundation
class MOTopologyMapVC:MOBaseViewController {
	
	
	var imageUrl:String
	var scrollView = {
		let vi = MOTopologyMapScrollView()
		
		return vi
	}()
	var closeBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_interface_orientation_rotate"))
		btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
		btn.imageView?.transform = CGAffineTransform(rotationAngle: .pi / -2)
		return btn
	}()
	
	func setupUI(){
		self.fd_interactivePopDisabled = true
		self.view.addSubview(scrollView)
		self.view.addSubview(closeBtn)
	}
	
	func setupConstraints(){
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		if let imageURL = URL(string: imageUrl) {
			
			scrollView.imageView.sd_setImage(with: imageURL)
		}
		
		
		closeBtn.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
		}
	}
	
	func addActions(){
		closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func closeBtnClick(){
		MOAppDelegate().transition.popViewController(animated: false)
	}
	
	init(imageUrl:String) {
		self.imageUrl = imageUrl
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		
		return [.landscapeLeft, .landscapeRight]
	}
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .landscapeRight
	}
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupConstraints()
		addActions()
		
	}
}
