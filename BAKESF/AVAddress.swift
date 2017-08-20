//
//  AVAddress.swift
//  BAKESF
//
//  Created by 高宇超 on 8/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import AVOSCloud

class AVAddress: AVObject, AVSubclassing {
    
    @NSManaged var baker: AVBaker?
    @NSManaged var shop: AVShop?
    @NSManaged var name: String? // user name
    @NSManaged var phone: String?
    @NSManaged var gender: String?
    @NSManaged var province: String?
    @NSManaged var city: String?
    @NSManaged var citycode: String?
    @NSManaged var district: String?
    @NSManaged var township: String?
    @NSManaged var street: String? // for only updated from poi address
    @NSManaged var streetName: String?
    @NSManaged var streetNumber: String?
    @NSManaged var aoiName: String? // main address name
    @NSManaged var detailed: String? // input by user, eg. room number
    @NSManaged var formatted: String? // full address
    @NSManaged var address: String? // from province to street number
    @NSManaged var longitude: String?
    @NSManaged var latitude: String? 
    @NSManaged var label: String? // tag
    @NSManaged var recentlyUsed: Bool
    @NSManaged var isForPreOrder: Bool
    @NSManaged var isForRightNow: Bool
    
    static func parseClassName() -> String {
        return "Address"
    }
    
}
