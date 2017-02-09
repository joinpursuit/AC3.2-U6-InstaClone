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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let databaseUsersReference = FIRDatabase.database().reference().child("users")
    let databasePhotosReference = FIRDatabase.database().reference().child("photos")

    let storageReference = FIRStorage.storage()
    
    var profilePicFilePath = ""
    
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
    }
    

    
    // MARK: SET UP
    
    func getCurrentUser() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        _ = databaseUsersReference.child(userID!).observe(.value, with: { (snapshot) in
            if let userDict = snapshot.value as? NSDictionary {
                self.navigationItem.title = userDict["username"] as? String
                if let profilePicID = userDict["profilePic"] as? String {
                    print("profile pic id: \(profilePicID)")
                    
                    let photoRef = self.databasePhotosReference.child(profilePicID)
                    photoRef.observe(.value, with: { (snapshot2) in
                        if let photoDict = snapshot2.value as? NSDictionary {
                            if let filePath = photoDict["filePath"] as? String {
                                self.profilePicFilePath = filePath
                                
                                let imageRef = self.storageReference.reference().child(filePath)
                                
                                imageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data: Data?, error: Error?) in
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
            }
        })
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
        self.view.addSubview(scrollViewContainer)
        self.view.addSubview(feedTableView)
        self.view.addSubview(profileImageView)
    }
    
    func setConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.top.centerX.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.bounds.height * 0.25)
        }
        
        feedTableView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(profileImageView.snp.bottom)
            view.bottom.equalTo(scrollViewContainer.snp.top)
        }
        
        yourUploadsLabel.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(20)
        }
        
        scrollViewContainer.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(self.view.bounds.height * 0.15)
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
        view.contentMode = .scaleAspectFit
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(profileImageTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 8
        return view
    }()
    
    lazy var scrollViewContainer: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.instaPrimary()
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
    
}
