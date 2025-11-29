//
//  MODataPartnerSignInCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MODataPartnerSignInCell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
    
    var dataModel:MOLevelInfoResModel?
    var todayIndex = 0
    var cellHeight: CGFloat = 172
    
    var didSelectedCell: ((UITableViewCell) -> Void)?
    
    var didSelectedDate:((_ index:Int,_ isToday:Bool,_ isYesterday:Bool)->Void)?
    
    var weeks:[String] = {
        let weekdayNames = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        return weekdayNames
    }()
    
    var indexInWeeks:Int = {
        // 获取当前日期
        let currentDate = Date()
        // 创建Calendar实例
        var calendar = Calendar.current
        // 设置一周的第一天为周一
        calendar.firstWeekday = 2

        // 获取当前是周几（1是星期天，2是星期一，以此类推）
        let weekday = calendar.component(.weekday, from: currentDate)

        // 计算今天是本周的第几天，将周一作为第一天
        let dayOfWeekInThisWeek = (weekday + 5) % 7
        return dayOfWeekInThisWeek
    }()
    
    var dates:[String] = []
    var dataContentView:MOView = {
        
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    var titleLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("签到赚积分", comment: ""), textColor: BlackColor, font: MOPingFangSCFont(14))
        return label
    }()
    
    var subTitleLabel:UILabel = {
        
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCFont(12))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    var dateCollectionView:UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let itemWidth = 42
        flowLayout.itemSize = CGSize(width: itemWidth, height: 80)
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        collectionView.register(MOSigInDateCell.self, forCellWithReuseIdentifier: "MOSigInDateCell")
        return collectionView
        
    }()
    
    func caculeDate(){
        
        // 获取当前日期
        let currentDate = Date()
        // 创建Calendar实例
        var calendar = Calendar.current
        // 设置一周的第一天为周一
        calendar.firstWeekday = 2

        // 获取当前日期所在周的开始日期（即本周周一）
        if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: currentDate)) {
            // 格式化日期输出
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            
            // 循环打印本周的日期
            for dayOffset in 0..<7 {
                if let dayDate = calendar.date(byAdding:.day, value: dayOffset, to: startOfWeek) {
                    dates.append(dateFormatter.string(from: dayDate))
                }
            }
        }
    }
    
    func configCell(model:MOLevelInfoResModel) {
        self.dataModel = model
        let siginStr = String(format: NSLocalizedString("已连续签到%d天", comment: ""), model.continuous_days)
        subTitleLabel.text = siginStr
        if let week_data = model.week_data{
            for (index,item) in week_data.enumerated() {
                if item.is_today {
                    todayIndex = index
                }
                
            }
        }
        
        dateCollectionView.reloadData()
    }
    
    func coverDateToMMDD(dateString:String?)->String {

        
        guard let dateString else {return ""}
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM/dd"
            let result = outputFormatter.string(from: date)
            return result
        }
        return ""
    }
    
    func setupUI(){
        
        caculeDate()
        contentView.backgroundColor = ClearColor
        contentView.addSubview(dataContentView)
        
        dataContentView.addSubview(titleLabel)
        dataContentView.addSubview(subTitleLabel)
        dataContentView.addSubview(dateCollectionView)
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
    }
    
    func setupConstraints(){
        
        
        dataContentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.top.equalToSuperview().offset(20)
            
        }
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(9)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalTo(titleLabel.snp.centerY)
            
        }
        
        dateCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-13)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-15)
        }
        
    }
    override func addSubViews() {
        setupUI()
        setupConstraints()
    }
}

extension MODataPartnerSignInCell:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel?.week_data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MOSigInDateCell", for: indexPath)
        if let weakDate = dataModel?.week_data![indexPath.row] {
            
            if let cell1 = cell as? MOSigInDateCell {
                cell1.weekLable.text = weakDate.week_day
                if weakDate.is_today{
                    cell1.weekLable.text = NSLocalizedString("今天", comment: "")
                }
                
                
                cell1.dateLable.text = self.coverDateToMMDD(dateString: weakDate.date)
                cell1.topPointsLabel.text = "+\(weakDate.val)"
                if indexPath.row == todayIndex && weakDate.status == 0 {
                    cell1.todaySignInStyle()
                }
                if indexPath.row == todayIndex && weakDate.status == 1 {
                    cell1.cannotSignInStyle();
                }
                
                if indexPath.row > todayIndex {
                    cell1.toBeSignInStyle();
                }
                
                if indexPath.row < todayIndex {
                    cell1.cannotSignInStyle();
                }
                
                if weakDate.is_yesterday && weakDate.status == 0{
                    cell1.weekLable.text = NSLocalizedString("补签", comment: "")
                }
                if indexPath.row == todayIndex - 1 && weakDate.status == 0{
                    cell1.backdateSignInStyle();
                }
                
                if weakDate.status == 1 {
                    cell1.topPointsLabel.isHidden = true
                    cell1.topStateImageView.isHidden = false
                } else {
                    cell1.topPointsLabel.isHidden = false
                    cell1.topStateImageView.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let didSelectedDate else {return}
        guard let weakDate = dataModel?.week_data![indexPath.row] else {return}
        didSelectedDate(indexPath.row,weakDate.is_today,weakDate.is_yesterday)
    }
    
}

class MOSigInDateCell: UICollectionViewCell {
     lazy var gradientLayer: CAGradientLayer =  {
        
        let layer = CAGradientLayer.init()
         layer.startPoint = CGPoint(x: 0.5, y: 0)
         layer.endPoint = CGPoint(x: 0.5, y: 1)
         layer.locations = [0,1]
         layer.frame = self.bounds
        layer.colors = [ColorFFE6D4!.cgColor,WhiteColor!.cgColor]
        return layer
    }()
    lazy var bgView:MOView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 21)
        return vi
    }()
    
    lazy var gradientView:MOView = {
        let vi = MOView()
        vi.backgroundColor = ClearColor
        vi.cornerRadius(QYCornerRadius.all, radius: 21)
        vi.frame = self.bounds
        return vi
    }()
    
    lazy var backdateSignatureBorderView:MOGradientBorderView = {
        let vi = MOGradientBorderView(gradientColors: [ColorF6A15D!, WhiteColor!.withAlphaComponent(0)])
        vi.cornerRadius(QYCornerRadius.all, radius: 21)
        return vi
    }()
    
    lazy var currentSignatureBorderView:MOGradientBorderView = {
        let vi = MOGradientBorderView(gradientColors: [Color9A1E2E!, WhiteColor!.withAlphaComponent(0)])
        vi.cornerRadius(QYCornerRadius.all, radius: 21)
        return vi
    }()

    
    lazy var topPointsLabel:UILabel = {
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCFont(12))
        return label
    }()
    
    
    lazy var topStateImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_signin_successful")
        return imageView
    }()
    
    lazy var weekLable:UILabel = {
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCFont(12))
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }()
    
    lazy var dateLable:UILabel = {
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCFont(10))
        return label
    }()
    
    func setupUI(){
        contentView.addSubview(bgView)
        bgView.addSubview(backdateSignatureBorderView)
        bgView.addSubview(currentSignatureBorderView)
        
        bgView.addSubview(gradientView)
        gradientView.layer.addSublayer(gradientLayer)
        
        bgView.addSubview(topPointsLabel)
        bgView.addSubview(topStateImageView)
        bgView.addSubview(weekLable)
        bgView.addSubview(dateLable)
    }
    func setupConstraints(){
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backdateSignatureBorderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currentSignatureBorderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
        }
        
        topPointsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalTo(bgView.snp.centerX)
        }
        
        topStateImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalTo(bgView.snp.centerX)
        }
        
        dateLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalTo(bgView.snp.centerX)
        }
        
        weekLable.snp.makeConstraints { make in
            make.bottom.equalTo(dateLable.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
    }
    //不能签到风格
    func cannotSignInStyle(){
        backdateSignatureBorderView.isHidden = true
        currentSignatureBorderView.isHidden = true
        gradientLayer.isHidden = true
        bgView.backgroundColor = ColorEDEEF5
        topPointsLabel.textColor = Color9B9B9B
        weekLable.textColor = Color9B9B9B
        dateLable.textColor = Color9B9B9B
    }
    //补签风格
    func backdateSignInStyle(){
        backdateSignatureBorderView.isHidden = false
        currentSignatureBorderView.isHidden = true
        gradientLayer.isHidden = false
        gradientLayer.colors = [ColorFFE6D4!.cgColor,WhiteColor!.cgColor]
        gradientView.setNeedsLayout()
        bgView.backgroundColor = WhiteColor
        topPointsLabel.textColor = ColorF6A361
        weekLable.textColor = ColorF6A361
        dateLable.textColor = BlackColor
    }
    //今天待签到风格
    func todaySignInStyle(){
        backdateSignatureBorderView.isHidden = true
        currentSignatureBorderView.isHidden = false
        gradientLayer.isHidden = false
        gradientLayer.colors = [ColorFAC9CF!.cgColor,WhiteColor!.cgColor]
        bgView.backgroundColor = WhiteColor
        topPointsLabel.textColor = Color9A1E2E
        weekLable.textColor = BlackColor
        dateLable.textColor = BlackColor
    }
    //将要签到风格
    func toBeSignInStyle(){
        backdateSignatureBorderView.isHidden = true
        currentSignatureBorderView.isHidden = true
        gradientLayer.isHidden = false
        gradientLayer.colors = [ColorFAC9CF!.cgColor,WhiteColor!.cgColor]
        bgView.backgroundColor = WhiteColor
        topPointsLabel.textColor = Color9A1E2E
        weekLable.textColor = BlackColor
        dateLable.textColor = BlackColor
    }
    
    func addSubviews(){
        setupUI()
        setupConstraints()
        toBeSignInStyle()
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientLayer.frame.size.width != gradientView.bounds.width ||
            gradientLayer.frame.size.height != gradientView.bounds.height {
            
            gradientLayer.frame = gradientView.bounds
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
