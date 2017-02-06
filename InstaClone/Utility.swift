//
//  Utility.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    static func instaPrimary() -> UIColor {
        return UIColor(hexString: "#607D8B")
    }
    static func instaPrimaryDark() -> UIColor {
        return UIColor(hexString: "#455A64")
    }
    static func instaPrimaryLight() -> UIColor {
        return UIColor(hexString: "#CFD8DC")
    }
    static func instaAccent() -> UIColor {
        return UIColor(hexString: "#FFD740")
    }
    static func instaPrimeText() -> UIColor {
        return UIColor(hexString: "#212121")
    }
    static func instaSecondaryText() -> UIColor {
        return UIColor(hexString: "#727272")
    }
    static func instaDivider() -> UIColor {
        return UIColor(hexString: "#B6B6B6")
    }
    static func instaIconWhite() -> UIColor {
        return UIColor(hexString: "#455A64")
    }
    
}






