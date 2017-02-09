//
//  PhotoDetailViewController.swift
//  InstaClone
//
//  Created by Tong Lin on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class PhotoDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    func setupViewHierarchy(){
        activitiesTableView.register(ActivityFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewController.activityFeedCellIdentifyer)
        
        self.view.addSubview(imageView)
        self.view.addSubview(upCountLabel)
        self.view.addSubview(downCountLabel)
        self.view.addSubview(activitiesTableView)
        imageView.addSubview(upVoteImage)
        imageView.addSubview(downVoteImage)
    }
    
    func configureConstraints(){
        imageView.snp.makeConstraints { (view) in
            view.height.equalToSuperview().multipliedBy(0.5)
            view.top.leading.trailing.equalToSuperview()
        }
        
        upCountLabel.snp.makeConstraints { (view) in
            view.top.equalTo(imageView.snp.bottom)
            view.leading.equalToSuperview()
            view.trailing.equalTo(self.view.snp.centerX)
        }
        
        downCountLabel.snp.makeConstraints { (view) in
            view.top.equalTo(imageView.snp.bottom)
            view.trailing.equalToSuperview()
            view.leading.equalTo(upCountLabel.snp.trailing)
        }
        
        activitiesTableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(upCountLabel.snp.bottom)
        }
        
        upVoteImage.snp.makeConstraints { (view) in
            view.leading.bottom.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.15)
            view.width.equalToSuperview().multipliedBy(0.50)
        }
        
        downVoteImage.snp.makeConstraints { (view) in
            view.bottom.trailing.equalToSuperview()
            view.height.equalTo(upVoteImage.snp.height)
            view.leading.equalTo(upVoteImage.snp.trailing)
        }
    }
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.activityFeedCellIdentifyer, for: indexPath) as! ActivityFeedTableViewCell
        
        cell.profileImageView.image = #imageLiteral(resourceName: "user_icon")
        cell.activityTextLabel.text = "👍🏻👍🏼👍🏽👍🏾👍🏿"
        cell.activityDateLabel.text = "11:30PM"
        return cell
    }
    
    //MARK: - Lazy Inits
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var upCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.instaPrimaryDark()
        label.textColor = UIColor.instaAccent()
        label.textAlignment = .center
        label.text = "328"
        return label
    }()
    
    lazy var downCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.instaPrimaryDark()
        label.textColor = UIColor.instaAccent()
        label.textAlignment = .center
        label.text = "10"
        return label
    }()
    
    lazy var activitiesTableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var upVoteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "up_arrow")
        image.backgroundColor = UIColor.instaPrimary()
        image.alpha = 0.7
        image.contentMode = .center
        return image
    }()
    
    lazy var downVoteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "down_arrow")
        image.backgroundColor = UIColor.instaPrimary()
        image.alpha = 0.7
        image.contentMode = .center
        return image
    }()
}
