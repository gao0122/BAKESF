//
//  AVHomePageSearchHistory.swift
//  BAKESF
//
//  Created by 高宇超 on 10/27/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVHomePageSearchHistory: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var searchingText: String?
    
    static func parseClassName() -> String {
        return "HomePageSearchHistory"
    }
    
}

