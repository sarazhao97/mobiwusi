//
//  MOOnlyIuputVIew.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/28.
//

import Foundation
class MOOnlyIuputVIew: MOView {
    var inputTF:UITextField = {
        let tf = UITextField()
        tf.font = MOPingFangSCHeavyFont(17)
        return tf
    }()
    
    init(placeholder: String?) {
        self.inputTF.placeholder = placeholder
        super.init(frame: CGRect())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func addSubViews(inFrame frame: CGRect) {
        
        self.addSubview(inputTF)
        inputTF.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.5)
            make.right.equalToSuperview().offset(-21.5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
