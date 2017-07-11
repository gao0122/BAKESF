//
//  Data+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension Data {
    
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeatElement(0, count: 1))
        self.copyBytes(to: &buffer, from: NSRange(location: 0, length: 0).toRange()!)
        if buffer == ImageHeaderData.png {
            return .png
        } else if buffer == ImageHeaderData.jpeg {
            return .jpeg
        } else if buffer == ImageHeaderData.gif {
            return .gif
        } else if buffer == ImageHeaderData.tiff01 || buffer == ImageHeaderData.tiff02 {
            return .tiff
        } else {
            return .unknown
        }
    }
    
}
