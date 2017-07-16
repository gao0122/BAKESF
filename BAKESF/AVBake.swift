//
//  AVBake.swift
//  BAKESF
//
//  Created by 高宇超 on 7/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBake: AVObject, AVSubclassing {
    
    dynamic var name: String?
    dynamic var category: String?
    dynamic var tag: String?
    dynamic var Shop: AVShop?
    dynamic var image: AVFile?
    var stock: NSNumber? // 0, 1 or 2
    var amount: NSNumber?
    var price: NSNumber?
    var priority: NSNumber?
    
    static func parseClassName() -> String {
        return "Bake"
    }
    
}
