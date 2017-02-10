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

class CategoryListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let ReuseIdentifierForCell = "CategoryCellIdentifier"
    var images: [Photo] = []
    var currrentCells: [UICollectionViewCell] = []
    let databasePhotosReference = FIRDatabase.database().reference().child("photos")
    let storageReference = FIRStorage.storage().reference()
    var dynamicAnimator: UIDynamicAnimator?

    var normalSize: CGSize?
    var smallSize: CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        getImages()
        DispatchQueue.main.async {
            self.categoryCollectionV.reloadData()
        }
    }
    
    func setupViewHierarchy(){
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.normalSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.width/2)
        self.smallSize = CGSize(width: self.view.frame.width/3.1, height: self.view.frame.width/3.1)
        
        self.view.addSubview(categoryCollectionV)
        categoryCollectionV.addSubview(snapButton)
        self.categoryCollectionV.addSubview(refreshControl)
        categoryCollectionV.register(CategoryListCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifierForCell)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        snapButton.addTarget(self, action: #selector(bringCellsBack), for: .touchUpInside)
        snapButton.isHidden = true
        snapButton.isEnabled = false
    }
    
    func refreshWithAnimation(){
        categoryCollectionV.performBatchUpdates(nil) { (_) in
            self.currrentCells = self.categoryCollectionV.visibleCells
            let _ = self.currrentCells.map{ $0.startRotating(duration: Double(arc4random_uniform(6) + 1)) }
            //init animator
            self.dynamicAnimator = UIDynamicAnimator(referenceView: self.categoryCollectionV)
            let bouncyBehavior = BouncyViewBehavior(items: self.currrentCells)
            self.dynamicAnimator?.addBehavior(bouncyBehavior)
        }
        
        snapButton.isEnabled = true
        snapButton.alpha = 0
        UIView.animate(withDuration: 3, animations: {
            self.snapButton.isHidden = false
            self.snapButton.alpha = 1
            self.categoryCollectionV.layoutIfNeeded()
        })
    }
    
    func bringCellsBack(){
        
        let _ = currrentCells.map{ $0.stopRotating() }
        self.dynamicAnimator?.removeAllBehaviors()
        self.getImages()
        snapButton.isEnabled = false
        snapButton.isHidden = true
    }
    
    func configureConstraints(){
        categoryCollectionV.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        snapButton.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
        }
    }
    
    //MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! CategoryListCollectionViewCell
        
        cell.indexxx = indexPath
        
        let currentPhoto = self.images[indexPath.row]
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if refreshControl.isRefreshing{
            return smallSize!
        }
        return normalSize!
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
        layout.itemSize = self.normalSize!
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cView.backgroundColor = .white
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
    
    lazy var snapButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.instaAccent(), for: .normal)
        button.setTitle("Snap Them Back", for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CategoryListViewController.refreshWithAnimation), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //MARK: Pull Category Images
    
    func getImages () {
        self.images = []
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
                    
                    
                    if self.refreshControl.isRefreshing{
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.categoryCollectionV.reloadData()
                }
            }
        })
    }
}

class BouncyViewBehavior: UIDynamicBehavior{
    override init() {
        
    }
    convenience init(items: [UIDynamicItem]){
        self.init()
        
        let gravityBehavior = UIGravityBehavior(items: items)
        gravityBehavior.angle = CGFloat(arc4random_uniform(360) + 1) / 180 * CGFloat.pi
        gravityBehavior.magnitude = 0.3
        self.addChildBehavior(gravityBehavior)
        
        let elasticityBehavior = UIDynamicItemBehavior(items: items)
        elasticityBehavior.elasticity = 1
        self.addChildBehavior(elasticityBehavior)
    }
}

