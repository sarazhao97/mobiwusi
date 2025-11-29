//
//  MOAudioSegmentationView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioSegmentationView:MOView {
	
	var stepWidth = 100
	var timeStamp:Int64
    var segmentStart = 0.0
    var segmentEnd = 0.0
	
	var didSetStartTime:((_ timeValue:Double,_ initEndTime:Bool)->Void)?
	var didSetEndTime:((_ timeValue:Double)->Void)?
	var didSetTimeError:((_ msg:String)->Void)?
	
	var  detailModel:MOAnnotationDetailModel
	var segmentData:MOAudioClipSegmentModel?
	var historyMaskView:[MOView] = []
	
    lazy var scrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: SCREEN_WIDTH/2.0, bottom: 0, right: SCREEN_WIDTH/2.0)
        return scroll
    }()
    
    lazy var currentSegmentMaskView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor?.withAlphaComponent(0.25)
        return vi
    }()
    
    lazy var segmentStartBuoyImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_audio_segmentation_start")
        return imageView
    }()
    
    lazy var segmentEndBuoyImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_audio_segmentation_end")
        return imageView
    }()
    
    lazy var setStartTimeBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("设为开始", comment: ""), titleColor: WhiteColor!, bgColor: (WhiteColor?.withAlphaComponent(0.25))!, font: MOPingFangSCMediumFont(12))
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        btn.cornerRadius(QYCornerRadius.all, radius: 20)
        return btn
    }()
    
    lazy var setEndTimeBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("设为结束", comment: ""), titleColor: WhiteColor!, bgColor: (WhiteColor?.withAlphaComponent(0.25))!, font: MOPingFangSCMediumFont(12))
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        btn.cornerRadius(QYCornerRadius.all, radius: 20)
        return btn
    }()
    
    lazy var buoyView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_buoy_red")
        return imageView
    }()
    
    lazy var waveView = {
		let vi  = MOAudioWaveView(waveColor: WhiteColor,soundDecibels: detailModel.sound_decibels)
        return vi
    }()
    
    
    func setupUI(){
        self.backgroundColor = BlackColor
        self.addSubview(scrollView)
        scrollView.addSubview(waveView)
        scrollView.addSubview(currentSegmentMaskView)
		
		if let audio_slice = detailModel.audio_slice {
			for item in audio_slice {
				let vi = MOView()
				vi.backgroundColor = Color9A1E2E?.withAlphaComponent(0.5)
				let startX =  CGFloat(stepWidth) * CGFloat(item.start_time)/1000.0
				let endX =  CGFloat(stepWidth) * CGFloat(item.end_time)/1000.0
				scrollView.addSubview(vi)
				//历史的 直接固定死
				vi.snp.makeConstraints { make in
					make.left.equalToSuperview().offset(startX)
					make.width.equalTo(endX - startX)
					make.centerY.equalToSuperview().offset(13)
					make.height.equalTo(58)
				}
			}
		}
		
		
        segmentStartBuoyImageView.isHidden = true
        scrollView.addSubview(segmentStartBuoyImageView)
        segmentEndBuoyImageView.isHidden = true
        scrollView.addSubview(segmentEndBuoyImageView)
        self.addSubview(setStartTimeBtn)
        self.addSubview(setEndTimeBtn)
        self.addSubview(buoyView)
        
    }
    
    func setupConstraints(){
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(35)
            make.height.equalTo(118)
        }
        
        setStartTimeBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(26)
            make.right.equalTo(self.snp.centerX).offset(-5)
        }
        
        setEndTimeBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(26)
            make.left.equalTo(self.snp.centerX).offset(5)
        }
        
        buoyView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.height.equalTo(107)
            make.centerX.equalToSuperview()
        }
		
		waveView.snp.remakeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.width.equalTo(CGFloat(stepWidth) * (CGFloat(timeStamp) / 1000.0))
			make.height.equalTo(58)
			make.centerY.equalToSuperview().offset(13)
		}
    }
    
    func hollowOutRect(rect:CGRect) {
        let bezierPath = UIBezierPath(rect: self.currentSegmentMaskView.bounds)
        let ezierPath1 = UIBezierPath(rect: rect)
        bezierPath.append(ezierPath1)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.green.cgColor
        maskLayer.fillRule = .evenOdd
        maskLayer.path = bezierPath.cgPath;
        self.currentSegmentMaskView.layer.mask = maskLayer
    }
    
    func addActions(){
        setStartTimeBtn.addTarget(self, action: #selector(setStartTimeBtnClick), for: UIControl.Event.touchUpInside)
        setEndTimeBtn.addTarget(self, action: #selector(setEndTimeBtnClick), for: UIControl.Event.touchUpInside)
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		segmentStartBuoyImageView.isUserInteractionEnabled = true
		segmentStartBuoyImageView.addGestureRecognizer(panGesture)
		let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		segmentEndBuoyImageView.isUserInteractionEnabled = true
		segmentEndBuoyImageView.addGestureRecognizer(panGesture1)
		
    }
	
	@objc func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard let view = gesture.view else { return }
		let translation = gesture.translation(in: view.superview)
		
		if view == segmentStartBuoyImageView &&  segmentEnd > 0 && CGRectGetMaxX(view.frame) <= segmentEnd {
			segmentStartBuoyImageView.center = CGPoint(x: view.center.x + translation.x,
								  y: view.center.y)
			gesture.setTranslation(.zero, in: view.superview)
			let x = CGRectGetMaxX(view.frame)
			segmentStart = x
			let progress = x / scrollView.contentSize.width
			let timeValue = progress * CGFloat(timeStamp)
			segmentData?.start_time = Int64(timeValue)
			didSetStartTime?(timeValue,false)
			
			currentSegmentMaskView.frame = CGRect(x: segmentStart, y: waveView.frame.origin.y, width: segmentEnd - segmentStart, height: CGRectGetHeight(waveView.frame))
		}
		
		if view == segmentEndBuoyImageView &&  segmentStart > 0 && CGRectGetMinX(view.frame) >= segmentStart  {
			
			segmentEndBuoyImageView.center = CGPoint(x: view.center.x + translation.x,
								  y: view.center.y)
			gesture.setTranslation(.zero, in: view.superview)
			
			let x = CGRectGetMinX(view.frame)
			segmentEnd = x
			let progress = x / scrollView.contentSize.width
			let timeValue = progress * CGFloat(timeStamp)
			segmentData?.end_time = Int64(timeValue)
			didSetEndTime?(timeValue)
			
			currentSegmentMaskView.frame = CGRect(x: segmentStart, y: waveView.frame.origin.y, width: segmentEnd - segmentStart, height: CGRectGetHeight(waveView.frame))
			
		}
		
		
	}
    
    @objc func setStartTimeBtnClick(){
		
		if scrollView.isDragging || scrollView.isDecelerating {
			return
		}
		
		let progress = (scrollView.contentOffset.x + scrollView.contentInset.left)/scrollView.contentSize.width
		if progress.isNaN {
			
			return
		}
		if progress < 0 {
			return
		}
		if progress > 1.0 {
			return
		}
		
		
		self.currentSegmentMaskView.layer.mask = nil
		currentSegmentMaskView.isHidden = true
        segmentStartBuoyImageView.isHidden = false
		segmentEndBuoyImageView.isHidden = true
        segmentStart = scrollView.contentOffset.x + scrollView.contentInset.left
		segmentStartBuoyImageView.frame = CGRect(x: segmentStart -  14.5, y: 0, width: 14.5, height: 118.5)
		let timeValue = progress * CGFloat(timeStamp)
		segmentData?.start_time = Int64(timeValue)
		segmentData?.end_time = -1
		didSetStartTime?(timeValue,true)
    }
    
    @objc func setEndTimeBtnClick(){
		if scrollView.isDragging || scrollView.isDecelerating {
			return 
		}
		
		if segmentStart == 0 {
			didSetTimeError?(NSLocalizedString("请先设置开始时间", comment: ""))
			return
		}
		
		let tmpEnd = scrollView.contentOffset.x + scrollView.contentInset.left
		if tmpEnd < segmentStart {
			didSetTimeError?(NSLocalizedString("结束时间不能小于开始时间", comment: ""))
			return
		}
		
		let progress = (scrollView.contentOffset.x + scrollView.contentInset.left)/scrollView.contentSize.width
		if progress.isNaN {
			
			return
		}
		if progress < 0 {
			return
		}
		if progress > 1.0 {
			return
		}
		
        segmentEndBuoyImageView.isHidden = false
        segmentEnd = tmpEnd
		segmentEndBuoyImageView.frame = CGRect(x: segmentEnd, y: 0, width: 18.5, height: 118.5)
        
		currentSegmentMaskView.isHidden = false
		currentSegmentMaskView.frame = CGRect(x: segmentStart, y: waveView.frame.origin.y, width: segmentEnd - segmentStart, height: CGRectGetHeight(waveView.frame))
		
		let timeValue = progress * CGFloat(timeStamp)
		segmentData?.end_time = Int64(timeValue)
		didSetEndTime?(timeValue)
    }
	
	func updateWaveViews(contentOffsetX:CGFloat){
		
		
		if contentOffsetX < waveView.frame.origin.x + waveView.frame.width {
			let offset  = contentOffsetX - waveView.frame.origin.x < SCREEN_WIDTH/2 ? 0:contentOffsetX - waveView.frame.origin.x - SCREEN_WIDTH/2
			waveView.updateRealTime(drawOffset: offset)
		}
	}
	
	init(timeStamp: Int64, detailModel:MOAnnotationDetailModel,segmentData: MOAudioClipSegmentModel? = nil) {
		self.timeStamp = timeStamp
		self.segmentData = segmentData
		self.detailModel = detailModel
		super.init(frame: CGRect())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addActions()
    }
}
