import UIKit

class MOLinkRecognitionBottomView: MOView {

	lazy var summarizeBtn = {
			let btn = MOButton()
			btn.semanticContentAttribute = .forceRightToLeft
			btn.setImage(UIImage(namedNoCache: "icon_four_pointed_star"))
			btn.setTitle(NSLocalizedString("资讯分析师", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(13))
			btn.cornerRadius(QYCornerRadius.all, radius: 14)
			return btn
		}()
		
	lazy var leavBtn = {
		let btn = MOButton()
		btn.setTitle(NSLocalizedString("什么也不做，去上传", comment: ""), titleColor: Color9A1E2E!, bgColor: ClearColor, font: MOPingFangSCHeavyFont(13))
		return btn
	}()

    func setupUI() {
        
        addSubview(summarizeBtn)
        addSubview(leavBtn)
        
		summarizeBtn.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(19)
			make.right.equalToSuperview().offset(-19)
			make.top.equalToSuperview()
			make.height.equalTo(55)
		}

        
        leavBtn.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(summarizeBtn.snp.bottom).offset(22)
			make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(44)
        }
    }
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
	}
}
