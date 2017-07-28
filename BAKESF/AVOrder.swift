//
//  AVOrder.swift
//  BAKESF
//
//  Created by 高宇超 on 7/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVOrder: AVObject, AVSubclassing {
    
    @NSManaged var Shop: AVShop?
    @NSManaged var deliveryTime: Date?
    @NSManaged var deliveryWay: NSNumber?
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
