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
            view.leading.equalTo(profileImageView.snp.trailing).offset(8)
            view.trailing.equalToSuperview().inset(4)
            view.top.equalToSuperview()
            view.bottom.equalTo(activityDateLabel.snp.top)
        }
        
        activityDateLabel.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(4)
            view.leading.equalTo(profileImageView.snp.trailing).offset(8)
            view.bottom.equalToSuperview()
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
        view.textAlignment = .center
       return view
    }()
    
    lazy var activityDateLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    

}
