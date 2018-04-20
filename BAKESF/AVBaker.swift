//
//  AVBaker.swift
//  BAKESF
//
//  Created by 高宇超 on 6/28/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBaker: AVObject, AVSubclassing {
    
    @NSManaged var mobilePhoneNumber: String?
    @NSManaged var password: String?
    @NSManaged var username: String?
    @NSManaged var msgSentDate: Date?
    @NSManaged var headphoto: String?
    @NSManaged var gender: String?
    @NSManaged var birthday: Date?
    @NSManaged var signedup: Bool

    @NSManaged var wxOpenID: String?

    static func parseClassName() -> String {
        return "Baker"
    }
    
}
