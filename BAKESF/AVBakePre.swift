//
//  AVBakePre.swift
//  BAKESF
//
//  Created by 高宇超 on 7/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBakePre: AVObject, AVSubclassing {
    
    @NSManaged var Bake: AVBake?
    @NSManaged var Order: AVOrder?
    @NSManaged var amount: NSNumber?
    @NSManaged var pickupTime: Date?
    
    static func parseClassName() -> String {
        return "BakePreOrder"
    }
    
}
