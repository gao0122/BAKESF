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
    
}
