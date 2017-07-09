//
//  LCBaker.swift
//  BAKESF
//
//  Created by 高宇超 on 6/28/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import LeanCloud
import AVOSCloud

class LCBaker: LCObject {
    
    dynamic var mobilePhoneNumber: LCString?
    dynamic var password: LCString?
    dynamic var username: LCString?
    dynamic var msgSentDate: LCDate?
    dynamic var headphoto: LCString?
    
    
    
    override static func objectClassName() -> String {
        return "Baker"
    }
    
}
