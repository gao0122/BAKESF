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

func printit(any: Any) {
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

func generateRandomPwd(length: Int = 14) -> String {
    let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*()_+-="
    var pwd = "Bk"
    for _ in 0..<length {
        let index = Int(arc4random_uniform(UInt32(chars.characters.count)))
        pwd.append(chars.substring(from: index, to: index + 1))
    }
    return pwd
}

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
    let query = AVFileQuery(className: "_File")
    query.whereKey(lcKey[.url]!, equalTo: url)
    let files = try! query.findFiles()
    return files.first as? AVFile
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

