//
//  UploadViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

enum CollectionViewIdentifier: String {
    case smallPhoto, largePhoto, category
}

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var smallPhotoCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
    
    var largePhotoCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
    
    var categoryCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .lightGray
        smallPhotoCollectionView.dataSource = self
        smallPhotoCollectionView.delegate = self
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        setUpIdentifiersAndCells()
        setUpViewHierarchyAndDelegates()
        configureConstraints()
        view.backgroundColor = UIColor.instaPrimary()
    }
    
    override func viewDidLayoutSubviews() {
        self.smallPhotoCollectionView.setUpItemLayout()
        self.largePhotoCollectionView.setUpItemLayout()
        self.categoryCollectionView.setUpItemLayout()
    }
    
    func configureConstraints() {
        smallPhotoCollectionView.snp.makeConstraints { (view) in
            view.height.equalTo(self.view.snp.width).multipliedBy(0.29)
            view.trailing.leading.bottom.equalToSuperview()
        }
        
        categoryCollectionView.snp.makeConstraints { (view) in
            view.leading.top.trailing.equalToSuperview()
            view.height.equalTo(32)
        }
        
        largePhotoCollectionView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.width.height.equalTo(self.view.snp.width)
            view.bottom.equalTo(self.smallPhotoCollectionView.snp.top)
        }
    }
    
    func setUpViewHierarchyAndDelegates() {
        let views = [smallPhotoCollectionView, largePhotoCollectionView, categoryCollectionView]
        _ = views.map{ self.view.addSubview($0) }
        _ = views.map{ $0.delegate = self }
        _ = views.map{ $0.dataSource = self }
        
        largePhotoCollectionView.isPagingEnabled = true
    }
    
    func setUpIdentifiersAndCells() {
        self.smallPhotoCollectionView.accessibilityIdentifier = CollectionViewIdentifier.smallPhoto.rawValue
        self.smallPhotoCollectionView.registerPhotoCell()
        
        self.largePhotoCollectionView.accessibilityIdentifier = CollectionViewIdentifier.largePhoto.rawValue
        self.largePhotoCollectionView.registerPhotoCell()
        
        self.categoryCollectionView.accessibilityIdentifier = CollectionViewIdentifier.category.rawValue
        self.categoryCollectionView.registerCategoryCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        guard let viewID = collectionView.accessibilityIdentifier else { return cell }
        
        switch viewID {
        case CollectionViewIdentifier.smallPhoto.rawValue:
            let smallPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCollectionViewCell.cellID, for: indexPath) as! PhotoPickerCollectionViewCell
            smallPhotoCell.imageView.image = #imageLiteral(resourceName: "user_icon")
            smallPhotoCell.backgroundColor = .red
            return smallPhotoCell
        case CollectionViewIdentifier.largePhoto.rawValue:
            let largePhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCollectionViewCell.cellID, for: indexPath) as! PhotoPickerCollectionViewCell
            largePhotoCell.backgroundColor = .green
            largePhotoCell.layer.borderWidth = 2.0
            largePhotoCell.layer.borderColor = UIColor.white.cgColor

            return largePhotoCell
        case CollectionViewIdentifier.category.rawValue:
            let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPickerCollectionViewCell.cellID, for: indexPath) as! CategoryPickerCollectionViewCell
            categoryCell.backgroundColor = .blue
            categoryCell.button.setTitle(Array(repeating: "BB", count: indexPath.row + 1).joined(), for: .normal)
            return categoryCell
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //If this causes a crash, something seriously wrong has happened becuse all the collectionViews should be Pickers.
        let pickerCollectionView = collectionView as! PickerCollectionView
        if collectionView.accessibilityIdentifier == CollectionViewIdentifier.category.rawValue {
            let cell = CategoryPickerCollectionViewCell()
            cell.button.setTitle(Array(repeating: "BB", count: indexPath.row + 1).joined(), for: .normal)
            print(cell.contentView.frame.size)
            return cell.contentView.frame.size
        } else {
            return pickerCollectionView.layout.itemSize
        }
    }
}
