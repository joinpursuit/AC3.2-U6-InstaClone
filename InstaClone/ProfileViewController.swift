//
//  ProfileViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let databaseUsersReference = FIRDatabase.database().reference().child("users")
    let databasePhotosReference = FIRDatabase.database().reference().child("photos")
    
    let storageReference = FIRStorage.storage().reference()
    
    var userImages: [Photo] = []
    
    static let activityFeedCellIdentifyer: String = "activityFeedCell"
    static let myFont = UIFont.systemFont(ofSize: 16)
    
    var activities: [UserActivity] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.instaPrimary()
        setUpViewHeirachy()
        setConstraints()
        setNavigationBar()
        getCurrentUser()
        getUserAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userImages = []
        getUploadedImagePaths()
        getUserAction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.userImages = []
        self.activities = []
        FIRDatabase.database().reference().removeAllObservers()
    }
    
    override func viewDidLayoutSubviews() {
        uploadedPhotosCollectionView.setUpItemLayout()
    }
    
    // MARK: SET UP
    
    func getCurrentUser() {
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        _ = databaseUsersReference.child(userID).observe(.value, with: { (snapshot) in
            if let userDict = snapshot.value as? NSDictionary {
                self.navigationItem.title = userDict["username"] as? String
                if let profilePicDict = userDict["profilePic"] as? NSDictionary,
                    let profilePicFilePath = profilePicDict["filePath"] as? String {
                    let imageRef = self.storageReference.child(profilePicFilePath)
                    imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
                        if error != nil {
                            print("Error \(error)")
                        }
                        if let validData = data {
                            self.setNewImageWithFade(imageData: validData)
                        }
                    })
                }
            }
        })
    }
    
    func getUploadedImagePaths() {
        print("WTF")
        if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
            let userPhotosReference = databaseUsersReference.child(currentUserID).child("photos")
            userPhotosReference.observe(.value, with: { (snapshot) in
                
                if snapshot.children.allObjects.count == 0 {
                    self.noPhotosLabel.isHidden = false
                } else {
                    self.noPhotosLabel.isHidden = true
                }

                let allUserPhotos = snapshot.children
                while let photoSnapshot = allUserPhotos.nextObject() as? FIRDataSnapshot,
                    let photoDict = photoSnapshot.value as? NSDictionary {
                        guard let category = photoDict["category"] as? String else { continue }
                        let photoID = photoSnapshot.key
                        let path = category + "/" + photoID
                        self.databasePhotosReference.child(path).observe(.value, with: { (photoInfoSnapshot) in
                            if let photoDictionary = photoInfoSnapshot.value as? NSDictionary,
                                let photo = Photo(dict: photoDictionary, photoID: photoID) {
                                self.userImages.append(photo)
                                print(snapshot.childrenCount)
                                
                                if self.userImages.count == Int(snapshot.childrenCount) {
                                    self.uploadedPhotosCollectionView.reloadData()
                                }
                            } else {
                                print("\(photoID) couldn't be parsed")
                            }
                        })
                }
            })
        }
    }
    
    func getUserAction () {
        if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
            let userRef = databaseUsersReference.child(currentUserID)
            var userActivities = [UserActivity]()
            var allVotes = false
            var allPhotos = false
            
            userRef.child("votes").observe(.value, with: { (votesSnapshot) in
                let votes = votesSnapshot.children
                var voteActivity = [UserActivity]()

                while let vote = votes.nextObject() as? FIRDataSnapshot,
                    let voteDict = vote.value as? [String: AnyObject] {
                        let value = voteDict["value"] as! Bool
                        let voteActivityObject = UserActivity(dict: voteDict, value: value)!
                        voteActivity.append(voteActivityObject)
                        
                        if voteActivity.count == Int(votesSnapshot.childrenCount) {
                            userActivities += voteActivity
                            allVotes = true
                        }
                        
                        if allVotes && allPhotos {
                            self.activities = userActivities
                            self.feedTableView.reloadData()
                        }
                }
            })
            
            userRef.child("photos").observe(.value, with: { (photosSnapshot) in
                let photos = photosSnapshot.children
                var photoActivity = [UserActivity]()
                while let photo = photos.nextObject() as? FIRDataSnapshot,
                    var photoDict = photo.value as? [String: AnyObject] {
                        let photoID = photo.key
                        photoDict["photoID"] = photoID as AnyObject?
                        let photoActivityObject = UserActivity(dict: photoDict, value: nil)!
                        photoActivity.append(photoActivityObject)
                        if photoActivity.count == Int(photosSnapshot.childrenCount) {
                            userActivities += photoActivity
                            allPhotos = true
                        }
                        
                        if allVotes && allPhotos {
                            self.activities = userActivities
                            self.feedTableView.reloadData()
                        }
                }
            })
        }
    }
    
    func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle.plain, target: self, action: #selector(logoutTapped))
        
        logoutButton.setTitleTextAttributes([NSFontAttributeName: ProfileViewController.myFont, NSForegroundColorAttributeName : UIColor.instaAccent()], for: .normal)
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    func setUpViewHeirachy() {
        self.view.backgroundColor = UIColor.instaPrimary()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.addSubview(yourUploadsLabel)
        self.view.addSubview(feedTableView)
        self.view.addSubview(uploadedPhotosCollectionView)
        self.view.addSubview(noPhotosLabel)
        self.view.addSubview(profileImageView)
        
        uploadedPhotosCollectionView.dataSource = self
        uploadedPhotosCollectionView.delegate = self
    }
    
    func setConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.top.centerX.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.bounds.height * 0.30)
        }
        
        feedTableView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(profileImageView.snp.bottom)
            view.bottom.equalTo(uploadedPhotosCollectionView.snp.top)
            
        }
        
        yourUploadsLabel.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(20)
        }
        
        uploadedPhotosCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(feedTableView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.15)
            view.bottom.equalTo(yourUploadsLabel.snp.top)
        }
        
        noPhotosLabel.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalTo(uploadedPhotosCollectionView)
        }
    }
    
    
    // MARK: - HELPER FUNCTIONS
    
    func setNewImageWithFade(imageData: Data) {
        UIView.animate(withDuration: 0.2, animations: {
            self.profileImageView.alpha = 0.0
            self.view.setNeedsLayout()
        }, completion: { (bool) in
            self.profileImageView.image = UIImage(data: imageData)
            UIView.animate(withDuration: 0.2, animations: {
                self.profileImageView.alpha = 1.0
                self.view.setNeedsLayout()
            })
        })
    }
    

    
    // MARK: - TABLEVIEW DATA SOURCE METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.activityFeedCellIdentifyer, for: indexPath) as! ActivityFeedTableViewCell
        
        let currentActivity = self.activities[indexPath.row]
        dump(currentActivity)
        cell.backgroundColor = UIColor.instaPrimaryLight()
        cell.profileImageView.image = #imageLiteral(resourceName: "user_icon")
        cell.activityDateLabel.text = "at \(currentActivity.time) on \(currentActivity.date)"
        
        var thisPhotoFilePath = ""
 
        if let photoID = currentActivity.photoID,
            let category = currentActivity.category {
            _ = databasePhotosReference.child("\(category)/\(photoID)").observe(.value, with: { (snapshot) in
                if let thisPhotoDict = snapshot.value as? NSDictionary {
                    let thisPhotoTitle = thisPhotoDict["title"] as! String
                    thisPhotoFilePath = thisPhotoDict["filePath"] as! String
                    
                    cell.activityTextLabel.text = "You uploaded \(thisPhotoTitle) "
                    
                    let imageRef = self.storageReference.child(thisPhotoFilePath)
                    imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
                        if error != nil {
                            print("Error \(error)")
                        }
                        if let validData = data {
                            cell.profileImageView.image = UIImage(data: validData)
                            cell.setNeedsLayout()
                        }
                    })
                }
            })
        }
        
        if let voteBool = currentActivity.value,
            let photoFilePath = currentActivity.filePath {
            thisPhotoFilePath = photoFilePath
            
            let direction = voteBool ? "up" : "down"
            cell.activityTextLabel.text = "You voted \(currentActivity.imageName!) \(direction)"
        }
        
        let imageRef = self.storageReference.child(thisPhotoFilePath)
        imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
            if error != nil {
                print("Error \(error)")
            }
            if let validData = data {
                cell.profileImageView.image = UIImage(data: validData)
                cell.setNeedsLayout()
            }
        })
        
        
        return cell
    }
    
    //MARK: - CollectionView Data Source Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let smallPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCollectionViewCell.cellID, for: indexPath) as! PhotoPickerCollectionViewCell
        let currentPhoto = self.userImages[indexPath.row]
        self.storageReference.child(currentPhoto.filePath).data(withMaxSize: 10 * 1024 * 1024) { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let validData = data {
                smallPhotoCell.imageView.image = UIImage(data: validData)
                smallPhotoCell.setNeedsLayout()
            }
        }
        
        return smallPhotoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.currentPhoto = userImages[indexPath.item]
        _ = navigationController?.pushViewController(photoDetailVC, animated: true)
    }
    
    // MARK: - TARGET ACTION METHODS
    
    func logoutTapped() {
        print("logging out")
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                print("logged out")
            } catch {
                print("Error occured while logging out: \(error)")
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func profileImageTapped() {
        print("show image picker")
        let uploadVC = UploadViewController()
        uploadVC.uploadType = .profile
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    // MARK: - LAZY VIEW INITS
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.instaPrimary()
        
        let origImage = UIImage(named: "user_icon")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        view.image = tintedImage
        view.tintColor = UIColor.instaAccent()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(profileImageTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 8
        return view
    }()
    
    lazy var yourUploadsLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.instaPrimaryDark()
        view.textColor = UIColor.instaAccent()
        view.text = " YOUR UPLOADS"
        view.font = myFont
        view.textAlignment = .left
        return view
    }()
    
    lazy var noPhotosLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.instaPrimary()
        view.textColor = UIColor.instaAccent()
        view.text = "YOU HAVE NO UPLOADED PHOTOS"
        view.font = myFont
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()

    
    lazy var feedTableView: UITableView = {
        let view = UITableView()
        view.register(ActivityFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewController.activityFeedCellIdentifyer)
        view.backgroundColor = UIColor.instaPrimary()
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    var uploadedPhotosCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        view.backgroundColor = UIColor.instaPrimary()
        return view
    }()
}
