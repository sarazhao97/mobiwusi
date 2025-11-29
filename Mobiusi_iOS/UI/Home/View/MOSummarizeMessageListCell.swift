//
//  MOSummarizeMessageListCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit

class MOSummarizeMessageListCell: MOTableViewCell {

	// MARK: - UI Components
		private lazy var myContent: MOView = {
			let view = MOView()
			return view
		}()
		
		private lazy var iconImageView: UIImageView = {
			let imageView = UIImageView()
			return imageView
		}()
		
		private lazy var msgTitleLabel: UILabel = {
			let label = UILabel()
			label.textColor = BlackColor
			label.font = MOPingFangSCBoldFont(13)
			return label
		}()
		
		private lazy var timeLabel: UILabel = {
			let label = UILabel()
			label.textColor = Color9B9B9B
			label.font = MOPingFangSCMediumFont(11)
			return label
		}()
		
		private lazy var lineView: MOView = {
			let view = MOView()
			view.backgroundColor = ColorF2F2F2
			return view
		}()
	
		private lazy var userInfoView = {
			let vi = MOSummarizeAvatarView()
			return vi
		}()
		
		private lazy var msgTextLabel: UILabel = {
			let label = UILabel()
			label.textColor = Color333333
			label.font = MOPingFangSCMediumFont(12)
			label.numberOfLines = 1
			return label
		}()
		
	
		override func addSubViews() {
			setupViews()
		}
		
		// MARK: - Setup Views
		private func setupViews() {
	//        self.contentView.autoresizingMask = .flexibleWidth
			self.translatesAutoresizingMaskIntoConstraints = false
			self.contentView.exerciseAmbiguityInLayout()
			self.contentView.backgroundColor = WhiteColor
			
			self.contentView.addSubview(myContent)
			myContent.snp.makeConstraints { make in
				make.edges.equalTo(self.contentView)
			}
			
			myContent.addSubview(iconImageView)
			myContent.addSubview(msgTitleLabel)
			msgTitleLabel.snp.makeConstraints { make in
				make.left.equalTo(iconImageView.snp.right).offset(5)
				make.top.equalTo(myContent.snp.top).offset(11)
			}
			
			iconImageView.snp.makeConstraints { make in
				make.left.equalTo(myContent.snp.left).offset(13)
				make.width.height.equalTo(18)
				make.centerY.equalTo(msgTitleLabel.snp.centerY)
			}
			
			myContent.addSubview(timeLabel)
			timeLabel.snp.makeConstraints { make in
				make.left.equalTo(msgTitleLabel.snp.right).offset(5)
				make.right.equalTo(myContent.snp.right).offset(-16)
				make.centerY.equalTo(msgTitleLabel.snp.centerY)
			}
			
			timeLabel.setContentHuggingPriority(.required, for: .horizontal)
			timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
			
			myContent.addSubview(lineView)
			lineView.snp.makeConstraints { make in
				make.left.equalTo(myContent.snp.left).offset(16)
				make.right.equalTo(myContent.snp.right).offset(-16)
				make.height.equalTo(1)
				make.top.equalTo(myContent.snp.top).offset(41)
			}
			
			myContent.addSubview(userInfoView)
			userInfoView.snp.makeConstraints { make in
				make.left.equalTo(myContent.snp.left).offset(13)
				make.top.equalTo(lineView.snp.bottom).offset(8)
				make.bottom.equalTo(myContent.snp.bottom).offset(-17)
			}
			myContent.addSubview(msgTextLabel)
			msgTextLabel.snp.makeConstraints { make in
				make.left.equalTo(userInfoView.snp.right).offset(10)
				make.right.equalTo(myContent.snp.right).offset(-13)
				make.centerY.equalTo(userInfoView.snp.centerY)
			}
			
			msgTextLabel.translatesAutoresizingMaskIntoConstraints = false
			msgTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		}
		
		// MARK: - Configuration
	func config(model:MOSummarizeMessageItemModel) {
		iconImageView.sd_setImage(with: URL(string: model.icon ?? ""))
		msgTitleLabel.text = model.operation_type_text
		timeLabel.text = model.create_time
		msgTextLabel.text = model.operation_content
		userInfoView.nickNameLabel.text = model.user_name
		if let url = URL(string: model.user_avatar ?? ""){
			userInfoView.avatarImageView.sd_setImage(with: url)
		}
			
		}

}
