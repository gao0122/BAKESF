//
//  RealmHelper.swift
//  BAKESF
//
//  Created by 高宇超 on 5/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift
import AVOSCloud
import LeanCloud

class RealmHelper {
    
    // MARK: - User
    static func addUser(user: UserRealm) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(user)            
        }
    }
    
    static func updateUserPhone(user: UserRealm, phone: String) {
        let realm = try! Realm()
        try! realm.write {
            user.phone = phone
        }
    }
    
    static func setCurrentUser(baker: LCBaker, data: Data?) -> Bool {
        let id = baker.objectId!.value
        let realm = try! Realm()
        if let user = realm.object(ofType: UserRealm.self, forPrimaryKey: id) {
            try! realm.write {
                user.current = true
                user.name = baker.username!.value
                user.phone = baker.mobilePhoneNumber!.value
                user.headphotoURL = baker.headphoto?.value
                user.headphoto = data
            }
            return true
        } else {
            return false
        }
    }
    
    static func retrieveUsers() -> Results<UserRealm> {
        let realm = try! Realm()
        return realm.objects(UserRealm.self)
    }
    
    static func retrieveCurrentUser() -> UserRealm? {
        let realm = try! Realm()
        return realm.objects(UserRealm.self).filter("current = true").first
    }
    
    static func retrieveUser(withPhone phone: String) -> UserRealm? {
        let realm = try! Realm()
        return realm.objects(UserRealm.self).filter("phone = '\(phone)'").first
    }
    
    static func retrieveUser(withID id: String) -> UserRealm? {
        let realm = try! Realm()
        return realm.objects(UserRealm.self).filter("id = '\(id)'").first
    }
    
    static func logoutCurrentUser(user: UserRealm) -> Void {
        let realm = try! Realm()
        try! realm.write {
            user.current = false
        }
    }
    
    static func saveHeadphoto(user: UserRealm, data: Data, url: String) {
        let realm = try! Realm()
        try! realm.write {
            user.headphoto = data
            user.headphotoURL = url
        }
    }
    
}
