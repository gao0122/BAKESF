//
//  Date+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension Date {
    
    func seconds(fromDate from: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: from, to: self).second ?? 0
    }
    
    func isTimeBetween(from: Date?, to: Date?) -> Bool {
        guard let fromDate = from else { return true }
        guard let toDate = to else { return true }
        let cal = Calendar.current
        let from = cal.dateComponents([.hour, .minute], from: fromDate)
        let to = cal.dateComponents([.hour, .minute], from: toDate)
        let me = cal.dateComponents([.hour, .minute], from: self)
        let fromCS = cal.dateComponents([.hour, .minute], from: from, to: me)
        let toCS = cal.dateComponents([.hour, .minute], from: me, to: to)
        return fromCS.hour! > 0 && fromCS.minute! > 0 && toCS.hour! > 0 && toCS.minute! > 0
    }
    
}
