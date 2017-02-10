//
//  CategoryListViewController.swift
//  InstaClone
//
//  Created by Tong Lin on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CategoryListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let ReuseIdentifierForCell = "someCellID"
    var images: [Photo] = []
    let databasePhotosReference = FIRDatabase.database().reference().child("photos")
    let databaseVotesReference = FIRDatabase.database().reference().child("votes")
    let storageReference = FIRStorage.storage().reference()
    
    var databaseObserver: FIRDatabaseHandle?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        getImages()
        //setObserver()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // should probably put the setObserver func in view will appear
        databaseVotesReference.removeAllObservers()
    }
    
    func setupViewHierarchy(){
        self.navigationController?.navigationBar.tintColor = UIColor.instaAccent()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(categoryCollectionV)
        self.view.addSubview(noPhotosLabel)
        categoryCollectionV.register(CategoryListCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifierForCell)
        
    }
    
    func configureConstraints(){
        categoryCollectionV.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        noPhotosLabel.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    // Tom was working on live updatng the votes in the collection view...
    
//    private func setObserver() {
////        guard let category = navigationItem.title else { return }
////        let thisCategoryDatabaseReference = databasePhotosReference.child(category)
//
//        databaseObserver = databaseVotesReference.observe(.childAdded, with: { (snapshot: FIRDataSnapshot) in
//            if let thisPhotoVotesDict = snapshot.value as? NSDictionary {
//                print("ZZZZZZZZZZZZZZZZZZZZZZ/n/n")
//                dump(thisPhotoVotesDict)
////                let up = voteDict["upvotes"] as! Int
////                let down = voteDict["downvotes"] as! Int
//                
//                // get the photoID and find the cell to change
//                
////                self.upCountLabel.text = String(up)
////                self.downCountLabel.text = String(down)
////                self.currentPhoto.upCount = up
////                self.currentPhoto.downCount = down
//            }
//        })
//    }

    
    //MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! CategoryListCollectionViewCell
        
        let currentPhoto = self.images[indexPath.row]
        cell.indexxx = indexPath
        cell.upVoteLabel.text = String(self.images[indexPath.item].upCount)
        cell.downVoteLabel.text = String(self.images[indexPath.item].downCount)
        
        self.storageReference.child(currentPhoto.filePath).data(withMaxSize: 10 * 1024 * 1024) { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let validData = data {
                cell.BGImageView.image = UIImage(data: validData)
                cell.layoutIfNeeded()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetail = PhotoDetailViewController()
        photoDetail.currentPhoto = images[indexPath.item]
        navigationController?.pushViewController(photoDetail, animated: true)
    }
    
    //MARK: - Lazy Inits
    lazy var categoryCollectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.width/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cView.backgroundColor = UIColor.instaPrimary()
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    lazy var noPhotosLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.instaPrimary()
        view.textColor = UIColor.instaAccent()
        view.text = "YOU HAVE NO UPLOADED PHOTOS"
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()

    
    //MARK: Pull Category Images
    
    func getImages () {
        guard let category = self.navigationItem.title else { return }
        databasePhotosReference.child(category).observe(.value, with: { (snapshot) in
            if snapshot.children.allObjects.count == 0 {
                self.noPhotosLabel.isHidden = false
            } else {
                self.noPhotosLabel.isHidden = true
            }
            let children = snapshot.children
            while let child = children.nextObject() as? FIRDataSnapshot {
                
                if let photoDict = child.value as? NSDictionary,
                    let photo = Photo(dict: photoDict, photoID: child.key) {
                    self.images.append(photo)
                }
                
                if self.images.count == Int(snapshot.childrenCount) {
                    print(self.images.count)
                    self.categoryCollectionV.reloadData()
                }
            }
        })
    }
}
