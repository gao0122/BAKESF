//
//  Constants.swift
//  BAKESF
//
//  Created by 高宇超 on 6/25/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Colors
enum BKColor {
    case green, orange, red, white, black, bkRed
}
let colors: [BKColor : UIColor] = [
    .green: UIColor(red: 16 / 255, green: 206 / 255, blue: 105 / 255, alpha: 1),
    .red: UIColor(red: 255 / 255, green: 36 / 255, blue: 40 / 255, alpha: 1),
    .orange: UIColor(red: 255 / 255, green: 128 / 255, blue: 0, alpha: 1),
    .white: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1),
    .black: UIColor(red: 0.032, green: 0.032, blue: 0.032, alpha: 1),
    .bkRed: UIColor(hex: 0xFF0000)
]

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

