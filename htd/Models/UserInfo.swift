//
//  UserInfo.swift
//  htd
//
//  Created by Alexey Landyrev on 07.04.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import Foundation
import RealmSwift


class UserInfo {
    
    class Keys {
        static let lastRated = "LAST_RATED"
    }
    
    static let defaults = UserDefaults.standard
    static let secondsOff = 30 * 24 * 3600
    
    static func mayRate() -> Bool {
//        #if IOS_SIMULATOR
//            return true
//        #endif
        let lastRate = defaults.integer(forKey: Keys.lastRated)
        if lastRate == 0 {
            return true
        }
        let currentTs = Int(Date().timeIntervalSince1970)
        if currentTs - lastRate > secondsOff {
            return true
        }
        return false
    }
    
    static func setRateTimeout() {
        defaults.set(Int(Date().timeIntervalSince1970), forKey: Keys.lastRated)
    }
    
    static var firstRunDate: Date? {
        get {
            let preferences = UserDefaults.standard
            let startDate = preferences.double(forKey: "first_run") as TimeInterval
            if (startDate > 0) {
                return Date(timeIntervalSince1970: startDate)
            } else {
                return nil
            }
        }
    }
    
    static var isOldFreeVersion: Bool {
        get {
            let edgeDate = Date(timeIntervalSince1970: 1538816400)
            return (self.firstRunDate! < edgeDate)
        }
    }
    
    static func initFirstRun() {
        let preferences = UserDefaults.standard
        preferences.set(Date().timeIntervalSince1970, forKey: "first_run")
        preferences.synchronize()
    }

}
