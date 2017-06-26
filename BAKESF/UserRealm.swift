//
//  UserRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 5/17/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class UserRealm: Object {
    
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var phone: String = ""
    dynamic var current = false
 
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
