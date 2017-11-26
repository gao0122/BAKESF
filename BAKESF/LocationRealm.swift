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
    
    dynamic var userID: String = ""
    
    dynamic var formatted: String = "" // full address string
    dynamic var address: String = "" // province to street number
    dynamic var province: String = ""
    dynamic var city: String = ""
    dynamic var district: String = ""
    dynamic var building: String = ""
    dynamic var township: String = ""
    dynamic var streetName: String = ""
    dynamic var streetNumber: String = ""
    dynamic var street: String?
    dynamic var aoiname: String = ""
    dynamic var citycode: String = ""
    dynamic var adcode: String = ""
    dynamic var longitude: String = ""
    dynamic var latitude: String = ""
    dynamic var detailed: String = "" // input by user
    dynamic var tag: Int = 0 // different kinds of address, 0 for current location, 1 for temp delivery location

}
