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
    static let bundleName: String = "Images.bundle"

    let tutorials: [String]
    let defaults: UserDefaults
    
    init(name: String, tutorials: [String], realm: Realm) {
        self.defaults = UserDefaults.standard
        
        self.name = name
        self.preview = Level.getUrl("\(name)/\(name)_preview.png")
        self.title = NSLocalizedString(name, comment: "Tutorial name")
        self.tutorials = tutorials.map { Level.getUrl($0) }
        
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
    
    private static func getUrl(_ name: String) -> String {
        let shortName = String(name.split(separator: ".")[0])
        let ext = String(name.split(separator: ".")[1])
        let url = Bundle.main.path(forResource: shortName, ofType: ext, inDirectory: self.bundleName)
        return url!
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
