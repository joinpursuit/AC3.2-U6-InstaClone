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
    
    
    var currentPhoto: Photo!
    
    var databaseReference: FIRDatabaseReference!
    
    let storageReference = FIRStorage.storage().reference()
    
    var databaseObserver: FIRDatabaseHandle?


    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID)
        
        setupViewHierarchy()
        configureConstraints()
        loadCurrentImage()
        setObserver()
    }
    
    func loadCurrentImage() {
        navigationItem.title = currentPhoto.title
        
        upCountLabel.text = String(currentPhoto.upCount)
        downCountLabel.text = String(currentPhoto.downCount)
        
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
    
    
    // MARK: - Vote observer
    
    private func setObserver() {
        databaseObserver = databaseReference.observe(.childChanged, with: { (snapshot: FIRDataSnapshot) in
            if let voteDict = snapshot.value as? NSDictionary {
                let up = voteDict["upvotes"] as! Int
                let down = voteDict["downvotes"] as! Int
                self.upCountLabel.text = String(up)
                self.downCountLabel.text = String(down)
                self.currentPhoto.upCount = up
                self.currentPhoto.downCount = down
            }
        })
    }
    
    
    // MARK: - Actions
    
    func didPressUpVoteButton() {
        Vote.voted(for: databaseReference, upvoted: true)
        animateButton(sender: upVoteButton)
    }
    
    func didPressDownVoteButton() {
        print("down")
        let ref = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID)
        Vote.voted(for: ref, upvoted: false)
//        placeVote(voteType: "downvotes", startingValue: currentPhoto.downCount)
    }
    
    internal func animateButton(sender: UIButton) {
        let newTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let originalTransform = sender.imageView!.transform
        UIView.animate(withDuration: 0.05, animations: {
            sender.layer.transform = CATransform3DMakeAffineTransform(newTransform)
        }, completion: { (complete) in
            sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
        })
    }

    
//    func placeVote(voteType: String, startingValue: Int) {
//        // update the upCount in the photos database
//        let voteDictDatabaseReference = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID).child("votes")
//        voteDictDatabaseReference.updateChildValues([voteType : startingValue + 1])
//
//    }
    
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
        label.text = "0"
        return label
    }()
    
    lazy var downCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.instaPrimaryDark()
        label.textColor = UIColor.instaAccent()
        label.textAlignment = .center
        label.text = "0"
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
