//
//  String+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension String {
    
    func substring(from: Int, to: Int) -> String {
        if to > characters.count || from >= to { return "" }
        let fromIndex = self.index(startIndex, offsetBy: from)
        let toIndex = self.index(startIndex, offsetBy: to)
        return substring(with: fromIndex..<toIndex)
    }
    
    func toHttps() -> String {
        var str = self
        if str.hasPrefix("http://") {
            str = "https://" + str.components(separatedBy: "http://").joined()
        }
        return str
    }
    
    func removeNumbers() -> String {
        return self.components(separatedBy: .decimalDigits).joined()
    }
}

