//
//  UIColor+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension UIColor {
    
    // parse hex color directly
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static var teal: UIColor {
        return UIColor(hex: 0x008080)
    }
    
    static var alertGreen: UIColor {
        return UIColor(red: 16 / 255, green: 206 / 255, blue: 105 / 255, alpha: 1)
    }
    
    static var alertRed: UIColor {
        return UIColor(red: 255 / 255, green: 36 / 255, blue: 40 / 255, alpha: 1)
    }
    
    static var alertOrange: UIColor {
        return UIColor(red: 255 / 255, green: 128 / 255, blue: 0, alpha: 1)
    }
    
    static var bkWhite: UIColor {
        return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    }
    
    static var bkBlack: UIColor {
        return UIColor(red: 0.032, green: 0.032, blue: 0.032, alpha: 1)
    }
    
    static var bkRed: UIColor {
        return UIColor(hex: 0xE00028)
    }
    
    static var appleGreen: UIColor {
        return UIColor(hex: 0x4dd964)
    }
    
    static var checkBtnGray: UIColor {
        return UIColor(hex: 0x4C4C4C)
    }
}
