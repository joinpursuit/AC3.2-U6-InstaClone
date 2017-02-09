//
//  CategoryListViewController.swift
//  InstaClone
//
//  Created by Tong Lin on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let ReuseIdentifierForCell = "someCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        configureConstraints()
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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! CategoryListCollectionViewCell
        
        cell.indexxx = indexPath
        
        //pass image and data to cell
        
        if indexPath.row%3 == 2{
            cell.backgroundColor = .yellow
            cell.BGImageView.image = #imageLiteral(resourceName: "sample")
        }else if indexPath.row%3 == 1{
            cell.backgroundColor = .cyan
        }else{
            cell.BGImageView.image = #imageLiteral(resourceName: "sample2")
            cell.backgroundColor = .red
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetail = PhotoDetailViewController()
        //pass the title of photo to detail view
        photoDetail.navigationItem.title = "selected photo name"
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

}
