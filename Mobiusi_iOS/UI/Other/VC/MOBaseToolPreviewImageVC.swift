//
//  MOBaseToolPreviewImageVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOBaseToolPreviewImageVC: MOBaseViewController {

	

	// MARK: - UI Components
	private lazy var navBar: MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = ""
		navBar.backBtn.isHidden = true
		navBar.contentMode = .right
		return navBar
	}()

	private lazy var closeBtn: MOButton = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_close_gray_38"))
		btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		return btn
	}()

	lazy var previewImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.backgroundColor = ClearColor
		imageView.contentMode = .scaleAspectFit
		
		return imageView
	}()
	
	lazy var scrollView = {
		let scorll = UIScrollView()
		scorll.contentInsetAdjustmentBehavior = .never
		
		return scorll
	}()
	
	lazy var contentView = {
		let vi = MOView()
		vi.cornerRadius(QYCornerRadius.bottom, radius: 20)
		return vi
	}()

	private lazy var bottomActionView: MOTranslateTextBottomView4 = {
		let view = MOTranslateTextBottomView4()
		view.didClickSaveBtn = { [weak self] in
			self?.saveImageToAlbum()
		}
		view.didClickShareBtn = { [weak self] in
			self?.showShareSheet()
		}
		return view
	}()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

}


// MARK: - UI Setup
private extension MOBaseToolPreviewImageVC {
	func setupUI() {
		view.backgroundColor = Color162938
		view.addSubview(contentView)
		scrollView.minimumZoomScale = 0.2
		scrollView.maximumZoomScale = 10
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.delegate = self
		contentView.addSubview(scrollView)
		scrollView.addSubview(previewImageView)
		view.addSubview(navBar)
		view.addSubview(bottomActionView)
		
		
		navBar.rightItemsView.addArrangedSubview(closeBtn)

		setupConstraints()
	}

	func setupConstraints() {
		navBar.snp.makeConstraints {
			$0.leading.trailing.top.equalToSuperview()
		}
		
		contentView.snp.makeConstraints {
			$0.leading.trailing.top.equalToSuperview()
		}
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}

		previewImageView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.center.equalToSuperview()
		}

		bottomActionView.snp.makeConstraints {
			$0.leading.trailing.bottom.equalToSuperview()
			$0.top.equalTo(contentView.snp.bottom)
		}
	}
}


// MARK: - Actions
extension MOBaseToolPreviewImageVC {
	@objc open func closeButtonTapped() {
		dismiss(animated: true)
	}

	

	func saveImageToAlbum() {
		guard let image = previewImageView.image else { return }
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
	}

	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			showMessage("\(NSLocalizedString("保存失败", comment: "")): \(error.localizedDescription)")
		} else {
			showMessage(NSLocalizedString("保存成功", comment: ""))
		}
	}
}


// MARK: - Sharing Logic
extension MOBaseToolPreviewImageVC {
	@objc func showShareSheet() {}
}


extension MOBaseToolPreviewImageVC:UIScrollViewDelegate {
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		
		return previewImageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let scrollViewSize = scrollView.bounds.size
		let containerSize = scrollView.contentSize

		let horizontalInset = max((scrollViewSize.width - containerSize.width) / 2, 0)
		let verticalInset = max((scrollViewSize.height - containerSize.height) / 2, 0)

		scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
		scrollView.setNeedsLayout()
		previewImageView.setNeedsLayout()
	}
}
