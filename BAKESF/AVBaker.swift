//
//  AVBaker.swift
//  BAKESF
//
//  Created by 高宇超 on 6/28/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBaker: AVObject, AVSubclassing {
    
    dynamic var mobilePhoneNumber: String?
    dynamic var password: String?
    dynamic var username: String?
    dynamic var msgSentDate: Date?
    dynamic var headphoto: String?
    dynamic var gender: String?
    dynamic var birthday: Date?
    

    static func parseClassName() -> String {
        return "Baker"
    }
    
}
