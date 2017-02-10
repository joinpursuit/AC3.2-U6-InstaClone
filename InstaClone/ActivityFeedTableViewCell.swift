//
//  ActivityFeedTableViewCell.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class ActivityFeedTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        setUpConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpView() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(activityTextLabel)
        self.contentView.addSubview(activityDateLabel)
    }
    
    func setUpConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(4)
            view.bottom.equalToSuperview().offset(-4)
            view.width.equalTo(profileImageView.snp.height)
        }
        
        activityTextLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(profileImageView.snp.trailing).offset(16)
            view.trailing.equalToSuperview().inset(4)
            view.bottom.equalTo(self.snp.centerY)
        }
        
        activityDateLabel.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(4)
            view.leading.equalTo(profileImageView.snp.trailing).offset(26)
            view.top.equalTo(activityTextLabel.snp.bottom).offset(2)
        }
    }

    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "user_icon")
        view.backgroundColor = UIColor.instaAccent()
        
        view.layer.borderWidth = 1
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.instaPrimaryDark().cgColor
        view.layer.cornerRadius = 17
        view.clipsToBounds = true
        return view
    }()
    
    lazy var activityTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
       return view
    }()
    
    lazy var activityDateLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        view.textAlignment = .left
        view.textColor = UIColor.instaSecondaryText()
        view.alpha = 0.7
        return view
    }()
    
    

}
