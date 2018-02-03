//
//  Levels.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import RealmSwift
import Yams

class Levels {
    let data: [Level]
    static let bundleName: String = "Images.bundle"
    static let sharedInstance = Levels()
    
    private static func loadLevels(_ realm: Realm) -> [Level] {
        var levels: [Level] = []
        let yamlUrl = Bundle.main.url(forResource: "levels", withExtension: "yaml", subdirectory: bundleName)!
        let yaml = try! String.init(contentsOf: yamlUrl)
        let yamlLevels = try! Yams.load(yaml: yaml) as! [[String: Any]]
        for level in yamlLevels {
            print(level["preview"] as! String)
            levels.append(Level.init(
                name: level["name"] as! String,
                preview: getUrl(level["preview"] as! String),
                title: level["title"] as! String,
                duration: level["duration"] as! Int,
                tutorials: (level["tutorials"] as! [String])
                    .map { getUrl($0) },
                realm: realm
            ))
        }
        return levels
    }
    
    private static func getUrl(_ name: String) -> String {
        let shortName = String(name.split(separator: ".")[0])
        let ext = String(name.split(separator: ".")[1])
        let url = Bundle.main.path(forResource: shortName, ofType: ext, inDirectory: self.bundleName)
        return url!
    }
    
    init() {
        
        let realm = try! Realm()
//        try! realm.write {
//            realm.deleteAll()
//        }
        
        self.data = Levels.loadLevels(realm)
    }
}
