//
//  PhotoPickerCollectionView.swift
//  testingStuff
//
//  Created by C4Q on 2/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class PickerCollectionView: UICollectionView  {
    
    var layout: UICollectionViewFlowLayout!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        //Init the layout of the collection view
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        horizontalLayout.minimumLineSpacing = 0
        horizontalLayout.minimumInteritemSpacing = 0
        horizontalLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        super.init(frame: frame, collectionViewLayout: horizontalLayout)
        
        self.layout = horizontalLayout
        self.showsVerticalScrollIndicator = false
        registerPhotoCell()
    }
    
    private func registerPhotoCell() {
        self.register(PhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: PhotoPickerCollectionViewCell.cellID)
    }
    
    func setUpItemLayout() {
        layout.itemSize = CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//CollectionCell

class PhotoPickerCollectionViewCell: UICollectionViewCell {
    static let cellID = "smallPhotoCell"
    
    var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.instaPrimary()
        self.contentView.addSubview(imageView)
        configureConstraints()
    }
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints () {
        self.imageView.snp.makeConstraints { (view) in
            view.top.trailing.bottom.leading.equalToSuperview()
        }
    }    
}


