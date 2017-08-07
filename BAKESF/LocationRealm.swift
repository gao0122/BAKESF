//
//  LocationRealm.swift
//  BAKESF
//
//  Created by 高宇超 on 8/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import RealmSwift

class LocationRealm: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    dynamic var formatted: String = ""
    dynamic var province: String = ""
    dynamic var city: String = ""
    dynamic var district: String = ""
    dynamic var building: String = ""
    dynamic var township: String = ""
    dynamic var streetName: String = ""
    dynamic var streetNumber: String = ""
    dynamic var aoisname: String = ""
    dynamic var citycode: String = ""
    dynamic var adcode: String = ""

}