//
//  AVOrder.swift
//  BAKESF
//
//  Created by 高宇超 on 7/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVOrder: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var shop: AVShop?
    @NSManaged var comment: AVCommentShop?
    @NSManaged var deliveryAddress: AVAddress?
    @NSManaged var deliveryTime: Date?
    @NSManaged var deliveryWay: NSNumber?
    @NSManaged var status: NSNumber?
    @NSManaged var type: NSNumber?
    @NSManaged var totalCost: NSNumber?
    @NSManaged var shouldDeliveryAtOnce: Bool
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
