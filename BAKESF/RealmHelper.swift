//
//  RealmHelper.swift
//  BAKESF
//
//  Created by 高宇超 on 5/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import RealmSwift
import AVOSCloud

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
    
    static func setCurrentUser(baker: AVBaker, data: Data?) -> UserRealm? {
        let id = baker.objectId!
        let realm = try! Realm()
        if let user = realm.object(ofType: UserRealm.self, forPrimaryKey: id) {
            try! realm.write {
                user.current = true
                user.name = baker.username!
                user.phone = baker.mobilePhoneNumber!
                user.headphotoURL = baker.headphoto
                user.headphoto = data
            }
            return user
        } else {
            return nil
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
    
    // MARK: - Bake in Bag
    static func addOneBake(_ bake: BakeInBagRealm) -> Void {
        let realm = try! Realm()
        try! realm.write {
            realm.add(bake)
        }
    }
    
    static func addOneMoreBake(_ bake: BakeInBagRealm) {
        let realm = try! Realm()
        try! realm.write {
            bake.amount += 1
        }
    }
    
    static func minueOneBake(_ bake: BakeInBagRealm) -> Bool {
        let zero = bake.amount == 1
        let realm = try! Realm()
        try! realm.write {
            bake.amount -= 1
            if bake.amount == 0 {
                realm.delete(bake)
            }
        }
        return zero
    }
    
    static func setBakeAmount(_ bake: BakeInBagRealm, amount: Int) -> Bool {
        let zero = amount == 0
        let realm = try! Realm()
        try! realm.write {
            bake.amount = amount
            if bake.amount == 0 {
                realm.delete(bake)
            }
        }
        return zero
    }
    
    static func retrieveOneBake(byID id: String) -> BakeInBagRealm? {
        let realm = try! Realm()
        return realm.objects(BakeInBagRealm.self).filter("id = '\(id)'").first
    }
    
    static func retrieveBakesInBag(avshopID shopID: String? = nil) -> Results<BakeInBagRealm> {
        let realm = try! Realm()
        if let id = shopID {
            return realm.objects(BakeInBagRealm.self).filter("shopID = '\(id)'")
        } else {
            return realm.objects(BakeInBagRealm.self)
        }
    }
    
    static func retrieveBakesInBagCount(avshopID shopID: String? = nil) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakeInBagRealm.self)
        var total = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                total += bake.amount
            }
        }
        return total
    }
    
    static func retrieveBakesInBagCost(avshopID shopID: String? = nil) -> Double {
        let realm = try! Realm()
        let bakes = realm.objects(BakeInBagRealm.self)
        var total: Double = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                for _ in 0..<bake.amount {
                    total += bake.price
                }
            }
        }
        return total
    }
    
    static func retrieveBakesPreOrder(avshopID shopID: String? = nil) -> Results<BakePreOrderRealm> {
        let realm = try! Realm()
        if let id = shopID {
            return realm.objects(BakePreOrderRealm.self).filter("shopID = '\(id)'")
        } else {
            return realm.objects(BakePreOrderRealm.self)
        }
    }
    
    static func retrieveBakesPreOrderCount(avshopID shopID: String? = nil) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakePreOrderRealm.self)
        var total = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                total += bake.amount
            }
        }
        return total
    }
    
    static func retrieveBakesPreOrderCost(avshopID shopID: String? = nil) -> Double {
        let realm = try! Realm()
        let bakes = realm.objects(BakePreOrderRealm.self)
        var total: Double = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                for _ in 0..<bake.amount {
                    total += bake.price
                }
            }
        }
        return total
    }
}

