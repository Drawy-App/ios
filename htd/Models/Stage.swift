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
    
    init(_ number: Int, levels: [Level]) {
        self.number = number
        self.levels = levels
    }
}
