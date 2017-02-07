//
//  CategoryCell.swift
//  InstaClone
//
//  Created by C4Q on 2/7/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

import UIKit
import SnapKit

class CategoryPickerCollectionViewCell: UICollectionViewCell {
    static let cellID = "categoryCell"
    
    var button: UIButton = {
        let view = WhiteBorderButton()
        view.contentMode = .scaleAspectFit

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = UIColor.white
        self.contentView.addSubview(button)
        configureConstraints()
    }
    override func prepareForReuse() {
        button.titleLabel?.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureConstraints () {
        self.button.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(2)
            view.trailing.bottom.equalToSuperview().inset(2)
        }
    }
    
}
