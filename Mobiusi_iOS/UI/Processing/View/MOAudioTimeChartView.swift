//
//  MOAudioTimeChartView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOAudioTimeChartView:MOView {
    
	var stepWidth = 100
	var timeStamp:Int64 = 0 {
		didSet {
			setScrollViewUI()
		}
	}
    var timeLabels:[UILabel] = []
	private var waveViewList:[MOAudioCanTaggingWaveView] = []
    lazy var scrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = ClearColor
        scroll.contentInset = UIEdgeInsets(top: 0, left: SCREEN_WIDTH/2, bottom: 0, right: SCREEN_WIDTH/2)
        return scroll
    }()
	
	
	lazy var expandWidthView = {
		let vi  = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}()
    
    lazy var bottomLine = {
        let vi = MOView()
        vi.backgroundColor = ColorD9D9D9
        return vi
    }()
    lazy var buoyView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_buoy_black")
        return imageView
    }()
    
    func setupUI(){
        
        self.addSubview(scrollView)
        scrollView.addSubview(expandWidthView);
        self.addSubview(bottomLine)
        self.addSubview(buoyView)
        
        
    }
	
	
	
	func updateMaskViews(datetailData:MOAnnotationDetailModel){
		
		for item in waveViewList {
			item.removeFromSuperview()
		}
		waveViewList.removeAll()
		let subRanges = datetailData.audio_slice ?? []
		for (index,item) in subRanges.enumerated() {
			item.localIndex = index
		}
		let noData = subRanges.count == 0
		
		let remaining = MOAudioTimeChartView.getRemainingIntervals(mainStart: 0, mainEnd: Int(timeStamp), subIntervals: subRanges)
		
		var  sortedIntervals = MOAudioTimeChartView.mergeAndSortIntervals(existing: subRanges, remaining: remaining)
		for item in sortedIntervals {
			item.wave_start_time = item.start_time
			item.wave_end_time = item.end_time
		}
		sortedIntervals = MOAudioTimeChartView.adjustIntervalsWithPadding(intervals: sortedIntervals)
		
		for (_,item) in sortedIntervals.enumerated() {
			var  startX = CGFloat(item.wave_start_time)/1000
			var  endX = CGFloat(item.wave_end_time)/1000
			startX = startX * CGFloat(stepWidth)
			endX = endX * CGFloat(stepWidth)
			let width = endX - startX
			let vi  = MOAudioCanTaggingWaveView(waveColor: WhiteColor,layerOffset: startX,layerWidth: width, soundDecibels: datetailData.sound_decibels)
			vi.configView(data: item)
			vi.backgroundColor = Color9A1E2E
			if !noData {
				vi.cornerRadius(QYCornerRadius.all, radius: 2)
			}
			scrollView.addSubview(vi)
			vi.snp.remakeConstraints { make in
				make.left.equalToSuperview().offset(startX)
				make.width.equalTo(width)
				make.height.equalTo(58)
				make.centerY.equalToSuperview().offset(13)
			}
			
			waveViewList.append(vi)
		}
		
		updateWaveViews(contentOffsetX: scrollView.contentOffset.x + scrollView.contentInset.left)
	}
	
	
	func setScrollViewUI(){
		
		for subview in timeLabels {
			subview.removeFromSuperview()
		}
		timeLabels.removeAll()
		let count = timeStamp / 1000
		for i in 0...count {
			let seconds = i
			// 格式化时间为 mm:ss
			let minutes = seconds / 60
			let remainingSeconds = seconds % 60
			let timeString = String(format: "%02d:%02d", minutes, remainingSeconds)
			let lable = UILabel(text: timeString, textColor: Color626262!, font: MOPingFangSCMediumFont(10))
			scrollView.addSubview(lable)
			timeLabels.append(lable)
		}
		
		for (index,label) in timeLabels.enumerated() {
			
			let offset  = index * stepWidth
			label.snp.makeConstraints { make in
				make.centerX.equalTo(scrollView.snp.left).offset(offset)
				make.top.equalToSuperview().offset(4)
				make.width.equalTo(27)
				make.height.equalTo(22)
			}
		}
		expandWidthView.snp.remakeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.width.equalTo(CGFloat(stepWidth) * (CGFloat(timeStamp) / 1000.0))
			make.height.equalTo(0.5)
			make.top.equalToSuperview()
		}
	}
	
    
    func setupConstraints(){
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        buoyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(26)
            make.bottom.equalToSuperview()
        }
        
        
        for (index,label) in timeLabels.enumerated() {
            
            let offset  = index * stepWidth
            label.snp.makeConstraints { make in
                make.centerX.equalTo(scrollView.snp.left).offset(offset)
                make.top.equalToSuperview().offset(4)
                make.width.equalTo(27)
                make.height.equalTo(22)
            }
        }
        
    }
	
	
	func updateWaveViews(contentOffsetX:CGFloat){
		
		let centerOffset = SCREEN_WIDTH/2.0
		let visibleMinX = contentOffsetX - SCREEN_WIDTH/2.0
		let visibleMaxX = contentOffsetX + SCREEN_WIDTH/2.0
		for (_,item) in waveViewList.enumerated() {
			
			let itemMinX = item.layerOffset
			let itemMaxX = itemMinX + item.layerWidth
			guard itemMaxX > visibleMinX, itemMinX < visibleMaxX else {
					continue
			}

			let relativeX = contentOffsetX - itemMinX
			let offset = max(0, relativeX - centerOffset)
			item.waveView.updateRealTime(drawOffset: offset)

				
		}
	}
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
    }
}

//MARK: 算法
extension MOAudioTimeChartView {
	static func getRemainingIntervals(mainStart: Int, mainEnd: Int, subIntervals: [MOAudioClipSegmentCustomModel]) -> [MOAudioClipSegmentCustomModel] {
		// 过滤非法区间并按起点排序
		let validSubs = subIntervals
			.filter { $0.start_time <= $0.end_time && $0.start_time >= mainStart && $0.end_time <= mainEnd }
			.sorted { $0.start_time < $1.end_time }
		
		var remaining: [MOAudioClipSegmentCustomModel] = []
		var currentStart = mainStart
		for item in validSubs {
			if currentStart < item.start_time {
				let model = MOAudioClipSegmentCustomModel()
				model.start_time = Int64(currentStart)
				model.end_time = item.start_time - 1
				remaining.append(model)
			}
			currentStart = Int(item.end_time + 1)
		}
		
		// 添加最后一个剩余区间
		if currentStart <= mainEnd {
			let model = MOAudioClipSegmentCustomModel()
			model.start_time = Int64(currentStart)
			model.end_time = Int64(mainEnd)
			remaining.append(model)
		}
		
		return remaining
	}
	
	static func mergeAndSortIntervals(existing: [MOAudioClipSegmentCustomModel], remaining: [MOAudioClipSegmentCustomModel]) -> [MOAudioClipSegmentCustomModel] {
		// 合并已有区间和剩余区间
		let allIntervals = existing + remaining
		
		// 按起点排序
		return allIntervals.sorted { $0.start_time < $1.start_time }
	}
	
	static func adjustIntervalsWithPadding(intervals: [MOAudioClipSegmentCustomModel], minLength: Int = 50, padding: Int64 = 10) -> [MOAudioClipSegmentCustomModel] {
		// 过滤掉长度小于minLength的区间
		let validIntervals = intervals.filter { $0.wave_end_time - $0.wave_start_time + 1 >= minLength }
		
		guard !validIntervals.isEmpty else { return [] }
		
		// 按起点排序
		let  sortedIntervals = validIntervals.sorted { $0.wave_start_time < $1.wave_start_time }
		
		
		// 调整区间位置以确保间隔为padding
		
		if sortedIntervals.count == 1 {
			
			return sortedIntervals
		}
		
		var adjusted: [MOAudioClipSegmentCustomModel] = [sortedIntervals.first!]
		
		for i in 1..<sortedIntervals.count {
			let prev = adjusted.last!
			prev.wave_end_time -= padding
			let current = sortedIntervals[i]
			
			// 计算当前区间的新起点
			let newStart = prev.wave_end_time + 2 * padding
			
			// 如果新起点导致区间长度不足minLength，则丢弃该区间
			if current.wave_end_time - newStart + 1 < minLength {
				continue
			}
			
			// 调整当前区间位置
			current.wave_start_time = newStart
			adjusted.append(current)
		}
		
		return adjusted
	}
}
