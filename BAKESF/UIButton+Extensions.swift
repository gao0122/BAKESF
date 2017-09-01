//
//  UIButton+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 8/30/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

extension UIButton {
    
    
    func setBorder(with color: UIColor) {
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = color.cgColor
        self.setTitleColor(color, for: .normal)
    }
    
}
