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

func retrieveFile(withURL url: String) -> AVFile? {
    let query = AVFile.query()
    query.whereKey(lcKey[.url]!, equalTo: url)
    let files = try! query.findFiles()
    return files.first as? AVFile
}

// calculate the stars difference
// the width of one rating star in png is 18px, but the actual width of the star is only 16.3px
func calStarsWidth(byStarWidth width: CGFloat, stars: CGFloat) -> CGFloat {
    let gap = (width - 5 * starWidth) / 4
    let starInt = CGFloat(floorf(Float(stars)))
    return stars * starWidth + gap * starInt
}


// MARK: - just for copy and paste
func helperBaker(phone: String) {
    let query = AVBaker.query()
    query.whereKey(lcKey[.phone]!, equalTo: phone)
    query.getFirstObjectInBackground({
        object, error in
        if error == nil {
            
        } else {
            
        }
    })
}


