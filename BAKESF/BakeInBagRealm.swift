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
    dynamic var amount: Int = 0
    dynamic var price: Double = 0
    dynamic var shopID: String = ""
    dynamic var tag: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
