//
//  MOPorcessingAudioSHView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOPorcessingAudioSHView:UITableViewHeaderFooterView {
    
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var indexLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(20))
        label.textAlignment = .right
        return label
    }()
    
    
    lazy var separateView = {
        let vi = MOView()
        vi.backgroundColor = ColorD9D9D9
        return vi
    }()
    
    lazy var playBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_record_my_voice_play"))
        return btn
    }()
    
    lazy var timeLable = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(15))
        label.textAlignment = .right
        return label
    }()
    
    lazy var expandBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_black_arrow_u"))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    func setupUI(){
        contentView.addSubview(cunstomContentView)
        cunstomContentView.addSubview(indexLabel)
        cunstomContentView.addSubview(separateView)
        cunstomContentView.addSubview(playBtn)
        cunstomContentView.addSubview(timeLable)
        cunstomContentView.addSubview(expandBtn)
    }
    
    func setupConstraints(){
        cunstomContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        indexLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.width.equalTo(19)
            make.centerY.equalToSuperview()
            
        }
        
        separateView.snp.makeConstraints { make in
            make.left.equalTo(indexLabel.snp.right).offset(7)
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        playBtn.snp.makeConstraints { make in
            make.left.equalTo(separateView.snp.right).offset(11)
            make.centerY.equalToSuperview()
        }
        
        timeLable.snp.makeConstraints { make in
            make.left.equalTo(playBtn.snp.right).offset(7)
            make.centerY.equalToSuperview()
        }
        
        expandBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-11)
            make.centerY.equalToSuperview()
        }
        
    }
	
	func configView(segmentData:MOAudioClipSegmentModel,index:Int) {
		indexLabel.text = "\(index)"
		let startTime = MOPorcessingAudioSHView.formatMilliseconds(Int(segmentData.start_time))
		let endTime = MOPorcessingAudioSHView.formatMilliseconds(Int(segmentData.end_time))
		timeLable.text = "\(startTime)-\(endTime)"
	}
	
	static func formatMilliseconds(_ milliseconds: Int) -> String {
		let totalMilliseconds = max(milliseconds, 0) // 确保非负数
		let minutes = totalMilliseconds / (60 * 1000)
		let remainingMilliseconds = totalMilliseconds % (60 * 1000)
		let seconds = remainingMilliseconds / 1000
		let millisecondsPart = remainingMilliseconds % 1000 // 取最后3位毫秒
		return String(format: "%02d:%02d:%03d", minutes, seconds,millisecondsPart)
	}
    
    func addSubviews() {
        setupUI()
        setupConstraints()
    }
    
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
