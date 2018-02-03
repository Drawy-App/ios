//
//  Score.swift
//  htd
//
//  Created by Alexey Landyrev on 02.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import Foundation
import RealmSwift


@objcMembers class Score: Object {
    dynamic var name: String = ""
    dynamic var rating: Int = 0
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
