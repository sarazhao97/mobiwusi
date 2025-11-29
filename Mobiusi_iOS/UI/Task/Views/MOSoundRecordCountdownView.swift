//
//  MOSoundRecordCountdownView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/5.
//

import Foundation
class MOSoundRecordCountdownView: MOView {
    
    var complete:(()->Void)?
    lazy var countdownValue:Int = 0
    lazy var blurEffectView:UIVisualEffectView = {
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.light)
        let vi = UIVisualEffectView.init(effect: blurEffect)
        return vi
    }()
    
    lazy var countdownLabel:UILabel =  {
        let label = UILabel(text: "", textColor: WhiteColor!, font: MOPingFangSCBoldFont(40))
        label.backgroundColor = MainSelectColor
        label.cornerRadius(QYCornerRadius.all, radius: 50)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    func setupUI() {
        self.addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(countdownLabel)
    }
    
    func setupConstraints(){
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        countdownLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
    
    func countdownLabelAnimate(complete:@escaping (_ finished:Bool)->Void) {
        UIView.animate(withDuration: 0.5) {[weak self] in
            guard let self else {return}
            self.countdownLabel.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.5,delay: 0.5) {[weak self] in
                guard let self else {return}
                self.countdownLabel.alpha = 0.0
            } completion: { _ in
                complete(true)
            }
        }

    }
    
    func start(){
        self.countdownLabel.text = "1"
        countdownLabelAnimate { [weak self] finished in
            
            guard let self else { return}
            self.countdownLabel.text = "GO"
            self.countdownLabelAnimate { [weak self]finished in
                guard let self else { return}
                guard let complete else {return}
                complete()
            }
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        
    }
}
