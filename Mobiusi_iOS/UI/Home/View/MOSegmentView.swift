//
//  MOSegmentView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOSegmentView: MOView {
    var currentSelectIndex = 0
    var titles:[String] = ["总结","导图"]
    var images:[UIImage] = []
    var titleBtns:[MOButton] = []
    var didSelectedIndex:((_ index:Int)->Void)?
    lazy var selectedView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    func setupUI(){
        
        
        self.backgroundColor = ColorDFE1EC
        self.addSubview(selectedView)
        
        for (index,title) in titles.enumerated() {
            let btn = MOButton()
            btn.setTitle(title, titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCBoldFont(12))
//            btn.setImage(images[index])
            titleBtns.append(btn)
            self.addSubview(btn)
        }
        
        
    }
    
    func setupConstraints(){
        
        for (index,btn) in titleBtns.enumerated() {
            let percent = CGFloat(index + 1) / CGFloat(titleBtns.count)
            btn.snp.makeConstraints { make in
                make.right.equalTo(self.snp.right).multipliedBy(percent)
                make.width.equalToSuperview().multipliedBy(1.0 / CGFloat(titleBtns.count))
                make.centerY.equalToSuperview()
            }
        }
        
        let selectedBtn = titleBtns[currentSelectIndex]
        
        selectedView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.width.equalToSuperview().multipliedBy(1.0 / CGFloat(titleBtns.count)).offset(-6)
            make.centerX.equalTo(selectedBtn.snp.centerX)
        }
        
    }
    
    
    func addAction(){
        
        for btn in titleBtns {
            btn.addTarget(self, action: #selector(itemBtnClick(btn:)), for: UIControl.Event.touchUpInside)
        }
    }
    
    @objc func itemBtnClick(btn:MOButton){
        
        let index = titleBtns.firstIndex { btn1 in
            return btn == btn1
        };
        
        if index == currentSelectIndex {
            return
        }
        currentSelectIndex = index ?? 0
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else {return}
            selectedView.snp.remakeConstraints{ make in
                make.top.equalToSuperview().offset(3)
                make.bottom.equalToSuperview().offset(-3)
                make.width.equalToSuperview().multipliedBy(1.0 / CGFloat(titleBtns.count)).offset(-6)
                make.centerX.equalTo(btn.snp.centerX)
            }
            selectedView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
        didSelectedIndex?(currentSelectIndex)
        
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addAction()
    }
}
