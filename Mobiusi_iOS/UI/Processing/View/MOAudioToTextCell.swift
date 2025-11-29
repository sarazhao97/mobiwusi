//
//  MOAudioToTextCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOAudioToTextCell:MOTableViewCell {
    
	var textdidChanged:((_ text:String?)->Void)?
	var textViewHeightdidChanged:((_ height:CGFloat)->Void)?
	var audioToTextBtnClick:(()->Void)?
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var titleLabel = {
        let label = UILabel(text: NSLocalizedString("音频转写", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(15))
        label.textAlignment = .right
        return label
    }()
    
    lazy var toTextBtn = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("智能转写", comment: ""), titleColor: Color333333!, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
        btn.setImage(UIImage(namedNoCache: "icon_audio_to_text"))
        return btn
    }()
    
    lazy var textView = {
        let tv = UITextView()
        tv.zw_placeHolder = NSLocalizedString("点击此处可进行手动转写", comment: "")
        tv.font = MOPingFangSCMediumFont(14)
        tv.textContainerInset = .zero
        return tv
    }()
    
    func setupUI(){
		
        contentView.addSubview(cunstomContentView)
		cunstomContentView.translatesAutoresizingMaskIntoConstraints = false
        cunstomContentView.addSubview(titleLabel)
        cunstomContentView.addSubview(toTextBtn)
		textView.delegate = self
        cunstomContentView.addSubview(textView)
		textView.observeValue(forKeyPath: "contentSize") {[weak self] dict, object in
			let size:CGSize = dict["new"] as! CGSize
			   guard let self else {return}
				DLog("size.height :\(size.height)")
			   if size.height != self.textView.bounds.height && size.height > 36{
				   textViewHeightdidChanged?(100 - 36 + size.height)
				   self.textView.snp.remakeConstraints{ make in
					   make.height.equalTo(size.height).priority(800)
					   make.top.equalTo(titleLabel.snp.bottom).offset(5)
					   make.left.equalToSuperview().offset(17)
					   make.right.equalToSuperview().offset(-17)
					   make.bottom.equalToSuperview().offset(-15)
				   }
			   }
		}
    }
    
    func setupConstraints(){
        cunstomContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.top.equalToSuperview().offset(13)
            
        }
        toTextBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-15)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-17)
			make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
	func addAtcions(){
		toTextBtn.addTarget(self, action: #selector(toTextBtnClick), for: UIControl.Event.touchUpInside)
	}
	@objc func toTextBtnClick(){
		audioToTextBtnClick?()
	}
	
	func configCell(textStr:String?) {
		textView.text = textStr
		
	}
    
    override func addSubViews() {
        
        setupUI()
        setupConstraints()
		addAtcions()
    }
}


extension MOAudioToTextCell:UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		textdidChanged?(textView.text)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		
	}
}
