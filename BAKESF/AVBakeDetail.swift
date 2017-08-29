//
//  AVBakeDetail.swift
//  BAKESF
//
//  Created by 高宇超 on 8/24/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBakeDetail: AVObject, AVSubclassing {
    
    @NSManaged var bake: AVBake?
    @NSManaged var image: AVFile?
    @NSManaged var attributes: [String]?
    @NSManaged var price: NSNumber?
    @NSManaged var amount: NSNumber?
    @NSManaged var amountPreLimit: NSNumber?
    
    static func parseClassName() -> String {
        return "BakeDetail"
    }
    
}