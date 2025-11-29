//
//  MOLoginManagementVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/1.
//

import Foundation
@objc class MOLoginManagementVC: MOBaseViewController {
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("登录管理", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }();
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(), style: UITableView.Style.plain)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.backgroundColor = ClearColor
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
        return tableView
    }()
    
    
    func setupUI() {
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PersonCenterType1Cell.self, forCellReuseIdentifier: "PersonCenterType1Cell")
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.bottom.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension MOLoginManagementVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PersonCenterType1Cell = tableView.dequeueReusableCell(withIdentifier: "PersonCenterType1Cell") as!  PersonCenterType1Cell
        cell.leftLabel.text = "-网通登录密码"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        MOAppDelegate().transition.push(MOThirdPartyLoginManagement(), animated: true)
    }
    
}
