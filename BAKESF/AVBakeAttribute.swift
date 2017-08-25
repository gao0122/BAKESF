//
//  AVBakeAttribute.swift
//  BAKESF
//
//  Created by 高宇超 on 8/24/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVBakeAttribute: AVObject, AVSubclassing {
    
    @NSManaged var key: String?
    @NSManaged var value: String?

    static func parseClassName() -> String {
        return "BakeAttribute"
    }

}
