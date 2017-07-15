//
//  AVShop.swift
//  BAKESF
//
//  Created by 高宇超 on 7/12/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVShop: AVObject, AVSubclassing {
    
    dynamic var Baker: AVBaker?
    dynamic var name: String?
    dynamic var address: String?
    dynamic var bgImage: AVFile?
    dynamic var headphoto: AVFile?
    dynamic var broadcast: String?
    dynamic var categories: [String]?
    
    static func parseClassName() -> String {
        return "Shop"
    }

}
