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
    
    var voteData = [PhotoActivity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = FIRDatabase.database().reference().child("photos").child(currentPhoto.category).child(currentPhoto.photoID)
        
        setupViewHierarchy()
        configureConstraints()
        loadCurrentImage()
        setObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getPhotoActivity()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.voteData = []
        FIRDatabase.database().reference().removeAllObservers()
    }
    
    func getPhotoActivity () {
        var voteData = [PhotoActivity]()
        let votesReference = FIRDatabase.database().reference().child("votes").child(currentPhoto.photoID)
        votesReference.observe(.value, with: { (photoVotesSnapshot) in
            let votes = photoVotesSnapshot.children
            while let vote = votes.nextObject() as? FIRDataSnapshot,
                var voteInfo = vote.value as? [String: AnyObject] {
                    
                    let userReference = FIRDatabase.database().reference().child("users").child(vote.key).child("username")
                    userReference.observe(.value, with: { (userSnapshot) in
                        
                        if let username = userSnapshot.value as? String {
                            voteInfo["username"] = username as AnyObject
                            voteInfo["userID"] = vote.key as AnyObject
                            print("working to this point")
                            if let voteObject = PhotoActivity(voteInfo) {
                                print(vote)
                                voteData.append(voteObject)
                            }
                            if voteData.count == Int(photoVotesSnapshot.childrenCount) {
                                self.voteData = voteData
                                self.activitiesTableView.reloadData()
                            }
                        }
                    })
            }
        })
    }
    
    func setupViewHierarchy(){
        self.navigationController?.navigationBar.tintColor = UIColor.instaAccent()
        navigationItem.title = currentPhoto.title
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
    
    func loadCurrentImage() {
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
        Vote.voted(for: databaseReference, upvoted: false)
        animateButton(sender: downVoteButton)
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
    
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.voteData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.activityFeedCellIdentifyer, for: indexPath) as! ActivityFeedTableViewCell
        
        cell.backgroundColor = UIColor.instaPrimaryLight()
        let currentVote = self.voteData[indexPath.row]
        let voteValueText = currentVote.value ? "up" : "down"
        
        let userRef = FIRDatabase.database().reference().child("users").child(currentVote.userID).child("profilePic")
        userRef.observe(.value, with: { (snapshot) in
            if let userDict = snapshot.value as? NSDictionary,
                let profilePicFilePath = userDict["filePath"] as? String {
                let imageRef = self.storageReference.child(profilePicFilePath)
                imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
                    if error != nil {
                        print("Error \(error)")
                    }
                    if let validData = data {
                        cell.profileImageView.image = UIImage(data: validData)
                        cell.layoutIfNeeded()
                    }
                })
            }
        })
        
        cell.profileImageView.image = #imageLiteral(resourceName: "user_icon")
        cell.activityTextLabel.text = "\(currentVote.username) voted \(voteValueText)"
        cell.activityDateLabel.text = "at \(currentVote.time) on \(currentVote.date)"
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
