//
//  String+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension String {
    
    var md5: String {
        get {
            let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
            var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5_Init(context)
            CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
            CC_MD5_Final(&digest, context)
            context.deallocate(capacity: 1)
            var hexString = ""
            for byte in digest {
                hexString += String(format:"%02x", byte)
            }
            return hexString
        }
    }
    
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
    
    func removeSpacesAndLines() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    // parse String to NSAttributedString to highlight key string
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
    
    
    var urlEncoded: String {
        get {
            return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }
    
    
}

