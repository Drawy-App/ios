//
//  Stage.swift
//  htd
//
//  Created by Alexey Landyrev on 18.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import Foundation



class Stage {
    let number: Int
    let levels: [Level]
    var isUnlocked: Bool {
        return self.isUnlockedByUser || Purchase.sharedInstance.payments!.products.contains(Purchase.unlockAllId)
    }
    
    var isUnlockedByUser: Bool {
        return (UserInfo.isOldFreeVersion || self.number <= 2) && Levels.sharedInstance.totalStars >= Stage.needed[self.number]!
            || self.levels.filter({ $0.rating > 0}).count > 0
    }
    
    static let needed: [Int: Int] = [
        0: 0,
        1: 1,
        2: 3,
        3: 7,
        4: 12,
        5: 14,
        6: 17,
        7: 20,
        8: 24,
        9: 29,
        10: 34,
        11: 40,
        12: 46,
        13: 53,
    ]
    
    var totalStars: Int {
        return levels.map {level in
            level.totalStars
        }.reduce(0, +)
    }
    
    init(_ number: Int, levels: [Level]) {
        self.number = number
        self.levels = levels
    }
}
