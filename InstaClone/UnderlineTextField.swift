//
//  UnderlineTextField.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {

    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        UITextField.appearance().tintColor = UIColor.instaIconWhite()
        self.textColor = UIColor.instaIconWhite()
        self.autocapitalizationType = .none
        self.spellCheckingType = .no
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 2.0
        
        let startPoint = CGPoint(x: 0.0, y: rect.height - lineWidth)
        let endPoint = CGPoint(x: rect.width, y: rect.height - lineWidth)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        
        context?.setStrokeColor(UIColor.white.cgColor)
        
        context?.move(to: startPoint)
        context?.addLine(to: endPoint)
        
        context?.strokePath()
    }
    
    
}
