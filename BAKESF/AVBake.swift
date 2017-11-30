//
//  AVBake.swift
//  BAKESF
//
//  Created by 高宇超 on 7/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBake: AVObject, AVSubclassing {
    
    @NSManaged var name: String?
    @NSManaged var preTime: NSNumber? // hour
    @NSManaged var category: String?
    @NSManaged var tag: String?
    @NSManaged var shop: AVShop?
    @NSManaged var image: AVFile?
    @NSManaged var stock: NSNumber? // 0, 1 or 2
    @NSManaged var priceRange: [NSNumber]?
    @NSManaged var priority: NSNumber?
    @NSManaged var attributes: [String]?
    @NSManaged var defaultBake: AVBakeDetail?

    
    static func parseClassName() -> String {
        return "Bake"
    }
    
}
