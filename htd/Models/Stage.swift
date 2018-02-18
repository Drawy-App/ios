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
        return Levels.sharedInstance.totalStars >= self.needed[self.number]!
            || self.levels.filter({ $0.rating > 0}).count > 0
    }
    
    let needed: [Int: Int] = [
        1: 0,
        2: 6,
        3: 14,
        4: 29,
        5: 50
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
