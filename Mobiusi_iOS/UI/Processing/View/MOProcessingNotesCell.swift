//
//  MOProcessingNotesCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOProcessingNotesCell: MOTableViewCell {
    
	var textdidChanged:((_ text:String?)->Void)?
	var textViewHeightdidChanged:((_ height:CGFloat)->Void)?
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var titleLabel = {
        let label = UILabel(text: NSLocalizedString("备注", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(15))
        label.textAlignment = .right
        return label
    }()
    
    
    lazy var textView = {
        let tv = UITextView()
        tv.zw_placeHolder = NSLocalizedString("点击此处进行音频备注操作", comment: "")
        tv.font = MOPingFangSCMediumFont(14)
        tv.textContainerInset = .zero
        return tv
    }()
    
    func setupUI(){
        contentView.addSubview(cunstomContentView)
        cunstomContentView.addSubview(titleLabel)
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
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-17)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        
    }
	
	func configCell(textStr:String?) {
		textView.text = textStr
		
	}
    
    override func addSubViews() {
        
        setupUI()
        setupConstraints()
    }
}

extension MOProcessingNotesCell:UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		textdidChanged?(textView.text)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		
	}
}

