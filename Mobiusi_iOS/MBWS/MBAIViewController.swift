//
//  MBAIViewController.swift
//  Mobiusi_iOS
//
//  Created by MBWS on 2024/12/19.
//

import UIKit

public class MBAIViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // 设置背景渐变
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.85, green: 0.92, blue: 0.98, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // 创建滚动视图
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // 创建内容视图
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 添加标题
        let titleLabel = UILabel()
        titleLabel.text = "AI智能助手"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "让AI为您提供专业服务，提升工作效率"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // 创建AI功能网格容器
        let gridContainer = UIView()
        gridContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gridContainer)
        
        // 创建AI功能按钮
        let features = [
            ("食品安全检测", "icon_ai_food_safety", "智能食品安全检测"),
            ("资讯分析师", "icon_ai_information_analyst", "专业资讯分析服务"),
            ("MO", "icon_ai_mo", "MO智能助手"),
            ("海外翻译", "icon_ai_overseas_translator", "多语言翻译服务"),
            ("全能摄影师", "icon_ai_versatile_photographer", "AI摄影助手")
        ]
        
        var buttons: [UIButton] = []
        
        for (index, feature) in features.enumerated() {
            let button = createFeatureButton(title: feature.0, iconName: feature.1, description: feature.2, tag: index)
            gridContainer.addSubview(button)
            buttons.append(button)
        }
        
        // 设置网格布局约束
        let buttonWidth: CGFloat = 160
        let buttonHeight: CGFloat = 140
        let spacing: CGFloat = 16
        
        for (index, button) in buttons.enumerated() {
            let row = index / 2
            let col = index % 2
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight),
                button.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor, constant: CGFloat(col) * (buttonWidth + spacing)),
                button.topAnchor.constraint(equalTo: gridContainer.topAnchor, constant: CGFloat(row) * (buttonHeight + spacing))
            ])
        }
        
        // 设置主约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            gridContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gridContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            gridContainer.widthAnchor.constraint(equalToConstant: buttonWidth * 2 + spacing),
            gridContainer.heightAnchor.constraint(equalToConstant: buttonHeight * 3 + spacing * 2),
            gridContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func createFeatureButton(title: String, iconName: String, description: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 10
        button.tag = tag
        
        // 添加图标
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconImageView)
        
        // 添加标题
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        // 添加描述
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(descLabel)
        
        // 设置按钮内部约束
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8),
            
            descLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            descLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -16)
        ])
        
        // 添加点击事件
        button.addTarget(self, action: #selector(featureButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func featureButtonTapped(_ sender: UIButton) {
        let features = ["食品安全检测", "资讯分析师", "MO", "海外翻译", "全能摄影师"]
        let featureName = features[sender.tag]
        
        // 显示功能详情
        let alert = UIAlertController(title: featureName, message: "此功能正在开发中，敬请期待！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层frame
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}
