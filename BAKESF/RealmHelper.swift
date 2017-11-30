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
    
    static func setBakeInBagAmount(_ bake: BakeInBagRealm, amount: Int) -> Bool {
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
    
    static func retrieveOneBakeInBag(by id: String) -> BakeInBagRealm? {
        let realm = try! Realm()
        return realm.objects(BakeInBagRealm.self).filter("id = '\(id)'").first
    }
    
    static func retrieveBakesInBag(avshopID shopID: String? = nil, avbakesIn: [String: AVBakeIn]) -> [BakeInBagRealm] {
        let realm = try! Realm()
        if let id = shopID {
            return realm.objects(BakeInBagRealm.self).filter("shopID = '\(id)'").filter({ return avbakesIn[$0.id] != nil }).reversed().reversed()
        } else {
            return realm.objects(BakeInBagRealm.self).reversed().reversed()
        }
    }
    
    static func retrieveBakesInBagCount(avshopID shopID: String? = nil, avbakesIn: [String: AVBakeIn]) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakeInBagRealm.self).filter({ return avbakesIn[$0.id] != nil })
        var total = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                total += bake.amount
            }
        }
        return total
    }
    
    static func retrieveBakesInBagCount(by tag: String, avbakesIn: [String: AVBakeIn]) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakeInBagRealm.self).filter("tag = '\(tag)'").filter({ return avbakesIn[$0.id] != nil })
        var total = 0
        for bake in bakes {
            total += bake.amount
        }
        return total
    }
    
    static func retrieveBakesInBagCost(avshopID shopID: String? = nil, avbakesIn: [String: AVBakeIn]) -> Double {
        let realm = try! Realm()
        let bakes = realm.objects(BakeInBagRealm.self).filter({ return avbakesIn[$0.id] != nil })
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
    
    static func deleteAllBakesInBag(by shopID: String? = nil) {
        let realm = try! Realm()
        try! realm.write {
            if let id = shopID {
                realm.delete(realm.objects(BakeInBagRealm.self).filter("shopID = '\(id)'"))
            } else {
                realm.delete(realm.objects(BakeInBagRealm.self))
            }
        }
    }

    // MARK: - Bake pre order
    static func addOneBake(_ bake: BakePreOrderRealm) -> Void {
        let realm = try! Realm()
        try! realm.write {
            realm.add(bake)
        }
    }
    
    static func addOneMoreBake(_ bake: BakePreOrderRealm) {
        let realm = try! Realm()
        try! realm.write {
            bake.amount += 1
        }
    }
    
    // returns true when the amount became zero.
    static func minueOneBake(_ bake: BakePreOrderRealm) -> Bool {
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
    
    static func setBakePreOrderAmount(_ bake: BakePreOrderRealm, amount: Int) -> Bool {
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
    
    static func retrieveOneBakePreOrder(by id: String) -> BakePreOrderRealm? {
        let realm = try! Realm()
        return realm.objects(BakePreOrderRealm.self).filter("id = '\(id)'").first
    }
    
    static func retrieveBakesPreOrder(avshopID shopID: String? = nil, avbakesPre: [String: AVBakePre]) -> [BakePreOrderRealm] {
        let realm = try! Realm()
        if let id = shopID {
            return realm.objects(BakePreOrderRealm.self).filter("shopID = '\(id)'").filter({ return avbakesPre[$0.id] != nil }).reversed().reversed()
        } else {
            return realm.objects(BakePreOrderRealm.self).reversed().reversed()
        }
    }
    
    static func retrieveBakesPreOrderCount(avshopID shopID: String? = nil, avbakesPre: [String: AVBakePre]) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakePreOrderRealm.self).filter({ return avbakesPre[$0.id] != nil })
        var total = 0
        for bake in bakes {
            if shopID == bake.shopID || shopID == nil {
                total += bake.amount
            }
        }
        return total
    }
    
    static func retrieveBakesPreOrderCount(by tag: String, avbakesPre: [String: AVBakePre]) -> Int {
        let realm = try! Realm()
        let bakes = realm.objects(BakePreOrderRealm.self).filter("tag = '\(tag)'").filter({ return avbakesPre[$0.id] != nil })
        var total = 0
        for bake in bakes {
            total += bake.amount
        }
        return total
    }
    
    static func retrieveBakesPreOrderCost(avshopID shopID: String? = nil, avbakesPre: [String: AVBakePre]) -> Double {
        let realm = try! Realm()
        let bakes = realm.objects(BakePreOrderRealm.self).filter({ return avbakesPre[$0.id] != nil })
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
    
    static func deleteAllBakesPreOrder(by shopID: String? = nil) {
        let realm = try! Realm()
        try! realm.write {
            if let id = shopID {
                realm.delete(realm.objects(BakePreOrderRealm.self).filter("shopID = '\(id)'"))
            } else {
                realm.delete(realm.objects(BakePreOrderRealm.self))
            }
        }
    }
    
    
    // All Bakes
    static func retrieveAllBakesCount(avshopID shopID: String? = nil, avbakesIn: [String: AVBakeIn], avbakesPre: [String: AVBakePre]) -> Int {
        return retrieveBakesInBagCount(avshopID: shopID, avbakesIn: avbakesIn) + retrieveBakesPreOrderCount(avshopID: shopID, avbakesPre: avbakesPre)
    }
    
    static func retrieveAllBakesCost(avshopID shopID: String? = nil, avbakesIn: [String: AVBakeIn], avbakesPre: [String: AVBakePre]) -> Double {
        return retrieveBakesInBagCost(avshopID: shopID, avbakesIn: avbakesIn) + retrieveBakesPreOrderCost(avshopID: shopID, avbakesPre: avbakesPre)
    }
    
    static func retrieveAllBakes(avshopID shopID: String? = nil) -> [Object] {
        let realm = try! Realm()
        if let id = shopID {
            let preOrder = realm.objects(BakePreOrderRealm.self).filter("shopID = '\(id)'").sorted(by: { _, _ in return true })
            let inBag = realm.objects(BakeInBagRealm.self).filter("shopID = '\(id)'").sorted(by: { _, _ in return true })
            var bakes = [Object]()
            preOrder.forEach({ bakes.append($0) })
            inBag.forEach({ bakes.append($0) })
            return bakes
        } else {
            let preOrder = realm.objects(BakePreOrderRealm.self).sorted(by: { _, _ in return true })
            let inBag = realm.objects(BakeInBagRealm.self).sorted(by: { _, _ in return true })
            var bakes = [Object]()
            preOrder.forEach({ bakes.append($0) })
            inBag.forEach({ bakes.append($0) })
            return bakes
        }
    }
    
    static func deleteAllBakes(byShopID shopID: String? = nil) {
        deleteAllBakesInBag(by: shopID)
        deleteAllBakesPreOrder(by: shopID)
    }

    
    // MARK: - Location
    static func addLocation(by regeocode: AMapReGeocode, poi: AMapPOI? = nil, for tag: Int) -> LocationRealm {
        if let location = retrieveLocation(by: tag) {
            let realm = try! Realm()
            try! realm.write {
                setLocation(location, by: regeocode, poi: poi, for: tag)
            }
            return location
        } else {
            let location = LocationRealm()
            setLocation(location, by: regeocode, poi: poi, for: tag)
            let realm = try! Realm()
            try! realm.write {
                realm.add(location)
            }
            return location
        }
    }
    private static func setLocation(_ location: LocationRealm, by regeocode: AMapReGeocode, poi: AMapPOI? = nil, for tag: Int) {
        guard let ac = regeocode.addressComponent else { return }
        location.tag = tag
        location.detailed = ""
        location.citycode = ac.citycode!
        location.province = ac.province!
        location.city = ac.city!
        location.district = ac.district!
        location.township = ac.township!
        location.adcode = ac.adcode!
        guard let street = ac.streetNumber else { return }
        location.streetName = street.street!
        location.streetNumber = street.number!
        let addressText = location.province + location.city + location.district + location.township
        if let poi = poi {
            location.aoiname = poi.name
            location.longitude = String(describing: poi.location.longitude)
            location.latitude = String(describing: poi.location.latitude)
            location.street = poi.address
            location.address = addressText + poi.address
        } else {
            guard let aoi = regeocode.aois.first else { return }
            location.aoiname = aoi.name
            location.longitude = String(describing: aoi.location.longitude)
            location.latitude = String(describing: aoi.location.latitude)
            location.street = nil
            location.address = addressText + location.streetName + location.streetNumber
        }
        location.formatted = addressText + location.aoiname
    }
    
    static func addLocation(by avaddress: AVAddress, for tag: Int) -> LocationRealm {
        if let location = retrieveLocation(by: tag) {
            let realm = try! Realm()
            try! realm.write {
                setLocation(location, by: avaddress, for: tag)
            }
            return location
        } else {
            let location = LocationRealm()
            setLocation(location, by: avaddress, for: tag)
            let realm = try! Realm()
            try! realm.write {
                realm.add(location)
            }
            return location
        }
    }
    private static func setLocation(_ location: LocationRealm, by avaddress: AVAddress, for tag: Int) {
        location.tag = tag
        location.detailed = avaddress.detailed ?? ""
        location.formatted = avaddress.formatted ?? ""
        location.citycode = avaddress.citycode ?? ""
        location.province = avaddress.province ?? ""
        location.city = avaddress.city ?? ""
        location.district = avaddress.district ?? ""
        location.township = avaddress.township ?? ""
        location.adcode = ""
        location.streetName = avaddress.streetName ?? ""
        location.streetNumber = avaddress.streetNumber ?? ""
        let addressText = location.province + location.city + location.district + location.township
        location.aoiname = avaddress.aoiName ?? ""
        location.longitude = String(describing: avaddress.longitude!)
        location.latitude = String(describing: avaddress.latitude!)
        location.street = avaddress.street
        if location.street == "" { location.street = nil }
        location.address = addressText + location.streetName + location.streetNumber
    }
    
    static func retrieveLocation(by tag: Int) -> LocationRealm? {
        let realm = try! Realm()
        return realm.objects(LocationRealm.self).filter("tag = \(tag)").first
    }
    
    static func deleteLocation(by tag: Int) {
        let realm = try! Realm()
        try! realm.write {
            if let location = retrieveLocation(by: tag) {
                realm.delete(location)
            }
        }
    }
    
    
    // MARK: - Searching History
    static func addSearchHistory(_ searchHistoryRealm: SearchHistoryRealm) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(searchHistoryRealm)
        }
    }

    static func deleteAllHistory() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(SearchHistoryRealm.self))
        }
    }
    
    static func retrieveSearchHistories(by baker: AVBaker? = nil) -> Results<SearchHistoryRealm> {
        let realm = try! Realm()
        if let baker = baker {
            return realm.objects(SearchHistoryRealm.self).filter("searchingUserID = \(baker.objectId!)")
        } else {
            return realm.objects(SearchHistoryRealm.self)
        }
    }
    
}

