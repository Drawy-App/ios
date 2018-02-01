//
//  Level.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class Level {
    let name: String
    let preview: UIImage
    let title: String
    let duration: Int
    let tutorials: [String]
    
    init(name: String, preview: UIImage, title: String, duration: Int, tutorials: [String]) {
        self.name = name
        self.preview = preview
        self.title = title
        self.duration = duration
        self.tutorials = tutorials
    }
}
