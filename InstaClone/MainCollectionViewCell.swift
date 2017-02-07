//
//  MainCollectionViewCell.swift
//  InstaClone
//
//  Created by Tong Lin on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHierarchy(){
        self.addSubview(categoryLabel)
    }
    
    func configureConstraints(){
        categoryLabel.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.6)
            view.height.equalToSuperview().multipliedBy(0.2)
            view.center.equalToSuperview()
        }
    }
    
    //MARK: - Lazy Inits
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .white
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 2.0
        return label
    }()
    
    
}
