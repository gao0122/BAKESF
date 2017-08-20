//
//  AVRemarksOrder.swift
//  BAKESF
//
//  Created by 高宇超 on 8/20/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVRemarksOrder: AVObject, AVSubclassing {
    
    @NSManaged var order: AVOrder?
    @NSManaged var name: String? // red packet name
    @NSManaged var deliveryPhone: String? // should only be used by this phone
    @NSManaged var fromDate: Date?
    @NSManaged var beforeDate: Date?
    @NSManaged var discount: NSNumber?
    @NSManaged var noLessThan: NSNumber?
    @NSManaged var categories: [String]?
    
    static func parseClassName() -> String {
        return "RemarksOrder"
    }
    
}
