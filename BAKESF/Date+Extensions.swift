//
//  Date+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension Date {
    
    func getTimestamp() -> UInt32 {
        return UInt32(self.timeIntervalSince1970)
    }
    
    func seconds(fromDate from: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: from, to: self).second ?? 0
    }
    
    func minutesInOneDay(fromDate from: Date) -> Int {
        let cal = Calendar.current
        var fromCs = cal.dateComponents([.hour, .minute, .timeZone], from: from)
        var toCs = cal.dateComponents([.hour, .minute, .timeZone], from: self)
        fromCs.calendar = cal
        toCs.calendar = cal
        guard let fromDate = fromCs.date, let toDate = toCs.date else { return 0 }
        let cs = cal.dateComponents([.minute], from: fromDate, to: toDate)
        return cs.minute ?? 0
    }
    
    func getDeliveryDateComponents() -> DateComponents {
        let cal = Calendar.current
        var cs = cal.dateComponents([.year, .month, .day, .hour, .minute, .timeZone, .weekday], from: self)
        cs.calendar = cal
        return cs
    }
    
    func isTimeBetween(from: Date?, to: Date?) -> Bool {
        guard let fromDate = from else { return true }
        guard let toDate = to else { return true }
        let cal = Calendar.current
        let from = cal.dateComponents([.hour, .minute], from: fromDate)
        let to = cal.dateComponents([.hour, .minute], from: toDate)
        let me = cal.dateComponents([.hour, .minute], from: self)
        guard let fromHour = from.hour else { return true }
        guard let toHour = to.hour else { return true }
        guard let meHour = me.hour else { return false }
        guard let fromMin = from.minute else { return true }
        guard let toMin = to.minute else { return true }
        guard let meMin = me.minute else { return false }
        if fromHour > toHour {
            let toHour = toHour + 24
            if fromHour > meHour {
                let meHour = meHour + 24
                if toHour > meHour {
                    return true
                } else if toHour == fromHour {
                    return toMin > meMin
                } else {
                    return false
                }
            } else if fromHour == meHour {
                return fromMin < meMin
            } else {
                return true
            }
        } else if fromHour == toHour {
            if meHour == fromHour {
                if fromMin >= toMin {
                    return meMin > fromMin
                } else {
                    return fromMin < meMin && meMin < toMin
                }
            } else {
                return fromMin >= toMin
            }
        } else {
            let fromCS = cal.dateComponents([.hour, .minute], from: from, to: me)
            let toCS = cal.dateComponents([.hour, .minute], from: me, to: to)
            return fromCS.hour! > 0 && fromCS.minute! > 0 && toCS.hour! > 0 && toCS.minute! > 0
        }
    }
    
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formatter.string(from: self)
    }
    
}
