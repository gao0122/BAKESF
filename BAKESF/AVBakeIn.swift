//
//  AVBakeBuy.swift
//  BAKESF
//
//  Created by 高宇超 on 7/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBakeIn: AVObject, AVSubclassing {
    
    @NSManaged var bake: AVBake?
    @NSManaged var baked: AVBakeDetail?
    @NSManaged var order: AVOrder?
    @NSManaged var amount: NSNumber?
    
    static func parseClassName() -> String {
        return "BakeInOrder"
    }
    
} 
