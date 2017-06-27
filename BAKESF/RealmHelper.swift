//
//  RealmHelper.swift
//  BAKESF
//
//  Created by 高宇超 on 5/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift

class RealmHelper {
    
    // MARK: - User
    static func addUser(user: UserRealm) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(user)            
        }
    }
    
    static func retrieveUsers() -> Results<UserRealm> {
        let realm = try! Realm()
        return realm.objects(UserRealm.self)
    }
    
    static func updateUserPhone(user: UserRealm, phone: String) {
        let realm = try! Realm()
        try! realm.write {
            user.phone = phone
        }
    }
    
    static func setCurrentUser(withID id: String) -> Bool {
        let realm = try! Realm()
        if let user = realm.object(ofType: UserRealm.self, forPrimaryKey: id) {
            try! realm.write {
                user.current = true
            }
            return true
        } else {
            return false
        }
    }
    
    static func retrieveCurrentUser() -> UserRealm? {
        let realm = try! Realm()
        return realm.objects(UserRealm.self).filter("current = true").first
    }
    
    static func logoutCurrentUser(user: UserRealm) -> Void {
        let realm = try! Realm()
        try! realm.write {
            user.current = false
        }
    }
    
}
