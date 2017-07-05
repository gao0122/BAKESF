//
//  Helper.swift
//  BAKESF
//
//  Created by 高宇超 on 6/3/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import SystemConfiguration
import LeanCloud

enum ImageFormat {
    case unknown, png, jpeg, gif, tiff
}

struct ImageHeaderData {
    static var png: [UInt8] = [0x89]
    static var jpeg: [UInt8] = [0xFF]
    static var gif: [UInt8] = [0x47]
    static var tiff01: [UInt8] = [0x49]
    static var tiff02: [UInt8] = [0x4D]
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

func generateRandomPwd(length: Int = 14) -> String {
    let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*()_+-="
    var pwd = "Bk"
    for _ in 0..<length {
        let index = Int(arc4random_uniform(UInt32(chars.characters.count)))
        pwd.append(chars.substring(from: index, to: index + 1))
    }
    return pwd
}

func hasLCBakerRegistered(withPhone phone: String) -> Bool {
    let query = LCQuery(className: "Baker")
    query.whereKey("mobilePhoneNumber", .equalTo(phone))
    return query.getFirst().isSuccess
}

func retrieveBaker(withPhone phone: String) -> LCBaker? {
    let query = LCQuery(className: "Baker")
    query.whereKey("mobilePhoneNumber", .equalTo(phone))
    return query.getFirst().object as? LCBaker
}

func retrieveBaker(withID id: String) -> LCBaker? {
    let query = LCQuery(className: "Baker")
    return query.get(id).object as? LCBaker
}



// MARK: - to copy and paste
func helperBaker(phone: String) {
    let query = LCQuery(className: "Baker")
    query.whereKey("mobilePhoneNumber", .equalTo(phone))
    query.getFirst {
        result in
        switch result {
        case .success(let usr as LCBaker):
            break
        case .failure(let error):
            break
        default:
            break
        }
    }
}

