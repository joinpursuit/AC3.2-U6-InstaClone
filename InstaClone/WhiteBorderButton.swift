//
//  WhiteBorderButton.swift
//  testingStuff
//
//  Created by C4Q on 2/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class WhiteBorderButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
