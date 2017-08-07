//
//  AMapLocationManager+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 8/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation

extension AMapLocationManager {
    
    // MARK: - location accuracy
    //
    func setLocationAccuracyHundredMeters() {
        self.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationTimeout = 2
        self.reGeocodeTimeout = 2
    }
    
    func setLocationAccuracyBest() {
        self.desiredAccuracy = kCLLocationAccuracyBest
        self.locationTimeout = 10
        self.reGeocodeTimeout = 10
    }
    
}
