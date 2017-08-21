//
//  AVShop.swift
//  BAKESF
//
//  Created by 高宇超 on 7/12/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVShop: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var name: String?
    @NSManaged var address: AVAddress?
    @NSManaged var bgImage: AVFile?
    @NSManaged var headphoto: AVFile?
    @NSManaged var broadcast: String?
    @NSManaged var tags: [String]?
    @NSManaged var deliveryFee: NSNumber? // Double
    @NSManaged var lowestFee: NSNumber? // Double
    @NSManaged var deliveryMaxDistance: NSNumber?
    @NSManaged var deliveryPreOrderDays: NSNumber?
    @NSManaged var deliveryWays: [NSNumber]?
    
    
    static func parseClassName() -> String {
        return "Shop"
    }

}
