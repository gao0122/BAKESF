//
//  Double+Extension.swift
//  BAKESF
//
//  Created by 高宇超 on 7/28/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension Double {
    
    func fixPriceTagFormat() -> String {
        if self == Double(Int(self)) {
            return "\(Int(self))"
        } else {
            return String(format: "%.2f", self)
        }
    }
    
}
