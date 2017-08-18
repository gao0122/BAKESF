//
//  AVRedPacket.swift
//  BAKESF
//
//  Created by 高宇超 on 8/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVRedPacket: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var name: String? // red packet name
    @NSManaged var deliveryPhone: String? // should only be used by this phone
    @NSManaged var fromDate: Date?
    @NSManaged var beforeDate: Date?
    @NSManaged var discount: NSNumber?
    @NSManaged var noLessThan: NSNumber?
    @NSManaged var categories: [String]?
    
    static func parseClassName() -> String {
        return "RedPacket"
    }
    
}
