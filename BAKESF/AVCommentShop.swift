//
//  AVCommentShop.swift
//  BAKESF
//
//  Created by 高宇超 on 8/20/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVCommentShop: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var shop: AVShop? // red packet name
    @NSManaged var stars: NSNumber? // should only be used by this phone
    @NSManaged var content: String?
    
    static func parseClassName() -> String {
        return "CommentShop"
    }
    
}
