//
//  SearchHistoryRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 10/13/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import RealmSwift

class SearchHistoryRealm: Object {
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    
    dynamic var searchingUserID: String = ""
    dynamic var searchingText: String = ""
    dynamic var searchingDate: Date?
    
}
