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
        if to > self.count || from >= to { return "" }
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
    
    func removeSpaces() -> String {
        return self.components(separatedBy: .whitespaces).joined()
    }
    
    // parse String to NSAttributedString
    func attributedString(key: String, keyFont: UIFont, color: UIColor) -> NSMutableAttributedString {
        let texts = self.components(separatedBy: key)
        if texts.count == 1 {
            return NSMutableAttributedString(string: self)
        }
        let string = NSMutableAttributedString()
        let attr = [NSForegroundColorAttributeName: color, NSFontAttributeName: keyFont]
        for (i, text) in texts.enumerated() {
            string.append(NSMutableAttributedString(string: text))
            if i + 1 < texts.count {
                string.append(NSMutableAttributedString(string: key, attributes: attr))
            }
        }
        return string
    }
}

