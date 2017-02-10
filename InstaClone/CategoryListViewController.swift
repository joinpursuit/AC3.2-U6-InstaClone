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
    let storageReference = FIRStorage.storage().reference()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        getImages()
    }
    
    func setupViewHierarchy(){
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(categoryCollectionV)
        categoryCollectionV.register(CategoryListCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifierForCell)
        
    }
    
    func configureConstraints(){
        categoryCollectionV.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
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
        cView.backgroundColor = .white
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    //MARK: Pull Category Images
    
    func getImages () {
        guard let category = self.navigationItem.title else { return }
        databasePhotosReference.child(category).observe(.value, with: { (snapshot) in
            
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
