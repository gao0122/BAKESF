//
//  AVAddress.swift
//  BAKESF
//
//  Created by 高宇超 on 8/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVAddress: AVObject, AVSubclassing {
    
    @NSManaged var Baker: AVBaker?
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var phone: String?
    @NSManaged var city: String?
    @NSManaged var province: String?
    @NSManaged var district: String?
    @NSManaged var label: String?
    
    
    static func parseClassName() -> String {
        return "Address"
    }
    
}
