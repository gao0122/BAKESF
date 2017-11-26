//
//  BakePreOrderRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 7/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class BakePreOrderRealm: Object {
    

    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var amount: Int = 0
    dynamic var price: Double = 0
    dynamic var shopID: String = ""
    dynamic var tag: String = ""

    
}
