//
//  Constants.swift
//  BAKESF
//
//  Created by 高宇超 on 6/25/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

// MARK: - String
enum LCKey {
    case name, phone, pwd, msgSentDate, url
}
let lcKey: [LCKey : String] = [
    .name: "username",
    .phone: "mobilePhoneNumber",
    .pwd: "password",
    .msgSentDate: "msgSentDate",
    .url: "url"
]

let broadcastRandom: [String] = [
    "烘焙师有点忙，没来得及写公告。",
    "店小二有点懒，什么也没写。"
]

// MARK: - CGFloat
let starWidth: CGFloat = 16.3
let shopVCNameLabelHeight: CGFloat = 21
let bagBarHeight: CGFloat = 50

let screenHeight: CGFloat = {
    return UIScreen.main.bounds.height
}()
let screenWidth: CGFloat = {
    return UIScreen.main.bounds.width
}()

let starHeightInHomeVC: CGFloat = 18

let weekdays: [String] = [
    "周日", "周一", "周二", "周三", "周四", "周五", "周六"
]
