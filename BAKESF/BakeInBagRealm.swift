//
//  BakeInBagRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 7/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class BakeInBagRealm: Object {
    
    dynamic var id: String = ""
    
    dynamic var name: String = ""
    dynamic var phone: String = ""
    
    dynamic var current = false
    
    dynamic var headphoto: Data?
    dynamic var headphotoURL: String?
    
    let followers = List<UserRealm>()
    let following = List<UserRealm>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
