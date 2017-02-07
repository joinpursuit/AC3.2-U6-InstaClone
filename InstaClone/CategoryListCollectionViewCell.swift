//
//  CategoryListCollectionViewCell.swift
//  InstaClone
//
//  Created by Tong Lin on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class CategoryListCollectionViewCell: UICollectionViewCell {
    var indexxx: IndexPath? {
        didSet {
            configureConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewHierarchy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        upVoteImage.snp.removeConstraints()
        downVoteImage.snp.removeConstraints()
        upVoteLabel.snp.removeConstraints()
        downVoteLabel.snp.removeConstraints()
    }
    
    func setupViewHierarchy(){
        self.addSubview(upVoteImage)
        self.addSubview(downVoteImage)
        self.addSubview(upVoteLabel)
        self.addSubview(downVoteLabel)
        
        configureConstraints()
    }
    
    func configureConstraints(){
        if let index = indexxx{
            if (index.row+1)%2 == 1{
                downVoteImage.snp.makeConstraints({ (view) in
                    view.bottom.equalToSuperview().offset(-15)
                    view.leading.equalToSuperview().offset(15)
                    view.size.equalToSuperview().multipliedBy(0.1)
                })
                
                upVoteImage.snp.makeConstraints({ (view) in
                    view.leading.equalTo(downVoteImage)
                    view.bottom.equalTo(downVoteImage.snp.top).offset(-10)
                    view.size.equalTo(downVoteImage)
                })
                
                downVoteLabel.snp.makeConstraints({ (view) in
                    view.bottom.equalTo(downVoteImage)
                    view.leading.equalTo(downVoteImage.snp.trailing).offset(8)
                })
                
                upVoteLabel.snp.makeConstraints({ (view) in
                    view.bottom.equalTo(upVoteImage)
                    view.leading.equalTo(upVoteImage.snp.trailing).offset(8)
                })
            }else{
                downVoteLabel.snp.makeConstraints({ (view) in
                    view.bottom.equalToSuperview().offset(-15)
                    view.trailing.equalToSuperview().offset(-20)
                    view.height.equalToSuperview().multipliedBy(0.1)
                })
                
                upVoteLabel.snp.makeConstraints({ (view) in
                    view.bottom.equalTo(downVoteLabel.snp.top).offset(-10)
                    view.leading.equalTo(downVoteLabel.snp.leading)
                    view.height.equalTo(downVoteLabel)
                })
                
                downVoteImage.snp.makeConstraints({ (view) in
                    view.bottom.equalTo(downVoteLabel)
                    view.trailing.equalTo(downVoteLabel.snp.leading).offset(-8)
                    view.size.equalToSuperview().multipliedBy(0.1)
                })
                
                upVoteImage.snp.makeConstraints({ (view) in
                    view.trailing.equalTo(upVoteLabel.snp.leading).offset(-8)
                    view.bottom.equalTo(upVoteLabel)
                    view.size.equalTo(downVoteImage)
                })
            }
        }
    }
    
    //Mark: - Lazy Inits
    lazy var upVoteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "up_arrow")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var downVoteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "down_arrow")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var upVoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = UIColor.instaDivider()
        label.text = "328"
        return label
    }()
    
    lazy var downVoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = UIColor.instaDivider()
        label.text = "18"
        return label
    }()
    
}
