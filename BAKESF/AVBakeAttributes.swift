//
//  AVBakeAttributes.swift
//  BAKESF
//
//  Created by 高宇超 on 8/24/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBakeAttributes: AVObject, AVSubclassing {
    
    @NSManaged var attribute0: AVBakeAttribute?
    @NSManaged var attribute1: AVBakeAttribute?
    @NSManaged var attribute2: AVBakeAttribute?
    
    static func parseClassName() -> String {
        return "BakeAttributes"
    }
    

}
