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

let iPhoneX: Bool = {
    return UIScreen.main.nativeBounds.height == 2436
}()
let xTopMargin: CGFloat = 42
let xBottomMargin: CGFloat = 34

let starHeightInHomeVC: CGFloat = 18

let weekdays: [String] = [
    "周日", "周一", "周二", "周三", "周四", "周五", "周六"
]


let alipayScheme = "AlipayBeike"
let alipayAppID = "2018022702282155"
let aliRSAprivateKey = "MIIEwAIBADANBgkqhkiG9w0BAQEFAASCBKowggSmAgEAAoIBAQC3AkKEfwiD7b26aDrCrDNrJVF8wzpJf+nJDDDLhhYWg+UFWeKOD4sksKnKDeBRyVEoSglDLXl2E9yNT8SYCW72MsxyDeWw40IWPhk3XOff9o87ASBMMWFAMRvBmBjUwLUQk2J/BXzVv+JY+c4XK849as8GiXtQt8ZzPtfbX+yJFKI3JaNDJ/uKtRLugHhYvu1G3BK+Gs6FpLh5p/VrhLghCy/eccfnYC2+0pUjIVGzp49fUgrcaLDyVC7pmFaQIwHO2NKlxLFsMx7kpzMWGqJYV2ruzxr1TInZGwxB3h/XToq/HoLukaxWdMAnmhtQsYvwCyQoI3oDE2nACHK7pnKRAgMBAAECggEBALOFY/rVImVIMXVKCVot0cKpOOZKHEM9VvgBHVyIi+JKP76gDb2NQdEb+3JZalLQSOxcs/lSAnPxx8hXF2KM3mxkKGk5eLesNofbIqFMYakxFA+tayFSzzNI+RFPQgxxfSxlZ5lyqKKFOGRPp/rS3d0hiTPAaVck72bdnqFz13QfO7MzuFzfEVAsZn3F8uXBR0tWzc+BH8JXr9S5tsHHnjustjE2YO6l9p9UZle59socj3KHhwj+9lnE9hIQVNTj1oMLtoN46sEizbVwL0JL1v8un4HI10omRNnVEVHrsiflwKaAWh0WcPl+JhaH4flC42CU2Y1g6JDqdtcN/AylgAECgYEA/OJxU6LLpaVSOmdisfq/ENqC6nsKs5i6OHMQMlAxaR1mB0/Y2zAqO14ab3j+yshV19jRFqtPwvA20VE01SUiM85LAK3Uh5a5mR7cExnTZIG94wSD768ZRQrbmJ/yWdQ125mEUSkNzkCxBMN0t7kG+4zX/oUk5S8VV5O7DNr78lECgYEAuUNwuplCSLXdd6ShNnS6fS9yKQBb/ZqBTQF1Lw4UXCBFxa6opz+HmzJraeq9KkOMfHeA2iGHB2Uk0hlRo2uKwyS7+WkIEB4NybjN6N0UCvOA0Lzlgpz8zEJ8MJQLGqw5RXYhxhs1D9hphAF2VbLJ7KFqN/otIdF+3k3sekmILEECgYEAng/fa7pOdZvOuKiUPNCQijU6LNt5ReZJRy1MS1Zqe9wfQKS808vYKcFY3qIPB6qOVVq03el38k14xf5u+ma6aQ0hPixosdMY8MckIWA8DA84I+RXnwGf1tLBjTU0IseMXlUnKh9x/J/cxTByDL++yI4xF2obNJDoUxQIjzF01vECgYEAgD7uL03ec6TpjWP6cU72taf9d+KWy4SEE4F51DwD3g49Hm4cs8InpkiN0ME9d59RBexX1yg0Z+sdRQ9f0yej5Bhuw2Vwvm9/je+PIq6/rCEKP/UzT2pLGT7A54Pj9+/WqX3wPUoiPjjKOiYk+4gLffHzLJLTYUC7eToqBDEYwcECgYEA6wb/8aLgJ4Uae+oF88exLIFCPFuYzw+iPN1JDeXXRGtPyzrWhxBMPZH2TvHMLgbUyAYP0slLE7anDxuDHUQniA2LyPtJJFiTKydokDbW2JvELqOUSzh9SWTaaV9aj4GNornwhiH/iHl45E2YraxRGphY3JVwD7SPIu+HiJu8dCU="
let aliRSApublicKeyApp = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtwJChH8Ig+29umg6wqwzayVRfMM6SX/pyQwwy4YWFoPlBVnijg+LJLCpyg3gUclRKEoJQy15dhPcjU/EmAlu9jLMcg3lsONCFj4ZN1zn3/aPOwEgTDFhQDEbwZgY1MC1EJNifwV81b/iWPnOFyvOPWrPBol7ULfGcz7X21/siRSiNyWjQyf7irUS7oB4WL7tRtwSvhrOhaS4eaf1a4S4IQsv3nHH52AtvtKVIyFRs6ePX1IK3Giw8lQu6ZhWkCMBztjSpcSxbDMe5KczFhqiWFdq7s8a9UyJ2RsMQd4f106Kvx6C7pGsVnTAJ5obULGL8AskKCN6AxNpwAhyu6ZykQIDAQAB"
let aliRSApublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuj3m+TNlOXzS11hMvhvmGSgKn7Yp9wBP8Ak1uYnVOuuMbshA8JCKTMdDfRfBvtMc010aRurivz0nm1l2W5Cdfbxmxzmm53/OwDiNezgm6Rt/sINZ+t+HnqOBsP+KQJEm8X1ZI37V6UHoAxTiZU3ZktCJfBbsnXU0QX7n6JIDPjVT60Sv72cpOxbwcBAK69vk99sggr0xCL2PbURdL6GRJaQGdXRiIl2Q+ojdMDMPJaEiZI841VgwTqxFIVlDZnbf0CRO39EvRyBeAYFJtnCsNlWPXSCVPJrXzVuUv9+1DAmXkbGFdRK293bs//1L5BfHRFtnRWoOfuWmjWCGvy9KuwIDAQAB"



let wxMchID = "1499503112"
let wxAppID = "wxc3148eeb95ecf773"
//let wxAppSecret = "1690b3fcb79fb94f6f0311cdc430a1e8"
let wxAppSecret = "BakesfDomi20180311BakesfDomi2018"

enum PaymentMethod {
    case wepay, alipay
}

let paymentMethods: [PaymentMethod: String] = [
    .wepay: "微信支付",
    .alipay: "支付宝"
]

let WXUnifiedOrderURL = "https://api.mch.weixin.qq.com/pay/unifiedorder"
