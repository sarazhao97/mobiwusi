//
//  MOAudioWaveView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/19.
//

import Foundation
class MOAudioWaveView: MOView {
	var layerOffset:CGFloat = 0
	var drawOffset:CGFloat = 0
	var soundDecibels:[Int] = []
	var displayWith = SCREEN_WIDTH
	
	lazy var  waveLayer = {
        let layer = CAShapeLayer()
        
        layer.fillColor = ClearColor.cgColor
        layer.strokeColor = UIColor.red.cgColor // 线条颜色
        layer.backgroundColor = ClearColor.cgColor
        layer.lineWidth = 2.0 // 线条宽度
        layer.lineCap = .round
		layer.contentsScale = UIScreen.main.scale
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
		layer.masksToBounds = true
        return layer
    }()
    var waveColor:UIColor? = UIColor.red
	
	func drawWave(width:CGFloat,height:CGFloat,drawNewOffsetX:CGFloat = 0,displayWith:CGFloat = SCREEN_WIDTH) {
		
		let path = UIBezierPath()
		
        let amplitude: CGFloat = 5.0 // 振幅，控制脉冲高度
        let period: CGFloat = 5.0 // 每个点的水平间距
        
//		let length: [CGFloat] = [
//				0.1, 0.4, 0.8, 1.5, 3.0, 5.0, 7.0, 5.0, 3.0, 1.5,
//				2.0, 3.0, 5.0, 3.0, 2.0, 1.5, 1.0, 0.4, 0.8, 1.5,
//				3.0, 5.0, 7.0, 5.0, 3.0, 1.5, 2.0, 3.0, 5.0, 3.0,
//				2.0, 1.5, 1.0, 0.4, 0.8, 1.5, 3.0, 5.0, 7.0, 5.0,
//				3.0, 1.5, 2.0, 3.0, 5.0, 3.0, 2.0, 1.5, 1.0, 0.8,
//				0.4, 0.1,
//			]
		let length: [CGFloat] = self.soundDecibels.map {
			var newValue = CGFloat($0) / 10.0
			if newValue == 0 {
				newValue = 0.1
			}
			return newValue
		}
		
		var x =  0.0
		
		for i in 0..<length.count {
			x =  period + x
			let y = height / 2 +  amplitude * length[i]/2.0
			let yf = height / 2 - amplitude * length[i]/2.0
			
			if x - self.layerOffset + waveLayer.lineWidth  < 0 {
				continue
			}
			if x  < drawNewOffsetX {
				continue
			}
			if x - self.layerOffset - drawNewOffsetX > displayWith {
				break
			}
			if x - self.layerOffset  > width {
				break
			}
			path.move(to: CGPoint(x: x, y: yf))
			path.addLine(to: CGPoint(x: x, y: y))
		}
		
		self.waveLayer.path = path.cgPath;
		
    }
	
	func updateRealTime(drawOffset:CGFloat){
		//除非你确定先layout ,你后滑动调用drawWave，否则要在layout时就更新drawOffset
		self.drawOffset = drawOffset
		drawWave(width: self.bounds.width + self.layerOffset, height: self.bounds.height,drawNewOffsetX: self.drawOffset,displayWith: self.displayWith)
	}
    
    
    func refrenshWave(){
        
        waveLayer.removeFromSuperlayer()
		waveLayer.frame = CGRect(x:  -self.layerOffset, y: 0, width: self.bounds.width + self.layerOffset, height: self.bounds.height)
		//一定要使用当前实时更新的到位置
		drawWave(width: self.bounds.width + self.layerOffset, height: self.bounds.height,drawNewOffsetX: drawOffset,displayWith: self.displayWith)
        self.layer.addSublayer(self.waveLayer)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refrenshWave()
    }
    
	init(waveColor:UIColor?,layerOffset:CGFloat = 0,soundDecibels:[Int]?) {
        if let waveColor {
            self.waveColor = waveColor
        }
		self.layerOffset = layerOffset
		
		if let soundDecibels {
			self.soundDecibels.append(contentsOf: soundDecibels)
		}
        super.init(frame: CGRect())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        self.waveLayer.strokeColor = waveColor?.cgColor
        self.isOpaque = true
        self.layer.addSublayer(self.waveLayer)
        self.clipsToBounds = true
		waveLayer.frame = CGRect(x:  -self.layerOffset, y: 0, width: self.bounds.width + self.layerOffset, height: self.bounds.height)
    }
}
