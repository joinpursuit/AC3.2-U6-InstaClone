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
    var currentUserID: String?
    
    static let activityFeedCellIdentifyer: String = "activityFeedCell"
    static let myFont = UIFont.systemFont(ofSize: 16)
    
    let activities: [String] = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.instaPrimary()
        setUpViewHeirachy()
        setConstraints()
        setNavigationBar()
        getCurrentUser()
        getUploadedImagePaths()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.userImages = []
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
                            self.profileImageView.image = UIImage(data: validData)
                        }
                    })
                }
            }
        })
    }
    
    func getUploadedImagePaths() {
        if let currentUserID = FIRAuth.auth()?.currentUser?.uid {
            self.currentUserID = currentUserID
            databaseUsersReference.child(currentUserID).child("photos").observe(.value, with: { (snapshot) in
                if let allUserPhotos = snapshot.value as? NSDictionary {
                    let userImageIDs = allUserPhotos.allKeys as! [String]
                    var userPhotos: [Photo] = []
                    for photoID in userImageIDs {
                        self.databasePhotosReference.child(photoID).observe(.value, with: { (snapshot) in
                            if let photoDictionary = snapshot.value as? NSDictionary {
                                if let photo = Photo(dict: photoDictionary, photoID: photoID) {
                                    print("photo created")
                                    userPhotos.append(photo)
                                    self.uploadedPhotosCollectionView.reloadData()
                                    if userPhotos.count == userImageIDs.count {
                                        self.userImages = userPhotos
                                        dump(userPhotos)
                                        self.uploadedPhotosCollectionView.reloadData()
                                    }
                                } else {
                                    print("\(photoID) couldn't be parsed")
                                }
                            }
                        })
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
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.addSubview(yourUploadsLabel)
        self.view.addSubview(feedTableView)
        self.view.addSubview(profileImageView)
        self.view.addSubview(uploadedPhotosCollectionView)
        
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
    }
    
    
    // MARK: - TABLEVIEW DATA SOURCE METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.activityFeedCellIdentifyer, for: indexPath) as! ActivityFeedTableViewCell
        
        cell.profileImageView.image = #imageLiteral(resourceName: "user_icon")
        cell.activityTextLabel.text = activities[indexPath.row]
        cell.activityDateLabel.text = "11:30PM"
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
    
    lazy var feedTableView: UITableView = {
        let view = UITableView()
        view.register(ActivityFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewController.activityFeedCellIdentifyer)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    var uploadedPhotosCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
}
