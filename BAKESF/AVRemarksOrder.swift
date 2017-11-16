//
//  AVRemarksOrder.swift
//  BAKESF
//
//  Created by 高宇超 on 8/20/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

//
// Order remarks
class AVRemarksOrder: AVObject, AVSubclassing {
    
    @NSManaged var order: AVOrder?
    @NSManaged var content: String?
    
    static func parseClassName() -> String {
        return "RemarksOrder"
    }
    
}
