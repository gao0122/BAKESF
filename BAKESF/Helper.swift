//
//  Helper.swift
//  BAKESF
//
//  Created by 高宇超 on 6/3/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVOSCloud

func printit(_ any: Any) {
    print()
    print("------------------------------")
    print(any)
    print("------------------------------")
}


enum TimerState {
    case inited, rolling, done
}

// navigation controller 
func setBackItemTitle(with title: String = "", for navigationItem: UINavigationItem) {
    if navigationItem.backBarButtonItem == nil {
        setBackItemTitle(title, for: navigationItem)
    } else if let title = navigationItem.backBarButtonItem!.title {
        if title != "" {
            setBackItemTitle(title, for: navigationItem)
        }
    }
}
func setBackItemTitle(_ title: String, for navigationItem: UINavigationItem ) {
    let backItem = UIBarButtonItem()
    backItem.title = title
    navigationItem.backBarButtonItem = backItem
}


// check if is connected to the network
func connectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return (isReachable && !needsConnection)
}

// random password generator
func generateRandomPwd(length: Int = 14) -> String {
    let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*()_+-="
    var pwd = "Bk"
    for _ in 0..<length {
        let index = Int(arc4random_uniform(UInt32(chars.characters.count)))
        pwd.append(chars.substring(from: index, to: index + 1))
    }
    return pwd
}

// MARK: - LeanCloud
func hasAVBakerRegistered(withPhone phone: String) -> Bool {
    let query = AVBaker.query()
    query.whereKey(lcKey[.phone]!, equalTo: phone)
    return query.getFirstObject() == nil
}

func retrieveBaker(withPhone phone: String) -> AVBaker? {
    let query = AVBaker.query()
    query.whereKey(lcKey[.phone]!, equalTo: phone)
    return query.getFirstObject() as? AVBaker
}

func retrieveBaker(withID id: String) -> AVBaker? {
    let query = AVBaker.query()
    return query.getObjectWithId(id) as? AVBaker
}

func retrieveBaker(withID id: String, completion: @escaping (AVObject?, Error?) -> Void) {
    let query = AVBaker.query()
    query.getObjectInBackground(withId: id, block: completion)
}

func retrieveFile(withURL url: String) -> AVFile? {
    let query = AVFile.query()
    query.whereKey(lcKey[.url]!, equalTo: url)
    let files = try! query.findFiles()
    return files.first as? AVFile
}

// update sent message date
func updateSentMsgDate(phone: String) {
    let query = AVBaker.query()
    query.whereKey(lcKey[.phone]!, equalTo: phone)
    query.getFirstObjectInBackground({
        object, error in
        if error == nil {
            let usr = object as! AVBaker
            usr.msgSentDate = Date()
            _ = usr.save()
        } else {
            // error
        }
    })
}

func retrieveRecentlyAddress(by baker: AVBaker, completion: @escaping ([AVObject]?, Error?) -> Void) {
    let q1 = AVAddress.query()
    q1.whereKey("recentlyUsed", equalTo: true)
    let q2 = AVAddress.query()
    q2.whereKey("baker", equalTo: baker)
    let query = AVQuery.andQuery(withSubqueries: [q1, q2])
    query.includeKey("baker")
    query.findObjectsInBackground({
        objects, error in
        completion(objects as? [AVObject], error)
    })
}


// calculate the stars difference
// the width of one rating star in png is 18px, but the actual width of the star is only 16.3px
func calStarsWidth(byStarWidth width: CGFloat, stars: CGFloat) -> CGFloat {
    let gap = (width - 5 * starWidth) / 4
    let starInt = CGFloat(floorf(Float(stars)))
    return stars * starWidth + gap * starInt
}


// return value which indicates that in bag or pre order
func determineSections(_ avshop: AVShop) -> Int {
    let bakeInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).count
    let bakePreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).count
    if bakeInBag == 0 && bakePreOrder == 0 { return 0 }     // none
    else if bakeInBag > 0 && bakePreOrder == 0 { return 2 } // only in bag
    else if bakeInBag == 0 && bakePreOrder > 0 { return 3 } // only pre order
    else { return 4 }                                       // both
}


// MARK: - Location
func cllocationToAMapGeoPoint(_ location: CLLocation) -> AMapGeoPoint {
    return AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
}

func amapGeoPointToCLLocation(_ location: AMapGeoPoint) -> CLLocation {
    return CLLocation(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
}

func saveAVAddress(for address: AVAddress, from locationRealm: LocationRealm) {
    address.province = locationRealm.province
    address.city = locationRealm.city
    address.citycode = locationRealm.citycode
    address.district = locationRealm.district
    address.township = locationRealm.township
    address.street = locationRealm.street
    address.streetName = locationRealm.streetName
    address.streetNumber = locationRealm.streetNumber
    address.aoiName = locationRealm.aoiname
    address.formatted = locationRealm.formatted
    address.address = locationRealm.address
    address.longitude = locationRealm.longitude
    address.latitude = locationRealm.latitude
}

func print(regeocode: AMapReGeocode) {
    let ac = regeocode.addressComponent!
    printit("\(regeocode.formattedAddress!)")
    printit("province\t\(ac.province!)")
    printit("city\t\(ac.city!)")
    printit("district\t\(ac.district!)")
    printit("township\t\(ac.township!)")
    printit("streetNumber.street\t\(ac.streetNumber.street!)")
    printit("streetNumber.number\t\(ac.streetNumber.number!)")
    printit("streetNumber.direction\t\(ac.streetNumber.direction!)")
    for aoi in regeocode.aois {
        printit("aois.name\t\(aoi.name!)")
    }
    printit("neighborhood\t\(ac.neighborhood!)")
    printit("building\t\(ac.building!)")
    printit("citycode\t\(ac.citycode!)")
    for ri in regeocode.roadinters {
        printit("ri\t\(ri.firstName!) \(ri.secondName!)")
    }
    for road in regeocode.roads {
        printit("road\t\(road.name!)")
    }
    for ba in ac.businessAreas {
        printit("businessAreas\t\(ba.name!)")
    }
}

func print(poi: AMapPOI) {
    printit("\(poi.address!)")
    printit("province\t\(poi.province!)")
    printit("city\t\(poi.city!)")
    printit("district\t\(poi.district!)")
    printit("name\t\(poi.name!)")
    printit("citycode\t\(poi.citycode!)")
    printit("citycode\t\(1)")
    printit("businessArea\t\(poi.businessArea!)")
}



