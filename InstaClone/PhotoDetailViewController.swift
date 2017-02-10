//
//  PhotoDetailViewController.swift
//  InstaClone
//
//  Created by Tong Lin on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class PhotoDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let storageReference = FIRStorage.storage().reference()
    
    var currentPhoto: Photo!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        
        loadCurrentImage()
    }
    
    func loadCurrentImage() {
        navigationItem.title = currentPhoto.title
        let imageRef = self.storageReference.child(currentPhoto.filePath)
        imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
            if error != nil {
                print("Error \(error)")
            }
            if let validData = data {
                self.imageView.image = UIImage(data: validData)
            }
        })
    }
    
    func setupViewHierarchy(){
        activitiesTableView.register(ActivityFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewController.activityFeedCellIdentifyer)
        
        self.view.addSubview(imageView)
        self.view.addSubview(upCountLabel)
        self.view.addSubview(downCountLabel)
        self.view.addSubview(activitiesTableView)
        self.view.addSubview(upVoteButton)
        self.view.addSubview(downVoteButton)
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
        
        upVoteButton.snp.makeConstraints { (view) in
            view.bottom.equalTo(upCountLabel.snp.top)
            view.leading.equalToSuperview()
            view.height.equalTo(imageView).multipliedBy(0.15)
            view.width.equalToSuperview().multipliedBy(0.50)
        }
        
        downVoteButton.snp.makeConstraints { (view) in
            view.bottom.equalTo(downCountLabel.snp.top)
            view.trailing.equalToSuperview()
            view.height.equalTo(upVoteButton.snp.height)
            view.leading.equalTo(upVoteButton.snp.trailing)
        }
    }
    
    
    // MARK: - Actions
    
    func didPressUpVoteButton() {
        print("UP")
        let ref = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID)
        Vote.voted(for: ref, upvoted: true)
//        placeVote(voteType: "upvotes", startingValue: currentPhoto.upCount)
    }
    
    func didPressDownVoteButton() {
        print("down")
        let ref = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID)
        Vote.voted(for: ref, upvoted: false)
//        placeVote(voteType: "downvotes", startingValue: currentPhoto.downCount)
    }
    
    func placeVote(voteType: String, startingValue: Int) {
        // update the upCount in the photos database
        let voteDictDatabaseReference = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID).child("votes")
        voteDictDatabaseReference.updateChildValues([voteType : startingValue + 1])

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
    
    lazy var upVoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.addTarget(self, action: #selector(didPressUpVoteButton), for: .touchUpInside)
        button.backgroundColor = UIColor.instaPrimary()
        button.alpha = 0.7
        button.contentMode = .center
        button.isEnabled = true
        return button
    }()
    
    lazy var downVoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "down_arrow"), for: .normal)
        button.addTarget(self, action: #selector(didPressDownVoteButton), for: .touchUpInside)
        button.backgroundColor = UIColor.instaPrimary()
        button.alpha = 0.7
        button.contentMode = .center
        button.isEnabled = true
        return button
    }()
}
