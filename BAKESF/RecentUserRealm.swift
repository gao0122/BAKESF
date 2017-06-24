//
//  RecentUserRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 5/30/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class RecentUserRealm: Object {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var phone: String!
    dynamic var pwd: String!
}
