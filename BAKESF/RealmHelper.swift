//
//  RealmHelper.swift
//  BAKESF
//
//  Created by 高宇超 on 5/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class RealmHelper {
    
    static func addUser(user: UserRealm) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(user)
        }
    }
    
    static func retrieveUser() -> Results<UserRealm> {
        let realm = try! Realm()
        return realm.objects(UserRealm.self)
    }
    
    static func updateUserPhone(user: UserRealm, phone: String) {
        let realm = try! Realm()
        try! realm.write() {
            user.phone = phone
        }
    }
    
    static func updateRecentUser(user: RecentUserRealm) {
        if let usr = RealmHelper.retrieveRecentUser().first {
            let realm = try! Realm()
            try! realm.write {
                usr.id = user.id
                usr.name = user.name
                usr.phone = user.phone
                usr.pwd = user.pwd
            }
        } else {
            let realm = try! Realm()
            try! realm.write {
                realm.add(user)
            }
        }
    }
    
    static func retrieveRecentUser() -> Results<RecentUserRealm> {
        let realm = try! Realm()
        return realm.objects(RecentUserRealm.self)
    }
    
    static func initCurrentSeller() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(CurrentSeller())
        }
    }
    
    static func updateCurrentSellerID(id: Int, seller: CurrentSeller) -> Void {
        let realm = try! Realm()
        try! realm.write {
            seller.id = id
        }
    }
    
    static func retrieveCurrentSeller() -> CurrentSeller {
        let realm = try! Realm()
        
        if let seller = realm.objects(CurrentSeller.self).first {
            return seller
        } else {
            return CurrentSeller()
        }
    }
    
    static func retrieveCurrentSellerID() -> Int {
        let realm = try! Realm()
        
        if let seller = realm.objects(CurrentSeller.self).first {
            return seller.id
        } else {
            return 0
        }
    }

}
