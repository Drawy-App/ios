//
//  Level.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import RealmSwift

class Level {
    let name: String
    var rating: Int
    let preview: String
    let title: String
    let duration: Int
    let tutorials: [String]
    let defaults: UserDefaults
    
    init(name: String, preview: String, title: String, duration: Int,
         tutorials: [String], realm: Realm) {
        self.defaults = UserDefaults.standard
        
        self.name = name
        self.preview = preview
        self.title = title
        self.duration = duration
        self.tutorials = tutorials
        
        var score = realm.object(ofType: Score.self, forPrimaryKey: name)
        if score == nil {
            score = Score()
            score!.name = name
            score!.rating = 0
            try! realm.write {
                realm.add(score!)
            }
        }
        self.rating = score!.rating
        
    }
    
    func set(_ rating: Int) {
        let realm = try! Realm()
        let score = realm.object(ofType: Score.self, forPrimaryKey: self.name)!
        self.rating = rating
        try! realm.write {
            score.rating = rating
        }
    }
}
