//
//  MOQuestionListStateView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/20.
//

import Foundation
@objcMembers
class MOQuestionListStateView: MOView {
    
    var  currentSelectedIndex = 0
    var questionList:[MOTaskQuestionModel]?
    var taskModel:MOTaskListModel?
	@objc public var didClickNewIndex:((_ index:Int)->Void)?
    lazy var questionCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        collection.contentInset = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    func setupUI(){
        self.addSubview(questionCollectionView)
        questionCollectionView.register(MOQuestionStateCell.self, forCellWithReuseIdentifier: "MOQuestionStateCell")
        questionCollectionView.delegate = self
        questionCollectionView.dataSource = self
        
    }
    
    func setupConstraints(){
        questionCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7)
            make.height.equalTo(69)
        }
    }
    
    @objc public func configView(questionList1:[MOTaskQuestionModel],selectedIndex:Int,taskModel1:MOTaskListModel?) {
        currentSelectedIndex = selectedIndex;
        questionList = questionList1
        taskModel = taskModel1
        
        self.questionCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {[weak self] in
            guard let self else {return}
            questionCollectionView.scrollToItem(at: IndexPath(item: self.currentSelectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        
    }
}

extension MOQuestionListStateView:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: 31, height: collectionView.bounds.height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOQuestionStateCell", for: indexPath)
        
        if let cell1 = cell as? MOQuestionStateCell {
            cell1.topLable.text = String(indexPath.row + 1)
            
            if let questionList {
                let model = questionList[indexPath.row]
                guard let taskModel else {
                    return cell1
                }
                
                let taskStatus = taskModel.task_status.intValue
                if (taskStatus == 1 || taskStatus == 0) {
					if model.status == 0{
                        cell1.showTobeDone()
                    }
                    
                    
                    if model.status == 1 || model.status == 2 {
                        cell1.showComplete()
                    }
					if model.status == 3{
						cell1.showTobeDone()
					}
					
					if (currentSelectedIndex == indexPath.row) {
						if taskModel.topic_type == 1 {
							cell1.showTestDataDoingNow()
						} else {
							cell1.showDoingNow()
						}
						
					}
                }
                
                if (taskStatus == 3) {
					if model.status == 0{
						cell1.showTobeDone()
					}
					
					
					if model.status == 1 || model.status == 2 {
						cell1.showComplete()
					}
					if model.status == 3{
						cell1.showTobeDone()
					}
					
					if (currentSelectedIndex == indexPath.row) {
						if taskModel.topic_type == 1 {
							cell1.showTestDataDoingNow()
						} else {
							cell1.showDoingNow()
						}
						
					}
                }
                
                
                if (taskStatus == 4 || taskStatus == 5 || taskStatus == 2) {
					if currentSelectedIndex == indexPath.row {
						if taskModel.topic_type == 1 {
							cell1.showTestDataDoingNow()
						} else {
							cell1.showDoingNow()
						}
						
					} else {
						cell1.showComplete()
					}
                    
                }
            }
        }
        
    
        
        
        return cell
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if currentSelectedIndex != indexPath.row {
			didClickNewIndex?(indexPath.row)
		}
	}
	
}



class MOQuestionStateCell: UICollectionViewCell {
    
    lazy var topLable = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(14))
        label.textAlignment = .center
        return label
    }()
    
    lazy var stateView = {
        let vi = MOView()
        return vi
    }()
    
    func setupUI(){
        contentView.addSubview(topLable)
        contentView.addSubview(stateView)
    }
    
    func setupConstraints(){
        topLable.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(32)
        }
        
        stateView.snp.makeConstraints { make in
            make.top.equalTo(topLable.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(5)
        }
    }
    
    func showComplete(){
        topLable.cornerRadius(QYCornerRadius.all, radius: 16)
        topLable.backgroundColor = ClearColor
        topLable.textColor = BlackColor
        
        self.stateView.isHidden = false
        self.stateView.cornerRadius(QYCornerRadius.all, radius: 2.5)
        self.stateView.backgroundColor = Color34C759
        
    }
    
    func showTobeDone(){
        topLable.cornerRadius(QYCornerRadius.all, radius: 16)
        topLable.backgroundColor = ClearColor
        topLable.textColor = ColorD9D9D9
        
        self.stateView.isHidden = false
        self.stateView.cornerRadius(QYCornerRadius.all, radius: 2.5)
        self.stateView.backgroundColor = ColorD9D9D9
        
    }
    
    func showDoingNow(){
        topLable.cornerRadius(QYCornerRadius.all, radius: 16)
        topLable.backgroundColor = MainSelectColor
        topLable.textColor = WhiteColor
        
        self.stateView.isHidden = true
        self.stateView.cornerRadius(QYCornerRadius.all, radius: 2.5)
        self.stateView.backgroundColor = ColorD9D9D9
        
    }
    
    func showTestDataDoingNow(){
        topLable.cornerRadius(QYCornerRadius.all, radius: 16)
        topLable.backgroundColor = ColorFC9E09
        topLable.textColor = WhiteColor
        
        self.stateView.isHidden = true
        self.stateView.cornerRadius(QYCornerRadius.all, radius: 2.5)
        self.stateView.backgroundColor = ColorD9D9D9
        
    }
    
    func addSubviews() {
        
        setupUI()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
